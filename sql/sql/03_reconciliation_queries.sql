-- ============================================================
-- UFRS reconciliation & validation queries (SQLite)
-- Converted from PostgreSQL: date arithmetic via julianday()/DATE(),
-- GREATEST -> MAX(), FILTER -> SUM(CASE ...), DATE_TRUNC -> strftime(),
-- FULL OUTER JOIN -> UNION of keys + LEFT JOINs (works on all SQLite versions).
-- ============================================================

-- Q1. Record count per source for the txn date (ingestion check)
SELECT 'SWITCH' AS source, COUNT(*) AS cnt FROM switch_txn WHERE DATE(txn_datetime) = '2026-10-04'
UNION ALL
SELECT 'CBS',   COUNT(*) FROM cbs_posting WHERE posting_date = '2026-10-04'
UNION ALL
SELECT 'NPCI',  COUNT(*) FROM npci_txn   WHERE txn_date     = '2026-10-04';

-- Q2. Three-way match: all RRNs from all sources, joined on RRN
WITH keys AS (
    SELECT rrn FROM switch_txn
    UNION SELECT rrn FROM npci_txn
    UNION SELECT rrn FROM cbs_posting WHERE dr_cr_flag = 'D'
),
c AS (SELECT rrn, SUM(amount) AS amount FROM cbs_posting WHERE dr_cr_flag = 'D' GROUP BY rrn)
SELECT k.rrn AS rrn,
       s.amount AS switch_amt, c.amount AS cbs_amt, n.amount AS npci_amt,
       s.status AS switch_status, n.status AS npci_status,
       CASE WHEN c.rrn IS NOT NULL THEN 'DEBITED' ELSE 'NOT_FOUND' END AS cbs_status
FROM keys k
LEFT JOIN switch_txn s ON s.rrn = k.rrn
LEFT JOIN npci_txn   n ON n.rrn = k.rrn
LEFT JOIN c            ON c.rrn = k.rrn
ORDER BY k.rrn;

-- Q3. Fully reconciled transactions
SELECT s.rrn, s.amount
FROM switch_txn s
JOIN npci_txn n ON n.rrn = s.rrn
JOIN cbs_posting c ON c.rrn = s.rrn AND c.dr_cr_flag = 'D'
WHERE s.amount = n.amount AND n.amount = c.amount
  AND s.status = 'SUCCESS' AND n.status = 'SUCCESS'
  AND s.rrn NOT IN (SELECT rrn FROM cbs_posting WHERE dr_cr_flag='D' GROUP BY rrn HAVING COUNT(*) > 1);

-- Q4. EX01 Debit-No-Credit: switch SUCCESS, debited in CBS, FAILED at NPCI
SELECT n.rrn, c.amount, n.txn_date,
       DATE(n.txn_date, '+1 day') AS reversal_due_date
FROM npci_txn n
JOIN switch_txn s ON s.rrn = n.rrn AND s.status = 'SUCCESS'
JOIN cbs_posting c ON c.rrn = n.rrn AND c.dr_cr_flag = 'D'
WHERE n.status = 'FAILED'
  AND NOT EXISTS (SELECT 1 FROM cbs_posting r WHERE r.rrn = n.rrn AND r.dr_cr_flag = 'C');

-- Q4b. EX03 Failed at both Switch and NPCI but debited in CBS (reverse the debit)
SELECT n.rrn, c.amount
FROM npci_txn n
JOIN switch_txn s ON s.rrn = n.rrn AND s.status = 'FAILED'
JOIN cbs_posting c ON c.rrn = n.rrn AND c.dr_cr_flag = 'D'
WHERE n.status = 'FAILED';

-- Q5. EX02 Success at NPCI, missing in CBS
SELECT n.rrn, n.amount
FROM npci_txn n
WHERE n.status = 'SUCCESS'
  AND NOT EXISTS (SELECT 1 FROM cbs_posting c WHERE c.rrn = n.rrn);

-- Q6. EX05 Present in CBS, missing in NPCI
SELECT c.rrn, c.amount
FROM cbs_posting c
WHERE c.dr_cr_flag = 'D'
  AND NOT EXISTS (SELECT 1 FROM npci_txn n WHERE n.rrn = c.rrn);

-- Q7. EX06 Duplicate debits
SELECT rrn, COUNT(*) AS debit_count, SUM(amount) AS total_debited
FROM cbs_posting
WHERE dr_cr_flag = 'D'
GROUP BY rrn
HAVING COUNT(*) > 1;

-- Q8. EX07 Amount mismatch between NPCI and CBS
SELECT n.rrn, n.amount AS npci_amt, c.amount AS cbs_amt, n.amount - c.amount AS diff
FROM npci_txn n
JOIN cbs_posting c ON c.rrn = n.rrn AND c.dr_cr_flag = 'D'
WHERE n.amount <> c.amount;

-- Q9. EX08 Deemed approved awaiting TCC
SELECT rrn, amount, txn_date FROM npci_txn WHERE status = 'DEEMED';

-- Q10. Duplicate RRN in a source file (data quality)
SELECT rrn, COUNT(*) FROM npci_txn GROUP BY rrn HAVING COUNT(*) > 1;

-- Q11. TAT breach: open EX01 cases past T+1
SELECT case_id, rrn, amount, reversal_due_date,
       CAST(julianday(CURRENT_DATE) - julianday(reversal_due_date) AS INTEGER) AS days_overdue
FROM exception_case
WHERE exception_code = 'EX01'
  AND reversal_date IS NULL
  AND CURRENT_DATE > reversal_due_date;

-- Q12. Compensation calculation (Rs 100 per day after T+1)
SELECT case_id, rrn,
       MAX(CAST(julianday(COALESCE(reversal_date, CURRENT_DATE)) - julianday(reversal_due_date) AS INTEGER), 0) AS days_delayed,
       MAX(CAST(julianday(COALESCE(reversal_date, CURRENT_DATE)) - julianday(reversal_due_date) AS INTEGER), 0) * 100 AS compensation_amt
FROM exception_case
WHERE exception_code = 'EX01';

-- Q13. Ageing of open exceptions
SELECT exception_code,
       SUM(CASE WHEN julianday(CURRENT_DATE) - julianday(txn_date) <= 1 THEN 1 ELSE 0 END)  AS age_0_1,
       SUM(CASE WHEN julianday(CURRENT_DATE) - julianday(txn_date) BETWEEN 2 AND 3 THEN 1 ELSE 0 END) AS age_2_3,
       SUM(CASE WHEN julianday(CURRENT_DATE) - julianday(txn_date) > 3 THEN 1 ELSE 0 END)   AS age_4_plus
FROM exception_case
WHERE status <> 'CLOSED'
GROUP BY exception_code;

-- Q14. Daily reconciliation rate
SELECT txn_date,
       COUNT(*) AS total,
       SUM(CASE WHEN recon_status = 'RECONCILED' THEN 1 ELSE 0 END) AS reconciled,
       ROUND(100.0 * SUM(CASE WHEN recon_status = 'RECONCILED' THEN 1 ELSE 0 END) / COUNT(*), 2) AS recon_pct
FROM recon_result
GROUP BY txn_date
ORDER BY txn_date DESC;

-- Q15. Maker-checker violation check (audit)
SELECT a.case_id, a.user_id
FROM audit_log a
WHERE a.action = 'APPROVE'
  AND EXISTS (SELECT 1 FROM audit_log m WHERE m.case_id = a.case_id AND m.action = 'CREATE_ADJUSTMENT' AND m.user_id = a.user_id);

-- Q16. Breach summary by month (for Compliance MIS)
SELECT strftime('%Y-%m', txn_date) AS month,
       COUNT(*) AS failed_debits,
       SUM(CASE WHEN tat_breached = 1 THEN 1 ELSE 0 END) AS breaches,
       ROUND(100.0 * SUM(CASE WHEN tat_breached = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS breach_pct
FROM exception_case
WHERE exception_code = 'EX01'
GROUP BY 1 ORDER BY 1;

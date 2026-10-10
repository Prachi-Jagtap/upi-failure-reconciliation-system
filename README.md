# UPI Payment Failure & Reconciliation System (UFRS)

> A Technical Business Analysis portfolio project for the BFSI – Payments domain.
> **Disclaimer:** This is an illustrative case study built from publicly available NPCI/RBI information. "Bharat Digital Bank (BDB)" is a fictional bank. No real customer, bank or confidential data is used.

## 1. Problem Statement
Bharat Digital Bank (BDB) is a UPI **remitter bank** processing ~2.5 million UPI transactions per day. Failed, pending and "debit-without-credit" transactions are reconciled manually in Excel against NPCI raw files. This causes:

| Pain point | Impact |
|---|---|
| Reconciliation done by 6 ops analysts in Excel, T+2 to T+3 | Late refunds, RBI TAT breaches |
| No single view of a transaction across CBS, UPI switch and NPCI file | High effort per exception (~12 min) |
| Customers raise complaints before the bank detects the failure | ~38% of failed-debit complaints are customer-initiated |
| Manual compensation calculation for TAT breach | Errors, penalty payouts |

## 2. Goal
Automate detection, matching, auto-reversal tracking, exception handling and compensation for failed UPI transactions, and cut reconciliation TAT from **T+2 to T+1** (RBI-compliant).

## 3. Deliverables (Repository Map)

| # | Artifact | File |
|---|---|---|
| 1 | Business Requirement Document | [docs/01-BRD.md](docs/01-BRD.md) |
| 2 | As-Is, To-Be & Process Flow | [docs/02-as-is-to-be-process-flow.md](docs/02-as-is-to-be-process-flow.md) |
| 3 | Functional Requirements | [docs/03-functional-requirements.md](docs/03-functional-requirements.md) |
| 4 | User Stories + Acceptance Criteria (14 detailed; 16 in Jira) | [docs/04-user-stories.md](docs/04-user-stories.md) |
| 5 | API Flow + Sample JSON | [docs/05-api-flow.md](docs/05-api-flow.md), [api/](api/) |
| 6 | Data Mapping | [docs/06-data-mapping.md](docs/06-data-mapping.md) |
| 7 | SQL (schema, sample data, recon queries) | [sql/](sql/) |
| 8 | UAT Test Cases | [docs/07-uat-test-cases.md](docs/07-uat-test-cases.md) |
| 9 | Requirement Traceability Matrix | [docs/08-rtm.md](docs/08-rtm.md) |
| 10 | Jira Backlog (import-ready CSV) | [jira/backlog.csv](jira/backlog.csv) |

## 4. Tools & Techniques Used
Mermaid (BPMN-style flows & sequence diagrams) · SQL (PostgreSQL) · Postman/JSON · Jira (Epics/Stories) · MoSCoW prioritisation · INVEST user stories · Gherkin acceptance criteria · RTM · UAT planning

## 5. My Role
Technical Business Analyst – requirement elicitation, as-is/to-be modelling, BRD/FRD, user stories, API & data mapping, SQL validation, UAT design, backlog management.

## 6. Key Domain Concepts
UPI · PSP · Remitter / Beneficiary bank · NPCI · RRN · UPI Txn ID · CBS · Deemed Approved · Auto-reversal · TCC · UDIR · Settlement · Recon (3-way) · RBI TAT harmonisation (T+1 auto-reversal, ₹100/day compensation)

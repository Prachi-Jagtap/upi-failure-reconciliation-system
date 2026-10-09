# UFRS - SQLite Database

`ufrs.db` is a ready-to-use SQLite database (no server or installation needed) for the UPI Payment Failure & Reconciliation System case study.

## Open it
- **GUI:** DB Browser for SQLite (free) > Open Database > `ufrs.db`. Use the *Execute SQL* tab to run the queries.
- **VS Code:** SQLite Viewer or SQLite extension.
- **Command line:** `sqlite3 ufrs.db`, then `.read sql/03_reconciliation_queries.sql`

## Rebuild from scripts
```
sqlite3 ufrs.db < sql/01_schema.sql
sqlite3 ufrs.db < sql/02_sample_data.sql
sqlite3 ufrs.db < sql/04_seed_recon_results.sql
```

| Script | Purpose |
|---|---|
| 01_schema.sql | 8 tables + indexes (SQLite syntax) |
| 02_sample_data.sql | Sample file loads, switch, CBS and NPCI data for 2026-10-04 (unchanged) |
| 03_reconciliation_queries.sql | 17 reconciliation and validation queries, converted to SQLite |
| 04_seed_recon_results.sql | Sample rows for recon_result, exception_case, audit_log so Q11-Q16 return results |

Note: Q11-Q13 use CURRENT_DATE, so day counts change with the date you run them.

-- UFRS schema (SQLite). Illustrative for portfolio use.
-- Converted from the PostgreSQL version: BIGSERIAL -> INTEGER PRIMARY KEY AUTOINCREMENT,
-- NOW() -> CURRENT_TIMESTAMP, BOOLEAN -> INTEGER (0/1).
PRAGMA foreign_keys = ON;

CREATE TABLE file_load (
    file_id        INTEGER PRIMARY KEY AUTOINCREMENT,
    file_name      VARCHAR(100) NOT NULL,
    source_system  VARCHAR(10)  NOT NULL,          -- NPCI / SWITCH / CBS
    checksum       VARCHAR(64),
    record_count   INT,
    load_status    VARCHAR(20)  NOT NULL,          -- RECEIVED, LOADED, REJECTED
    loaded_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (file_name, checksum)
);

CREATE TABLE switch_txn (
    rrn            VARCHAR(12),
    upi_txn_id     VARCHAR(35),
    txn_datetime   TIMESTAMP NOT NULL,
    amount         NUMERIC(15,2) NOT NULL,
    payer_vpa      VARCHAR(100),
    payee_vpa      VARCHAR(100),
    response_code  VARCHAR(5),
    status         VARCHAR(15),
    file_id        BIGINT REFERENCES file_load(file_id)
);

CREATE TABLE cbs_posting (
    cbs_tran_id    VARCHAR(20) PRIMARY KEY,
    rrn            VARCHAR(12),
    account_no     VARCHAR(20),
    amount         NUMERIC(15,2) NOT NULL,
    dr_cr_flag     CHAR(1) CHECK (dr_cr_flag IN ('D','C')),
    narration      VARCHAR(100),
    posting_date   DATE NOT NULL,
    file_id        BIGINT REFERENCES file_load(file_id)
);

CREATE TABLE npci_txn (
    rrn              VARCHAR(12),
    upi_txn_id       VARCHAR(35),
    txn_date         DATE NOT NULL,
    amount           NUMERIC(15,2) NOT NULL,
    response_code    VARCHAR(5),
    status           VARCHAR(15),
    settlement_date  DATE,
    file_id          BIGINT REFERENCES file_load(file_id)
);

CREATE TABLE recon_result (
    recon_id       INTEGER PRIMARY KEY AUTOINCREMENT,
    rrn            VARCHAR(12) NOT NULL,
    txn_date       DATE NOT NULL,
    amount         NUMERIC(15,2),
    switch_status  VARCHAR(15),
    cbs_status     VARCHAR(20),
    npci_status    VARCHAR(15),
    recon_status   VARCHAR(20) NOT NULL,           -- RECONCILED / EXCEPTION
    exception_code VARCHAR(5),                     -- EX01..EX08
    run_id         VARCHAR(30)
);

CREATE TABLE exception_case (
    case_id          VARCHAR(20) PRIMARY KEY,
    rrn              VARCHAR(12) NOT NULL,
    txn_date         DATE NOT NULL,
    amount           NUMERIC(15,2) NOT NULL,
    exception_code   VARCHAR(5) NOT NULL,
    status           VARCHAR(20) NOT NULL,         -- OPEN, ASSIGNED, PENDING_APPROVAL, ADJUSTED, CLOSED
    assigned_to      VARCHAR(30),
    reversal_due_date DATE,
    reversal_date    DATE,
    tat_breached     INTEGER DEFAULT 0,            -- 0 = no, 1 = yes
    created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE compensation (
    comp_id          INTEGER PRIMARY KEY AUTOINCREMENT,
    case_id          VARCHAR(20) REFERENCES exception_case(case_id),
    days_delayed     INT NOT NULL,
    amount           NUMERIC(10,2) NOT NULL,
    payout_status    VARCHAR(15) DEFAULT 'PENDING'
);

CREATE TABLE audit_log (
    audit_id     INTEGER PRIMARY KEY AUTOINCREMENT,
    case_id      VARCHAR(20),
    action       VARCHAR(50),
    old_value    VARCHAR(100),
    new_value    VARCHAR(100),
    user_id      VARCHAR(30),
    action_ts    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_switch_rrn ON switch_txn(rrn);
CREATE INDEX idx_cbs_rrn    ON cbs_posting(rrn);
CREATE INDEX idx_npci_rrn   ON npci_txn(rrn);
CREATE INDEX idx_case_status ON exception_case(status, exception_code);

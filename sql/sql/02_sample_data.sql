-- Sample data for txn date 2026-10-04 (fictional)
INSERT INTO file_load(file_name, source_system, checksum, record_count, load_status) VALUES
('NPCI_RAW_04102026.csv','NPCI','abc123',8,'LOADED'),
('SWITCH_04102026.csv','SWITCH','def456',8,'LOADED'),
('CBS_04102026.csv','CBS','ghi789',9,'LOADED');

INSERT INTO switch_txn(rrn,upi_txn_id,txn_datetime,amount,payer_vpa,payee_vpa,response_code,status,file_id) VALUES
('427715689001','T001','2026-10-04 09:10:00',500.00,'a@bdb','m1@bank','00','SUCCESS',2),
('427715689002','T002','2026-10-04 09:15:00',1200.00,'b@bdb','m2@bank','00','SUCCESS',2),
('427715689003','T003','2026-10-04 10:00:00',5000.00,'c@bdb','m3@bank','00','SUCCESS',2),  -- EX01
('427715689004','T004','2026-10-04 10:30:00',750.00,'d@bdb','m4@bank','00','SUCCESS',2),   -- EX02 (missing in CBS)
('427715689005','T005','2026-10-04 11:00:00',300.00,'e@bdb','m5@bank','U30','FAILED',2),   -- EX03
('427715689006','T006','2026-10-04 11:30:00',2000.00,'f@bdb','m6@bank','00','SUCCESS',2),  -- EX06 dup debit
('427715689007','T007','2026-10-04 12:00:00',1000.00,'g@bdb','m7@bank','00','SUCCESS',2),  -- EX07 amt diff
('427715689008','T008','2026-10-04 12:30:00',650.00,'h@bdb','m8@bank',NULL,'PENDING',2);  -- EX08

INSERT INTO cbs_posting(cbs_tran_id,rrn,account_no,amount,dr_cr_flag,narration,posting_date,file_id) VALUES
('C001','427715689001','ACC001',500.00,'D','UPI PAY','2026-10-04',3),
('C002','427715689002','ACC002',1200.00,'D','UPI PAY','2026-10-04',3),
('C003','427715689003','ACC003',5000.00,'D','UPI PAY','2026-10-04',3),
('C005','427715689005','ACC005',300.00,'D','UPI PAY','2026-10-04',3),
('C006','427715689006','ACC006',2000.00,'D','UPI PAY','2026-10-04',3),
('C006B','427715689006','ACC006',2000.00,'D','UPI PAY','2026-10-04',3),
('C007','427715689007','ACC007',900.00,'D','UPI PAY','2026-10-04',3),
('C008','427715689008','ACC008',650.00,'D','UPI PAY','2026-10-04',3),
('C009','427715689009','ACC009',400.00,'D','UPI PAY','2026-10-04',3);                      -- EX05 missing in NPCI

INSERT INTO npci_txn(rrn,upi_txn_id,txn_date,amount,response_code,status,settlement_date,file_id) VALUES
('427715689001','T001','2026-10-04',500.00,'00','SUCCESS','2026-10-05',1),
('427715689002','T002','2026-10-04',1200.00,'00','SUCCESS','2026-10-05',1),
('427715689003','T003','2026-10-04',5000.00,'U30','FAILED','2026-10-05',1),
('427715689004','T004','2026-10-04',750.00,'00','SUCCESS','2026-10-05',1),
('427715689005','T005','2026-10-04',300.00,'U30','FAILED','2026-10-05',1),
('427715689006','T006','2026-10-04',2000.00,'00','SUCCESS','2026-10-05',1),
('427715689007','T007','2026-10-04',1000.00,'00','SUCCESS','2026-10-05',1),
('427715689008','T008','2026-10-04',650.00,'DEEMED','DEEMED','2026-10-05',1);

-- Script SQL para crear la tabla de logs de ejecución
-- Se ejecuta con: psql -U $DB_USER -d $DB_NAME -f create_execution_logs.sql

DROP TABLE IF EXISTS dpa.execution_logs;

CREATE TABLE dpa.execution_logs (
    id SERIAL PRIMARY KEY,
    execution_id INTEGER,
    process_name TEXT,
    step TEXT,
    schema_name TEXT,
    table_name TEXT,
    records_count INTEGER,
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    status TEXT,
    details TEXT,
    log_time TIMESTAMP
);
-- Script SQL para seleccionar logs recientes
-- Se ejecuta con: psql -U $DB_USER -d $DB_NAME -t -f select_recent_logs.sql

SELECT id, execution_id, process_name, step, schema_name, table_name, records_count, start_time, end_time, status, details, log_time
FROM dpa.execution_logs
ORDER BY id DESC LIMIT 10;
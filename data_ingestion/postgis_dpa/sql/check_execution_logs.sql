-- Script SQL para verificar tabla de logs de ejecución
-- Se ejecuta con: psql -U $DB_USER -d $DB_NAME -f check_execution_logs.sql

SELECT 1 FROM dpa.execution_logs LIMIT 1;
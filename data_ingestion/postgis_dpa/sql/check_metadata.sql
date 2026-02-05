-- Script SQL para verificar tabla de metadata
-- Se ejecuta con: psql -U $DB_USER -d $DB_NAME -f check_metadata.sql

SELECT 1 FROM dpa.metadata LIMIT 1;
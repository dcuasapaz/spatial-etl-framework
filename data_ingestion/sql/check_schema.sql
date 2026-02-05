-- Script SQL para verificar existencia de esquema
-- Se ejecuta con: psql -U $DB_USER -d $DB_NAME -t -v schema_name="$TEST_SCHEMA" -f check_schema.sql

SELECT 1 FROM information_schema.schemata WHERE schema_name = :'schema_name';
-- Script SQL para optimizar tabla con VACUUM ANALYZE
-- Se ejecuta con: psql -U $DB_USER -d $DB_NAME -v table_name="$VAL_NAME_TABLE" -f vacuum_analyze.sql

VACUUM ANALYZE :table_name;
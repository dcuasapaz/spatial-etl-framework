-- Script SQL para contar registros en tabla
-- Se ejecuta con: psql -U $DB_USER -d $DB_NAME -t -v table_name="$VAL_NAME_TABLE" -f count_records.sql

SELECT count(*) AS registrosCargados FROM :table_name;
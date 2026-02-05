-- Script SQL para verificar índice GIST
-- Se ejecuta con: psql -U $DB_USER -d $DB_NAME -t -v table_name="$TEST_TABLE" -f check_gist_index.sql

SELECT 1 FROM pg_indexes WHERE tablename = :'table_name' AND indexdef LIKE '%gist%';
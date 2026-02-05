-- Script SQL para crear esquema si no existe
-- Se ejecuta con: psql -U $DB_USER -d $DB_NAME -v schema_name="$VAL_SCHEMA" -f create_schema.sql

CREATE SCHEMA IF NOT EXISTS :schema_name;
-- Script SQL para crear la tabla de metadata
-- Se ejecuta con: psql -U $DB_USER -d $DB_NAME -f create_metadata.sql

DROP TABLE IF EXISTS dpa.metadata;

CREATE TABLE dpa.metadata (
    table_name TEXT,
    version TEXT,
    load_date TIMESTAMP,
    source_file TEXT
);
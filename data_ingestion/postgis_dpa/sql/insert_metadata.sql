-- Script SQL para insertar metadata de carga
-- Se ejecuta con: psql -U $DB_USER -d $DB_NAME -v table_name="$VAL_NAME_TABLE" -v data_version="$DATA_VERSION" -v shp_path="$VAL_SHP_PATH" -f insert_metadata.sql

SET search_path TO dpa, public;
INSERT INTO dpa.metadata (table_name, version, load_date, source_file)
VALUES (:'table_name', :'data_version', NOW(), :'shp_path');
CREATE EXTENSION postgis;
SELECT postgis_full_version();
CREATE EXTENSION postgis_topology;

-- DROP SCHEMA dpa;

CREATE SCHEMA dpa AUTHORIZATION pg_database_owner;

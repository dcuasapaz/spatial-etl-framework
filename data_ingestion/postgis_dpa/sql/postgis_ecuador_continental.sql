-- Crear una nueva tabla con solo el contorno de Ecuador
drop view dpa.ec_ecu_prf;
create table dpa.ec_ecu_prf as 
SELECT ST_Union(geom) as geom
FROM dpa.ec_ecu_cnt_prf;

-- Crear el índice espacial para que sea rápido en QGIS/DBeaver
CREATE INDEX idx_perfil_ecuador ON dpa.ec_ecu_prf USING GIST (geom);

-- Perfil como una linea (no un polígono relleno)
drop view dpa.ec_ecu_prf_lne;
CREATE TABLE dpa.ec_ecu_prf_lne AS
SELECT ST_ExteriorRing((ST_Dump(ST_Union(geom))).geom) as geom
FROM dpa.ec_ecu_cnt_prf;

-- Crear una nueva tabla con solo el contorno de Ecuador con galapagos
drop view dpa.ec_ecu_prf_glp;
create table dpa.ec_ecu_prf_glp as 
SELECT ST_Union(geom) as geom
FROM dpa.ec_ecu_cnt_prf_glp;

-- Crear el índice espacial para que sea rápido en QGIS/DBeaver
CREATE INDEX idx_perfil_ecuador_glp ON dpa.ec_ecu_prf_glp USING GIST (geom);

-- Perfil como una linea (no un polígono relleno)
drop view dpa.ec_ecu_prf_lne;
CREATE TABLE dpa.ec_ecu_prf_glp_lne AS
SELECT ST_ExteriorRing((ST_Dump(ST_Union(geom))).geom) as geom
FROM dpa.ec_ecu_cnt_prf_glp;


#!/bin/bash
#####################################################################################
# MODIFICACIONES:														            #
# FECHA  		AUTOR     		DESCRIPCION MOTIVO						            #
# 2026-02-04	Diego Cuasapaz	Crear script de pruebas automatizadas #
#####################################################################################

PROCESO=TEST_LOAD_DPA

# Cargar configuración
CONFIG_FILE=$(dirname $(readlink -f $0))/config.sh
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "ERROR: Archivo de configuración no encontrado"
    exit 1
fi

# Función de logging
log() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$timestamp $level: $message"
}

log "INFO" "Iniciando pruebas automatizadas"

# Prueba 1: Verificar conexión a BD
log "INFO" "Prueba 1: Conexión a BD"
if psql -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1;" > /dev/null 2>&1; then
    log "PASS" "Conexión a BD exitosa"
else
    log "FAIL" "Conexión a BD fallida"
    exit 1
fi

# Prueba 2: Verificar esquema existe
log "INFO" "Prueba 2: Esquema $DB_SCHEMA"
if psql -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1 FROM information_schema.schemata WHERE schema_name = '$DB_SCHEMA';" -t | grep -q 1; then
    log "PASS" "Esquema $DB_SCHEMA existe"
else
    log "FAIL" "Esquema $DB_SCHEMA no existe"
fi

# Prueba 3: Verificar tabla de metadata
log "INFO" "Prueba 3: Tabla de metadata $METADATA_TABLE"
if psql -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1 FROM $METADATA_TABLE LIMIT 1;" > /dev/null 2>&1; then
    log "PASS" "Tabla de metadata existe"
else
    log "FAIL" "Tabla de metadata no existe"
fi

# Prueba 4: Verificar carga de datos (ejemplo con prv si existe)
TABLE_TEST="$DB_SCHEMA.ec_ecu_prv"
log "INFO" "Prueba 4: Verificar datos en $TABLE_TEST"
COUNT=$(psql -U "$DB_USER" -d "$DB_NAME" -t -c "SELECT count(*) FROM $TABLE_TEST;")
if [ "$COUNT" -gt 0 ]; then
    log "PASS" "Tabla $TABLE_TEST tiene $COUNT registros"
else
    log "FAIL" "Tabla $TABLE_TEST está vacía o no existe"
fi

# Prueba 5: Verificar índice espacial
log "INFO" "Prueba 5: Índice espacial en $TABLE_TEST"
if psql -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1 FROM pg_indexes WHERE tablename = 'ec_ecu_prv' AND indexdef LIKE '%gist%';" -t | grep -q 1; then
    log "PASS" "Índice GIST existe"
else
    log "FAIL" "Índice GIST no encontrado"
fi

log "INFO" "Pruebas automatizadas completadas"
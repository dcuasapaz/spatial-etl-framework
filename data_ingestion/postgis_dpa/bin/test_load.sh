#!/bin/bash
#####################################################################################
# MODIFICACIONES:														            #
# FECHA  		AUTOR     		DESCRIPCION MOTIVO						            #
# 2026-02-04	Diego Cuasapaz	Crear script de pruebas automatizadas #
# 2026-02-04	Diego Cuasapaz	Hacer script parametrizable para reutilización #
#####################################################################################

PROCESO=TEST_LOAD_DPA

# Parámetros: esquema y tabla a probar (opcionales)
TEST_SCHEMA=${1:-dpa}
TEST_TABLE=${2:-ec_ecu_prv}
TEST_FULL_TABLE="$TEST_SCHEMA.$TEST_TABLE"

# Cargar configuración
CONFIG_FILE=$(dirname $(readlink -f $0))/config.sh
if [ -f "$CONFIG_FILE" ]; then
    . "$CONFIG_FILE"
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
if psql -U "$DB_USER" -d "$DB_NAME" -f "$(dirname $(dirname $(dirname $(readlink -f $0))))/sql/test_connection.sql" > /dev/null 2>&1; then
    log "PASS" "Conexión a BD exitosa"
else
    log "FAIL" "Conexión a BD fallida"
    exit 1
fi

# Prueba 2: Verificar esquema existe
log "INFO" "Prueba 2: Esquema $TEST_SCHEMA"
if psql -U "$DB_USER" -d "$DB_NAME" -t -v schema_name="$TEST_SCHEMA" -f "$(dirname $(dirname $(dirname $(readlink -f $0))))/sql/check_schema.sql" | grep -q 1; then
    log "PASS" "Esquema $TEST_SCHEMA existe"
else
    log "FAIL" "Esquema $TEST_SCHEMA no existe"
fi

# Prueba 3: Verificar tabla de metadata
log "INFO" "Prueba 3: Tabla de metadata $METADATA_TABLE"
if psql -U "$DB_USER" -d "$DB_NAME" -f "$(dirname $(dirname $(readlink -f $0)))/sql/check_metadata.sql" > /dev/null 2>&1; then
    log "PASS" "Tabla de metadata existe"
else
    log "FAIL" "Tabla de metadata no existe"
fi

# Prueba 4: Verificar carga de datos (ejemplo con tabla especificada)
log "INFO" "Prueba 4: Verificar datos en $TEST_FULL_TABLE"
COUNT=$(psql -U "$DB_USER" -d "$DB_NAME" -t -v table_name="$TEST_FULL_TABLE" -f "$(dirname $(dirname $(dirname $(readlink -f $0))))/sql/count_records.sql")
if [ "$COUNT" -gt 0 ]; then
    log "PASS" "Tabla $TEST_FULL_TABLE tiene $COUNT registros"
else
    log "FAIL" "Tabla $TEST_FULL_TABLE está vacía o no existe"
fi

# Prueba 5: Verificar índice espacial
log "INFO" "Prueba 5: Índice espacial en $TEST_FULL_TABLE"
if psql -U "$DB_USER" -d "$DB_NAME" -t -v table_name="$TEST_TABLE" -f "$(dirname $(dirname $(dirname $(readlink -f $0))))/sql/check_gist_index.sql" | grep -q 1; then
    log "PASS" "Índice GIST existe"
else
    log "FAIL" "Índice GIST no encontrado"
fi

# Prueba 6: Verificar tabla de logs de ejecución
log "INFO" "Prueba 6: Tabla de logs de ejecución $EXECUTION_LOG_TABLE"
if psql -U "$DB_USER" -d "$DB_NAME" -f "$(dirname $(dirname $(readlink -f $0)))/sql/check_execution_logs.sql" > /dev/null 2>&1; then
    log "PASS" "Tabla de logs de ejecución existe"
    # Mostrar últimas ejecuciones
    psql -U "$DB_USER" -d "$DB_NAME" -t -f "$(dirname $(dirname $(readlink -f $0)))/sql/select_recent_logs.sql" | while read line; do
        log "INFO" "Registro: $line"
    done
else
    log "FAIL" "Tabla de logs de ejecución no existe"
fi

log "INFO" "Pruebas automatizadas completadas"

# Mostrar uso si se ejecuta sin parámetros
if [ $# -eq 0 ]; then
    echo ""
    echo "Uso: $0 [esquema] [tabla]"
    echo "Ejemplo: $0 dpa ec_ecu_prv"
    echo "Si no se especifican parámetros, usa valores por defecto: dpa ec_ecu_prv"
fi
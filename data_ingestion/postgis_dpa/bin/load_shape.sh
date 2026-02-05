#!/bin/bash
#####################################################################################
# MODIFICACIONES:														            #
# FECHA  		AUTOR     		DESCRIPCION MOTIVO						            #
# 2026-02-04	Diego Cuasapaz	Crear el proceso                                    #
# 2026-02-04	Diego Cuasapaz	Actualizar para carga dinámica basada en parámetros #
# 2026-02-04	Diego Cuasapaz	Optimizaciones: rutas dinámicas, validación de archivo, funciones modulares #
# 2026-02-04	Diego Cuasapaz	Configuración externa, logging mejorado, versionado de datos #
#####################################################################################

PROCESO=DC_DPA_ECU

# Cargar configuración externa
CONFIG_FILE=$(dirname $(readlink -f $0))/config.sh
if [ -f "$CONFIG_FILE" ]; then
    . "$CONFIG_FILE"
else
    echo "ERROR: Archivo de configuración $CONFIG_FILE no encontrado"
    exit 1
fi

# Crear tabla de logs de ejecución si no existe
psql -U "$DB_USER" -d "$DB_NAME" -c "
CREATE TABLE IF NOT EXISTS $EXECUTION_LOG_TABLE (
    id SERIAL PRIMARY KEY,
    execution_id INTEGER,
    process_name TEXT,
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    status TEXT,
    details TEXT,
    log_level TEXT,
    message TEXT,
    log_time TIMESTAMP
);" 2>/dev/null || true

# Iniciar registro de ejecución
EXECUTION_ID=$(psql -U "$DB_USER" -d "$DB_NAME" -t -c "
INSERT INTO $EXECUTION_LOG_TABLE (process_name, start_time, status, details) 
VALUES ('$PROCESO', NOW(), 'STARTED', 'Carga de $2 en $1') RETURNING id;")

# Función de logging mejorado
log() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_entry="$timestamp $level: $message"
    
    # Enviar a archivo si VAL_LOG está definido
    if [ -n "$VAL_LOG" ]; then
        echo "$log_entry" >> "$VAL_LOG"
    fi
    
    # Insertar en BD
    psql -U "$DB_USER" -d "$DB_NAME" -c "
    INSERT INTO $EXECUTION_LOG_TABLE (execution_id, log_level, message, log_time) 
    VALUES ($EXECUTION_ID, '$level', '$message', '$timestamp');" 2>/dev/null || true
    
    # Enviar a syslog si habilitado
    if [ "$USE_SYSLOG" = "true" ]; then
        logger -t "$PROCESO" "$level: $message"
    fi
    
    # Mostrar en consola si DEBUG
    if [ "$LOG_LEVEL" = "DEBUG" ]; then
        echo "$log_entry"
    fi
}

###################################################################################################################
# Ruta dinámica basada en la ubicación del script
VAL_RUTA=$(dirname $(dirname $(readlink -f $0)))
VAL_RUTA_LOG=$LOG_DIR
VAL_DIA=$(date '+%Y%m%d')
VAL_HORA=$(date '+%H%M%S')
VAL_LOG=$VAL_RUTA_LOG/$PROCESO"_"$2"_"$VAL_DIA"_"$VAL_HORA.log

log "INFO" "1. Generar y validar parametros del file LOG"

log "INFO" "2. Leer parametros de ejecucion"

VAL_USER=$DB_USER
VAL_DB=$DB_NAME
VAL_SCHEMA=$DB_SCHEMA
VAL_TABLE=$1
VAL_NAME_TABLE="$VAL_SCHEMA.$VAL_TABLE"
VAL_SUBDIR=$4
VAL_SHP_PATH=$VAL_RUTA/$DATA_DIR/$VAL_SUBDIR/$2.shp

if [ -z "$VAL_USER" ] ||
    [ -z "$VAL_DB" ] ||
    [ -z "$VAL_SCHEMA" ] ||
    [ -z "$VAL_TABLE" ] ||
    [ -z "$VAL_NAME_TABLE" ] || 
    [ -z "$VAL_SUBDIR" ] ||
    [ -z "$VAL_SHP_PATH" ] ||
    [ -z "$1" ] ||
    [ -z "$2" ] ||
    [ -z "$3" ] ||
    [ -z "$4" ] ;  then
    log "ERROR" "Uno de los parametros esta vacio o nulo"
    exit 1
fi

# Validar que el archivo Shapefile existe
if [ ! -f "$VAL_SHP_PATH" ]; then
    log "ERROR" "El archivo $VAL_SHP_PATH no existe"
    exit 1
fi

log "INFO" "VAL_SUBDIR => $VAL_SUBDIR"
log "INFO" "VAL_SHP_PATH => $VAL_SHP_PATH"

log "INFO" "3. Iniciando proceso de carga en: $VAL_DB"

VAL_ETAPA=1
# 1. Crear el esquema si no existe
if [ $VAL_ETAPA -eq 1 ]; then
    psql -U "$VAL_USER" -d "$VAL_DB" -c "CREATE SCHEMA IF NOT EXISTS $VAL_SCHEMA;" >>$VAL_LOG
    VAL_ETAPA=2
fi
# 2. Ejecutar la carga con shp2pgsql
if [ $VAL_ETAPA -eq 2 ]; then
    if [ "$DROP_TABLE" = "true" ]; then
        shp2pgsql -s $3 -d -I -W "$ENCODING" "$VAL_SHP_PATH" "$VAL_NAME_TABLE" | psql -U "$VAL_USER" -d "$VAL_DB" >>$VAL_LOG
    else
        shp2pgsql -s $3 -I -W "$ENCODING" "$VAL_SHP_PATH" "$VAL_NAME_TABLE" | psql -U "$VAL_USER" -d "$VAL_DB" >>$VAL_LOG
    fi
    VAL_ETAPA=3
fi
# 3. Optimizar la tabla con VACUUM ANALYZE
if [ $VAL_ETAPA -eq 3 ]; then
    psql -U "$VAL_USER" -d "$VAL_DB" -c "VACUUM ANALYZE $VAL_NAME_TABLE;" >>$VAL_LOG
    VAL_ETAPA=4
fi
# 4. Versionado de datos: Insertar metadata
if [ $VAL_ETAPA -eq 4 ]; then
    psql -U "$VAL_USER" -d "$VAL_DB" -c "CREATE TABLE IF NOT EXISTS $METADATA_TABLE (table_name TEXT, version TEXT, load_date TIMESTAMP, source_file TEXT);" >>$VAL_LOG
    psql -U "$VAL_USER" -d "$VAL_DB" -c "INSERT INTO $METADATA_TABLE (table_name, version, load_date, source_file) VALUES ('$VAL_NAME_TABLE', '$DATA_VERSION', NOW(), '$VAL_SHP_PATH');" >>$VAL_LOG
    VAL_ETAPA=5
fi
# 4. Verificación final
if [ $VAL_ETAPA -eq 5 ]; then
    log "INFO" "Carga exitosa: $VAL_NAME_TABLE"
    # Mostrar cuántos registros se cargaron
    VAL_CONTEO=$(psql -U "$VAL_USER" -d "$VAL_DB" -t -c "SELECT count(*) AS registrosCargados FROM $VAL_NAME_TABLE;")
    log "INFO" "Registros insertados: $VAL_CONTEO"
    log "INFO" "Finaliza ejecucion del proceso: $PROCESO"
    # Actualizar registro de ejecución
    psql -U "$DB_USER" -d "$DB_NAME" -c "
    UPDATE $EXECUTION_LOG_TABLE 
    SET end_time = NOW(), status = 'SUCCESS', details = 'Carga completada: $VAL_CONTEO registros' 
    WHERE id = $EXECUTION_ID;" 2>/dev/null || true
    exit 0
else
    log "ERROR" "Hubo un fallo en la conversión o carga del SHP."
    # Actualizar registro de ejecución con error
    psql -U "$DB_USER" -d "$DB_NAME" -c "
    UPDATE $EXECUTION_LOG_TABLE 
    SET end_time = NOW(), status = 'FAILED', details = 'Error en etapa $VAL_ETAPA' 
    WHERE id = $EXECUTION_ID;" 2>/dev/null || true
    exit 1
fi
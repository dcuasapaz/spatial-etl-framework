#!/bin/bash
################################################################################
# CONFIG.SH - Configuración externa para el proyecto postgis_dpa
# Modificar estos valores según el entorno de ejecución
################################################################################

# =============================================================================
# CONFIGURACIÓN DE BASE DE DATOS
# =============================================================================
DB_HOST="localhost"          # Host del servidor PostgreSQL
DB_PORT="5432"              # Puerto de conexión
DB_NAME="dpa_ecu"           # Nombre de la base de datos
DB_USER="dcuasapaz"         # Usuario de conexión
DB_SCHEMA="dpa"             # Esquema por defecto

# =============================================================================
# CONFIGURACIÓN DE RUTAS
# =============================================================================
LOG_DIR="/home/dcuasapaz/wrk/log"  # Directorio para logs
DATA_DIR="fnt"                     # Directorio relativo de datos fuente

# =============================================================================
# OPCIONES DE CARGA DE DATOS
# =============================================================================
ENCODING="LATIN1"           # Codificación de archivos Shapefile
DROP_TABLE="true"           # true: elimina tabla si existe (-d en shp2pgsql)

# =============================================================================
# CONFIGURACIÓN DE LOGGING
# =============================================================================
LOG_LEVEL="INFO"            # Nivel de logging: DEBUG, INFO, WARN, ERROR
USE_SYSLOG="false"          # true: enviar logs a syslog del sistema

# =============================================================================
# CONFIGURACIÓN DE VERSIONADO
# =============================================================================
DATA_VERSION="1.0"          # Versión de los datos
METADATA_TABLE="dpa.metadata"  # Tabla para metadata de cargas

# =============================================================================
# CONFIGURACIÓN DE LOGGING EN BD
# =============================================================================
EXECUTION_LOG_TABLE="dpa.execution_logs"  # Tabla para logs de ejecución

# =============================================================================
# VALIDACIONES BÁSICAS
# =============================================================================
# Verificar que las rutas existan
if [ ! -d "$LOG_DIR" ]; then
    echo "WARN: Directorio de logs no existe: $LOG_DIR"
fi

# Para DATA_DIR, construir la ruta completa relativa al directorio del script
SCRIPT_DIR=$(dirname $(readlink -f "${BASH_SOURCE[0]}"))
DATA_DIR_FULL="$SCRIPT_DIR/../$DATA_DIR"
if [ ! -d "$DATA_DIR_FULL" ]; then
    echo "WARN: Directorio de datos no existe: $DATA_DIR_FULL"
else
    DATA_DIR="$DATA_DIR_FULL"  # Actualizar DATA_DIR a ruta absoluta
fi
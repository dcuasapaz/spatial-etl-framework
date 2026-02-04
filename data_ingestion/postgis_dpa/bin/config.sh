# Configuración externa para el proyecto postgis_dpa
# Modificar estos valores según el entorno

# Base de datos
DB_HOST="localhost"
DB_PORT="5432"
DB_NAME="dpa_ecu"
DB_USER="dcuasapaz"
DB_SCHEMA="dpa"

# Rutas
LOG_DIR="/home/dcuasapaz/wrk/log"
DATA_DIR="fnt"

# Opciones de carga
ENCODING="LATIN1"
DROP_TABLE="true"  # true para -d en shp2pgsql

# Logging
LOG_LEVEL="INFO"  # DEBUG, INFO, WARN, ERROR
USE_SYSLOG="false"  # true para enviar a syslog

# Versionado
DATA_VERSION="1.0"
METADATA_TABLE="dpa.metadata"
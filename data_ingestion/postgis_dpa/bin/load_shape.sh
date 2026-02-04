#!/bin/bash
#####################################################################################
# MODIFICACIONES:														            #
# FECHA  		AUTOR     		DESCRIPCION MOTIVO						            #
# 2026-02-04	Diego Cuasapaz	Crear el proceso                                    #
# 2026-02-04	Diego Cuasapaz	Actualizar para carga dinámica basada en parámetros #
# 2026-02-04	Diego Cuasapaz	Optimizaciones: rutas dinámicas, validación de archivo, funciones modulares #
#####################################################################################

PROCESO=DC_DPA_ECU

###################################################################################################################
echo `date '+%Y-%m-%d %H:%M:%S'`" INFO: 1. Generar y validar parametros del file LOG"
###################################################################################################################
# Ruta dinámica basada en la ubicación del script
VAL_RUTA=$(dirname $(dirname $(readlink -f $0)))
VAL_RUTA_LOG=/home/dcuasapaz/wrk/log
VAL_DIA=`date '+%Y%m%d'`
VAL_HORA=`date '+%H%M%S'`
VAL_LOG=$VAL_RUTA_LOG/$PROCESO"_"$2"_"$VAL_DIA"_"$VAL_HORA.log

if [ -z "$VAL_RUTA" ] ||
    [ -z "$VAL_RUTA_LOG" ] ||
    [ -z "$VAL_DIA" ] ||

    [ -z "$VAL_HORA" ] ||
    [ -z "$VAL_LOG" ] ; then
    echo `date '+%Y-%m-%d %H:%M:%S'`" ERROR: Uno de los parametros esta vacio o nulo [Creacion del file log]" >>$VAL_LOG
    exit 1
else
    echo `date '+%Y-%m-%d %H:%M:%S'`" INFO: VAL_RUTA     => $VAL_RUTA" >>$VAL_LOG
    echo `date '+%Y-%m-%d %H:%M:%S'`" INFO: VAL_RUTA_LOG => $VAL_RUTA_LOG" >>$VAL_LOG
    echo `date '+%Y-%m-%d %H:%M:%S'`" INFO: VAL_DIA      => $VAL_DIA" >>$VAL_LOG
    echo `date '+%Y-%m-%d %H:%M:%S'`" INFO: VAL_HORA     => $VAL_HORA" >>$VAL_LOG
    echo `date '+%Y-%m-%d %H:%M:%S'`" INFO: VAL_LOG      => $VAL_LOG" >>$VAL_LOG
    echo `date '+%Y-%m-%d %H:%M:%S'`" INFO: VAL_SUBDIR   => $VAL_SUBDIR" >>$VAL_LOG
    echo `date '+%Y-%m-%d %H:%M:%S'`" INFO: VAL_SHP_PATH => $VAL_SHP_PATH" >>$VAL_LOG
fi

echo `date '+%Y-%m-%d %H:%M:%S'`"------------------------------------------" >>$VAL_LOG
echo `date '+%Y-%m-%d %H:%M:%S'`" INFO: 2. Leer parametros de ejecucion" >>$VAL_LOG
echo `date '+%Y-%m-%d %H:%M:%S'`"------------------------------------------" >>$VAL_LOG

VAL_USER="dcuasapaz"
VAL_DB="dpa_ecu"
VAL_SCHEMA="dpa"
VAL_TABLE=$1
VAL_NAME_TABLE="$VAL_SCHEMA.$VAL_TABLE"
VAL_SUBDIR=$4
VAL_SHP_PATH=$VAL_RUTA/fnt/$VAL_SUBDIR/$2.shp

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
    echo `date '+%Y-%m-%d %H:%M:%S'`" ERROR: Uno de los parametros esta vacio o nulo [Creacion del file log]" >>$VAL_LOG
    exit 1
fi

# Validar que el archivo Shapefile existe
if [ ! -f "$VAL_SHP_PATH" ]; then
    echo `date '+%Y-%m-%d %H:%M:%S'`" ERROR: El archivo $VAL_SHP_PATH no existe" >>$VAL_LOG
    exit 1
fi

echo `date '+%Y-%m-%d %H:%M:%S'`"------------------------------------------" >>$VAL_LOG
echo `date '+%Y-%m-%d %H:%M:%S'`" INFO: 3. Iniciando proceso de carga en: $VAL_DB" >>$VAL_LOG
echo `date '+%Y-%m-%d %H:%M:%S'`"------------------------------------------" >>$VAL_LOG

VAL_ETAPA=1
# 1. Crear el esquema si no existe
# Esto evita el error de "VAL_SCHEMA does not exist"
if [ $VAL_ETAPA -eq 1 ]; then
    psql -U "$VAL_USER" -d "$VAL_DB" -c "CREATE SCHEMA IF NOT EXISTS $VAL_SCHEMA;" >>$VAL_LOG
    VAL_ETAPA=2
fi
# 2. Ejecutar la carga con shp2pgsql
# -d: Borra la tabla si ya existe (evita el error que tuviste)
# -I: Crea índice espacial
# -W "LATIN1": Para que reconozca tildes y eñes de Ecuador
if [ $VAL_ETAPA -eq 2 ]; then
    shp2pgsql -s $3 -d -I -W "LATIN1" "$VAL_SHP_PATH" "$VAL_NAME_TABLE" | psql -U "$VAL_USER" -d "$VAL_DB" >>$VAL_LOG
    VAL_ETAPA=3
fi
# 3. Optimizar la tabla con VACUUM ANALYZE
if [ $VAL_ETAPA -eq 3 ]; then
    psql -U "$VAL_USER" -d "$VAL_DB" -c "VACUUM ANALYZE $VAL_NAME_TABLE;" >>$VAL_LOG
    VAL_ETAPA=4
fi
# 3. Verificación final
if [ $VAL_ETAPA -eq 4 ]; then
    echo `date '+%Y-%m-%d %H:%M:%S'`"------------------------------------------" >>$VAL_LOG
    echo `date '+%Y-%m-%d %H:%M:%S'`" INFO: ✅ Carga exitosa: $VAL_NAME_TABLE" >>$VAL_LOG
    echo `date '+%Y-%m-%d %H:%M:%S'`"------------------------------------------" >>$VAL_LOG
    # Mostrar cuántos registros se cargaron
    VAL_CONTEO=$(psql -U "$VAL_USER" -d "$VAL_DB" -t -c "SELECT count(*) AS registrosCargados FROM $VAL_NAME_TABLE;")
    echo `date '+%Y-%m-%d %H:%M:%S'`" INFO: ======================================================================" >> $VAL_LOG
    echo `date '+%Y-%m-%d %H:%M:%S'`" INFO: Registros insertados: $VAL_CONTEO" >> $VAL_LOG
    echo `date '+%Y-%m-%d %H:%M:%S'`" INFO: ======================================================================" >> $VAL_LOG
    echo `date '+%Y-%m-%d %H:%M:%S'`" INFO: Finaliza ejecucion del proceso: $PROCESO" >> $VAL_LOG
    echo `date '+%Y-%m-%d %H:%M:%S'`" INFO: ======================================================================" >> $VAL_LOG
    exit 0
else
    echo `date '+%Y-%m-%d %H:%M:%S'`" ❌ ERROR: ======================================================================" >> $VAL_LOG
    echo `date '+%Y-%m-%d %H:%M:%S'`" ❌ ERROR: Hubo un fallo en la conversión o carga del SHP." >>$VAL_LOG
    echo `date '+%Y-%m-%d %H:%M:%S'`" ❌ ERROR: ======================================================================" >> $VAL_LOG    
    exit 1
fi
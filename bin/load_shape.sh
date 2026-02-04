#!/bin/bash
#####################################################################################
# MODIFICACIONES:														            #
# FECHA  		AUTOR     		DESCRIPCION MOTIVO						            #
# 2026-02-04	Diego Cuasapaz	Crear el proceso                                    #
#####################################################################################

PROCESO=DC_DPA_ECU

###################################################################################################################
echo `date '+%Y-%m-%d %H:%M:%S'`" INFO: 1. Generar y validar parametros del file LOG"
###################################################################################################################
VAL_RUTA=/home/dcuasapaz/git/dbeaver
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
fi

echo `date '+%Y-%m-%d %H:%M:%S'`"------------------------------------------" >>$VAL_LOG
echo `date '+%Y-%m-%d %H:%M:%S'`" INFO: 2. Leer parametros de ejecucion" >>$VAL_LOG
echo `date '+%Y-%m-%d %H:%M:%S'`"------------------------------------------" >>$VAL_LOG

VAL_USER="dcuasapaz"
VAL_DB="dpa_ecu"
VAL_SCHEMA="dpa"
VAL_TABLE=$1
VAL_NAME_TABLE="$VAL_SCHEMA.$VAL_TABLE"
VAL_SHP_PATH=$VAL_RUTA/fnt/INEC2012/EcdCntSmpGlp/$2.shp

if [ -z "$VAL_USER" ] ||
    [ -z "$VAL_DB" ] ||
    [ -z "$VAL_SCHEMA" ] ||
    [ -z "$VAL_TABLE" ] ||
    [ -z "$VAL_NAME_TABLE" ] || 
    [ -z "$VAL_SHP_PATH" ] ||
    [ -z "$1" ] ||
    [ -z "$2" ] ;  then
    echo `date '+%Y-%m-%d %H:%M:%S'`" ERROR: Uno de los parametros esta vacio o nulo [Creacion del file log]" >>$VAL_LOG
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
fi
# 3. Verificación final
if [ $VAL_ETAPA -eq 2 ]; then
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
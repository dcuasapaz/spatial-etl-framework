#!/bin/bash
#####################################################################################
# MODIFICACIONES:														            #
# FECHA  		AUTOR     		DESCRIPCION MOTIVO						            #
# 2026-02-04	Diego Cuasapaz	Crear script de carga por lotes para optimización #
#####################################################################################

PROCESO=BATCH_LOAD_DPA

# Ruta dinámica
VAL_RUTA=$(dirname $(readlink -f $0))
VAL_RUTA_LOG=/home/dcuasapaz/wrk/log
VAL_DIA=`date '+%Y%m%d'`
VAL_HORA=`date '+%H%M%S'`
VAL_LOG=$VAL_RUTA_LOG/$PROCESO"_"$VAL_DIA"_"$VAL_HORA.log

echo `date '+%Y-%m-%d %H:%M:%S'`" INFO: Iniciando carga por lotes" >>$VAL_LOG

# Lista de cargas: tabla,archivo,srid,subdir
CARGAS=(
    "ec_ecu_prv,Prv,4326,INEC2012"
    "ec_ecu_cnt,Cnt,4326,INEC2012"
    # Agregar más líneas aquí
)

for CARGA in "${CARGAS[@]}"; do
    IFS=',' read -r TABLE FILE SRID SUBDIR <<< "$CARGA"
    echo `date '+%Y-%m-%d %H:%M:%S'`" INFO: Cargando $TABLE desde $SUBDIR/$FILE.shp" >>$VAL_LOG
    sh -x $VAL_RUTA/load_shape.sh $TABLE $FILE $SRID $SUBDIR
    if [ $? -ne 0 ]; then
        echo `date '+%Y-%m-%d %H:%M:%S'`" ERROR: Fallo en carga de $TABLE" >>$VAL_LOG
        exit 1
    fi
done

echo `date '+%Y-%m-%d %H:%M:%S'`" INFO: Carga por lotes completada" >>$VAL_LOG
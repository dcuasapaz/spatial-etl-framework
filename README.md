# dbeaver
#####################################################################################
# PROCESO: DC_DPA_ECU
#####################################################################################
# MODIFICACIONES:														            #
# FECHA  		AUTOR     		DESCRIPCION MOTIVO						            #
# 2026-02-04	Diego Cuasapaz	Crear el proceso                                    #
#####################################################################################
# Para ejecutar en sh de load_shape.sh
/home/dcuasapaz/git/dbeaver/bin
# Se debe considerar la ruta de la fuente
VAL_SHP_PATH=$VAL_RUTA/fnt/XXXXXXXX/$2.shp
# Como ejecutar este proceso
# Param1: nombre de la tabla en postgres
# Param2: nombre del archivo (.sh)
# Param3: Sistema de referencia espacial 
sh -x load_shape.sh ec_ecu_cnt_prf_glp EcdCnt_Prf 32717
#####################################################################################
# --------------------------------------------------------------------------------- #

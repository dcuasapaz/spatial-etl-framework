#!/bin/bash
#####################################################################################
# MODIFICACIONES:														            #
# FECHA  		AUTOR     		DESCRIPCION MOTIVO						            #
# 2026-02-04	Diego Cuasapaz	Crear script de logging genérico parametrizable #
#####################################################################################

# Script para logging de ejecución en base de datos
# Uso: ./log_execution.sh <acción> <parámetros...>
# Acciones:
#   create_table: Crear tabla si no existe
#   insert: Insertar registro de log
#   alter_table: Alter table para agregar columnas faltantes

# Cargar configuración
CONFIG_FILE=${1:-$(dirname $(readlink -f $0))/../postgis_dpa/bin/config.sh}
if [ -f "$CONFIG_FILE" ]; then
    . "$CONFIG_FILE"
else
    echo "ERROR: Archivo de configuración no encontrado: $CONFIG_FILE"
    exit 1
fi

ACTION=$2
shift 2

case $ACTION in
    create_table)
        # Crear tabla de logs de ejecución
        SQL_FILE="$(dirname $(readlink -f $0))/../sql/create_execution_logs.sql"
        if [ -f "$SQL_FILE" ]; then
            psql -U "$DB_USER" -d "$DB_NAME" -f "$SQL_FILE"
        else
            echo "ERROR: Archivo SQL no encontrado: $SQL_FILE"
            exit 1
        fi
        ;;

    insert)
        # Parámetros: execution_id process_name step schema_name table_name records_count start_time end_time status details
        EXECUTION_ID=$1
        PROCESS_NAME=$2
        STEP=$3
        SCHEMA_NAME=$4
        TABLE_NAME=$5
        RECORDS_COUNT=$6
        START_TIME=$7
        END_TIME=$8
        STATUS=$9
        DETAILS=${10}

        # Construir la consulta dinámicamente
        COLUMNS="execution_id, process_name, step"
        VALUES="$EXECUTION_ID, '$PROCESS_NAME', '$STEP'"

        if [ -n "$SCHEMA_NAME" ]; then
            COLUMNS="$COLUMNS, schema_name"
            VALUES="$VALUES, '$SCHEMA_NAME'"
        fi
        if [ -n "$TABLE_NAME" ]; then
            COLUMNS="$COLUMNS, table_name"
            VALUES="$VALUES, '$TABLE_NAME'"
        fi
        if [ -n "$RECORDS_COUNT" ]; then
            COLUMNS="$COLUMNS, records_count"
            VALUES="$VALUES, $RECORDS_COUNT"
        fi
        if [ -n "$START_TIME" ]; then
            COLUMNS="$COLUMNS, start_time"
            VALUES="$VALUES, '$START_TIME'"
        fi
        if [ -n "$END_TIME" ]; then
            COLUMNS="$COLUMNS, end_time"
            VALUES="$VALUES, '$END_TIME'"
        fi
        COLUMNS="$COLUMNS, status, details, log_time"
        VALUES="$VALUES, '$STATUS', '$DETAILS', NOW()"

        psql -U "$DB_USER" -d "$DB_NAME" -c "SET search_path TO dpa, public; INSERT INTO $EXECUTION_LOG_TABLE ($COLUMNS) VALUES ($VALUES);" 2>/dev/null || true
        ;;

    *)
        echo "Uso: $0 <acción> [parámetros]"
        echo "Acciones:"
        echo "  create_table"
        echo "  insert <execution_id> <process_name> <step> [schema_name] [table_name] [records_count] [start_time] [end_time] <status> <details>"
        exit 1
        ;;
esac
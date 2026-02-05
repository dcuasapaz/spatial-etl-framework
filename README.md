# 🗺️ Macroproyecto: Data Ingestion - DPA Ecuador
# 🗺️ Spatial ETL Framework: Ingesta Automatizada de Datos Geoespaciales (DPA Ecuador)

Este repositorio contiene el macroproyecto de ingesta de datos, con el subproceso de automatización para la carga de capas geográficas de la División Político Administrativa (DPA) de Ecuador en **PostgreSQL/PostGIS**.
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![PostGIS](https://img.shields.io/badge/PostGIS-316192?style=for-the-badge&logo=postgis&logoColor=white)
![Bash](https://img.shields.io/badge/Shell_Script-121011?style=for-the-badge&logo=gnu-bash&logoColor=white)
![GDAL](https://img.shields.io/badge/GDAL-5F8B95?style=for-the-badge&logo=gdal&logoColor=white)

## � Descripción del Proyecto

Este repositorio aloja un framework de ingeniería de datos diseñado para la **automatización, transformación y carga (ETL)** masiva de información geográfica de la División Político Administrativa (DPA) de Ecuador hacia **PostgreSQL/PostGIS**.

El sistema resuelve el desafío de integrar múltiples fuentes de datos cartográficos (Shapefiles) con diferentes proyecciones y esquemas, estandarizándolos en un modelo de datos espacial unificado y optimizado para análisis geográfico.

---

## 👥 Control de Modificaciones
## �👥 Control de Modificaciones
| Fecha | Autor | Descripción / Motivo |
| :--- | :--- | :--- |
| 2026-02-04 | Diego Cuasapaz | Creación inicial del proceso y documentación base. |
| 2026-02-04 | Diego Cuasapaz | Reorganización de directorios y actualización de documentación considerando data_ingestion como macroproyecto.
## 🚀 Características Principales

*   **🔄 Automatización Batch:** Script de descubrimiento recursivo (`batch_load.sh`) que procesa directorios completos de Shapefiles sin intervención manual.
*   **🌍 Inteligencia Espacial:** Detección dinámica de SRID (Sistemas de Referencia de Coordenadas) basada en la fuente (UTM 17S vs WGS84).
*   **🛡️ Observabilidad Completa:** Sistema de logging dual (Archivos planos + Tablas de auditoría en BD) para trazabilidad total de la ejecución.
*   **⚡ Optimización Automática:** Generación de índices espaciales **GIST** y actualización de estadísticas (`VACUUM ANALYZE`) post-carga.
*   **🧪 Calidad de Datos:** Suite de pruebas automatizadas (`test_load.sh`) para validar integridad referencial y geometría.

---

## 📝 Descripción del Proceso
El script `load_shape.sh` automatiza la conversión de archivos Shapefile (.shp) a tablas espaciales en PostGIS. El proceso incluye la creación automática de índices espaciales (GIST) y permite la definición dinámica de proyecciones (SRID).
## 🏗️ Arquitectura del Sistema

El flujo de datos orquesta herramientas de sistema (Bash) y librerías geoespaciales (GDAL/OGR) para realizar una carga transaccional eficiente.

```mermaid
graph TD
    %% Estilos del Diagrama
    classDef source fill:#e1f5fe,stroke:#01579b,stroke-width:2px,color:#000;
    classDef process fill:#fff9c4,stroke:#fbc02d,stroke-width:2px,color:#000;
    classDef db fill:#e8f5e9,stroke:#2e7d32,stroke-width:2px,color:#000;

    subgraph "📥 Fuentes de Datos"
        A[📂 Shapefiles (.shp)]:::source
    end

    subgraph "⚙️ Motor de Procesamiento (ETL)"
        B[🔄 batch_load.sh<br/>Descubrimiento]:::process -->|Ejecuta| C[🛠️ load_shape.sh<br/>Carga Individual]:::process
        C -->|Valida| D{📐 Detector SRID}:::process
        D -->|UTM 17S| E[🌍 shp2pgsql]:::process
        D -->|WGS84| E
    end

    subgraph "🗄️ Capa de Persistencia (PostGIS)"
        E -->|Stream SQL| F[(🐘 Base de Datos)]:::db
        F --> G[🗺️ Tablas Espaciales]:::db
        C -.->|Registra| H[📊 Logs & Metadata]:::db
    end

    A -->|Input| B
```

---

## 🚀 Guía de Ejecución
## 🛠️ Documentación Técnica

### **Ubicación del Binario**
El script debe ejecutarse desde la carpeta de binarios del proyecto:  
`📂 /home/dcuasapaz/git/dbeaver/data_ingestion/postgis_dpa/bin`
### Requisitos Previos
*   **PostgreSQL** (9.5+) con extensión **PostGIS** (2.2+)
*   **GDAL/OGR Tools** (`shp2pgsql`)
*   **Bash Shell** (Entorno Linux/Unix)

### **Comando de ejecución**
### Estructura del Proyecto
```
spatial-etl-framework/
├── data_ingestion/
│   ├── postgis_dpa/
│   │   ├── bin/           # Scripts: load_shape.sh, batch_load.sh, config.sh
│   │   ├── sql/           # Scripts SQL de estructura y validación
│   │   └── fnt/           # Fuentes de datos (Shapefiles organizados)
│   └── utils/             # Utilidades transversales (Logging)
```

### Guía de Ejecución

#### 1. Carga por Lotes (Recomendado)
Para cargar automáticamente todos los archivos detectados en el directorio `fnt/`:

```bash
sh -x load_shape.sh [Param1] [Param2] [Param3] [Param4]
cd data_ingestion/postgis_dpa/bin
sh batch_load.sh
```

### **Carga por Lotes**
Para cargar automáticamente **todos los archivos Shapefile** disponibles en el directorio `fnt/`, utiliza el script `batch_load.sh`. El script detecta automáticamente todos los archivos `.shp`, determina el SRID apropiado basado en el subdirectorio (32717 para datos INEC2012/DST_CRC proyectados, 4326 para datos SHP geográficos), y genera nombres de tabla estandarizados.

```bash
sh -x batch_load.sh
```

**Características de la carga automática:**
- **Detección automática:** Encuentra todos los archivos `.shp` en `fnt/` y subdirectorios.
- **Determinación de SRID:** 32717 (UTM 17S) para datos proyectados, 4326 (WGS84) para geográficos.
- **Nombres de tabla:** `ec_ecu_<nombre_archivo_minúsculas>`.
- **Manejo de errores:** Registra fallos pero continúa con el siguiente archivo.
- **Logging detallado:** Registra cada paso en logs separados por archivo y un log general del batch.

### **Pruebas Automatizadas**
Ejecuta pruebas para validar la configuración y cargas previas:

```bash
sh -x test_load.sh [esquema] [tabla]
```

Ejemplo: `sh -x test_load.sh dpa ec_ecu_prv`

### **Configuración Externa**
Los parámetros se configuran en `config.sh`. Modifica este archivo para adaptar el entorno sin cambiar el código.
---

## 🛠️ Definición de Parámetros

### **Carga Individual (load_shape.sh)**
El script requiere ***4 parámetros obligatorios** para su correcto funcionamiento:

| Parámetro | Variable | Definición | Ejemplo |
| :--- | :--- | :--- | :--- |
| **Param1** | ` $1 ` | **Nombre de Tabla:** Nombre que recibirá la tabla en la base de datos. | ` ec_ecu_cnt_prf_glp ` |
| **Param2** | ` $2 ` | **Nombre del Archivo:** Nombre del archivo fuente (sin la extensión .shp). | ` EcdCnt_Prf ` |
| **Param3** | ` $3 ` | **SRID:** Código del Sistema de Referencia Espacial (4326 o 32717). | ` 32717 ` |
| **Param4** | ` $4 ` | **Subdirectorio Fuente:** Nombre del subdirectorio en fnt/ donde se encuentra el archivo. | ` INEC2012/EcdCntSmpGlp ` |

### **Carga Automática (batch_load.sh)**
Los parámetros se determinan automáticamente del archivo Shapefile detectado:

| Parámetro | Determinación Automática | Ejemplo |
| :--- | :--- | :--- |
| **Nombre de Tabla** | `ec_ecu_<nombre_archivo_minúsculas>` | `ec_ecu_crc` |
| **SRID** | 32717 si subdirectorio contiene INEC2012/DST_CRC, 4326 si no | `32717` |
| **Subdirectorio** | Ruta relativa desde fnt/ | `DST_CRC` o `INEC2012/EcdCntSmpGlp` |

---

## 📂 Estructura de Rutas
El flujo de datos depende de una estructura de directorios estandarizada basada en la variable raíz ` $VAL_RUTA `.

### 1. Ruta de Fuentes (Input)
* **Directorio Raíz:** ` $VAL_RUTA ` → /home/dcuasapaz/git/dbeaver/data_ingestion/postgis_dpa
* **Directorio de Fuentes:** ` $VAL_RUTA `/fnt/
* **Patrón de búsqueda dinámico:** ` $VAL_RUTA `/fnt/$4/$2.shp

&nbsp;&nbsp;&nbsp;&nbsp; **Nota:** El segmento XXXXXXXX representa el subdirectorio específico de la fuente de datos (ej. DPA, INEC, etc.).

### 2. Flujo de Datos
1. El script localiza el archivo en /fnt/.
2. Ejecuta shp2pgsql para convertir el binario a SQL.
3. Realiza un pipe (|) hacia el cliente psql para insertar los datos en la base de datos destino.

---

## 📋 Ejemplo Práctico de Carga
Para cargar los cantones de Ecuador usando coordenadas proyectadas (UTM 17S):

```bash
sh -x load_shape.sh ec_ecu_cnt_prf_glp EcdCnt_Prf 32717 INEC2012/EcdCntSmpGlp
```

---

## 📦 Conjuntos de Datos Disponibles

### **DST_CRC/** - Cartografía Base
Capas geográficas de referencia (Distritos y Circunscripciones):
- `Crc.*` - Circunscripciones
- `Dst.*` - Distritos

### **INEC2012/** - Censo Nacional 2012
Datos del Instituto Nacional de Estadística y Censos:
- `Cnt.*` - Cantones
- `Prv.*` - Provincias
- `Prq.*` - Parroquias (múltiples versiones SRID)
- `Ecd.*` - Estratos de Códigos
- **Subdirectorios:**
  - `EcdCntSmp/` - Muestra de Estratos-Cantones
  - `EcdCntSmpGlp/` - Muestra de Estratos-Cantones Agrupada

### **SHP/** - Capas Nacionales
Geometrías a nivel nacional:
- `nxprovincias.*` - Provincias de Ecuador
- `nxcantones.*` - Cantones de Ecuador
- `nxparroquias.*` - Parroquias de Ecuador
- `periferia.*` - Área de periferia nacional

---

## ⚙️ Requisitos Previos

### **Software Requerido**
- **PostgreSQL** (versión 9.5+)
- **PostGIS** (versión 2.2+)
- **GDAL/OGR Tools** (incluyendo `shp2pgsql`)
- **Bash Shell**

### **Credenciales y Conexión**
El script utiliza la variable de entorno `PGPASSWORD` para autenticar con PostgreSQL. Se recomienda configurarla previamente:

```bash
export PGPASSWORD="tu_contraseña"
```

O directamente en el script antes de ejecutarlo.

---

## 🔧 Consideraciones Técnicas

### **Sistemas de Referencia Espacial (SRID)**
- **4326** - WGS84 (Geográfico, latitud/longitud)
- **32717** - UTM Zone 17S (Proyectado, coordenadas métricas)

### **Índices Espaciales**
El script genera automáticamente índices GIST (Generalized Search Tree) para optimizar consultas espaciales:

```sql
CREATE INDEX idx_geom_table ON table USING GIST(geom);
```

### **Formatos de Archivo**
Los Shapefiles incluyen múltiples componentes:
- `.shp` - Geometría principal
- `.shx` - Índice de formas
- `.dbf` - Atributos
- `.prj` - Información de proyección
- `.qpj` - Proyección adicional (QGIS)
- `.cpg` - Codificación de página (opcional)
- `.sbn`, `.sbx` - Índices de búsqueda (opcional)
- `.shp.xml` - Metadatos XML (opcional)

---

## 🔧 Optimizaciones Implementadas

### **Rutas Dinámicas**
El script detecta automáticamente su ubicación para evitar rutas hardcodeadas.

### **Validación de Archivos**
Se verifica la existencia del archivo Shapefile antes de iniciar la carga.

### **Optimización de Base de Datos**
Después de la carga, se ejecuta `VACUUM ANALYZE` para optimizar el rendimiento de consultas.

### **Carga por Lotes**
Script `batch_load.sh` permite cargar múltiples archivos en secuencia, con control de errores.

### **Recomendaciones Adicionales**
- Usa índices espaciales GIST para consultas geoespaciales.
- Considera particionamiento de tablas para datasets grandes.
- Implementa backups regulares de la base de datos.
- Monitorea el rendimiento con `EXPLAIN ANALYZE` en consultas complejas.

---

## 🔧 Mejoras Avanzadas Implementadas

### **Configuración Externa**
Archivo `config.sh` centraliza parámetros como credenciales, rutas y opciones. Facilita la portabilidad entre entornos.

### **Logging Mejorado**
- Logs estructurados con niveles (INFO, ERROR, etc.).
- Soporte opcional para syslog.
- Salida a consola en modo DEBUG.

### **Versionado de Datos**
Tabla de metadata `$METADATA_TABLE` registra versiones, fechas de carga y fuentes de datos para rastreo de cambios.

### **Logging en Base de Datos**
Tabla `$EXECUTION_LOG_TABLE` registra cada paso del proceso de carga con campos detallados:
- `step`: Paso del proceso (START, LOAD, FINISH)
- `schema_name`: Esquema de destino
- `table_name`: Tabla cargada
- `records_count`: Número de registros insertados
- `execution_id`: ID único de ejecución
- `status`: Estado (STARTED, LOADING, SUCCESS, ERROR)
- `details`: Mensajes descriptivos
- `start_time`/`end_time`: Tiempos de ejecución

Permite rastreo granular de cada etapa del proceso de carga para auditoría y debugging.

### **Pruebas Automatizadas**
Script `test_load.sh` valida conexiones, esquemas, índices y datos cargados, asegurando integridad del proceso.
- **Parametrizable**: `bash bin/test_load.sh [esquema] [tabla]` para probar tablas específicas
- **Por defecto**: Si no se pasan parámetros, prueba `dpa.ec_ecu_prv`

### **Logging Modular**
Script `utils/log_execution.sh` proporciona logging genérico reutilizable en otros subprocesos:
- **Ubicación**: `data_ingestion/utils/log_execution.sh`
- **Crear tabla**: `./utils/log_execution.sh [config_file] create_table`
- **Insertar log**: `./utils/log_execution.sh [config_file] insert <execution_id> <process_name> <step> [parámetros...]`
- **Reutilizable**: Cualquier subproceso puede usar este script para logging consistente

---

## 📜 Scripts SQL Disponibles

Además del cargador de Shapefiles, el repositorio incluye scripts SQL para operaciones avanzadas:

- **`postgis.sql`** - Instalación base de PostGIS
- **`postgis_ecuador_continental.sql`** - Configuración de datos continentales de Ecuador
- **`create_dpa_ecu.sql`** - Creación de la estructura DPA específica

---

## 🔍 Troubleshooting

| Problema | Causa Probable | Solución |
| :--- | :--- | :--- |
| `psql: command not found` | PostgreSQL no instalado | Instalar PostgreSQL y añadir a PATH |
| `shp2pgsql: command not found` | GDAL/OGR no instalado | Instalar gdal-bin o postgis tools |
| `Encoding error` | Codificación de caracteres incorrecta | Revisar fichero `.cpg` o usar `-c` en shp2pgsql |
| `Invalid SRID` | Código de proyección desconocido | Verificar que el SRID existe en `spatial_ref_sys` |
| `Permission denied` | Permisos insuficientes en BD | Verificar permisos de usuario PostgreSQL |

---

## 📚 Estructura del Proyecto

```
dbeaver/
├── README.md                          # Este archivo
└── data_ingestion/                    # Macroproyecto de ingesta de datos
    ├── sql/                          # Scripts SQL genéricos
    │   ├── create_dpa_execution_logs.sql # Creación tabla logs (genérico)
    │   ├── create_dpa_metadata.sql       # Creación tabla metadata (genérico)
    │   ├── create_schema.sql         # Creación esquema (genérico)
    │   ├── vacuum_analyze.sql        # Optimización tabla (genérico)
    │   ├── count_records.sql         # Conteo registros (genérico)
    │   ├── test_connection.sql       # Prueba conexión BD (genérico)
    │   ├── check_schema.sql          # Verificación esquema (genérico)
    │   └── check_gist_index.sql      # Verificación índice GIST (genérico)
    ├── utils/                        # Scripts genéricos reutilizables
    │   └── log_execution.sh          # Logging modular para BD
    └── postgis_dpa/                  # Subproceso DPA Ecuador
        ├── sql/                      # Scripts SQL específicos DPA
        │   ├── insert_metadata.sql   # Inserción metadata
        │   ├── check_metadata.sql    # Verificación metadata
        │   ├── check_execution_logs.sql # Verificación logs
        │   ├── select_recent_logs.sql # Consulta logs recientes
        │   ├── create_dpa_ecu.sql    # Setup DPA Ecuador
        │   └── postgis_ecuador_continental.sql # Datos continentales
        ├── bin/
        │   ├── load_shape.sh         # Script principal de carga
        │   ├── test_load.sh          # Testing parametrizable
        │   └── config.sh             # Configuración
        └── fnt/                      # Datos fuente (Shapefiles)
            ├── DST_CRC/              # Distritos y Circunscripciones
            ├── INEC2012/             # Censo 2012
            │   ├── EcdCntSmp/
            │   └── EcdCntSmpGlp/
            └── SHP/                  # Capas nacionales
```

---

## 🤝 Contacto y Networking

Este proyecto forma parte de mi portafolio profesional como **Ingeniero de Datos**. Si te interesa discutir sobre la arquitectura, el stack tecnológico o explorar oportunidades de colaboración, no dudes en contactarme.

*   👤 **Diego Cuasapaz**
*   💼 **Rol:** Data Engineer | GIS Specialist
*   🔗 **Conectemos:** [Perfil de LinkedIn](https://www.linkedin.com/)

---
*© 2026 Spatial ETL Framework. Código desarrollado bajo estándares profesionales.*

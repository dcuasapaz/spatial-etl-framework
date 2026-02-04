# 🗺️ Macroproyecto: Data Ingestion - DPA Ecuador

Este repositorio contiene el macroproyecto de ingesta de datos, con el subproceso de automatización para la carga de capas geográficas de la División Político Administrativa (DPA) de Ecuador en **PostgreSQL/PostGIS**.

---

## 👥 Control de Modificaciones
| Fecha | Autor | Descripción / Motivo |
| :--- | :--- | :--- |
| 2026-02-04 | Diego Cuasapaz | Creación inicial del proceso y documentación base. |
| 2026-02-04 | Diego Cuasapaz | Reorganización de directorios y actualización de documentación considerando data_ingestion como macroproyecto.

---

## 📝 Descripción del Proceso
El script `load_shape.sh` automatiza la conversión de archivos Shapefile (.shp) a tablas espaciales en PostGIS. El proceso incluye la creación automática de índices espaciales (GIST) y permite la definición dinámica de proyecciones (SRID).

---

## 🚀 Guía de Ejecución

### **Ubicación del Binario**
El script debe ejecutarse desde la carpeta de binarios del proyecto:  
`📂 /home/dcuasapaz/git/dbeaver/data_ingestion/postgis_dpa/bin`

### **Comando de ejecución**
```bash
sh -x load_shape.sh [Param1] [Param2] [Param3] [Param4]
```
---

## 🛠️ Definición de Parámetros

El script requiere ***4 parámetros obligatorios** para su correcto funcionamiento:

| Parámetro | Variable | Definición | Ejemplo |
| :--- | :--- | :--- | :--- |
| **Param1** | ` $1 ` | **Nombre de Tabla:** Nombre que recibirá la tabla en la base de datos. | ` ec_ecu_cnt_prf_glp ` |
| **Param2** | ` $2 ` | **Nombre del Archivo:** Nombre del archivo fuente (sin la extensión .shp). | ` EcdCnt_Prf ` |
| **Param3** | ` $3 ` | **SRID:** Código del Sistema de Referencia Espacial (4326 o 32717). | ` 32717 ` |
| **Param4** | ` $4 ` | **Subdirectorio Fuente:** Nombre del subdirectorio en fnt/ donde se encuentra el archivo. | ` INEC2012/EcdCntSmpGlp ` |

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
    └── postgis_dpa/                   # Subproceso DPA Ecuador
        ├── bin/
        │   └── load_shape.sh          # Script principal de carga
        ├── Scripts/
        │   ├── create_dpa_ecu.sql     # Setup DPA Ecuador
        │   ├── postgis.sql            # Instalación PostGIS
        │   └── postgis_ecuador_continental.sql # Datos continentales
        └── fnt/                       # Datos fuente (Shapefiles)
            ├── DST_CRC/               # Distritos y Circunscripciones
            ├── INEC2012/              # Censo 2012
            │   ├── EcdCntSmp/
            │   └── EcdCntSmpGlp/
            └── SHP/                   # Capas nacionales
```

---

## 📧 Contacto y Soporte

Para consultas o reportes de errores relacionados con este proceso:
- **Responsable:** Diego Cuasapaz
- **Proyecto:** Data Ingestion - DPA Ecuador
- **Última actualización:** 2026-02-04

---
***Documentación técnica - Macroproyecto Data Ingestion - DPA Ecuador***

_Generado por: Diego Cuasapaz_  
_Fecha de última actualización: 2026-02-04_  
***Nota:*** Este proceso es de uso exclusivo para el área de gestión de datos espaciales.*

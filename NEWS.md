# censosbo 0.1.0

Versión inicial del paquete.

## Nuevas funciones

* `get_personas()`: acceso a microdatos de personas del CPV-2024.
* `get_viviendas()`: acceso a microdatos de viviendas del CPV-2024.
* `get_emigracion()`: acceso a datos de emigración internacional.
* `get_mortalidad()`: acceso a datos de mortalidad en el hogar.
* `codebook()`: búsqueda en el diccionario de variables.
* `codebook_valores()`: valores codificados de variables categóricas.
* `departamentos()`, `provincias()`, `municipios()`: navegación geográfica.
* `censosbo_cache_dir()`, `censosbo_cache_info()`, `censosbo_cache_clear()`: gestión del caché local.
* Datos integrados: `geo_bolivia` y `codebook_meta`.

## Datos

* Primer release de datos (`data-v1.0.0`) con los microdatos del CPV-2024 en formato Parquet.
* Tabla de personas particionada por departamento (9 archivos).
* Tablas de viviendas, emigración y mortalidad como archivos únicos.

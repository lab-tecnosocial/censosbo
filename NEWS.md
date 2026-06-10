# censosbo 1.0.0

Primera versión de lanzamiento. `censosbo` proporciona acceso programático a
los microdatos de los cinco censos de Bolivia (1976, 1992, 2001, 2012 y
CPV-2024) y herramientas integradas para análisis demográfico, temporal
y visualización geográfica.

## Acceso a microdatos

* `get_personas_2024()`, `get_viviendas_2024()`, `get_emigracion_2024()`,
  `get_mortalidad_2024()`: acceso al CPV-2024 (11.4 M personas, 4.5 M
  viviendas). Los datos del CPV-2024 se descargan por departamento en
  archivos Parquet particionados (~4–77 MB cada uno).
* `get_censo(anio, tabla, ...)`: API unificada para censos históricos
  (1976, 1992, 2001, 2012). Atajos por año: `get_poblacion_1976()`,
  `get_personas_1992()`, `get_personas_2001()`, `get_personas_2012()`, y
  demás funciones por tabla y año.
* Soporte nativo para `dplyr`, Apache Arrow (carga diferida) y DuckDB
  (consultas SQL). El formato de retorno se controla con
  `as = c("arrow", "tibble", "duckdb")`.
* Filtros geográficos por departamento, provincia y municipio en todas las
  funciones de descarga.

## Análisis temporal

* `get_temporal()`: datos comparables entre todos los censos (1976–2024)
  para 11 variables armonizadas: `sexo`, `edad`, `grupo_edad`, `parentesco`,
  `estado_civil`, `sabe_leer`, `nivel_edu`, `pea`, `pet`, `area`,
  `departamento`.
* `get_temporal_vivienda()`: equivalente para la tabla de vivienda.
* `variables_armonizadas()` y `grupos_variables()`: exploración del mapa de
  armonización y los grupos temáticos predefinidos (`demografico`, `educacion`,
  `economia`, `cultural`, `migracion`, `fertilidad`).

## Diccionario de variables

* `codebook()`, `codebook_valores()`: búsqueda en el diccionario de las 168
  variables del CPV-2024.
* `codebook_1976()`, `codebook_1992()`, `codebook_2001()`, `codebook_2012()`,
  `codebook_2024()`: atajos por año para censos históricos.
* `etiquetar_valores()`, `etiquetar_variables()`: convierte códigos numéricos
  a etiquetas legibles y renombra columnas con las descripciones del INE.

## Mapas coropléticos

* `mapa_dep()`: mapa coroplético a nivel departamental. Geometrías de los 9
  departamentos incluidas en el paquete (`geo_departamentos`).
* `mapa_mun()`: mapa coroplético a nivel municipal. Geometrías de 336 de los
  343 municipios incluidas en el paquete (`geo_municipios`).
* Todas las funciones devuelven objetos `ggplot` modificables con capas y
  temas adicionales de ggplot2.

## Geografía

* `departamentos()`, `provincias()`, `municipios()`: navegación de la división
  político-administrativa de Bolivia.
* Datos incluidos: `geo_bolivia` (343 municipios con nombres y códigos),
  `geo_departamentos` (9 objetos sf), `geo_municipios` (336 objetos sf).

## Gestión del caché

* `censosbo_cache_dir()`, `censosbo_cache_info()`, `censosbo_cache_clear()`:
  los archivos Parquet se descargan una sola vez y se almacenan en caché
  local (`~/Library/Caches/org.R-project.R/R/censosbo/` por defecto).
* Opción `censosbo.cache_dir` para redirigir el caché al directorio del
  proyecto.

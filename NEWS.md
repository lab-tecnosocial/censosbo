# censosbo 1.2.0

## Filtros geográficos por nombre y validación (provincia / municipio)

* `provincia` y `municipio` ahora aceptan **nombres además de códigos** en
  `get_personas_2024()`, `get_viviendas_2024()`, `get_emigracion_2024()`,
  `get_mortalidad_2024()` y en los censos históricos 1992/2001/2012 vía
  `get_censo()`. Ejemplo: `get_personas_2024(departamento = "Cochabamba",
  municipio = "Cochabamba")`. (El censo 1976 mantiene solo códigos: usó cantones.)
* Los valores inexistentes ahora producen un **error claro** en vez de un
  resultado de 0 filas en silencio. Un nombre repetido entre departamentos
  (p.ej. `"Totora"`, `"Cercado"`) pide indicar `departamento` para desambiguar.
* Si se pasa `provincia`/`municipio` **sin** `departamento`, este se **infiere**
  del catálogo, de modo que `get_personas_2024(municipio = "Cochabamba")` solo
  descarga el departamento correspondiente en vez de todo el país.
* El filtrado se hace por la **tupla completa** `(idep, iprov, imun)`, corrigiendo
  un sobre-emparejamiento latente (el código de municipio se repite entre
  provincias y hay nombres de municipio repetidos entre departamentos).

## Nuevas funciones y mejoras de etiquetado

* Nueva función **`etiquetar_geografia()`**: agrega `nombre_dep`, `nombre_prov` y
  `nombre_mun` a un data frame de microdatos a partir de sus códigos geográficos,
  eliminando el `left_join` manual con `municipios()`. Es el equivalente
  geográfico de `etiquetar_valores()`.
* `etiquetar_valores()` etiqueta **`area`** (Urbana/Rural de la tabla persona) de
  forma determinista. Antes dependía de qué otras columnas acompañaran a `area`
  (la variable solo figuraba en el diccionario de 1976), por lo que a veces la
  dejaba como entero sin aviso.
* `etiquetar_valores()` ahora **avisa** cuando la detección automática del censo
  parece equivocada: si los valores de una columna reconocida no coinciden con
  los códigos del censo detectado, la deja cruda y sugiere usar `anio =` (en vez
  de devolver una columna toda-`NA` en silencio).
* `codebook()` / `codebook_valores()` documentan la variable derivada **`area`**
  (persona) con sus valores `1 = Urbana`, `2 = Rural`, equivalente a `urbrur`
  (vivienda).

## Consistencia

* `departamentos()`, `provincias()` y `municipios()` devuelven **`tibble`**
  (antes `data.frame`), por lo que `print(x, n = )` y la exploración funcionan
  como en el resto del tidyverse.

# censosbo 1.1.0

## Geografía directa en censos históricos (sin "consultas estrella")

* Las tablas de los censos 1992, 2001 y 2012 (`persona`, `vivienda`, `mortalidad`,
  `emigracion`, `discapacidad`) ahora incluyen las columnas geográficas
  **`idep`, `iprov` e `imun`** pre-unidas, idénticas en formato al CPV-2024
  (string de 2 dígitos, `"01"`–`"09"`). El censo 1976 (`poblacion`, `vivienda`)
  expone `idep` e `iprov` (no `imun`: usó cantones, no municipios comparables).
* `get_censo()` filtra ahora por geografía **directamente sobre estas columnas**,
  sin reconstruir la jerarquía REDATAM (`persona → vivienda → municipio`). Esto
  elimina el join estrella vía DuckDB y la descarga de `depto`/`provin`/`munic`,
  y hace que los Parquet sean usables tal cual desde otras herramientas
  (QGIS, Python, DuckDB) sin joins.
* `codebook()` documenta `idep`/`iprov`/`imun` (tipo `categorica`) en todos los censos.

> **Actualización de datos:** esta versión cambia los Parquet publicados. Si ya
> tenías datos en caché, ejecuta `update_censosbo()` (o `censosbo_cache_clear()`)
> para descargar la versión con las columnas geográficas.

# censosbo 1.0.4

## Correcciones

* `get_censo()` ahora muestra un mensaje claro al recibir un año no válido
  (antes fallaba con un error interno de `cli` por nombres de variable con punto).
  Mismo arreglo en los mensajes de error de descarga.
* `etiquetar_valores()` ahora usa las etiquetas **armonizadas** correctas con los
  datos de `get_temporal()`/`get_temporal_vivienda()` (antes aplicaba por error el
  diccionario del CPV-2024, produciendo etiquetas incorrectas en `nivel_edu` y otras).
* `departamentos()`, `provincias()` y `municipios()` reinician los nombres de
  fila (`1:n`) en lugar de arrastrar los del filtrado interno.

## Armonización temporal

* **`estado_civil`** ahora se armoniza a 4 categorías comparables entre censos
  (1=Soltero/a, 2=Casado/a o conviviente, 3=Separado/a o divorciado/a, 4=Viudo/a),
  limitadas por la granularidad del censo 1992.
* **`pea`** y **`pet`** corregidas: el mapeo apuntaba a columnas equivocadas del
  CPV-2024 (`fft_19`/`ft_19`). Ahora usan `pea_13` (1=Ocupado, 2=Cesante,
  3=Aspirante) y `pet_13` (1=Sí, 2=No), consistentes con los censos previos.
* `variable_temporal_map` y `variables_armonizadas()` incluyen una nueva columna
  `armonizada` que indica si los códigos son comparables entre censos.
* `get_temporal()` advierte cuando se solicita una variable no armonizada
  (`parentesco`), cuyos códigos crudos no son comparables entre años.

# censosbo 1.0.3

* Tipos de variable corregidos en los diccionarios.

# censosbo 1.0.2

* Ajustes menores en datos y sus etiquetas

# censosbo 1.0.1

* Mejoras en ejemplos de documentación

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

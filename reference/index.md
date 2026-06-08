# Package index

## CPV-2024: microdatos

Funciones para descargar y consultar los microdatos del Censo de
Población y Vivienda 2024. Todos devuelven un Arrow Dataset (lazy), un
tibble, o una conexión DuckDB.

- [`get_personas_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/get_personas_2024.md)
  : Accede a los microdatos de personas del CPV-2024
- [`get_viviendas_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/get_viviendas_2024.md)
  : Accede a los microdatos de viviendas del CPV-2024
- [`get_emigracion_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/get_emigracion_2024.md)
  : Accede a los microdatos de emigración internacional del CPV-2024
- [`get_mortalidad_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/get_mortalidad_2024.md)
  : Accede a los microdatos de mortalidad del CPV-2024

## Censos históricos: API general

Función principal para acceder a cualquier censo histórico (1976, 1992,
2001, 2012) y funciones de análisis longitudinal entre censos.

- [`get_poblacion_1976()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md)
  [`get_viviendas_1976()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md)
  [`get_personas_1992()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md)
  [`get_viviendas_1992()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md)
  [`get_mortalidad_1992()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md)
  [`get_personas_2001()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md)
  [`get_viviendas_2001()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md)
  [`get_personas_2012()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md)
  [`get_viviendas_2012()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md)
  [`get_emigracion_2012()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md)
  [`get_discapacidad_2012()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md)
  [`get_censo()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md)
  : Accede a los microdatos de los censos históricos de Bolivia
- [`get_longitudinal()`](https://lab-tecnosocial.github.io/censosbo/reference/get_longitudinal.md)
  : Obtiene datos longitudinales comparables de la tabla persona entre
  censos
- [`get_longitudinal_vivienda()`](https://lab-tecnosocial.github.io/censosbo/reference/get_longitudinal_vivienda.md)
  : Obtiene datos longitudinales comparables de la tabla vivienda entre
  censos
- [`variables_armonizadas()`](https://lab-tecnosocial.github.io/censosbo/reference/variables_armonizadas.md)
  : Muestra el mapeo de variables comparables entre censos de Bolivia
- [`grupos_variables()`](https://lab-tecnosocial.github.io/censosbo/reference/grupos_variables.md)
  : Grupos temáticos predefinidos de variables armonizadas

## Censos históricos: atajos por año

Funciones cortas equivalentes a `get_censo(anio, tabla, ...)`.

- [`get_poblacion_1976()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md)
  [`get_viviendas_1976()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md)
  [`get_personas_1992()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md)
  [`get_viviendas_1992()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md)
  [`get_mortalidad_1992()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md)
  [`get_personas_2001()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md)
  [`get_viviendas_2001()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md)
  [`get_personas_2012()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md)
  [`get_viviendas_2012()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md)
  [`get_emigracion_2012()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md)
  [`get_discapacidad_2012()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md)
  [`get_censo()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md)
  : Accede a los microdatos de los censos históricos de Bolivia

## Diccionario de variables

Funciones para explorar variables y etiquetas de todos los censos, y
para convertir códigos numéricos a texto legible.

- [`codebook_1976()`](https://lab-tecnosocial.github.io/censosbo/reference/codebook.md)
  [`codebook_1992()`](https://lab-tecnosocial.github.io/censosbo/reference/codebook.md)
  [`codebook_2001()`](https://lab-tecnosocial.github.io/censosbo/reference/codebook.md)
  [`codebook_2012()`](https://lab-tecnosocial.github.io/censosbo/reference/codebook.md)
  [`codebook_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/codebook.md)
  [`codebook()`](https://lab-tecnosocial.github.io/censosbo/reference/codebook.md)
  : Consulta el diccionario de variables de un censo de Bolivia
- [`codebook_valores()`](https://lab-tecnosocial.github.io/censosbo/reference/codebook_valores.md)
  : Muestra los valores codificados de una variable categórica
- [`etiquetar_valores()`](https://lab-tecnosocial.github.io/censosbo/reference/etiquetar_valores.md)
  : Etiqueta los valores de las variables categóricas
- [`etiquetar_variables()`](https://lab-tecnosocial.github.io/censosbo/reference/etiquetar_variables.md)
  : Etiqueta los nombres de las variables (columnas)

## Geografía y visualización en mapas

Funciones para consultar la división político-administrativa del país y
para generar mapas coropléticos con variables censales.

- [`departamentos()`](https://lab-tecnosocial.github.io/censosbo/reference/departamentos.md)
  : Lista los departamentos de Bolivia
- [`provincias()`](https://lab-tecnosocial.github.io/censosbo/reference/provincias.md)
  : Lista las provincias de un departamento
- [`municipios()`](https://lab-tecnosocial.github.io/censosbo/reference/municipios.md)
  : Lista los municipios de Bolivia
- [`mapa_dep()`](https://lab-tecnosocial.github.io/censosbo/reference/mapa_dep.md)
  : Visualiza una variable censal a nivel departamental
- [`mapa_mun()`](https://lab-tecnosocial.github.io/censosbo/reference/mapa_mun.md)
  : Visualiza una variable censal a nivel municipal
- [`mapa_man()`](https://lab-tecnosocial.github.io/censosbo/reference/mapa_man.md)
  : Visualiza una variable censal a nivel de manzano

## Gestión de caché

Los archivos Parquet se descargan una sola vez y quedan en caché local.

- [`censosbo_cache_dir()`](https://lab-tecnosocial.github.io/censosbo/reference/censosbo_cache_dir.md)
  : Directorio de caché local del paquete
- [`censosbo_cache_info()`](https://lab-tecnosocial.github.io/censosbo/reference/censosbo_cache_info.md)
  : Información sobre los archivos en caché
- [`censosbo_cache_clear()`](https://lab-tecnosocial.github.io/censosbo/reference/censosbo_cache_clear.md)
  : Limpia el caché local de datos

## Datos incluidos en el paquete

Datasets disponibles sin descarga, incluidos directamente en el paquete.

- [`codebook_meta`](https://lab-tecnosocial.github.io/censosbo/reference/codebook_meta.md)
  : Diccionario de variables del CPV-2024
- [`codebook_historico_meta`](https://lab-tecnosocial.github.io/censosbo/reference/codebook_historico_meta.md)
  : Diccionarios de variables de los censos históricos de Bolivia
- [`variable_longitudinal_map`](https://lab-tecnosocial.github.io/censosbo/reference/variable_longitudinal_map.md)
  : Variables armonizadas para análisis longitudinal
- [`geo_bolivia`](https://lab-tecnosocial.github.io/censosbo/reference/geo_bolivia.md)
  : Tabla de geografía de Bolivia
- [`geo_departamentos`](https://lab-tecnosocial.github.io/censosbo/reference/geo_departamentos.md)
  : Geometrías de los departamentos de Bolivia
- [`geo_municipios`](https://lab-tecnosocial.github.io/censosbo/reference/geo_municipios.md)
  : Geometrías de los municipios de Bolivia

## Información del paquete

- [`censosbo`](https://lab-tecnosocial.github.io/censosbo/reference/censosbo-package.md)
  [`censosbo-package`](https://lab-tecnosocial.github.io/censosbo/reference/censosbo-package.md)
  : censosbo: Acceso y Análisis de los Datos de los Censos de Bolivia

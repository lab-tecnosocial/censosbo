# Package index

## Acceso a microdatos

Funciones principales para descargar y consultar los cuatro conjuntos de
datos del CPV-2024. Todos devuelven un Arrow Dataset (lazy), un tibble,
o una conexión DuckDB.

- [`get_personas()`](https://lab-tecnosocial.github.io/censosbo/reference/get_personas.md)
  : Accede a los microdatos de personas del CPV-2024
- [`get_viviendas()`](https://lab-tecnosocial.github.io/censosbo/reference/get_viviendas.md)
  : Accede a los microdatos de viviendas del CPV-2024
- [`get_emigracion()`](https://lab-tecnosocial.github.io/censosbo/reference/get_emigracion.md)
  : Accede a los microdatos de emigración internacional del CPV-2024
- [`get_mortalidad()`](https://lab-tecnosocial.github.io/censosbo/reference/get_mortalidad.md)
  : Accede a los microdatos de mortalidad del CPV-2024

## Geografía de Bolivia

Dataset con la división político-administrativa completa (9
departamentos, 113 provincias, 343 municipios) y funciones de consulta.

- [`geo_bolivia`](https://lab-tecnosocial.github.io/censosbo/reference/geo_bolivia.md)
  : Tabla de geografía de Bolivia
- [`departamentos()`](https://lab-tecnosocial.github.io/censosbo/reference/departamentos.md)
  : Lista los departamentos de Bolivia
- [`provincias()`](https://lab-tecnosocial.github.io/censosbo/reference/provincias.md)
  : Lista las provincias de un departamento
- [`municipios()`](https://lab-tecnosocial.github.io/censosbo/reference/municipios.md)
  : Lista los municipios de Bolivia

## Diccionario de variables

Dataset y funciones para explorar las 168 variables del CPV-2024, con
etiquetas en español y códigos de categorías.

- [`codebook_meta`](https://lab-tecnosocial.github.io/censosbo/reference/codebook_meta.md)
  : Diccionario de variables del CPV-2024
- [`codebook()`](https://lab-tecnosocial.github.io/censosbo/reference/codebook.md)
  : Consulta el diccionario de variables del CPV-2024
- [`codebook_valores()`](https://lab-tecnosocial.github.io/censosbo/reference/codebook_valores.md)
  : Muestra los valores codificados de una variable categórica

## Gestión de caché

Los archivos Parquet se descargan una sola vez y quedan en caché local.
Estas funciones permiten inspeccionar y limpiar el caché.

- [`censosbo_cache_dir()`](https://lab-tecnosocial.github.io/censosbo/reference/censosbo_cache_dir.md)
  : Directorio de caché local del paquete
- [`censosbo_cache_info()`](https://lab-tecnosocial.github.io/censosbo/reference/censosbo_cache_info.md)
  : Información sobre los archivos en caché
- [`censosbo_cache_clear()`](https://lab-tecnosocial.github.io/censosbo/reference/censosbo_cache_clear.md)
  : Limpia el caché local de datos

## Información del paquete

- [`censosbo`](https://lab-tecnosocial.github.io/censosbo/reference/censosbo-package.md)
  [`censosbo-package`](https://lab-tecnosocial.github.io/censosbo/reference/censosbo-package.md)
  : censosbo: Acceso y Análisis de los Datos del Censo de Bolivia 2024

# Introducción a censosbo

## ¿Qué es censosbo?

`censosbo` es un paquete de R que facilita el acceso a los microdatos
del **Censo de Población y Vivienda 2024 (CPV-2024)** de Bolivia,
publicados por el Instituto Nacional de Estadística (INE).

Los datos originales en CSV pesan más de 3 GB, por lo que el paquete los
distribuye como archivos **Parquet** comprimidos (mucho más livianos y
rápidos), descargados **bajo demanda** y guardados en un caché local.

## Instalación

``` r

# Instalar desde GitHub
remotes::install_github("lab-tecnosocial/censosbo")
```

## Tablas disponibles

El CPV-2024 incluye cuatro tablas:

| Función | Tabla | Filas | Variables | Descripción |
|----|----|---:|---:|----|
| [`get_personas()`](https://lab-tecnosocial.github.io/censosbo/reference/get_personas.md) | Persona | ~11.4M | 118 | Datos individuales de cada persona |
| [`get_viviendas()`](https://lab-tecnosocial.github.io/censosbo/reference/get_viviendas.md) | Vivienda | ~4.5M | 48 | Características de cada vivienda |
| [`get_emigracion()`](https://lab-tecnosocial.github.io/censosbo/reference/get_emigracion.md) | Emigración | ~501K | 8 | Emigrantes al exterior (últimos 5 años) |
| [`get_mortalidad()`](https://lab-tecnosocial.github.io/censosbo/reference/get_mortalidad.md) | Mortalidad | ~383K | 10 | Fallecimientos en el hogar (últimos 12 meses) |

Las tablas se pueden unir usando la clave `idep + iprov + imun + i00`
(identificador de hogar).

## Primera descarga

Al llamar
[`get_personas()`](https://lab-tecnosocial.github.io/censosbo/reference/get_personas.md)
por primera vez, el paquete descargará el archivo Parquet
correspondiente y lo guardará en caché local. Las siguientes llamadas
usarán el caché sin descargar de nuevo.

``` r

library(censosbo)

# Descargar datos de un departamento (recomendado para empezar)
# Santa Cruz = código "07"
personas_sc <- get_personas(departamento = "Santa Cruz")
personas_sc
```

El argumento `departamento` acepta el código numérico (`"07"`) o el
nombre (`"Santa Cruz"`).

``` r

# Ver todos los departamentos con sus códigos
departamentos()
```

## Filtros geográficos

Todas las funciones `get_*()` aceptan los mismos argumentos geográficos:

``` r

# Por departamento
get_personas(departamento = "02")          # La Paz
get_personas(departamento = "La Paz")      # equivalente

# Por varios departamentos a la vez
get_personas(departamento = c("02", "03")) # La Paz y Cochabamba

# Por provincia (código de provincia)
get_personas(departamento = "07", provincia = "01")

# Ver provincias de un departamento
provincias("Santa Cruz")

# Ver municipios
municipios(departamento = "07")
```

## Selección de variables

Por defecto se devuelven todas las variables. Para análisis más rápidos,
se pueden seleccionar columnas específicas:

``` r

# Solo sexo y edad de Santa Cruz
get_personas(
  departamento = "07",
  variables    = c("p25_sexo", "p26_edad")
)
```

Las columnas geográficas (`idep`, `iprov`, `imun`, `i00`) siempre se
incluyen.

## Formatos de retorno

El argumento `as` controla el tipo de objeto retornado:

``` r

# Arrow Dataset (por defecto): lazy, no carga en RAM
ds_arrow <- get_personas(departamento = "07", as = "arrow")

# data.frame: trae los datos a memoria RAM
df <- get_personas(departamento = "07", as = "tibble")

# Conexión DuckDB: para consultas SQL
con <- get_personas(departamento = "07", as = "duckdb")
DBI::dbGetQuery(con, "SELECT COUNT(*) FROM personas")
DBI::dbDisconnect(con)
```

## Uso con dplyr

El formato Arrow es compatible directamente con `dplyr`:

``` r

library(dplyr)

# Contar personas por sexo en Cochabamba (sin traer todos los datos a RAM)
get_personas(departamento = "03") |>
  count(p25_sexo) |>
  collect()  # collect() materializa el resultado

# Edad promedio en Oruro
get_personas(
  departamento = "04",
  variables    = c("p26_edad")
) |>
  summarise(edad_promedio = mean(p26_edad, na.rm = TRUE)) |>
  collect()
```

## Diccionario de variables

Para explorar qué significa cada variable:

``` r

# Ver descripción de una variable
codebook("p25_sexo")

# Buscar variables relacionadas con educación
codebook(buscar = "educaci")

# Ver todas las variables de vivienda
codebook(tabla = "vivienda")

# Ver los códigos de una variable categórica
codebook_valores("p25_sexo")
```

## Gestión del caché

Los datos descargados se guardan localmente para evitar descargas
repetidas:

``` r

# Ver dónde está el caché
censosbo_cache_dir()

# Ver qué archivos están descargados
censosbo_cache_info()

# Limpiar el caché si necesitas liberar espacio
censosbo_cache_clear()
```

## Cómo citar

Si usas `censosbo` en tu trabajo, por favor cita:

``` r

citation("censosbo")
```

También cita la fuente original de los datos:

> Instituto Nacional de Estadística (INE). (2024). *Censo de Población y
> Vivienda 2024 — Base de datos de microdatos*. Bolivia.
> <https://anda.ine.gob.bo/index.php/catalog/132>


<!-- README.md is generated from README.Rmd. Please edit that file -->

# censosbo <img src="man/figures/logo.png" align="right" height="139" alt="" />

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![License:
MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![R-CMD-check](https://github.com/lab-tecnosocial/censosbo/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/lab-tecnosocial/censosbo/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

**censosbo** proporciona acceso programático a los microdatos del
**Censo de Población y Vivienda 2024 (CPV-2024) de Bolivia**. Los datos
se descargan bajo demanda desde GitHub Releases, se guardan en caché
local y se pueden consultar con `dplyr`, Apache Arrow o DuckDB.

## Instalación

``` r
# install.packages("remotes")
remotes::install_github("lab-tecnosocial/censosbo")
```

## Tablas disponibles

| Función | Registros | Variables | Descripción |
|----|---:|---:|----|
| `get_personas()` | ~11.4M | 118 | Datos de cada persona empadronada |
| `get_viviendas()` | ~4.5M | 48 | Características de viviendas |
| `get_emigracion()` | ~501K | 8 | Emigración internacional (últimos 5 años) |
| `get_mortalidad()` | ~383K | 10 | Fallecimientos en el hogar (últimos 12 meses) |

Todas las tablas se pueden unir por la clave `idep + iprov + imun + i00`
(identificador de hogar).

## Uso rápido

``` r
library(censosbo)
library(dplyr)

# Datos de Santa Cruz como Arrow Dataset (lazy, sin cargar todo en RAM)
personas_sc <- get_personas(departamento = "Santa Cruz")

# Pirámide de edad: conteo por grupo quinquenal y sexo
personas_sc |>
  filter(!is.na(p26_edad)) |>
  mutate(
    grupo_edad = cut(p26_edad, breaks = seq(0, 100, 5), right = FALSE),
    sexo       = ifelse(p25_sexo == 1, "Hombre", "Mujer")
  ) |>
  count(grupo_edad, sexo) |>
  collect()
```

``` r
# Ver departamentos disponibles
departamentos()

# Provincias de La Paz
provincias("La Paz")

# Filtrar por municipio
get_personas(departamento = "02", municipio = "050101")
```

``` r
# Consulta SQL con DuckDB
con <- get_personas(departamento = "07", as = "duckdb")
DBI::dbGetQuery(con, "
  SELECT p25_sexo, COUNT(*) AS total, ROUND(AVG(p26_edad), 1) AS edad_prom
  FROM personas
  GROUP BY p25_sexo
")
DBI::dbDisconnect(con)
```

``` r
# Join personas + viviendas
library(DBI)

con <- DBI::dbConnect(duckdb::duckdb())
duckdb::duckdb_register_arrow(con, "p", get_personas(departamento = "03"))
duckdb::duckdb_register_arrow(con, "v", get_viviendas(departamento = "03"))

DBI::dbGetQuery(con, "
  SELECT v.urbrur AS area, COUNT(*) AS personas
  FROM p JOIN v ON p.idep=v.idep AND p.iprov=v.iprov
                AND p.imun=v.imun AND p.i00=v.i00
  WHERE v.v07_aguapro != 1
  GROUP BY area
")
DBI::dbDisconnect(con)
```

## Diccionario de variables

``` r
# Buscar variables
codebook(buscar = "educaci")

# Ver códigos de una variable categórica
codebook_valores("p25_sexo")
```

## Gestión del caché

Los datos se descargan una sola vez y se guardan localmente:

``` r
censosbo_cache_dir()    # dónde está el caché
censosbo_cache_info()   # qué archivos están descargados
censosbo_cache_clear()  # liberar espacio
```

## Fuente de datos

Los microdatos son publicados por el **Instituto Nacional de Estadística
(INE) de Bolivia** y están disponibles en:
<https://anda.ine.gob.bo/index.php/catalog/132>

## Citar

``` r
citation("censosbo")
```

> Ojeda Copa, A. (2024). *censosbo: Acceso y análisis de los datos del
> Censo de Bolivia 2024*. R package version 0.1.0.
> <https://github.com/lab-tecnosocial/censosbo>

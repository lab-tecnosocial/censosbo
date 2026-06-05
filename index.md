# censosbo

**censosbo** proporciona acceso programático a los microdatos de todos
los **censos de población de Bolivia**: 1976, 1992, 2001, 2012 y el
CPV-2024. Los datos se descargan bajo demanda desde GitHub Releases, se
guardan en caché local y se pueden consultar con `dplyr`, Apache Arrow o
DuckDB.

## Instalación

``` r

# install.packages("remotes")
remotes::install_github("lab-tecnosocial/censosbo")
```

## Censos disponibles

### CPV-2024

| Función | Registros | Variables | En disco (Parquet) |
|----|---:|---:|---:|
| [`get_personas_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/get_personas_2024.md) | ~11.4M | 118 | 7–155 MB/dep. (560 MB total) |
| [`get_viviendas_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/get_viviendas_2024.md) | ~4.5M | 48 | ~100 MB |
| [`get_emigracion_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/get_emigracion_2024.md) | ~501K | 8 | ~5 MB |
| [`get_mortalidad_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/get_mortalidad_2024.md) | ~383K | 10 | ~4 MB |

### Censos históricos (vía `get_censo()`)

| Año | Funciones disponibles | Personas |
|----|----|---:|
| 1976 | [`get_poblacion_1976()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md), [`get_viviendas_1976()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md) | ~4.6M |
| 1992 | [`get_personas_1992()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md), [`get_viviendas_1992()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md), [`get_mortalidad_1992()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md) | ~6.4M |
| 2001 | [`get_personas_2001()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md), [`get_viviendas_2001()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md) | ~8.3M |
| 2012 | [`get_personas_2012()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md), [`get_viviendas_2012()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md), [`get_emigracion_2012()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md), [`get_discapacidad_2012()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md) | ~10M |

El formato **Arrow** (por defecto) mantiene los datos en el disco hasta
que ejecutas
[`collect()`](https://dplyr.tidyverse.org/reference/compute.html). Las
tablas del CPV-2024 se pueden unir por la clave
`idep + iprov + imun + i00` (identificador de hogar).

## Uso rápido — CPV-2024

``` r

library(censosbo)
library(dplyr)

# Grupos quinquenales de edad por sexo, Santa Cruz
# Nota: usar %/% en lugar de cut() — cut() no es compatible con Arrow
get_personas_2024(departamento = "Santa Cruz") |>
  filter(!is.na(p26_edad), !is.na(p25_sexo)) |>
  mutate(grupo_edad = (p26_edad %/% 5L) * 5L) |>
  count(grupo_edad, p25_sexo) |>
  collect() |>
  etiquetar_valores()
```

``` r

# Consulta SQL con DuckDB
library(DBI)
con <- get_personas_2024(departamento = "Santa Cruz", as = "duckdb")
DBI::dbGetQuery(con, "
  SELECT p25_sexo, COUNT(*) AS total, ROUND(AVG(p26_edad), 1) AS edad_prom
  FROM personas
  GROUP BY p25_sexo
  ORDER BY p25_sexo
") |> etiquetar_valores()
DBI::dbDisconnect(con)
```

## Censos históricos

``` r

# Personas de Santa Cruz en el censo 2012
get_personas_2012(departamento = "Santa Cruz")

# API genérica — equivalente
get_censo(2012, "persona", departamento = "07")

# Censo 1976 (estructura directa, sin REDATAM)
get_poblacion_1976(departamento = "03")  # Cochabamba
```

## Análisis longitudinal

``` r

# Variables comparables entre censos
variables_armonizadas()

# Nivel educativo en todo el país, 1976–2024
edu <- get_longitudinal(
  variables = c("sexo", "nivel_edu"),
  anios     = c(1976, 1992, 2001, 2012, 2024)
)
edu |> count(anio, nivel_edu)
```

## Diccionario de variables

``` r

# Buscar variables del CPV-2024
codebook(buscar = "educa")

# Codebook para censos históricos
codebook_2012(buscar = "instruccion")
codebook_1992(buscar = "sexo")

# Ver códigos de una variable
codebook_valores("p25_sexo")          # CPV-2024
codebook_valores("P24", anio = 2012)  # Censo 2012
```

## Etiquetas en los resultados

``` r

library(dplyr)

get_personas_2024(departamento = "Santa Cruz") |>
  count(p25_sexo, nivel_edu) |>
  collect() |>
  etiquetar_valores() |>    # 1 → "Mujer", 2 → "Hombre"
  etiquetar_variables()     # "p25_sexo" → "25. Es mujer u hombre"
```

## Geografía

``` r

departamentos()
provincias("La Paz")
municipios(departamento = "Santa Cruz") |> head(5)
```

## Gestión del caché

``` r

# Guardar caché dentro del proyecto (recomendado)
options(censosbo.cache_dir = "data/censosbo")

censosbo_cache_dir()    # dónde está el caché
censosbo_cache_info()   # qué archivos están descargados
censosbo_cache_clear()  # liberar espacio en disco
```

## Fuente de datos

Los microdatos son publicados por el **Instituto Nacional de Estadística
(INE) de Bolivia**:

- CPV-2024: <https://anda.ine.gob.bo/index.php/catalog/132>
- Censos históricos 1976–2012: <https://anda.ine.gob.bo>

## Citar

``` r

citation("censosbo")
```

> Ojeda Copa, A. (2025). *censosbo: Acceso y análisis de los censos de
> Bolivia (1976–2024)*. R package version 0.2.0.
> <https://github.com/lab-tecnosocial/censosbo>

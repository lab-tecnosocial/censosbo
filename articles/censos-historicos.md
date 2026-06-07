# Censos históricos de Bolivia (1976–2012)

`censosbo` incluye microdatos de los cuatro censos bolivianos anteriores
al CPV-2024: **1976, 1992, 2001 y 2012**. Los datos se descargan bajo
demanda desde GitHub Releases y se almacenan en el mismo caché local que
los datos del 2024.

## Tablas disponibles por año

| Año | Tablas | Filas | Estructura geográfica |
|----|----|---:|----|
| 1976 | `poblacion` (alias: `persona`), `vivienda` | ~4.6M | Columnas directas `dep`, `pro`, `can` |
| 1992 | `persona`, `vivienda`, `mortalidad` | ~6.4M | REDATAM (REF_ID) |
| 2001 | `persona`, `vivienda`, `comunidades_poblacion`, `comunidades_vivienda` | ~8.3M | REDATAM (REF_ID) |
| 2012 | `persona`, `vivienda`, `emigracion`, `discapacidad` | ~10M | REDATAM (REF_ID) |

## API: `get_censo()` y funciones cortas

La función principal es `get_censo(anio, tabla, ...)`. También hay
funciones cortas por año.

``` r

# API genérica — forma canónica
get_censo(2012, "persona", departamento = "07")

# Funciones cortas equivalentes
get_personas_2012(departamento = "07")
get_personas_2001(departamento = "La Paz")
get_personas_1992(departamento = "03")
get_poblacion_1976(departamento = "05")
```

Los parámetros son los mismos que en
[`get_personas_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/get_personas_2024.md):

| Parámetro      | Descripción                                    |
|----------------|------------------------------------------------|
| `anio`         | Año del censo: 1976, 1992, 2001 o 2012         |
| `tabla`        | Nombre de la tabla (ver tabla arriba)          |
| `departamento` | Código `"01"`–`"09"` o nombre del departamento |
| `provincia`    | Código de provincia (no disponible en 1976)    |
| `municipio`    | Código de municipio (no disponible en 1976)    |
| `variables`    | Vector de columnas a seleccionar               |
| `as`           | `"arrow"` (defecto), `"tibble"`, o `"duckdb"`  |

## Descarga y caché

La primera llamada descarga el archivo Parquet desde GitHub Releases.
Las siguientes usan el caché local:

``` r

# Primera vez: descarga ~135 MB
personas_1992 <- get_personas_1992(departamento = "07")

# Siguiente vez: instantáneo (caché)
personas_1992 <- get_personas_1992(departamento = "07")

# Forzar re-descarga
personas_1992 <- get_personas_1992(departamento = "07", overwrite = TRUE)

# Ver qué hay en caché
censosbo_cache_info()
```

Los archivos históricos se guardan en subcarpetas por año:
`censosbo_cache_dir()/historico/1992/persona.parquet`, etc.

## Filtros geográficos

``` r

# Por departamento (nombre o código)
get_personas_2012(departamento = "Santa Cruz")
get_personas_2012(departamento = "07")

# Por departamento + provincia
get_viviendas_1992(departamento = "03", provincia = "01")

# Por municipio (1992, 2001, 2012 — no disponible en 1976)
get_personas_2012(departamento = "07", municipio = "01")
```

Si el municipio no existe en ese año, se emite una advertencia y se
retorna `NULL`:

``` r

# El municipio 100 no existe en el censo 1992 — emite cli_warn + retorna NULL
get_personas_1992(municipio = "100")
```

> **Nota:** El número de municipios cambió entre censos (1992: 339,
> 2001: 343, 2012: 339, 2024: 344). Un código válido en un año puede no
> existir en otro.

## Censo 1976: estructura diferente

El censo de 1976 no usa REDATAM. Sus columnas geográficas son:

- `dep` — código de departamento (1–9, entero)
- `pro` — código de provincia
- `can` — código de cantón/municipio

``` r

# Población del censo 1976 en el depto de Cochabamba (código 3)
pob_cbba_76 <- get_poblacion_1976(departamento = "03")

# Ver las primeras columnas
pob_cbba_76 |>
  select(dep, pro, can, p02_sexo = p02, p03_edad = p03) |>
  collect() |>
  head()

# Viviendas 1976
get_viviendas_1976(departamento = "La Paz")
```

## Consulta básica con dplyr

``` r

# Distribución por sexo en el censo 2012, Santa Cruz
get_personas_2012(departamento = "07") |>
  count(P24) |>   # P24 = sexo en 2012
  collect()

# Nivel educativo en el censo 2001, La Paz
get_personas_2001(departamento = "02") |>
  count(P39NIV) |>   # P39NIV = nivel de instrucción en 2001
  collect()
```

## Codebook para censos históricos

Cada censo tiene su propio diccionario. Usa `codebook(anio = ...)` o las
funciones cortas:

``` r

# Ver todas las variables del censo 2012
codebook_2012()

# Buscar variables relacionadas con educación en 1992
codebook_1992(buscar = "instruccion")

# Variable específica en 2001
codebook(variable = "P39NIV", anio = 2001)

# Ver los códigos de una variable categórica
codebook_valores("P24", anio = 2012)   # sexo en 2012
codebook_valores("p02", anio = 1976)   # sexo en 1976
```

## Consulta SQL con DuckDB

``` r

library(DBI)

# Censo 2012 con DuckDB
con <- get_censo(2012, "persona", departamento = "07", as = "duckdb")

DBI::dbGetQuery(con, "
  SELECT P24 AS sexo, COUNT(*) AS total,
         ROUND(AVG(P25) * 1.0, 1) AS edad_prom
  FROM persona
  GROUP BY P24
  ORDER BY P24
")
#>   sexo   total edad_prom
#> 1    1 1311573      26.1
#> 2    2 1346189      25.9

DBI::dbDisconnect(con)
```

## Selección de variables

``` r

# Solo las variables que necesitas (más rápido)
get_personas_2012(
  departamento = "07",
  variables    = c("P24", "P25", "P37A_NIVELNUE")
)

# Censo 2001: solo sexo, edad y nivel educativo
get_censo(2001, "persona",
  variables = c("P28", "P29", "P39NIV")
)
```

## Comparación entre dos censos (mismo año de referencia)

``` r

# Distribución de sexo en 2012 y 2024 para Santa Cruz
dep_sc <- "07"

sexo_2012 <- get_personas_2012(departamento = dep_sc) |>
  count(sexo = P24) |>
  collect() |>
  mutate(anio = 2012L)

sexo_2024 <- get_personas_2024(departamento = dep_sc) |>
  count(sexo = p25_sexo) |>
  collect() |>
  mutate(anio = 2024L)

bind_rows(sexo_2012, sexo_2024) |>
  arrange(anio, sexo)
```

Para comparaciones sistemáticas entre múltiples censos con variables
armonizadas, ver la viñeta **[Análisis
longitudinal](https://lab-tecnosocial.github.io/censosbo/articles/analisis-longitudinal.md)**.

## Tablas complementarias

Los censos 2012, 2001 y 1992 tienen tablas adicionales:

``` r

# Emigración internacional (2012)
get_emigracion_2012(departamento = "07")

# Discapacidad (2012)
get_discapacidad_2012()

# Mortalidad (1992)
get_mortalidad_1992(departamento = "02")

# Comunidades (2001)
get_censo(2001, "comunidades_poblacion")
get_censo(2001, "comunidades_vivienda")
```

## Citar los censos

``` r

# CPV-2024
citation("censosbo")
#> To cite package 'censosbo' in publications use:
#> 
#>   Ojeda Copa A (2026). _censosbo: Acceso y Análisis de los Datos de los
#>   Censos de Bolivia_. R package version 0.3.0,
#>   <https://lab-tecnosocial.github.io/censosbo/>.
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Manual{,
#>     title = {censosbo: Acceso y Análisis de los Datos de los Censos de Bolivia},
#>     author = {Alex {Ojeda Copa}},
#>     year = {2026},
#>     note = {R package version 0.3.0},
#>     url = {https://lab-tecnosocial.github.io/censosbo/},
#>   }
```

Para los censos históricos, citar también las fuentes del INE Bolivia:

- INE Bolivia (1977). *Resultados del Censo Nacional de Población y
  Vivienda 1976*. La Paz: INE.
- INE Bolivia (1993). *Resultados del Censo Nacional de Población y
  Vivienda 1992*. La Paz: INE.
- INE Bolivia (2002). *Resultados del Censo Nacional de Población y
  Vivienda 2001*. La Paz: INE.
- INE Bolivia (2013). *Resultados del Censo Nacional de Población y
  Vivienda 2012*. La Paz: INE.

# Censos históricos de Bolivia (1976–2012)

`censosbo` incluye microdatos de los cuatro censos bolivianos anteriores
al CPV-2024: **1976, 1992, 2001 y 2012**. Los datos se descargan bajo
demanda desde GitHub Releases y se almacenan en el mismo caché local que
los datos del 2024.

## Tablas disponibles por año

| Año | Tablas | Filas | Columnas geográficas |
|----|----|---:|----|
| 1976 | `poblacion` (alias: `persona`), `vivienda` | ~4.6M | `idep`, `iprov` (string `"01"`–`"09"`) |
| 1992 | `persona`, `vivienda`, `mortalidad` | ~6.4M | `idep`, `iprov`, `imun` |
| 2001 | `persona`, `vivienda` | ~8.3M | `idep`, `iprov`, `imun` |
| 2012 | `persona`, `vivienda`, `emigracion`, `discapacidad` | ~10M | `idep`, `iprov`, `imun` |

Todas las tablas traen las columnas geográficas armonizadas
`idep`/`iprov`/`imun` (mismo formato que el CPV-2024), por lo que se
puede filtrar por geografía directamente, sin reconstruir la jerarquía
REDATAM ni hacer joins.

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

# Por municipio (1992, 2001, 2012 — no disponible en 1976).
# El código de municipio se repite entre provincias, así que por código hay que
# indicar también la provincia; por nombre no hace falta.
get_personas_2012(municipio = "Cotoca")
get_personas_2012(departamento = "07", provincia = "01", municipio = "01")
```

Hay dos situaciones distintas cuando un municipio no aparece:

- Si **no está en el catálogo geográfico** del paquete, es un error
  inmediato, antes de descargar nada.
- Si **está en el catálogo pero no tiene registros en ese censo**, se
  emite una advertencia y se retorna `NULL`.

``` r

# "100" no es un código de municipio válido — error con sugerencia
get_personas_1992(municipio = "100")
```

> **Nota:** El número de municipios cambió entre censos (1992: 339,
> 2001: 343, 2012: 339, 2024: 344). Un código válido en un año puede no
> existir en otro.

## Censo 1976: estructura diferente

El censo de 1976 no usa REDATAM. Conserva sus columnas originales y
además expone las armonizadas `idep`/`iprov` (string `"01"`–`"09"`, como
el resto):

- `idep` / `iprov` — departamento y provincia armonizados (recomendadas)
- `dep` — código de departamento original (1–9, entero)
- `pro` — código de provincia original
- `can` — código de cantón (1976 no tuvo municipios comparables → no hay
  `imun`; el filtro `municipio` se aplica sobre el cantón)

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
codebook_1992(buscar = "nivel")

# Variable específica en 2001
codebook(variable = "P39NIV", anio = 2001)

# Ver los códigos de una variable categórica
codebook_valores("P24", anio = 2012)   # sexo en 2012
codebook_valores("p02", anio = 1976)   # sexo en 1976
```

## Etiquetado de resultados

[`etiquetar_valores()`](https://lab-tecnosocial.github.io/censosbo/reference/etiquetar_valores.md)
y
[`etiquetar_variables()`](https://lab-tecnosocial.github.io/censosbo/reference/etiquetar_variables.md)
detectan automáticamente el censo a partir de los nombres de columna,
por lo que funcionan igual para datos históricos que para el CPV-2024:

``` r

# 1992: detección automática por el nombre de columna "P03"
get_personas_1992(departamento = "07") |>
  count(P03) |>
  collect() |>
  etiquetar_valores() |>
  etiquetar_variables()
#> # A tibble: 2 × 2
#>   `Es hombre o mujer`       n
#>   <fct>                 <int>
#> 1 Hombre               686978
#> 2 Mujer                677411

# 2012: estado civil
get_personas_2012(departamento = "02") |>
  count(P45) |>
  collect() |>
  etiquetar_valores() |>
  etiquetar_variables()

# 1976: idioma que habla
get_poblacion_1976(departamento = "03") |>
  count(p09) |>
  collect() |>
  etiquetar_valores() |>
  etiquetar_variables()
```

Si el data frame tiene muy pocas columnas o solo columnas genéricas,
puedes especificar el año con el argumento `anio`:

``` r

df |> etiquetar_valores(anio = 1992)
df |> etiquetar_variables(anio = 2001)
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
# Cuando se especifica departamento, idep/iprov/imun se agregan automáticamente
get_personas_2012(
  departamento = "07",
  variables    = c("P24", "P25", "P37A_NIVELNUE")
)
#> # idep  iprov  imun  P24  P25  P37A_NIVELNUE

# Censo 2001: solo sexo, edad y nivel educativo
# Sin departamento no se agregan columnas geográficas
get_censo(2001, "persona",
  variables = c("P28", "P29", "P39NIV")
)
#> # P28  P29  P39NIV   (sin idep/iprov/imun)

# Con departamento sí se incluyen las columnas geográficas
get_censo(2001, "persona",
  departamento = "La Paz",
  variables    = c("P28", "P29", "P39NIV")
)
#> # idep  iprov  imun  P28  P29  P39NIV
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
temporal](https://lab-tecnosocial.github.io/censosbo/articles/analisis-temporal.md)**.

## Tablas complementarias

Los censos 2012, 2001 y 1992 tienen tablas adicionales:

``` r

# Emigración internacional (2012)
get_emigracion_2012(departamento = "07")

# Discapacidad (2012)
get_discapacidad_2012()

# Mortalidad (1992)
get_mortalidad_1992(departamento = "02")

# Emigración y discapacidad (2012)
get_emigracion_2012(departamento = "07")
get_discapacidad_2012(departamento = "07")
```

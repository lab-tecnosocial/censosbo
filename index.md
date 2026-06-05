# censosbo

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

| Función | Registros | Variables | En disco (Parquet) | En memoria (tibble) |
|----|---:|---:|---:|---:|
| [`get_personas()`](https://lab-tecnosocial.github.io/censosbo/reference/get_personas.md) | ~11.4M | 118 | 7–155 MB/dep. (560 MB total) | 60 MB–1.2 GB/dep. |
| [`get_viviendas()`](https://lab-tecnosocial.github.io/censosbo/reference/get_viviendas.md) | ~4.5M | 48 | ~100 MB | ~700 MB |
| [`get_emigracion()`](https://lab-tecnosocial.github.io/censosbo/reference/get_emigracion.md) | ~501K | 8 | ~5 MB | ~40 MB |
| [`get_mortalidad()`](https://lab-tecnosocial.github.io/censosbo/reference/get_mortalidad.md) | ~383K | 10 | ~4 MB | ~30 MB |

El formato **Arrow** (por defecto) mantiene los datos en el disco hasta
que ejecutas
[`collect()`](https://dplyr.tidyverse.org/reference/compute.html). Las
tablas se pueden unir por la clave `idep + iprov + imun + i00`
(identificador de hogar).

## Diccionario de variables

El paquete incluye un diccionario con las 168 variables del CPV-2024 y
sus etiquetas en español:

``` r

library(censosbo)

# Buscar variables relacionadas con educación
codebook(buscar = "educa")
#> # A tibble: 6 × 4
#>   variable  etiqueta                             tabla   tipo
#>   <chr>     <chr>                                <chr>   <chr>
#> 1 nivel_edu Nivel educativo alcanzado agrupado…  persona categorica
#> 2 p39_grado Grado o curso más alto aprobado      persona numerica
#> ...
```

``` r

# Ver los códigos de una variable categórica
codebook_valores("p25_sexo")
#>   codigo etiqueta
#> 1      1    Mujer
#> 2      2   Hombre
```

## Etiquetas en los resultados

Los resultados muestran códigos numéricos por defecto. Usa
[`etiquetar_valores()`](https://lab-tecnosocial.github.io/censosbo/reference/etiquetar_valores.md)
para convertirlos a texto y
[`etiquetar_variables()`](https://lab-tecnosocial.github.io/censosbo/reference/etiquetar_variables.md)
para renombrar las columnas con sus descripciones:

``` r

library(dplyr)

# Contar por sexo con etiquetas de valores
get_personas(departamento = "Santa Cruz") |>
  count(p25_sexo) |>
  collect() |>
  etiquetar_valores()
#> # A tibble: 2 × 2
#>   p25_sexo       n
#>   <fct>      <int>
#> 1 Mujer    1234567
#> 2 Hombre   1212345

# También renombrar las columnas con sus descripciones del INE
get_personas(departamento = "Santa Cruz") |>
  count(p25_sexo, nivel_edu) |>
  collect() |>
  etiquetar_valores() |>
  etiquetar_variables()
#> # A tibble: 8 × 3
#>   `25. Es mujer u hombre` `Nivel educativo alcanzado...`      n
```

## Uso rápido

``` r

# Grupos quinquenales de edad por sexo
# Nota: usar %/% en lugar de cut() — cut() no es compatible con Arrow
get_personas(departamento = "Santa Cruz") |>
  filter(!is.na(p26_edad), !is.na(p25_sexo)) |>
  mutate(grupo_edad = (p26_edad %/% 5L) * 5L) |>
  count(grupo_edad, p25_sexo) |>
  collect() |>
  etiquetar_valores()
```

``` r

# Ver departamentos disponibles
departamentos()

# Provincias de La Paz
provincias("La Paz")

# Municipios de Santa Cruz
municipios(departamento = "Santa Cruz") |> head(5)
```

``` r

# Consulta SQL con DuckDB
library(DBI)
con <- get_personas(departamento = "Santa Cruz", as = "duckdb")
DBI::dbGetQuery(con, "
  SELECT p25_sexo, COUNT(*) AS total, ROUND(AVG(p26_edad), 1) AS edad_prom
  FROM personas
  GROUP BY p25_sexo
  ORDER BY p25_sexo
") |> etiquetar_valores()
DBI::dbDisconnect(con)
```

``` r

# Join personas + viviendas (Cochabamba)
con <- DBI::dbConnect(duckdb::duckdb())
duckdb::duckdb_register_arrow(con, "p", get_personas(departamento = "Cochabamba"))
duckdb::duckdb_register_arrow(con, "v", get_viviendas(departamento = "Cochabamba"))

DBI::dbGetQuery(con, "
  SELECT v.urbrur AS area, COUNT(*) AS personas
  FROM p JOIN v ON p.idep=v.idep AND p.iprov=v.iprov
                AND p.imun=v.imun AND p.i00=v.i00
  GROUP BY area
  ORDER BY personas DESC
") |> etiquetar_valores()
DBI::dbDisconnect(con)
```

## Gestión del caché

Los datos se descargan una sola vez y se guardan localmente. Para
guardar el caché dentro del proyecto en lugar del directorio del
sistema:

``` r

# Añadir a .Rprofile o al inicio del script
options(censosbo.cache_dir = "data/censosbo")

censosbo_cache_dir()    # dónde está el caché
censosbo_cache_info()   # qué archivos están descargados
censosbo_cache_clear()  # liberar espacio en disco
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

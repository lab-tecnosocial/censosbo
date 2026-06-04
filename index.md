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

El formato **Arrow** (por defecto) nunca carga todo en RAM: los datos
permanecen en el archivo Parquet del disco hasta que ejecutas
[`collect()`](https://dplyr.tidyverse.org/reference/compute.html).

Todas las tablas se pueden unir por la clave `idep + iprov + imun + i00`
(identificador de hogar).

## Uso rápido

``` r

library(censosbo)
library(dplyr)

# Datos de Santa Cruz como Arrow Dataset (lazy, sin cargar todo en RAM)
personas_sc <- get_personas(departamento = "Santa Cruz")

# Distribución por sexo con etiquetas legibles
personas_sc |>
  count(p25_sexo) |>
  collect() |>
  etiquetar()
# p25_sexo ahora muestra "Mujer" / "Hombre" en lugar de 1 / 2
```

``` r

# Grupos quinquenales de edad
# Nota: usar (edad %/% 5) * 5 en lugar de cut() — cut() no es compatible con Arrow
personas_sc |>
  filter(!is.na(p26_edad), !is.na(p25_sexo)) |>
  mutate(grupo_edad = (p26_edad %/% 5L) * 5L) |>
  count(grupo_edad, p25_sexo) |>
  collect() |>
  etiquetar()
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

# Consulta SQL con DuckDB — aplicar etiquetar() al resultado
library(DBI)
con <- get_personas(departamento = "Santa Cruz", as = "duckdb")
DBI::dbGetQuery(con, "
  SELECT p25_sexo, COUNT(*) AS total, ROUND(AVG(p26_edad), 1) AS edad_prom
  FROM personas
  GROUP BY p25_sexo
  ORDER BY p25_sexo
") |> etiquetar()
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
") |> etiquetar()
DBI::dbDisconnect(con)
```

## Diccionario de variables y etiquetas

``` r

# Buscar variables relacionadas con educación
codebook(buscar = "educa")

# Ver los códigos y etiquetas de una variable categórica
codebook_valores("p25_sexo")

# Aplicar etiquetas a un resultado
sample_personas |>
  count(p25_sexo, nivel_edu) |>
  etiquetar()
```

## Gestión del caché

Los datos se descargan una sola vez y se guardan localmente. Por defecto
van al directorio del sistema; para guardar dentro del proyecto actual
añade esto al inicio del script:

``` r

# Guardar caché dentro del proyecto (añadir a .Rprofile o al inicio del script)
options(censosbo.cache_dir = "data/censosbo")

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

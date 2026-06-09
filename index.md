# censosbo

**censosbo** proporciona acceso programático a los microdatos de los
**censos de población de Bolivia**: 1976, 1992, 2001, 2012 y 2024. Los
datos se descargan bajo demanda desde GitHub Releases, se guardan en
caché local y se pueden consultar con `dplyr`, Apache Arrow o DuckDB.

## Instalación

``` r

# install.packages("remotes")
remotes::install_github("lab-tecnosocial/censosbo")
```

## Censos disponibles

| Año | Función | Registros | Variables | Disco (Parquet) | RAM (aprox.)¹ |
|:--:|----|---:|---:|---:|---:|
| **1976** | [`get_poblacion_1976()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md) | 4,613,419 | 46 | 63 MB | 83 MB |
| **1976** | [`get_viviendas_1976()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md) | 1,158,482 | 28 | 7 MB | 9 MB |
| **1992** | [`get_personas_1992()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md) | 6,420,792 | 54 | 135 MB | 238 MB |
| **1992** | [`get_viviendas_1992()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md) | 1,706,107 | 44 | 29 MB | 43 MB |
| **2001** | [`get_personas_2001()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md) | 8,274,325 | 66 | 136 MB | 316 MB |
| **2001** | [`get_viviendas_2001()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md) | 2,290,414 | 39 | 20 MB | 37 MB |
| **2012** | [`get_personas_2012()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md) | 10,059,856 | 33 | 146 MB | 279 MB |
| **2012** | [`get_viviendas_2012()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md) | 3,172,321 | 32 | 38 MB | 58 MB |
| **2012** | [`get_emigracion_2012()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md) | 489,559 | 6 | 5 MB | 11 MB |
| **2024**² | [`get_personas_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/get_personas_2024.md) | 11,365,333 | 118 | 283 MB | ~490 MB |
| **2024**² | [`get_viviendas_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/get_viviendas_2024.md) | 4,490,488 | 48 | 55 MB | ~111 MB |
| **2024**² | [`get_emigracion_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/get_emigracion_2024.md) | 500,914 | 8 | 2 MB | ~7 MB |

¹ Tamaño al cargar la tabla completa con
[`collect()`](https://dplyr.tidyverse.org/reference/compute.html) sin
filtros, medido desde metadatos Parquet. ² Persona 2024 está
particionada en 9 archivos por departamento (4–77 MB cada uno). Disco y
RAM muestran el total; en la práctica se descarga solo el/los
departamentos necesarios.

El formato **Arrow** (por defecto) mantiene los datos en el disco hasta
que ejecutas
[`collect()`](https://dplyr.tidyverse.org/reference/compute.html). Las
tablas del CPV-2024 se pueden unir por la clave
`idep + iprov + imun + i00` (identificador de hogar).

## Uso rápido — CPV-2024

``` r

library(tidyverse)
library(censosbo)

# Grupos quinquenales de edad por sexo, Santa Cruz
get_personas_2024(departamento = "Santa Cruz") |>
  filter(!is.na(p26_edad), !is.na(p25_sexo)) |>
  mutate(grupo_edad = (p26_edad %/% 5) * 5) |>
  count(grupo_edad, p25_sexo) |>
  collect() |>
  etiquetar_valores()
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

## Censos históricos

``` r

# Personas de Santa Cruz en el censo 2012
get_personas_2012(departamento = "Santa Cruz")

# API genérica — equivalente
get_censo(2012, "persona", departamento = "07")

# Censo 1976 
get_poblacion_1976(departamento = "Cochabamba") 
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

## Geografía y mapas

``` r

departamentos()
provincias("La Paz")
municipios(departamento = "Santa Cruz") |> head(5)
```

El paquete incluye geometrías sf para los 9 departamentos
(`geo_departamentos`) y 336 municipios (`geo_municipios`) de Bolivia.
Las funciones
[`mapa_dep()`](https://lab-tecnosocial.github.io/censosbo/reference/mapa_dep.md)
y
[`mapa_mun()`](https://lab-tecnosocial.github.io/censosbo/reference/mapa_mun.md)
generan mapas coropléticos a partir de cualquier agregación de datos del
censo.

``` r

library(dplyr)

# mapa_dep(): nivel departamental — geometrías incluidas en el paquete
n_mun <- geo_bolivia |>
  count(idep, name = "n_municipios")
mapa_dep(n_mun, "n_municipios", titulo = "Municipios por departamento")

# mapa_mun(): nivel municipal — geometrías incluidas en el paquete
personas_beni <- get_personas_2024(departamento = "Beni", variables = "p26_edad") |>
  group_by(idep, iprov, imun) |>
  summarise(edad_prom = mean(p26_edad, na.rm = TRUE), .groups = "drop") |>
  collect()
mapa_mun(personas_beni, "edad_prom", departamento = "Beni",
         titulo = "Edad promedio por municipio — Beni (CPV-2024)")
```

## Gestión del caché

``` r

censosbo_cache_dir()    # dónde está el caché
censosbo_cache_info()   # qué archivos están descargados
censosbo_cache_clear()  # liberar espacio en disco
```

## Fuentes de datos

Los microdatos originales fueron publicados por el **Instituto Nacional
de Estadística (INE) de Bolivia**:

- **CPV-2024**:
  <https://cpv2024.ine.gob.bo/index.php/principal/descargas/>
- **Censos históricos 1976–2012**:
  <https://www.ine.gob.bo/index.php/censos-y-banco-de-datos/censos/>

### Nota metodológica

Los archivos originales fueron transformados a formato **Parquet**
(compresión zstd nivel 6) para distribución eficiente. El proceso de
conversión varía por censo:

| Censo | Formato original | Herramienta de conversión |
|----|----|----|
| 1976 | SPSS (`.sav`) | `pyreadstat` + `pyarrow` |
| 1992 | REDATAM (`.dic` binario + `.rbf`) | `open-redatam` CLI → CSV → Parquet |
| 2001 | REDATAM (`.wxp` → `.dicX`) | conversión `.wxp`→`.dicX` + `open-redatam` → CSV → Parquet |
| 2012 | REDATAM (`.dic` binario + `.ptr`) | `open-redatam` CLI → CSV → Parquet |
| 2024 | CSV delimitado por `;` (~3.6 GB total) | `pandas` + `pyarrow`; persona particionada por departamento |

El formato Parquet conserva todos los registros y variables originales
sin modificación de valores.

## Citar

``` r

citation("censosbo")
```

> Ojeda Copa, A. (2026). *censosbo: Acceso y análisis de los censos de
> Bolivia (1976–2024)*. R package version 1.0.0.
> <https://github.com/lab-tecnosocial/censosbo>

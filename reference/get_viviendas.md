# Accede a los microdatos de viviendas del CPV-2024

Descarga y/o carga desde caché los datos de viviendas del Censo de
Población y Vivienda 2024 de Bolivia, con filtros geográficos
opcionales.

## Usage

``` r
get_viviendas(
  departamento = NULL,
  provincia = NULL,
  municipio = NULL,
  variables = NULL,
  as = c("arrow", "tibble", "duckdb"),
  overwrite = FALSE,
  verbose = TRUE
)
```

## Arguments

- departamento:

  Vector de caracteres. Código(s) de departamento (\`"01"\`-\`"09"\`) o
  nombre(s) (e.g., \`"La Paz"\`, \`"Santa Cruz"\`). Si \`NULL\`, incluye
  todos los departamentos (descarga ~500 MB).

- provincia:

  Vector de caracteres. Código(s) de provincia. Si \`NULL\`, incluye
  todas.

- municipio:

  Vector de caracteres. Código(s) de municipio. Si \`NULL\`, incluye
  todos.

- variables:

  Vector de caracteres. Nombres de columnas a seleccionar. Si \`NULL\`,
  devuelve todas (118 columnas). Las columnas geográficas (\`idep\`,
  \`iprov\`, \`imun\`, \`i00\`) siempre se incluyen.

- as:

  Formato de retorno: \`"arrow"\` (por defecto), \`"tibble"\` o
  \`"duckdb"\` (tabla \`"viviendas"\`).

- overwrite:

  Lógico. Si \`TRUE\`, re-descarga aunque exista en caché.

- verbose:

  Lógico. Mostrar mensajes de progreso. Por defecto \`TRUE\`.

## Value

Ver \[get_personas()\].

## Details

La tabla de viviendas contiene 48 variables para ~4.5 millones de
viviendas particulares y colectivas. Se puede unir con
\[get_personas()\] usando la clave \`idep + iprov + imun + i00\`.

## Examples

``` r
if (FALSE) { # \dontrun{
# Viviendas de Cochabamba
get_viviendas(departamento = "Cochabamba")

# Condiciones de servicios básicos en Oruro
library(dplyr)
get_viviendas(departamento = "04", variables = c("urbrur", "v07_aguapro", "v09_energia")) |>
  count(urbrur, v07_aguapro) |>
  collect()
} # }
```

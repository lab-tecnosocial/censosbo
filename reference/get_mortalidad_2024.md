# Accede a los microdatos de mortalidad del CPV-2024

Descarga y/o carga desde caché los datos de mortalidad del Censo de
Población y Vivienda 2024 de Bolivia.

## Usage

``` r
get_mortalidad_2024(
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
  \`"duckdb"\` (tabla \`"mortalidad"\`).

- overwrite:

  Lógico. Si \`TRUE\`, re-descarga aunque exista en caché.

- verbose:

  Lógico. Mostrar mensajes de progreso. Por defecto \`TRUE\`.

## Value

Ver \[get_personas_2024()\].

## Details

Registra los fallecimientos ocurridos en el hogar durante los últimos 12
meses. Variables principales: mes y año de fallecimiento, edad, causa
COVID-19 (\`m214_cov\`), sexo y si fue parto (\`m216_parto\`).

Para mortalidad del censo 1992 usa \[get_mortalidad_1992()\] o
\`get_censo(1992, "mortalidad")\`.

## Examples

``` r
if (FALSE) { # \dontrun{
# Fallecimientos por departamento
library(dplyr)
get_mortalidad_2024() |>
  count(idep) |>
  collect()
} # }
```

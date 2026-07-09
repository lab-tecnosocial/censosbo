# Accede a los microdatos de emigración internacional del CPV-2024

Descarga y/o carga desde caché los datos de emigración internacional del
Censo de Población y Vivienda 2024 de Bolivia.

## Usage

``` r
get_emigracion_2024(
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
  todos los departamentos (descarga ~282 MB).

- provincia:

  Vector de caracteres. Código(s) (\`"01"\`) o nombre(s) (\`"Cercado"\`)
  de provincia. Si \`NULL\`, incluye todas. Los valores no existentes
  producen un error (en vez de un resultado vacío silencioso).

- municipio:

  Vector de caracteres. Código(s) (\`"01"\`) o nombre(s)
  (\`"Cochabamba"\`) de municipio. Si \`NULL\`, incluye todos. Si se
  especifica \`provincia\`/\`municipio\` sin \`departamento\`, este se
  infiere del catálogo para no descargar todo el país. Un nombre
  repetido entre departamentos requiere indicar \`departamento\` para
  desambiguar.

- variables:

  Vector de caracteres. Nombres de columnas a seleccionar. Si \`NULL\`,
  devuelve todas (119 columnas). Las columnas geográficas (\`idep\`,
  \`iprov\`, \`imun\`, \`i00\`) siempre se incluyen.

- as:

  Formato de retorno: \`"arrow"\` (por defecto), \`"tibble"\` o
  \`"duckdb"\` (tabla \`"emigracion"\`).

- overwrite:

  Lógico. Si \`TRUE\`, re-descarga aunque exista en caché.

- verbose:

  Lógico. Mostrar mensajes de progreso. Por defecto \`TRUE\`.

## Value

Ver \[get_personas_2024()\].

## Details

Registra los miembros del hogar que emigraron al exterior en los últimos
5 años. Variables principales: sexo, año de salida, edad al salir y país
de destino (\`pais_destino_cod\`).

Para emigración del censo 2012 usa \[get_emigracion_2012()\] o
\`get_censo(2012, "emigracion")\`.

## Examples

``` r
if (FALSE) { # \dontrun{
# Emigración por país de destino
library(dplyr)
get_emigracion_2024() |>
  count(pais_destino_cod, sort = TRUE) |>
  collect()
} # }
```

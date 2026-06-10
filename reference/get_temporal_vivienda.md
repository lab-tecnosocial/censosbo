# Obtiene datos temporales comparables de la tabla vivienda entre censos

Descarga y armoniza variables de vivienda de múltiples censos para
análisis de tendencias en condiciones habitacionales. El resultado tiene
una fila por vivienda y una columna \`anio\` que identifica el censo de
origen.

## Usage

``` r
get_temporal_vivienda(
  variables,
  anios = c(1976L, 1992L, 2001L, 2012L, 2024L),
  departamento = NULL,
  verbose = TRUE
)
```

## Arguments

- variables:

  Vector de caracteres. Nombres de variables armonizadas de vivienda.
  Usa \[variables_armonizadas(tabla = "vivienda")\] para ver las
  opciones disponibles.

- anios:

  Vector de enteros. Años de censo a incluir. Por defecto todos.

- departamento:

  Vector de caracteres. Código(s) de departamento (\`"01"\`-\`"09"\`).
  Si \`NULL\`, incluye todo el país.

- verbose:

  Lógico. Mostrar mensajes de progreso. Por defecto \`TRUE\`.

## Value

Un tibble con columnas \`anio\` + variables solicitadas. Una fila por
vivienda. Las variables no disponibles en un año aparecen como \`NA\`.

## Details

Variables disponibles para comparación temporal de vivienda:
\`material_paredes\`, \`material_techo\`, \`material_piso\`,
\`fuente_agua\`, \`energia_electrica\`, \`servicio_sanitario\`,
\`tenencia_vivienda\`, \`habitaciones_total\`.

\*\*Limitaciones conocidas:\*\* - \`habitaciones_total\` en 2024:
variable codificada como categorías ordinales (1=Una, ..., 8=Ocho o
más), no como número absoluto.

## Examples

``` r
if (FALSE) { # \dontrun{
# Evolución del acceso a agua potable
agua <- get_temporal_vivienda(
  variables = c("fuente_agua", "energia_electrica"),
  anios = c(1992, 2001, 2012, 2024)
)
library(dplyr)
agua |> count(anio, fuente_agua) |> group_by(anio) |>
  mutate(pct = n / sum(n))
} # }
```

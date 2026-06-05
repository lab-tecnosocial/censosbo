# Obtiene datos longitudinales comparables entre censos de Bolivia

Descarga y armoniza variables clave de múltiples censos para análisis de
tendencias y comparaciones históricas. El resultado es un data.frame en
formato largo ("tidy"), con una fila por individuo y una columna
\`anio\` que identifica el censo de origen.

## Usage

``` r
get_longitudinal(
  variables,
  anios = c(1976L, 1992L, 2001L, 2012L, 2024L),
  departamento = NULL,
  verbose = TRUE
)
```

## Arguments

- variables:

  Vector de caracteres. Nombres de variables armonizadas a incluir. Usa
  \[variables_armonizadas()\] para ver las opciones disponibles.

- anios:

  Vector de enteros. Años de censo a incluir (cualquier subconjunto de
  \`c(1976, 1992, 2001, 2012, 2024)\`). Por defecto todos.

- departamento:

  Vector de caracteres. Código(s) \`"01"\`-\`"09"\` o nombre(s) de
  departamento. Si \`NULL\`, incluye todo el país.

- verbose:

  Lógico. Mostrar mensajes de progreso. Por defecto \`TRUE\`.

## Value

Un tibble con columnas \`anio\`, seguida de las variables solicitadas.
Las columnas ausentes en un censo aparecen como \`NA\` con un aviso.

## Details

\*\*Variables con limitaciones conocidas:\*\* - \`area\` (urbano/rural):
no disponible en el censo 2001 ni en 2024 (está en la tabla de vivienda,
no de persona). Se incluye como \`NA\` con advertencia. - \`nivel_edu\`:
la Ley Avelino Siñani (2010) cambió la nomenclatura en 2012. Se armoniza
automáticamente a 4 categorías comparables. - \`grupo_edad\`: solo
disponible directamente en 1976; se calcula para el resto. - \`pea\`,
\`pet\`: no disponibles directamente en 1992 y 2001; se retornan como
\`NA\`.

\*\*Sobre municipios:\*\* El filtro geográfico en \`get_longitudinal()\`
opera a nivel de departamento para garantizar comparabilidad. El número
de municipios cambió entre censos (1992: 339, 2001: 343, 2012: 339,
2024: 344).

## Examples

``` r
if (FALSE) { # \dontrun{
# Serie temporal de sexo y edad para Santa Cruz
datos <- get_longitudinal(
  variables = c("sexo", "edad"),
  anios = c(1992, 2001, 2012, 2024),
  departamento = "07"
)
library(dplyr)
datos |> count(anio, sexo)

# Evolución del nivel educativo en todo el país
get_longitudinal(c("nivel_edu"), anios = c(1976, 1992, 2001, 2012, 2024))
} # }
```

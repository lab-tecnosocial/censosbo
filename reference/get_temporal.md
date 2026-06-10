# Obtiene datos temporales comparables de la tabla persona entre censos

Descarga y armoniza variables clave de múltiples censos para análisis de
tendencias y comparaciones históricas. El resultado es un data.frame en
formato largo ("tidy"), con una fila por individuo y una columna
\`anio\` que identifica el censo de origen.

## Usage

``` r
get_temporal(
  variables = NULL,
  grupo = NULL,
  anios = c(1976L, 1992L, 2001L, 2012L, 2024L),
  departamento = NULL,
  verbose = TRUE
)
```

## Arguments

- variables:

  Vector de caracteres. Nombres de variables armonizadas a incluir. Usa
  \[variables_armonizadas()\] para ver las opciones disponibles. Si se
  especifica \`grupo\`, este parámetro se ignora.

- grupo:

  Nombre de un grupo temático predefinido (ver \[grupos_variables()\]):
  \`"demografico"\`, \`"educacion"\`, \`"economia"\`, \`"cultural"\`,
  \`"migracion"\`, \`"fertilidad"\`. Si se especifica, \`variables\` se
  ignora.

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
\*\*Nota:\*\* \`area\` (1=Urbana, 2=Rural) y \`departamento\` (código
numérico) se incluyen siempre en el resultado, incluso si no fueron
solicitados. Son útiles para estratificar o filtrar los datos.

## Details

\*\*Variables con limitaciones conocidas:\*\* - \`nivel_edu\`: la Ley
Avelino Siñani (2010) cambió la nomenclatura en 2012. -
\`identidad_indigena\`, \`idioma_materno\`: NO disponibles en 1976 o
1992. - \`pea\`, \`pet\`: no disponibles en 2001. -
\`migracion_nac_dpto\`, \`migracion_rec_dpto\`: variables derivadas de
comparación de departamento de nacimiento/residencia con el actual.
Pueden contener NAs cuando la información de origen no fue registrada en
el censo. \*\*Atención:\*\* \`migracion_rec_dpto\` solo tiene los
códigos 1 (mismo dpto) y 2 (otro dpto) en 1992 y 2001. Los códigos 3
(exterior) y 4 (no había nacido) solo existen en 1976, 2012 y 2024.
Comparar distribuciones entre todos los años puede ser engañoso. -
\`idioma_materno\` en 1976: captura "idioma que habla", no el materno.

Para variables de vivienda usa \[get_temporal_vivienda()\].

## Examples

``` r
if (FALSE) { # \dontrun{
# Usando grupo temático
datos <- get_temporal(grupo = "educacion", anios = c(1992, 2001, 2012, 2024))
library(dplyr)
datos |> count(anio, asistencia_escolar)

# Evolución del nivel educativo en todo el país
get_temporal(variables = c("nivel_edu", "sexo"),
             anios = c(1976, 1992, 2001, 2012, 2024))

# Identidad cultural (solo 2001-2024)
get_temporal(grupo = "cultural", anios = c(2001, 2012, 2024))
} # }
```

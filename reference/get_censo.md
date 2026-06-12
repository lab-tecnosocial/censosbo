# Accede a los microdatos de los censos históricos de Bolivia

Descarga y/o carga desde caché los microdatos de los censos de población
de Bolivia de 1976, 1992, 2001 y 2012, con filtros geográficos
opcionales.

## Usage

``` r
get_poblacion_1976(
  departamento = NULL,
  provincia = NULL,
  municipio = NULL,
  variables = NULL,
  as = c("arrow", "tibble", "duckdb"),
  overwrite = FALSE,
  verbose = TRUE
)

get_viviendas_1976(
  departamento = NULL,
  provincia = NULL,
  municipio = NULL,
  variables = NULL,
  as = c("arrow", "tibble", "duckdb"),
  overwrite = FALSE,
  verbose = TRUE
)

get_personas_1992(
  departamento = NULL,
  provincia = NULL,
  municipio = NULL,
  variables = NULL,
  as = c("arrow", "tibble", "duckdb"),
  overwrite = FALSE,
  verbose = TRUE
)

get_viviendas_1992(
  departamento = NULL,
  provincia = NULL,
  municipio = NULL,
  variables = NULL,
  as = c("arrow", "tibble", "duckdb"),
  overwrite = FALSE,
  verbose = TRUE
)

get_mortalidad_1992(
  departamento = NULL,
  provincia = NULL,
  municipio = NULL,
  variables = NULL,
  as = c("arrow", "tibble", "duckdb"),
  overwrite = FALSE,
  verbose = TRUE
)

get_personas_2001(
  departamento = NULL,
  provincia = NULL,
  municipio = NULL,
  variables = NULL,
  as = c("arrow", "tibble", "duckdb"),
  overwrite = FALSE,
  verbose = TRUE
)

get_viviendas_2001(
  departamento = NULL,
  provincia = NULL,
  municipio = NULL,
  variables = NULL,
  as = c("arrow", "tibble", "duckdb"),
  overwrite = FALSE,
  verbose = TRUE
)

get_personas_2012(
  departamento = NULL,
  provincia = NULL,
  municipio = NULL,
  variables = NULL,
  as = c("arrow", "tibble", "duckdb"),
  overwrite = FALSE,
  verbose = TRUE
)

get_viviendas_2012(
  departamento = NULL,
  provincia = NULL,
  municipio = NULL,
  variables = NULL,
  as = c("arrow", "tibble", "duckdb"),
  overwrite = FALSE,
  verbose = TRUE
)

get_emigracion_2012(
  departamento = NULL,
  provincia = NULL,
  municipio = NULL,
  variables = NULL,
  as = c("arrow", "tibble", "duckdb"),
  overwrite = FALSE,
  verbose = TRUE
)

get_discapacidad_2012(
  departamento = NULL,
  provincia = NULL,
  municipio = NULL,
  variables = NULL,
  as = c("arrow", "tibble", "duckdb"),
  overwrite = FALSE,
  verbose = TRUE
)

get_censo(
  anio,
  tabla = "persona",
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

  Vector de caracteres. Código(s) \`"01"\`-\`"09"\` o nombre(s) del
  departamento. Si \`NULL\`, incluye todos.

- provincia:

  Vector de caracteres. Código(s) de provincia. Si \`NULL\`, incluye
  todas.

- municipio:

  Vector de caracteres. Código(s) de municipio. Si \`NULL\`, incluye
  todos. Si el municipio no existe en el año solicitado, se emite una
  advertencia y se retorna \`NULL\`.

- variables:

  Vector de caracteres. Nombres de columnas a seleccionar. Si \`NULL\`,
  devuelve todas las columnas.

- as:

  Formato de retorno: \`"arrow"\` (lazy, por defecto), \`"tibble"\` o
  \`"duckdb"\`.

- overwrite:

  Lógico. Si \`TRUE\`, re-descarga aunque exista en caché.

- verbose:

  Lógico. Mostrar mensajes de progreso. Por defecto \`TRUE\`.

- anio:

  Entero. Año del censo: \`1976\`, \`1992\`, \`2001\` o \`2012\`.

- tabla:

  Caracteres. Nombre de la tabla a consultar. Depende del año: -
  \*\*1976\*\*: \`"poblacion"\` (o \`"persona"\` como alias),
  \`"vivienda"\` - \*\*1992\*\*: \`"persona"\`, \`"vivienda"\`,
  \`"mortalidad"\` - \*\*2001\*\*: \`"persona"\`, \`"vivienda"\` -
  \*\*2012\*\*: \`"persona"\`, \`"vivienda"\`, \`"emigracion"\`,
  \`"discapacidad"\`

## Value

Según \`as\`: - \`"arrow"\`: un \`arrow::Dataset\` o \`arrow::Table\`
(lazy cuando no hay filtros geo) - \`"tibble"\`: un \`data.frame\` con
los datos en RAM - \`"duckdb"\`: una conexión \`DBI\` con la tabla
registrada; cierra con \`DBI::dbDisconnect(con)\`.

## Details

Todas las tablas exponen los códigos geográficos armonizados como
columnas directas: \`idep\`, \`iprov\` e \`imun\` (2 dígitos,
consistentes con el CPV-2024). Esto permite filtrar por geografía sin
reconstruir la jerarquía REDATAM (antes requería un join \`persona →
vivienda → municipio\`). El filtrado se hace directamente sobre estas
columnas, igual que en el CPV-2024.

El censo 1976 no tuvo municipios comparables (usó cantones), por lo que
solo expone \`idep\` e \`iprov\`; el filtro de \`municipio\` se aplica
sobre el cantón.

## Advertencia sobre municipios

El número de municipios cambió entre censos. Un código de municipio
válido en 2012 puede no existir en 1992. En ese caso se emite una
advertencia y se retorna \`NULL\` sin error.

## Examples

``` r
if (FALSE) { # \dontrun{
# Personas de Santa Cruz en el censo 2012
get_censo(2012, "persona", departamento = "07")

# Viviendas del censo 1992 en La Paz
get_censo(1992, "vivienda", departamento = "La Paz")

# Todas las personas del censo 1976 (descarga completa ~63 MB)
get_censo(1976, "poblacion")

# Consulta SQL sobre censo 2001
con <- get_censo(2001, "persona", departamento = "03", as = "duckdb")
DBI::dbGetQuery(con, "SELECT P28, COUNT(*) AS n FROM persona GROUP BY P28")
DBI::dbDisconnect(con)
} # }
```

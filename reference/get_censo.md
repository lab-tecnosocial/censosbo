# Accede a los microdatos de cualquier censo de Bolivia

Descarga y/o carga desde caché los microdatos de los censos de población
de Bolivia de 1976, 1992, 2001, 2012 y 2024, con filtros geográficos
opcionales. Es la API genérica por año; para el CPV-2024 delega en
\[get_personas_2024()\] y sus funciones hermanas.

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
  universo = c("viviendas", "particulares", "colectivas", "todos"),
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
  universo = c("viviendas", "particulares", "colectivas", "todos"),
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
  universo = c("viviendas", "particulares", "colectivas", "todos"),
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
  universo = c("viviendas", "particulares", "colectivas", "todos"),
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
  universo = c("viviendas", "particulares", "colectivas", "todos"),
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

  Vector de caracteres. Código(s) o nombre(s) de provincia. En
  1992/2001/2012 acepta nombres (se resuelven contra el catálogo del
  CPV-2024). En \*\*1976\*\* solo acepta códigos numéricos (geografía
  cantonal distinta). Si \`NULL\`, incluye todas.

- municipio:

  Vector de caracteres. Código(s) o nombre(s) de municipio. En
  1992/2001/2012 acepta nombres; en \*\*1976\*\* solo códigos de cantón.
  Si \`NULL\`, incluye todos. Si el municipio no existe en el año
  solicitado, se emite una advertencia y se retorna \`NULL\`.

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

- universo:

  Solo para \`tabla = "vivienda"\`. Qué registros de la entidad
  devolver: \`"viviendas"\` (por defecto, el universo oficial del INE),
  \`"particulares"\`, \`"colectivas"\` o \`"todos"\` (la entidad cruda
  de REDATAM). Ver \[get_viviendas_2024()\] y \[tipos_vivienda()\].

- anio:

  Entero. Año del censo: \`1976\`, \`1992\`, \`2001\`, \`2012\` o
  \`2024\`.

- tabla:

  Caracteres. Nombre de la tabla a consultar. Depende del año: -
  \*\*1976\*\*: \`"poblacion"\` (o \`"persona"\` como alias),
  \`"vivienda"\` - \*\*1992\*\*: \`"persona"\`, \`"vivienda"\`,
  \`"mortalidad"\` - \*\*2001\*\*: \`"persona"\`, \`"vivienda"\` -
  \*\*2012\*\*: \`"persona"\`, \`"vivienda"\`, \`"emigracion"\`,
  \`"discapacidad"\` - \*\*2024\*\*: \`"persona"\`, \`"vivienda"\`,
  \`"emigracion"\`, \`"mortalidad"\`

## Value

Según \`as\`: - \`"arrow"\`: un \`arrow::Dataset\` o \`arrow::Table\`
(lazy cuando no hay filtros geo) - \`"tibble"\`: un \`data.frame\` con
los datos en RAM - \`"duckdb"\`: una conexión \`DBI\` con la tabla
registrada (con el nombre de \`tabla\`, p.ej. \`"persona"\`); cierra con
\`DBI::dbDisconnect(con, shutdown = TRUE)\`.

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

Con \`anio = 2024\` la llamada se redirige a \[get_personas_2024()\],
\[get_viviendas_2024()\], \[get_emigracion_2024()\] o
\[get_mortalidad_2024()\] según \`tabla\`, así que el resultado es
idéntico al de esas funciones — incluido el nombre con que se registra
la tabla en DuckDB (\`"personas"\`, \`"viviendas"\`, en plural, a
diferencia de los censos históricos).

## Advertencia sobre municipios

El número de municipios cambió entre censos. Un código de municipio
válido en 2012 puede no existir en 1992. En ese caso se emite una
advertencia y se retorna \`NULL\` sin error.

## El universo de vivienda

Con \`tabla = "vivienda"\`, todos los censos desde 1992 traen en la
entidad de REDATAM registros que \*\*no son viviendas\*\*: personas
censadas en la calle o en tránsito. El defecto \`universo =
"viviendas"\` los descuenta, que es cómo cuenta el INE. Los códigos
afectados de cada censo están en \[tipos_vivienda()\]:

\| Censo \| Variable \| Códigos que no son vivienda \| Registros \|
\|——:\|—————\|—————————————————-\|———-:\| \| 1976 \| \`v01\` \| (no se
preguntó) \| 0 \| \| 1992 \| \`V01\` \| 13 Ambulante \| 4.939 \| \| 2001
\| \`V04\` \| 24 Transeúntes \| 9.392 \| \| 2012 \| \`P01\` \| 7 En
tránsito, 8 Persona que vive en la calle \| 12.971 \| \| 2024 \|
\`v01_tipoviv\` \| 15 Persona vive en la calle, 16 En tránsito \| 10.287
\|

La reconciliación con los tabulados oficiales está comprobada para el
CPV-2024 (ver \[get_viviendas_2024()\]). Para los censos anteriores el
criterio es el mismo, tomado del diccionario de cada año.

## Examples

``` r
if (FALSE) { # \dontrun{
# Personas de Santa Cruz en el censo 2012
get_censo(2012, "persona", departamento = "07")

# Viviendas del censo 1992 en La Paz
get_censo(1992, "vivienda", departamento = "La Paz")

# La entidad cruda de vivienda del censo 2012, con calle y tránsito
get_censo(2012, "vivienda", universo = "todos")

# Todas las personas del censo 1976 (descarga completa ~46 MB)
get_censo(1976, "poblacion")

# El CPV-2024 también: equivale a get_personas_2024(departamento = "07")
get_censo(2024, "persona", departamento = "07")

# Consulta SQL sobre censo 2001
con <- get_censo(2001, "persona", departamento = "03", as = "duckdb")
DBI::dbGetQuery(con, "SELECT P28, COUNT(*) AS n FROM persona GROUP BY P28")
DBI::dbDisconnect(con, shutdown = TRUE)
} # }
```

# Accede a los microdatos de personas del CPV-2024

Descarga y/o carga desde caché los datos de personas del Censo de
Población y Vivienda 2024 de Bolivia, con filtros geográficos
opcionales.

## Usage

``` r
get_personas_2024(
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

  Formato de retorno: \`"arrow"\` (Dataset Arrow, por defecto — lazy, no
  carga en RAM), \`"tibble"\` (trae a memoria RAM; precaución con datos
  grandes), o \`"duckdb"\` (conexión DBI activa con tabla
  \`"personas"\`).

- overwrite:

  Lógico. Si \`TRUE\`, re-descarga aunque exista en caché.

- verbose:

  Lógico. Mostrar mensajes de progreso. Por defecto \`TRUE\`.

## Value

Según \`as\`: - \`"arrow"\`: un \`arrow::Dataset\` (lazy, soporta dplyr
y Arrow) - \`"tibble"\`: un \`data.frame\` con los datos en RAM -
\`"duckdb"\`: una conexión \`DBI\` con tabla \`"personas"\` registrada;
recuerda cerrarla con \`DBI::dbDisconnect(con)\`.

## Details

Los datos se descargan por departamento bajo demanda. Especificando
\`departamento = "07"\` solo se descarga \`persona_dep07.parquet\` (~155
MB). Sin especificar departamento se descargan los 9 archivos (~560 MB
en total).

El caché se almacena en \`censosbo_cache_dir()\`. Usa
\`censosbo_cache_info()\` para ver los archivos descargados.

Para censos históricos usa \[get_censo()\] o los atajos
\[get_personas_1992()\], \[get_personas_2001()\],
\[get_personas_2012()\].

## Examples

``` r
if (FALSE) { # \dontrun{
# Datos de Santa Cruz como Arrow Dataset (lazy)
personas_sc <- get_personas_2024(departamento = "Santa Cruz")

# Filtrar y agregar sin traer a RAM
library(dplyr)
get_personas_2024(departamento = "07") |>
  filter(p26_edad >= 18) |>
  count(p25_sexo) |>
  collect()

# Seleccionar pocas variables
get_personas_2024(
  departamento = c("02", "03"),
  variables = c("p25_sexo", "p26_edad", "nivel_edu")
)

# Consulta SQL con DuckDB
con <- get_personas_2024(departamento = "07", as = "duckdb")
DBI::dbGetQuery(con, "SELECT p25_sexo, AVG(p26_edad) FROM personas GROUP BY 1")
DBI::dbDisconnect(con)

# Equivalente genérico
get_censo(2024, "persona", departamento = "07")
} # }
```

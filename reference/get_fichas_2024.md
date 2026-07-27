# Accede a los indicadores del CPV-2024 por manzano y comunidad

Devuelve las 194 variables de la ficha resumen del INE para cada unidad
censal que la tenga disponible: población por edad y sexo, educación,
salud, migración, empleo, actividad económica, vivienda, servicios
básicos, TIC, materiales de construcción, hacinamiento y tipo de hogar.

## Usage

``` r
get_fichas_2024(
  departamento = NULL,
  provincia = NULL,
  municipio = NULL,
  area = NULL,
  variables = NULL,
  as = c("arrow", "tibble", "duckdb"),
  overwrite = FALSE,
  verbose = TRUE
)
```

## Source

Geoportal del INE Bolivia, \<https://geoportal.ine.gob.bo/\>.

## Arguments

- departamento:

  Nombre o código del departamento (e.g., \`"Cochabamba"\` o \`"03"\`).
  \`NULL\` (defecto) devuelve todo el país.

- provincia:

  Nombre o código de la provincia. Opcional.

- municipio:

  Nombre o código del municipio. Opcional.

- area:

  Filtra por tipo de unidad: \`"urbano"\` (manzanos) o \`"rural"\`
  (comunidades). \`NULL\` (defecto) devuelve ambas. La columna \`area\`
  se almacena con el mismo código que en los microdatos (1 = Urbana, 2 =
  Rural), así que también acepta \`1\` o \`2\`.

- variables:

  Vector de nombres de variables a devolver. Las columnas geográficas se
  conservan siempre. \`NULL\` (defecto) devuelve todas.

- as:

  Formato de retorno: \`"arrow"\` (por defecto), \`"tibble"\` o
  \`"duckdb"\` (tabla \`"fichas"\`).

- overwrite:

  Lógico. Si \`TRUE\`, re-descarga aunque exista en caché.

- verbose:

  Lógico. Mostrar progreso.

## Value

Ver \[get_unidades_2024()\].

## Details

Contiene 150.744 unidades: las que el INE libera (\`ficha == TRUE\` en
\[get_unidades_2024()\]). Para el universo completo, con población y
viviendas de todas las unidades, usa esa función.

Todas las variables son conteos de personas, viviendas u hogares. Cada
bloque temático trae su propio total, que sirve de denominador:

- \`pob\_\*\`:

  Población por grupo de edad y sexo. Total: \`pob_total\_\*\`.

- \`edu\_\*\`:

  Nivel de instrucción de la población de 19 o más años.

- \`salud_lugar\_\*\`:

  Dónde acude por problemas de salud. \*\*Respuesta múltiple\*\*: las
  categorías suman más que el total.

- \`salud_seguro\_\*\`:

  Registro al SUS o afiliación a seguros.

- \`nac\_\*\`, \`res\_\*\`:

  Lugar de nacimiento y residencia habitual.

- \`ocup\_\*\`, \`act\_\*\`:

  Categoría ocupacional y actividad económica de la población de 14 o
  más años.

- \`viv\_\*\`:

  Tipo, condición de ocupación y tenencia de la vivienda.

- \`serv\_\*\`:

  Energía eléctrica, agua, desagüe, combustible y basura.

- \`tic\_\*\`:

  Equipamiento del hogar. \*\*Respuesta múltiple\*\*.

- \`mat\_\*\`:

  Material de paredes, revoque, techo y piso.

- \`hac\_\*\`:

  Hacinamiento por dormitorio: sin, medio o alto.

- \`hogar\_\*\`:

  Tipología del hogar.

Los bloques \`mat\_\*\`, \`hac\_\*\` y \`hogar\_\*\` tienen como base
las viviendas particulares con personas presentes, es decir
\`viv_tipo_presentes\`.

Los sufijos \`\_h\` y \`\_m\` son hombres y mujeres; \`\_ns\` es "sin
especificar". Usa \`codebook(tabla = "ficha")\` para la lista completa
con sus etiquetas.

## Examples

``` r
if (FALSE) { # \dontrun{
# Acceso a agua por cañería en los manzanos de El Alto
library(dplyr)
get_fichas_2024(municipio = "El Alto", as = "tibble") |>
  mutate(pct_caneria = 100 * serv_agua_caneria / serv_agua_total) |>
  select(codigo, pct_caneria)

# Solo algunas variables, para no traer las 194
get_fichas_2024(departamento = "Oruro",
                variables = c("pob_total_h", "pob_total_m", "tic_internet"))
} # }
```

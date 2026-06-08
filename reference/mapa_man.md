# Visualiza una variable censal a nivel de manzano

Genera un mapa coroplético a nivel de manzano usando las geometrías del
Geoportal INE. Requiere especificar al menos un municipio para limitar
la carga de datos (el parquet cubre 247,000 manzanos en todo el país).

## Usage

``` r
mapa_man(
  datos,
  variable,
  municipio,
  departamento = NULL,
  titulo = NULL,
  etiqueta_fill = NULL,
  paleta = NULL,
  na_color = "grey80",
  mostrar_nombres = FALSE,
  overwrite = FALSE
)
```

## Arguments

- datos:

  Data.frame con al menos las columnas \`codigo\` (código único de
  manzano del INE, formato \`"XXXXXXXXXXX-X"\`) y \`variable\`.
  Típicamente datos del CPV-2024 agregados a nivel de manzano.

- variable:

  Nombre (caracter) de la columna a visualizar.

- municipio:

  Nombre o código XXYYZZ del municipio a mostrar. Acepta un vector para
  mostrar varios municipios a la vez.

- departamento:

  Nombre o código de departamento para resolver nombres de municipio
  ambiguos (que existen en más de un departamento).

- titulo:

  Título del mapa. Si \`NULL\`, genera \`"variable — municipio"\`.

- etiqueta_fill:

  Etiqueta de la leyenda. Si \`NULL\`, usa \`variable\`.

- paleta:

  Paleta de color. Por defecto \`"Blues"\` (continua) o \`"Set3"\`
  (categórica).

- na_color:

  Color para manzanos sin datos. Por defecto \`"grey80"\`.

- mostrar_nombres:

  Si \`TRUE\`, agrega etiquetas con el nombre del manzano (barrio/zona).
  Recomendado solo con pocos manzanos.

- overwrite:

  Si \`TRUE\`, re-descarga el parquet aunque exista en caché.

## Value

Un objeto \`ggplot\` modificable con capas adicionales de ggplot2.

## Details

Las geometrías provienen del Geoportal INE Bolivia (CPV-2024). El
parquet se descarga automáticamente desde GitHub Releases la primera vez
y se almacena en caché local (\[censosbo_cache_dir()\]).

La clave de unión entre \`datos\` y las geometrías es la columna
\`codigo\` del parquet INE (formato \`"XXXXXXXXXXX-X"\`).

## Examples

``` r
if (FALSE) { # \dontrun{
library(dplyr)
# Obtener códigos de manzano del parquet y crear datos de ejemplo
ruta <- censosbo_cache_dir() |> file.path("manzanos_ine.parquet")
codigos <- arrow::open_dataset(ruta) |>
  filter(codigo_municipio == 20101) |>
  collect() |>
  pull(codigo)
datos <- data.frame(codigo = codigos, valor = runif(length(codigos)))
mapa_man(datos, "valor", municipio = "La Paz",
         titulo = "Variable aleatoria por manzano - La Paz")
} # }
```

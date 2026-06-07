# Visualiza una variable censal a nivel departamental

Genera un mapa coroplético de Bolivia a nivel de departamento.

## Usage

``` r
mapa_dep(
  datos,
  variable,
  titulo = NULL,
  etiqueta_fill = NULL,
  paleta = NULL,
  na_color = "grey80",
  mostrar_nombres = FALSE
)
```

## Arguments

- datos:

  Data.frame con al menos las columnas \`idep\` y \`variable\`.
  Típicamente el resultado de una agregación con dplyr.

- variable:

  Nombre (caracter) de la columna a visualizar.

- titulo:

  Título del mapa. Si \`NULL\`, usa el nombre de la variable.

- etiqueta_fill:

  Etiqueta de la leyenda. Si \`NULL\`, usa \`variable\`.

- paleta:

  Paleta de color. Por defecto \`"Blues"\` (continua) o \`"Set3"\`
  (categórica).

- na_color:

  Color para departamentos sin datos. Por defecto \`"grey80"\`.

- mostrar_nombres:

  Si \`TRUE\`, agrega etiquetas con nombres de departamentos.

## Value

Un objeto \`ggplot\` modificable con capas adicionales de ggplot2.

## Details

Compatible con todos los censos (1976–2024): los 9 departamentos son
estables. Para el censo 1976, que usa la columna \`dep\` en lugar de
\`idep\`, primero convierte: \`datos\$idep \<- sprintf("

## Examples

``` r
if (FALSE) { # \dontrun{
library(dplyr)
pob <- get_personas_2024(as = "tibble") |>
  count(idep, name = "poblacion")
mapa_dep(pob, "poblacion", titulo = "Población por departamento (CPV-2024)")
} # }
```

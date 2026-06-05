# Muestra los valores codificados de una variable categórica

Muestra los valores codificados de una variable categórica

## Usage

``` r
codebook_valores(variable, anio = 2024)
```

## Arguments

- variable:

  Caracteres. Nombre de la variable (e.g., \`"p25_sexo"\`, \`"P23"\`).

- anio:

  Entero. Año del censo: \`2024\` (defecto), \`1976\`, \`1992\`,
  \`2001\` o \`2012\`.

## Value

Un data.frame con columnas \`codigo\` y \`etiqueta\`, o un mensaje si la
variable no tiene categorías.

## Examples

``` r
if (FALSE) { # \dontrun{
codebook_valores("p25_sexo")
codebook_valores("P23", anio = 2012)
} # }
```

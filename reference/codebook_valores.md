# Muestra los valores codificados de una variable categórica

Muestra los valores codificados de una variable categórica

## Usage

``` r
codebook_valores(variable)
```

## Arguments

- variable:

  Caracteres. Nombre de la variable (e.g., \`"p25_sexo"\`).

## Value

Un data.frame con columnas \`codigo\` y \`etiqueta\`, o un mensaje si la
variable no tiene categorías.

## Examples

``` r
if (FALSE) { # \dontrun{
codebook_valores("p25_sexo")
codebook_valores("nivel_edu")
} # }
```

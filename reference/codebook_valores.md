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
# Los diccionarios vienen dentro del paquete: esto no descarga nada.
codebook_valores("p25_sexo")
#>   codigo etiqueta
#> 1      1    Mujer
#> 2      2   Hombre
codebook_valores("P23", anio = 2012)
#> # A tibble: 13 × 2
#>    codigo etiqueta                            
#>  * <chr>  <chr>                               
#>  1 1      Jefa / Jefe                         
#>  2 10     Otro no pariente                    
#>  3 11     Persona en vivienda colectiva       
#>  4 12     Persona en tránsito                 
#>  5 13     Persona que vive en la calle        
#>  6 2      Esposa(o), Conviviente, Concubina(o)
#>  7 3      Hija(o)                             
#>  8 4      Nuera / Yerno                       
#>  9 5      Nieta(o)                            
#> 10 6      hermana(o) / Cuñanda(o)             
#> 11 7      Padre / Madre / Suegra(o)           
#> 12 8      Otro pariente                       
#> 13 9      Trabajador(a) del hogar             
```

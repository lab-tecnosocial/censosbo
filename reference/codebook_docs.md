# Definición, universo y pregunta literal de una variable

Accesor de \[codebook_docs_meta\]: los textos oficiales del INE sobre
una variable. Útil para resolver qué mide exactamente, a quién se le
preguntó, o cómo se construyó una variable derivada.

## Usage

``` r
codebook_docs(variable, tabla = NULL, campos = NULL, anio = 2024)
```

## Arguments

- variable:

  Caracteres. Nombre(s) de variable.

- tabla:

  Caracteres. Desambigua cuando la variable existe en varias tablas.

- campos:

  Caracteres. Devuelve solo estas columnas de documentación (e.g.
  \`"definicion"\`, \`"pregunta_literal"\`, \`"regla_derivacion"\`).

- anio:

  Entero. Censo o censos: \`2024\` (defecto), \`2012\`, \`2001\`. Acepta
  varios, que es la forma de comparar cómo cambió una definición entre
  censos.

## Value

Un data.frame con una fila por variable y año encontrados.

## See also

\[codebook()\] para las etiquetas y categorías, y \[codebook_valores()\]
para los códigos de una variable categórica.

## Examples

``` r
# ¿Qué mide exactamente y a quién se le preguntó?
codebook_docs("p40_lee", campos = c("definicion", "universo_literal"))
#>   anio variable   tabla
#> 1 2024  p40_lee persona
#>                                                                                                 definicion
#> 1 Esta pregunta se refiere a la capacidad que tiene una persona para leer y escribir, en cualquier idioma.
#>                              universo_literal
#> 1 Solo para personas de 5 años o más de edad.

# ¿Cómo construyó el INE esta variable derivada?
codebook_docs("nivel_edu", campos = "regla_derivacion")
#>   anio  variable   tabla
#> 1 2024 nivel_edu persona
#>                                                                                                                                                                                                                                                                                                                                                                           regla_derivacion
#> 1 Variable derivada a partir de la variable P41A_NIVEL_ACT), “Nivel educativo alcanzado: sistema actual”. Agrupa el nivel educativo alcanzado en las siguientes categorías: 1. Ninguno (categorías 1 al 3 de la variable P41A_NIVEL_ACT), 2. Primaria (categoría 7 de P41A_NIVEL_ACT), 3. Secundaria (categoría 8 de P41A_NIVEL_ACT) y 4. Superior (categorías 9 al 13 de P41A_NIVEL_ACT).
```

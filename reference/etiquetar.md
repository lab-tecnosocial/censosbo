# Aplica etiquetas a las variables categóricas de un data.frame

Convierte los códigos numéricos de las variables categóricas del
CPV-2024 en factores con las etiquetas en español del diccionario
oficial del INE. Se usa típicamente después de \`collect()\` para que
los resultados sean legibles directamente.

## Usage

``` r
etiquetar(df, variables = NULL)
```

## Arguments

- df:

  Un data.frame (resultado de \`collect()\`, \`DBI::dbGetQuery()\` u
  otro).

- variables:

  Vector de caracteres con los nombres de columnas a etiquetar. Si
  \`NULL\` (por defecto), etiqueta todas las columnas categóricas
  presentes.

## Value

El mismo \`df\` con las columnas categóricas convertidas a \`factor\`
ordenado con las etiquetas del diccionario. Las columnas no encontradas
en el diccionario se devuelven sin cambios.

## Details

Los valores que no coinciden con ningún código del diccionario
(incluyendo \`NA\`) se convierten en \`NA\` en el factor resultante.
Para ver los códigos disponibles de una variable usa
\`codebook_valores()\`.

Para cambiar entre etiquetas y códigos sobre un factor ya etiquetado:
“\`r \# Etiquetas → códigos numéricos as.integer(df\$p25_sexo)

\# Etiquetas → cadenas de texto sin factor as.character(df\$p25_sexo)
“\`

## Examples

``` r
# Etiquetar todas las variables categóricas de una vez
sample_personas |> etiquetar() |> head(3)
#> # A tibble: 3 × 16
#>   idep  iprov imun  i00      p24_parentes    p25_sexo p26_edad g_edad p38_asiste
#>   <chr> <chr> <chr> <chr>    <fct>           <fct>       <int> <fct>  <fct>     
#> 1 01    01    01    00003715 Esposa(o), con… Mujer          27 15 - … No asiste 
#> 2 01    01    01    00003715 Jefa o jefe de… Hombre         32 15 - … No asiste 
#> 3 01    01    01    00003715 Otro Pariente   Hombre          2 0 - 14 No asiste 
#> # ℹ 7 more variables: p40_lee <fct>, nivel_edu <fct>, aestudio <dbl>,
#> #   p32_pueblo_per <fct>, p32_pueblos <fct>, p53_ecivil <fct>, p28_cn <fct>

# Solo una variable específica
sample_personas |> etiquetar(variables = "p25_sexo") |> head(3)
#> # A tibble: 3 × 16
#>   idep  iprov imun  i00      p24_parentes p25_sexo p26_edad g_edad p38_asiste
#>   <chr> <chr> <chr> <chr>           <int> <fct>       <int>  <int>      <int>
#> 1 01    01    01    00003715            2 Mujer          27      2          8
#> 2 01    01    01    00003715            1 Hombre         32      2          8
#> 3 01    01    01    00003715           12 Hombre          2      1          8
#> # ℹ 7 more variables: p40_lee <int>, nivel_edu <int>, aestudio <dbl>,
#> #   p32_pueblo_per <int>, p32_pueblos <int>, p53_ecivil <int>, p28_cn <int>

# Flujo típico: Arrow → collect → etiquetar
if (FALSE) { # \dontrun{
get_personas(departamento = "Santa Cruz") |>
  dplyr::filter(p26_edad >= 18) |>
  dplyr::count(p25_sexo) |>
  dplyr::collect() |>
  etiquetar()
} # }
```

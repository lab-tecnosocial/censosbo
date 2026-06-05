# Etiqueta los valores de las variables categóricas

Convierte los códigos numéricos de las columnas categóricas del CPV-2024
en factores con las etiquetas en español del diccionario oficial del
INE. Se usa típicamente después de \`collect()\` para que los resultados
sean legibles directamente.

## Usage

``` r
etiquetar_valores(df, columnas = NULL)
```

## Arguments

- df:

  Un data.frame (resultado de \`collect()\`, \`DBI::dbGetQuery()\` u
  otro).

- columnas:

  Vector de caracteres con los nombres de columnas a etiquetar. Si
  \`NULL\` (por defecto), etiqueta todas las columnas categóricas
  presentes.

## Value

El mismo \`df\` con las columnas categóricas convertidas a \`factor\`
con las etiquetas del diccionario. Las columnas no encontradas en el
diccionario se devuelven sin cambios.

## Details

Los valores que no coinciden con ningún código del diccionario
(incluyendo \`NA\`) quedan como \`NA\` en el factor resultante. Para ver
los códigos disponibles de una variable usa \`codebook_valores()\`.

Para volver de etiquetas a códigos: “\`r as.integer(df\$p25_sexo) \# →
1, 2 as.character(df\$p25_sexo) \# → "Mujer", "Hombre" “\`

Para etiquetar también los nombres de columna, encadena con
\`etiquetar_variables()\`.

## See also

\[etiquetar_variables()\] para renombrar columnas con sus descripciones.

## Examples

``` r
# Etiquetar todas las columnas categóricas de un data.frame
if (FALSE) { # \dontrun{
get_personas(departamento = "Pando", as = "tibble") |>
  etiquetar_valores() |>
  head(3)
} # }

# Flujo típico: Arrow → collect → etiquetar_valores
if (FALSE) { # \dontrun{
get_personas(departamento = "Santa Cruz") |>
  dplyr::filter(p26_edad >= 18) |>
  dplyr::count(p25_sexo) |>
  dplyr::collect() |>
  etiquetar_valores()
} # }
```

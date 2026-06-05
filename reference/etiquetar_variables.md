# Etiqueta los nombres de las variables (columnas)

Reemplaza los nombres técnicos de las columnas (e.g., \`p25_sexo\`) por
sus descripciones en español del diccionario oficial del INE (e.g.,
\`"25. Es mujer u hombre"\`). Útil para tablas y reportes destinados a
lectores no técnicos.

## Usage

``` r
etiquetar_variables(df)
```

## Arguments

- df:

  Un data.frame.

## Value

El mismo \`df\` con los nombres de columnas reemplazados por sus
descripciones. Las columnas no encontradas en el diccionario conservan
su nombre original.

## Details

Las descripciones pueden contener espacios y caracteres especiales. En
RMarkdown/Quarto se muestran directamente en tablas. Para referenciarlas
en código R usa backticks: `` df$`25. Es mujer u hombre` ``.

Para etiquetar también los valores de las columnas, encadena con
\`etiquetar_valores()\`.

## See also

\[etiquetar_valores()\] para convertir códigos numéricos a etiquetas.

## Examples

``` r
# Renombrar columnas de un resumen del diccionario
codebook_meta[1:5, c("variable", "etiqueta", "tabla")] |>
  etiquetar_variables()
#>       variable                                                       etiqueta
#> 1 p24_parentes          24. Que parentesco tiene con la jefa o jefe del hogar
#> 2     p25_sexo                                          25. Es mujer u hombre
#> 3     p26_edad                               26. Cuantos años cumplidos tiene
#> 4       p28_cn 28. Su nacimiento está inscrito en el registro civil boliviano
#> 5       p29_ci                 29. Tiene o tuvo cédula de identidad boliviana
#>     tabla
#> 1 persona
#> 2 persona
#> 3 persona
#> 4 persona
#> 5 persona

# Con datos reales: valores y nombres etiquetados
if (FALSE) { # \dontrun{
get_personas_2024(departamento = "Pando") |>
  dplyr::count(p25_sexo, nivel_edu) |>
  dplyr::collect() |>
  etiquetar_valores() |>
  etiquetar_variables()
} # }
```

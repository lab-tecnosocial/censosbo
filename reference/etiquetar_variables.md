# Etiqueta los nombres de las variables (columnas)

Reemplaza los nombres técnicos de las columnas (e.g., \`p25_sexo\`) por
sus descripciones en español del diccionario oficial del INE (e.g.,
\`"25. Es mujer u hombre"\`). Detecta automáticamente el censo (1976,
1992, 2001, 2012 o 2024) a partir de los nombres de columna. Útil para
tablas y reportes destinados a lectores no técnicos.

## Usage

``` r
etiquetar_variables(df, anio = NULL)
```

## Arguments

- df:

  Un data.frame.

- anio:

  Entero. Año del censo: \`1976\`, \`1992\`, \`2001\`, \`2012\` o
  \`2024\`. Si \`NULL\` (por defecto), se detecta automáticamente a
  partir de los nombres de columna del data frame.

## Value

El mismo \`df\` con los nombres de columnas reemplazados por sus
descripciones. Las columnas no encontradas en el diccionario —y las que
están pero sin descripción, como algunas variables derivadas del censo
1976— conservan su nombre original.

## Details

Las descripciones pueden contener espacios y caracteres especiales. En
RMarkdown/Quarto se muestran directamente en tablas. Para referenciarlas
en código R usa backticks: `` df$`25. Es mujer u hombre` ``.

La detección automática del censo compara nombres de columna con los
codebooks disponibles. Usa \`anio\` explícito si el data frame tiene muy
pocas columnas o solo columnas geográficas.

## See also

\[etiquetar_valores()\] para convertir códigos numéricos a etiquetas.

## Examples

``` r
# Renombrar columnas de un resumen del diccionario
codebook_meta[1:5, c("variable", "etiqueta", "tabla")] |>
  etiquetar_variables()
#> Warning: No se pudo detectar el censo por los nombres de columnas. Usando 2024.
#> ℹ Especifica el año con `anio`: `etiquetar_valores(df, anio = 1992)`
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

# Valores y nombres etiquetados a la vez
data.frame(p25_sexo = c(1, 2), n = c(2894112, 2762418)) |>
  etiquetar_valores() |>
  etiquetar_variables()
#>   25. Es mujer u hombre       n
#> 1                 Mujer 2894112
#> 2                Hombre 2762418

# El mismo flujo sobre datos reales (requiere descarga)
if (FALSE) { # \dontrun{
get_personas_2024(departamento = "Pando") |>
  dplyr::count(p25_sexo, nivel_edu) |>
  dplyr::collect() |>
  etiquetar_valores() |>
  etiquetar_variables()
} # }
```

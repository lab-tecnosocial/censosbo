# Añade nombres geográficos legibles a los microdatos

Une un data frame de microdatos con \[geo_bolivia\] para agregar los
nombres de departamento, provincia y municipio (\`nombre_dep\`,
\`nombre_prov\`, \`nombre_mun\`) a partir de los códigos geográficos
(\`idep\`, \`iprov\`, \`imun\`). Es el equivalente geográfico de
\[etiquetar_valores()\] y evita el \`left_join\` manual con
\[municipios()\] que antes hacía falta para trabajar por municipio.

## Usage

``` r
etiquetar_geografia(df)
```

## Arguments

- df:

  Un data.frame ya materializado (tras \`collect()\`) que contenga al
  menos la columna \`idep\`. El nivel de detalle se detecta
  automáticamente según las columnas presentes: solo \`idep\` agrega
  \`nombre_dep\`; \`idep\`+\`iprov\` agrega también \`nombre_prov\`;
  \`idep\`+\`iprov\`+\`imun\` agrega los tres.

## Value

El mismo \`df\` con las columnas de nombre añadidas. Si ya existían
columnas de nombre, se reemplazan.

## Details

Los códigos se normalizan a 2 dígitos antes de unir, por lo que funciona
aunque \`idep\`/\`iprov\`/\`imun\` vengan como enteros. Los nombres
provienen de la geografía del CPV-2024 (\[geo_bolivia\]); en censos
históricos algunos códigos de municipio pueden no tener correspondencia
y quedar como \`NA\`.

## See also

\[etiquetar_valores()\], \[municipios()\]

## Examples

``` r
if (FALSE) { # \dontrun{
library(dplyr)
get_personas_2024(departamento = "Cochabamba") |>
  count(idep, iprov, imun) |>
  collect() |>
  etiquetar_geografia()
} # }
```

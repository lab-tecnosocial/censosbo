# Visualiza una variable a nivel de manzano o comunidad

Genera un mapa de un municipio al máximo detalle disponible del
CPV-2024: cada manzano urbano como polígono y cada comunidad rural como
punto.

## Usage

``` r
mapa_man(
  datos,
  variable,
  municipio,
  departamento = NULL,
  area = NULL,
  titulo = NULL,
  etiqueta_fill = NULL,
  paleta = NULL,
  na_color = "grey80",
  tamano_punto = 0.9
)
```

## Arguments

- datos:

  Data.frame con una columna \`codigo\` de unidad censal y la columna a
  visualizar. Típicamente sale de \[get_fichas_2024()\] o
  \[get_unidades_2024()\].

- variable:

  Nombre (caracter) de la columna a visualizar.

- municipio:

  Nombre o código del municipio a mapear. Obligatorio: son ~268.000
  unidades en todo el país y un mapa nacional no se lee.

- departamento:

  Departamento del municipio. Solo hace falta para desambiguar nombres
  repetidos entre departamentos.

- area:

  Qué unidades incluir: \`"urbano"\`, \`"rural"\` o ambas (defecto).

- titulo:

  Título del mapa. Si \`NULL\`, usa el nombre de la variable.

- etiqueta_fill:

  Etiqueta de la leyenda. Si \`NULL\`, usa \`variable\`.

- paleta:

  Paleta de color. Por defecto \`"Blues"\` (continua) o \`"Set3"\`
  (categórica).

- na_color:

  Color para unidades sin datos. Por defecto \`"grey80"\`.

- tamano_punto:

  Tamaño de los puntos de las comunidades rurales.

## Value

Un objeto \`ggplot\` modificable con capas adicionales de ggplot2.

## Details

Las geometrías se descargan al caché con \[get_geo_manzanos()\] y
\[get_geo_comunidades()\] la primera vez; después se reutilizan.

Las unidades del municipio que no estén en \`datos\` se dibujan con
\`na_color\`. Eso es lo normal al mapear \[get_fichas_2024()\]: el 47
tiene ficha por reserva estadística, y salen en gris.

## See also

\[mapa_mun()\] para el nivel municipal, \[mapa_dep()\] para el
departamental.

## Examples

``` r
if (FALSE) { # \dontrun{
library(dplyr)
agua <- get_fichas_2024(municipio = "Sucre", as = "tibble") |>
  mutate(pct_caneria = 100 * serv_agua_caneria / serv_agua_total)
mapa_man(agua, "pct_caneria", municipio = "Sucre",
         titulo = "% viviendas con agua por cañería - Sucre (2024)")
} # }
```

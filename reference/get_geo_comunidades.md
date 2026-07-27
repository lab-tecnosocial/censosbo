# Descarga las geometrías de las comunidades rurales del CPV-2024

Descarga las geometrías de las comunidades rurales del CPV-2024

## Usage

``` r
get_geo_comunidades(
  departamento = NULL,
  provincia = NULL,
  municipio = NULL,
  overwrite = FALSE,
  verbose = TRUE
)
```

## Arguments

- departamento:

  Nombre o código del departamento (e.g., \`"Cochabamba"\` o \`"03"\`).
  \`NULL\` (defecto) devuelve todo el país.

- provincia:

  Nombre o código de la provincia. Opcional.

- municipio:

  Nombre o código del municipio. Opcional.

- overwrite:

  Lógico. Si \`TRUE\`, re-descarga aunque exista en caché.

- verbose:

  Lógico. Mostrar progreso.

## Value

Un objeto \`sf\` con columnas \`codigo\`, \`nombre\`, \`idep\`,
\`iprov\`, \`imun\` y \`geometria\` (EPSG:4326).

## Details

El INE publica la mayoría de las comunidades rurales como \*\*puntos\*\*
(un centro aproximado), no como polígonos. Para mapas de coropletas
rurales no hay superficie que rellenar: conviene usar
\[ggplot2::geom_sf()\] con puntos graduados por tamaño o color.

## Examples

``` r
if (FALSE) { # \dontrun{
comunidades <- get_geo_comunidades(departamento = "Pando")
plot(comunidades["nombre"])
} # }
```

# Descarga las geometrías de los manzanos urbanos del CPV-2024

Descarga las geometrías de los manzanos urbanos del CPV-2024

## Usage

``` r
get_geo_manzanos(
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
\`iprov\`, \`imun\` y \`geometria\` (polígonos, EPSG:4326).

## Details

Los archivos están partidos por departamento (0,3 a 6,7 MB cada uno).
Sin el argumento \`departamento\` se descargan los nueve, unos 25 MB en
total; para un mapa de un municipio conviene acotar.

## See also

\[mapa_man()\] para dibujarlas, \[get_geo_comunidades()\] para el área
rural.

## Examples

``` r
if (FALSE) { # \dontrun{
manzanos <- get_geo_manzanos(municipio = "Sucre")
plot(manzanos["nombre"])
} # }
```

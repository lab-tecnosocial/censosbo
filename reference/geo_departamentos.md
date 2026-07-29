# Geometrías de los departamentos de Bolivia

Objeto \`sf\` con los 9 departamentos de Bolivia y sus geometrías
poligonales. Compatible con \`ggplot2::geom_sf()\` y la función
\[mapa_dep()\].

## Usage

``` r
geo_departamentos
```

## Format

Un \`sf\` data.frame con 9 filas y 3 columnas (más geometría):

- idep:

  Código de departamento (2 dígitos, con cero a la izquierda)

- nombre_dep:

  Nombre del departamento

- geometry:

  Geometría de polígono (CRS: WGS84 / EPSG:4326)

## Source

Derivado por disolución de \[geo_municipios\], de modo que los bordes
departamentales coinciden exactamente con los municipales.

## See also

\[geo_municipios\], \[mapa_dep()\]

# Bloques temáticos de los indicadores de manzano y comunidad

Los 15 bloques con que el INE organiza las fichas censales del CPV-2024
en su geoportal. Es un desglose más fino que el tema: \`salud_lugar\` y
\`salud_seguro\` son dos bloques dentro del tema
\`salud_seguridad_social\`.

## Usage

``` r
censo_bloques_meta
```

## Format

Un data.frame de 15 filas con columnas \`bloque\`, \`etiqueta\`,
\`tema\`, \`capitulo\` y \`orden\`.

## Source

INE Bolivia, fichas censales del geoportal del CPV-2024.

## Details

Se publica porque hasta ahora esta agrupación vivía duplicada a mano en
los proyectos que consumen el paquete. La fuente única son
\`data-raw/fichas/campos.csv\` y \`campos_vivienda.csv\`.

# Catálogo de temas de los censos de Bolivia

Los 20 temas con los que \`censosbo\` agrupa las variables censales.
Diecisiete son los \`topics\` oficiales que el INE declara en el
catálogo ANDA del CPV-2024; los otros tres (\`ubicacion_geografica\`,
\`identificacion\` y \`materiales_construccion\`) son extensiones del
paquete, marcadas en la columna \`fuente\`.

## Usage

``` r
censo_temas_meta
```

## Format

Un data.frame de 20 filas:

- tema:

  Identificador en snake_case; es la clave que acepta \`codebook(tema =
  )\` y \[vars_tema()\]

- etiqueta:

  Nombre legible del tema

- capitulo:

  Capítulo principal del cuestionario CPV-2024 (\`"A"\`–\`"G"\`)

- capitulo_etiqueta:

  Nombre del capítulo

- capitulos:

  Todos los capítulos en que aparece el tema, separados por coma

- anios:

  Censos en los que el tema tiene variables

- fuente:

  \`"INE-ANDA"\` si es un topic oficial, \`"censosbo"\` si es una
  extensión del paquete

- orden:

  Orden de presentación: por capítulo y luego por cuestionario

- descripcion:

  Qué incluye el tema y, cuando la asignación es discutible, por qué se
  decidió así

## Source

INE Bolivia — catálogo ANDA, estudios 132 (CPV-2024), 8 (CPV-2012) y 10
(CNPV-2001), elemento \`topcClas\` del DDI.

## Details

El mismo vocabulario se aplica a 2024, 2012 y 2001, de modo que
\`codebook(tema = "educacion", anio = ...)\` sea comparable entre
censos. Los ocho temas del vocabulario antiguo del INE (idénticos en
2012 y 2001) se mapearon a estos veinte: seis literales coinciden y dos
son renombrados (\`Hogar y/o Vivienda\` y \`Empleo, Ocupación y
Actividad Económica\`).

## Capítulo y tema son dos facetas independientes

Cada variable tiene exactamente un \`capitulo\` y un \`tema\`, pero el
tema \*\*no\*\* está anidado en el capítulo: \`v01_tipoviv\` está en el
capítulo B y \`v17_tenencia\` en el C, y los dos son \`vivienda_hogar\`.
En esta tabla, \`capitulo\` es el capítulo principal del tema (donde
vive la mayoría de sus variables) y \`capitulos\` lista todos aquellos
en los que aparece.

Los capítulos son los del cuestionario del CPV-2024 y solo se aplican a
ese censo; en 2012 y 2001 la columna \`capitulo\` del codebook queda a
\`NA\` y la estructura oficial de cada año vive en \`grupo_ine\`.

## See also

\[censo_temas()\] para consultarlo con conteos de variables.

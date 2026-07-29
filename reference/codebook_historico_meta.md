# Diccionarios de variables de los censos históricos de Bolivia

Lista nombrada con los metadatos de variables de los censos 1976, 1992,
2001 y 2012. Cada elemento es un data.frame con la misma estructura que
\[codebook_meta\].

## Usage

``` r
codebook_historico_meta
```

## Format

Una lista con elementos \`"1976"\`, \`"1992"\`, \`"2001"\` y \`"2012"\`,
cada uno un data.frame con las mismas columnas que \[codebook_meta\].
Estos objetos guardan \`tipo\` y \`valores_codigos\` en orden inverso al
de \`codebook_meta\`, por razones históricas; \[codebook()\] reordena
las columnas al devolver, así que consultado por ahí el esquema es
idéntico en los cinco censos. Tres particularidades de contenido:

- variable:

  Conserva el nombre original del censo, que en los primeros años son
  códigos cortos (\`p10\`, \`anioes1\`) y no nombres descriptivos

- tabla:

  Es la entidad REDATAM de origen, así que varía entre censos
  (\`"poblacion"\` en 1976 donde 2024 usa \`"persona"\`)

- capitulo:

  Siempre \`NA\`: los capítulos son los del cuestionario del CPV-2024.
  La estructura oficial de cada año está en \`grupo_ine\`

## Source

INE Bolivia. Diccionarios Parquet generados por open-redatam, con el
tema y el universo añadidos desde los DDI del catálogo ANDA (estudios 8,
10, 47 y 46) y los cuestionarios de cada censo.

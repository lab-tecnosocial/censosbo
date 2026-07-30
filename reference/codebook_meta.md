# Diccionario de variables del CPV-2024

Metadatos de todas las variables del Censo de Población y Vivienda 2024
de Bolivia, extraídos del Diccionario de Variables oficial del INE.

## Usage

``` r
codebook_meta
```

## Format

Un data.frame con las siguientes columnas:

- variable:

  Nombre de la variable (minúsculas, igual que en los datos)

- etiqueta:

  Descripción en español de la variable

- tabla:

  Tabla a la que pertenece: \`"persona"\`, \`"vivienda"\`,
  \`"emigracion"\`, \`"mortalidad"\`, \`"unidad"\` o \`"ficha"\`

- valores_codigos:

  Lista de data.frames con los códigos y etiquetas para variables
  categóricas; \`NULL\` para variables numéricas o de texto

- tipo:

  Tipo de dato: \`"categorica"\`, \`"numerica"\` o \`"texto"\`. Una
  variable es \`"categorica"\` si sus valores son códigos con etiquetas
  (aunque sean números, como \`sexo\` 1/2) o si su nombre indica un
  código de clasificación (sufijo \`cod\`: códigos geográficos, de
  ocupación, etc.); \`"texto"\` si almacena texto libre; \`"numerica"\`
  en los demás casos (conteos y medidas)

- tema:

  Uno de los 21 temas de \[censo_temas_meta\]. Es el eje comparable
  entre censos

- capitulo:

  Capítulo del cuestionario del CPV-2024 (\`"A"\`–\`"G"\`); \`NA\` en
  los censos anteriores, cuya estructura oficial está en \`grupo_ine\`

- pregunta, pregunta_num:

  Número de pregunta del formulario, como texto y como entero, para
  recorrer el censo en el orden en que se aplicó

- origen:

  Procedencia: \`"cuestionario"\` (pregunta directa), \`"derivada"\`
  (construida por el INE o por REDATAM), \`"geografia"\`,
  \`"identificador"\` o \`"indicador"\` (agregados de las fichas de
  manzano y comunidad)

- universo:

  Población de referencia normalizada (\`"personas_5_mas"\`,
  \`"mujeres_12_mas"\`, \`"viviendas_presentes"\`…). Es el denominador
  correcto de la variable; \`NA\` cuando el INE no lo declara. \*\*El
  censo 2012 es la excepción:\*\* su DDI solo distingue
  \`"todas_personas"\` y \`"todas_viviendas"\`, así que sus variables de
  universo restringido (como \`P37A_NIVELNUE\`) no lo declaran, y el
  aviso automático de universo no salta para ese censo. Al comparar 2012
  con otro año, toma el universo del año que sí lo declara

- grupo_ine:

  Agrupación oficial del censo de origen; \`NA\` en 2024, que no la
  publica

- bloque, denominador:

  Bloque de \[censo_bloques_meta\] y denominador de los indicadores de
  manzano y comunidad; \`NA\` en el resto de variables

- valores_fuente:

  De dónde salen las etiquetas de valor: \`"redatam"\`, \`"ddi"\` o el
  diccionario oficial

## Source

INE Bolivia, CPV-2024. Diccionario de Variables CPV 2024.xlsx, los
cuestionarios censales y el DDI del estudio 132 del catálogo ANDA.

## See also

\[censo_temas()\] y \[vars_tema()\] para navegar por tema, y
\[codebook_docs_meta\] para los textos conceptuales del INE.

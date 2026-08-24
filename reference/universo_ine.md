# Aplica el universo de los tabulados oficiales del INE

Recorta una tabla de personas al universo que el INE usa en sus cuadros
publicados: solo residentes habituales en el país y, si se indica, a
partir de una edad mínima. Sin este recorte, un conteo hecho sobre los
microdatos no cuadra con el tabulado equivalente del INE aunque el
cálculo sea correcto.

## Usage

``` r
universo_ine(datos, anio, edad_min = NULL)
```

## Arguments

- datos:

  Tabla de personas: \`arrow::Dataset\`, \`tbl\` o \`data.frame\`, tal
  como la devuelven \[get_personas_2024()\], \[get_personas_2012()\] o
  \[get_personas_2001()\]. Debe conservar las columnas de residencia
  habitual y de edad del censo correspondiente (ver \*Details\*).

- anio:

  Año del censo: \`2001\`, \`2012\` o \`2024\`.

- edad_min:

  Entero o \`NULL\`. Edad mínima del universo, en años cumplidos.
  \`NULL\` (por defecto) no filtra por edad. Los cuadros del INE usan 4
  para idioma materno, 6 para idioma de mayor uso e idiomas hablados, 5
  para discapacidad y 14 para condición de actividad; el valor exacto
  viene en el título de cada cuadro.

## Value

La misma tabla, filtrada. El tipo de objeto se conserva: un \`Dataset\`
de Arrow sigue siendo perezoso y no se trae a RAM.

## Details

Los cuadros temáticos del INE llevan al pie la nota \*«No incluye
personas que residen habitualmente en el exterior»\*. Esa exclusión no
está en ninguna variable derivada: hay que aplicarla a mano sobre la
pregunta de residencia habitual, que cambia de nombre en cada censo.

\| Censo \| Residencia habitual \| Edad \| Se excluye \| \|—\|—\|—\|—\|
\| 2024 \| \`p36_lugres\` \| \`p26_edad\` \| \`3\` (otro país) y \`9\`
(sin especificar) \| \| 2012 \| \`P33A\` \| \`P25\` \| \`3\` (en el
exterior) \| \| 2001 \| \`P33A\` \| \`P29\` \| \`3\` (en el exterior) \|

En 2024 la categoría «sin especificar» también queda fuera; en 2012 y
2001 esa categoría no existe. Para 1976 y 1992 la función aborta: los
tabulados de esos censos no llevan la nota y la equivalencia no está
verificada.

Comprobado contra los cuadros municipales del CPV-2024 de idioma
materno, idioma de mayor uso, idiomas hablados y multilingüismo: con
este recorte los conteos por municipio, área y lengua coinciden
\*\*exactamente\*\* con los publicados por el INE.

## Examples

``` r
if (FALSE) { # \dontrun{
library(dplyr)

# Idioma materno, universo del INE (4 años o más, residentes en el país)
get_personas_2024(departamento = "Chuquisaca",
                  variables = c("p26_edad", "p36_lugres", "idioma_mat")) |>
  universo_ine(2024, edad_min = 4) |>
  count(idioma_mat) |>
  collect()

# Idiomas hablados: el universo es 6 años o más
get_personas_2024(departamento = "Chuquisaca",
                  variables = c("p26_edad", "p36_lugres",
                                "p331_idiohab1_cod")) |>
  universo_ine(2024, edad_min = 6)
} # }
```

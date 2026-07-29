# Nombres de las variables de un tema

Devuelve un vector de caracteres listo para pasar al argumento
\`variables\` de las funciones \`get\_\*()\`, o a
\`dplyr::select(dplyr::all_of())\`.

## Usage

``` r
vars_tema(
  tema,
  tabla = NULL,
  tipo = NULL,
  origen = NULL,
  capitulo = NULL,
  anio = 2024
)
```

## Arguments

- tema:

  Caracteres. Uno o varios temas, con los slugs de \[censo_temas_meta\].

- tabla:

  Caracteres. Restringe a una tabla. Conviene indicarla cuando el tema
  abarca varias, porque pasar variables de \`vivienda\` a
  \[get_personas_2024()\] no devuelve nada útil.

- tipo:

  Caracteres. Filtra por tipo de dato: \`"categorica"\`, \`"numerica"\`
  o \`"texto"\`.

- origen:

  Caracteres. Filtra por procedencia: \`"cuestionario"\`,
  \`"derivada"\`, \`"geografia"\`, \`"identificador"\` o
  \`"indicador"\`.

- capitulo:

  Caracteres. Filtra por capítulo del cuestionario (solo 2024).

- anio:

  Entero. \`2024\` (defecto), \`2012\`, \`2001\`, \`1992\` o \`1976\`.

## Value

Un vector de caracteres, sin duplicados.

## Details

Las variables salen en el orden del cuestionario (capítulo, luego número
de pregunta) y las derivadas al final, para que la selección se lea
igual que el formulario original.

## See also

\[censo_temas()\] para ver qué temas existen.

## Examples

``` r
vars_tema("educacion", tabla = "persona")
#>  [1] "p38_asiste"     "p39_tipoest"    "p40_lee"        "p41a_nivel"    
#>  [5] "p41b_curso"     "p41a_nivel_act" "p41b_curso_act" "aestudio"      
#>  [9] "asiste"         "gedadedu"       "nivel_edu"     

# Solo las preguntas directas, sin las derivadas del INE
vars_tema("caracteristicas_economicas", tabla = "persona", origen = "cuestionario")
#> [1] "p43_pago"     "p44_nego"     "p45_agro"     "p46_dest"     "p47_otro"    
#> [6] "p48_nocu"     "p49_ocu_1d"   "p50_semp"     "p51_actec_2d"

if (FALSE) { # \dontrun{
# Descargar solo las variables de un tema
get_personas_2024(
  departamento = "Cochabamba",
  variables = vars_tema("educacion", tabla = "persona")
)
} # }
```

# Consulta el diccionario de variables de un censo de Bolivia

Permite buscar variables del censo por nombre, tabla o texto libre en
las etiquetas.

## Usage

``` r
codebook_1976(
  variable = NULL,
  tabla = NULL,
  buscar = NULL,
  tema = NULL,
  origen = NULL
)

codebook_1992(
  variable = NULL,
  tabla = NULL,
  buscar = NULL,
  tema = NULL,
  origen = NULL
)

codebook_2001(
  variable = NULL,
  tabla = NULL,
  buscar = NULL,
  tema = NULL,
  origen = NULL
)

codebook_2012(
  variable = NULL,
  tabla = NULL,
  buscar = NULL,
  tema = NULL,
  origen = NULL
)

codebook_2024(
  variable = NULL,
  tabla = NULL,
  buscar = NULL,
  tema = NULL,
  capitulo = NULL,
  origen = NULL
)

codebook(
  variable = NULL,
  tabla = NULL,
  buscar = NULL,
  anio = 2024,
  tema = NULL,
  capitulo = NULL,
  origen = NULL
)
```

## Arguments

- variable:

  Vector de caracteres. Nombre(s) de variable a consultar. Si \`NULL\`,
  devuelve todas.

- tabla:

  Caracteres. Filtra por tabla (e.g., \`"persona"\`, \`"vivienda"\`). Si
  \`NULL\`, devuelve todas las tablas.

- buscar:

  Caracteres. Texto libre para buscar en las etiquetas y nombres de
  variables, y también en el tema y el capítulo (no distingue
  mayúsculas/minúsculas). Se interpreta como expresión regular.

- tema:

  Caracteres. Filtra por tema, con los slugs de \[censo_temas_meta\]
  (e.g. \`"educacion"\`, \`"servicios_basicos"\`). Acepta varios.
  Disponible en los cinco censos; ver \[censo_temas()\].

- origen:

  Caracteres. Filtra por procedencia de la variable: \`"cuestionario"\`
  (pregunta directa), \`"derivada"\` (construida por el INE),
  \`"geografia"\`, \`"identificador"\` o \`"indicador"\` (agregados de
  las fichas de manzano y comunidad).

- capitulo:

  Caracteres. Filtra por capítulo del cuestionario del CPV-2024: la
  letra (\`"C"\`) o parte de su nombre (\`"vivienda"\`). Solo aplica a
  2024: los cuestionarios anteriores tienen otra estructura y varios
  numeran las secciones de vivienda y de persona en paralelo. El eje
  comparable entre censos es \`tema\`.

- anio:

  Entero. Año del censo: \`2024\` (defecto), \`1976\`, \`1992\`,
  \`2001\` o \`2012\`.

## Value

Un data.frame con las variables que coinciden con los filtros. Las
columnas son siempre las mismas para los cinco censos.

## See also

\[censo_temas()\] para el catálogo de temas, \[vars_tema()\] para
obtener los nombres de variable de un tema, y \[codebook_docs()\] para
la definición conceptual y la pregunta literal de cada variable.

## Examples

``` r
# Ver etiqueta de una variable específica del CPV-2024
codebook("p25_sexo")
#>   variable              etiqueta   tabla   categorias       tipo      tema
#> 1 p25_sexo 25. Es mujer u hombre persona 2 categorías categorica poblacion
#>   capitulo pregunta pregunta_num       origen       universo
#> 1        G       25           25 cuestionario todas_personas
#> 
#> 4 columnas sin datos aquí: grupo_ine, bloque, denominador, valores_fuente

# Variables de sexo en el censo 2012
codebook(buscar = "sexo", anio = 2012)
#>   variable etiqueta        tabla   categorias       tipo
#> 1     P20E     Sexo   emigracion 2 categorías categorica
#> 2     P22E     Sexo discapacidad 2 categorías categorica
#>                       tema pregunta pregunta_num       origen       universo
#> 1 emigracion_internacional     20.E           20 cuestionario todas_personas
#> 2             discapacidad     22.E           22 cuestionario todas_personas
#>   valores_fuente
#> 1        redatam
#> 2        redatam
#> 
#> 4 columnas sin datos aquí: capitulo, grupo_ine, bloque, denominador

# Todas las variables de vivienda del censo 1992
codebook(tabla = "vivienda", anio = 1992)
#>        variable                                         etiqueta    tabla
#> 1           I12                              Área rural dispersa vivienda
#> 2          I122                                  Categoría rural vivienda
#> 3           V01                                 Tipo de vivienda vivienda
#> 4           V02                           Condición de ocupación vivienda
#> 5           V03                                          Paredes vivienda
#> 6           V04                                           Techos vivienda
#> 7           V05                                            Pisos vivienda
#> 8           V06      Abastecimiento de agua para beber y cocinar vivienda
#> 9           V07                             Procedencia del agua vivienda
#> 10          V08                               Servicio sanitario vivienda
#> 11         V081                       Uso del servicio sanitario vivienda
#> 12         V082                   Desague del servicio sanitario vivienda
#> 13          V09                          Tiene energía eléctrica vivienda
#> 14          V10    Cuantos cuartos o habitaciones ocupa su hogar vivienda
#> 15          V11                     Cuantos utilizan para dormir vivienda
#> 16          V12          Tiene un cuarto especial para la cocina vivienda
#> 17          V13     Principal combustible utilizado para cocinar vivienda
#> 18          V14                          Tenencia de la vivienda vivienda
#> 19         V15A             Dependencias del Ministerio de Salud vivienda
#> 20         V15B                            Caja de Seguro Social vivienda
#> 21         V15C                    Dependencias de ONG o iglesia vivienda
#> 22         V15D                               Servicios Privados vivienda
#> 23         V15E                                         Farmacia vivienda
#> 24         V15F Jampiri, Yatiri, Curandero, Kallawaya, Naturista vivienda
#> 25         V15G                   Otro tipo de atención de Salud vivienda
#> 26         V15H                              No atiende su Salud vivienda
#> 27         V15I                    Ignorado en atención de Salud vivienda
#> 28          V16                 No pertenecen a ninguna religión vivienda
#> 29         V16B                                Religión católica vivienda
#> 30         V16C                              Religión evangélica vivienda
#> 31         V16D                                    Otra religión vivienda
#> 32         V16E                                Religión ignorada vivienda
#> 33          V17 En este hogar murió alguna persona el año pasado vivienda
#> 34         V18H                                    Total hombres vivienda
#> 35         V18M                                    Total mujeres vivienda
#> 36         V18T                                  Total población vivienda
#> 37          V20                                       Tipo Hogar vivienda
#> 38          V21                                    Tipo Vivienda vivienda
#> 39          V22                           Categoría Urbano/Rural vivienda
#> 40       URBRUR                                     Urbano/Rural vivienda
#> 41   NBI_GRUP_V                                       NBI_GRUPOS vivienda
#> 42 NBI_POBRES_V                                       NBI_POBRES vivienda
#> 43         idep                   Código de departamento (01-09) vivienda
#> 44        iprov                              Código de provincia vivienda
#> 45         imun                              Código de municipio vivienda
#>       categorias       tipo                    tema pregunta pregunta_num
#> 1   1 categorías categorica    ubicacion_geografica     <NA>           NA
#> 2   9 categorías categorica    ubicacion_geografica     <NA>           NA
#> 3  13 categorías categorica          vivienda_hogar       01            1
#> 4   6 categorías categorica          vivienda_hogar       02            2
#> 5   7 categorías categorica materiales_construccion       03            3
#> 6   5 categorías categorica materiales_construccion       04            4
#> 7   6 categorías categorica materiales_construccion       05            5
#> 8   4 categorías categorica       servicios_basicos       06            6
#> 9   5 categorías categorica       servicios_basicos       07            7
#> 10  3 categorías categorica       servicios_basicos       08            8
#> 11  2 categorías categorica       servicios_basicos     08.1            8
#> 12  3 categorías categorica       servicios_basicos     08.2            8
#> 13  2 categorías categorica       servicios_basicos       09            9
#> 14                 numerica          vivienda_hogar       10           10
#> 15  1 categorías categorica          vivienda_hogar       11           11
#> 16  2 categorías categorica          vivienda_hogar       12           12
#> 17  8 categorías categorica       servicios_basicos       13           13
#> 18  7 categorías categorica          vivienda_hogar       14           14
#> 19  1 categorías categorica  salud_seguridad_social     15.A           15
#> 20  1 categorías categorica  salud_seguridad_social     15.B           15
#> 21                 numerica  salud_seguridad_social     15.C           15
#> 22  1 categorías categorica  salud_seguridad_social     15.D           15
#> 23                 numerica  salud_seguridad_social     15.E           15
#> 24                 numerica  salud_seguridad_social     15.F           15
#> 25                 numerica  salud_seguridad_social     15.G           15
#> 26                 numerica  salud_seguridad_social     15.H           15
#> 27                 numerica  salud_seguridad_social     15.I           15
#> 28                 numerica                religion       16           16
#> 29                 numerica                religion     16.B           16
#> 30                 numerica                religion     16.C           16
#> 31                 numerica                religion     16.D           16
#> 32  1 categorías categorica                religion     16.E           16
#> 33  2 categorías categorica              mortalidad       17           17
#> 34                 numerica               poblacion     18.H           18
#> 35                 numerica               poblacion     18.M           18
#> 36  2 categorías categorica               poblacion     18.T           18
#> 37                 numerica          vivienda_hogar       20           20
#> 38                 numerica          vivienda_hogar       21           21
#> 39                 numerica    ubicacion_geografica       22           22
#> 40  2 categorías categorica    ubicacion_geografica     <NA>           NA
#> 41  5 categorías categorica          vivienda_hogar     <NA>           NA
#> 42  2 categorías categorica          vivienda_hogar     <NA>           NA
#> 43               categorica    ubicacion_geografica     <NA>           NA
#> 44               categorica    ubicacion_geografica     <NA>           NA
#> 45               categorica    ubicacion_geografica     <NA>           NA
#>          origen        universo                      grupo_ine valores_fuente
#> 1     geografia            <NA>                           <NA>        redatam
#> 2      derivada todas_viviendas Características de la Vivienda        redatam
#> 3  cuestionario todas_viviendas Características de la Vivienda        redatam
#> 4  cuestionario todas_viviendas Características de la Vivienda        redatam
#> 5  cuestionario todas_viviendas Características de la Vivienda        redatam
#> 6  cuestionario todas_viviendas Características de la Vivienda        redatam
#> 7  cuestionario todas_viviendas Características de la Vivienda        redatam
#> 8  cuestionario todas_viviendas              Servicios Básicos        redatam
#> 9  cuestionario todas_viviendas              Servicios Básicos        redatam
#> 10 cuestionario todas_viviendas              Servicios Básicos        redatam
#> 11 cuestionario todas_viviendas              Servicios Básicos        redatam
#> 12 cuestionario todas_viviendas              Servicios Básicos        redatam
#> 13 cuestionario todas_viviendas              Servicios Básicos        redatam
#> 14 cuestionario todas_viviendas Características de la Vivienda           <NA>
#> 15 cuestionario todas_viviendas Características de la Vivienda        redatam
#> 16 cuestionario todas_viviendas Características de la Vivienda        redatam
#> 17 cuestionario todas_viviendas              Servicios Básicos        redatam
#> 18 cuestionario todas_viviendas Características de la Vivienda        redatam
#> 19 cuestionario todas_viviendas                          Salud        redatam
#> 20 cuestionario todas_viviendas                          Salud        redatam
#> 21 cuestionario todas_viviendas                          Salud           <NA>
#> 22 cuestionario todas_viviendas                          Salud        redatam
#> 23 cuestionario todas_viviendas                          Salud           <NA>
#> 24 cuestionario todas_viviendas                          Salud           <NA>
#> 25 cuestionario todas_viviendas                          Salud           <NA>
#> 26 cuestionario todas_viviendas                          Salud           <NA>
#> 27 cuestionario            <NA>                           <NA>           <NA>
#> 28 cuestionario            <NA>                           <NA>           <NA>
#> 29 cuestionario todas_viviendas                       Religión           <NA>
#> 30 cuestionario todas_viviendas                       Religión           <NA>
#> 31 cuestionario todas_viviendas                       Religión           <NA>
#> 32 cuestionario            <NA>                           <NA>        redatam
#> 33 cuestionario todas_viviendas                     Mortalidad        redatam
#> 34 cuestionario todas_viviendas                           <NA>           <NA>
#> 35 cuestionario todas_viviendas                           <NA>           <NA>
#> 36 cuestionario todas_viviendas                           <NA>        redatam
#> 37 cuestionario            <NA>                           <NA>           <NA>
#> 38 cuestionario            <NA>                           <NA>           <NA>
#> 39 cuestionario            <NA>                           <NA>           <NA>
#> 40    geografia            <NA>                           <NA>        redatam
#> 41     derivada            <NA>                           <NA>        redatam
#> 42     derivada            <NA>                           <NA>        redatam
#> 43    geografia            <NA>                           <NA>           <NA>
#> 44    geografia            <NA>                           <NA>           <NA>
#> 45    geografia            <NA>                           <NA>           <NA>
#> 
#> 3 columnas sin datos aquí: capitulo, bloque, denominador

# Por tema, y comparando entre censos
codebook(tema = "educacion", tabla = "persona")
#>          variable
#> 1      p38_asiste
#> 2     p39_tipoest
#> 3         p40_lee
#> 4      p41a_nivel
#> 5      p41b_curso
#> 6  p41a_nivel_act
#> 7  p41b_curso_act
#> 8       nivel_edu
#> 9        aestudio
#> 10         asiste
#> 11       gedadedu
#>                                                                                                              etiqueta
#> 1                                                                          38. Actualmente, asiste como estudiante a:
#> 2                                                         39. El centro o establecimiento educativo al que asiste es:
#> 3                                                                                            40. Sabe leer y escribir
#> 4                                     41.A. Cuál es el último curso o año que aprobó y en que nivel educativo (Nivel)
#> 5                               41.B. Cuál es el último curso o año que aprobó y en que nivel educativo (Curso o Año)
#> 6                                                    Nivel educativo alcanzado: sistema actual (5 o más años de edad)
#> 7                                                         Curso o año aprobado: sistema actual (5 o más años de edad)
#> 8  Nivel educativo alcanzado agrupado (19 o más años de edad, residentes en el país y que respondieron a la pregunta)
#> 9                     Años de estudio (19 o más años de edad, residentes en el país y que respondieron a la pregunta)
#> 10                                      Asistencia educativa (residentes en el país y que respondieron a la pregunta)
#> 11                  Grupo de edad según asistencia educativa (residentes en el país y que respondieron a la pregunta)
#>      tabla    categorias       tipo      tema capitulo pregunta pregunta_num
#> 1  persona  9 categorías categorica educacion        G       38           38
#> 2  persona  3 categorías categorica educacion        G       39           39
#> 3  persona  3 categorías categorica educacion        G       40           40
#> 4  persona 14 categorías categorica educacion        G     41.A           41
#> 5  persona                 numerica educacion        G     41.B           41
#> 6  persona 11 categorías categorica educacion        G     41.A           41
#> 7  persona                 numerica educacion        G     41.B           41
#> 8  persona  4 categorías categorica educacion        G     <NA>           NA
#> 9  persona                 numerica educacion        G     <NA>           NA
#> 10 persona  2 categorías categorica educacion        G     <NA>           NA
#> 11 persona  7 categorías categorica educacion        G     <NA>           NA
#>          origen        universo
#> 1  cuestionario  todas_personas
#> 2  cuestionario  todas_personas
#> 3  cuestionario  personas_5_mas
#> 4  cuestionario  personas_5_mas
#> 5  cuestionario  personas_5_mas
#> 6      derivada  personas_5_mas
#> 7      derivada  personas_5_mas
#> 8      derivada personas_19_mas
#> 9      derivada personas_19_mas
#> 10     derivada  todas_personas
#> 11     derivada  todas_personas
#> 
#> 4 columnas sin datos aquí: grupo_ine, bloque, denominador, valores_fuente
codebook(tema = "educacion", tabla = "persona", anio = 2012)
#>        variable                                 etiqueta   tabla    categorias
#> 1           P35                     Sabe leer y escribir persona  3 categorías
#> 2           P36           Asiste a una escuela o colegio persona  5 categorías
#> 3 P37A_NIVELNUE Nivel más alto de instrucción que aprobó persona 14 categorías
#>         tipo      tema pregunta pregunta_num       origen       universo
#> 1 categorica educacion       35           35 cuestionario todas_personas
#> 2 categorica educacion       36           36 cuestionario todas_personas
#> 3 categorica educacion     37.A           37 cuestionario todas_personas
#>                           grupo_ine valores_fuente
#> 1 Características Sociodemográficas        redatam
#> 2 Características Sociodemográficas        redatam
#> 3 Características Sociodemográficas        redatam
#> 
#> 3 columnas sin datos aquí: capitulo, bloque, denominador

# Por capítulo del cuestionario, solo las preguntas directas
codebook(capitulo = "C", origen = "cuestionario")
#>          variable
#> 1       v03_pared
#> 2       v04_revoq
#> 3       v05_techo
#> 4        v06_piso
#> 5     v07_aguapro
#> 6    v08_aguadist
#> 7     v09_energia
#> 8      v10_combus
#> 9      v11_basura
#> 10     v12_cocina
#> 11    v13_habitac
#> 12     v14_dormit
#> 13    v15_servsan
#> 14    v16_desague
#> 15   v17_tenencia
#> 16      v18a_bici
#> 17      v18b_moto
#> 18      v18c_auto
#> 19   v18d_carreta
#> 20      v18e_bote
#> 21     v18f_refri
#> 22     v18g_micro
#> 23   v18h_calefon
#> 24      v18i_aire
#> 25  v18j_lavadora
#> 26     v19a_radio
#> 27        v19b_tv
#> 28     v19c_compu
#> 29   v19d_celular
#> 30  v19e_inetfijo
#> 31 v19f_inetmovil
#> 32   v19g_tvcable
#> 33   v19h_telfijo
#>                                                                                etiqueta
#> 1  3. Cual es el material de construcción más utilizado en las paredes de esta vivienda
#> 2                            4. Las paredes interiores de esta vivienda. Tienen revoque
#> 3   5. Cuál es el material de construcción más utilizado en los techos de esta vivienda
#> 4                    6. Cuál es el material más utilizado en los pisos de esta vivienda
#> 5                       7. Principalmente, el agua que usan en la vivienda proviene de:
#> 6                                     8. El agua que usan en la vivienda se distribuye:
#> 7                     9. De donde proviene la energía eléctrica que usan en la vivienda
#> 8               10. Cuál es el principal combustible o energía que utiliza para cocinar
#> 9                                11. Habitualmente. Qué hacen con la basura que generan
#> 10                                               12. Tienen un cuarto solo para cocinar
#> 11                  13. Cuántos cuartos o habitaciones ocupan, sin contar baño y cocina
#> 12            14. De estos cuartos o habitaciones, Cuántos se utilizan solo para dormir
#> 13                                                           15. Tienen, baño o letrina
#> 14                                                 16. El baño o letrina tiene desagüe:
#> 15                             17. La vivienda que ocupan es: (Tenencia de la vivienda)
#> 16                                                      18.1. Su hogar tiene: Bicicleta
#> 17                                      18.2. Su hogar tiene: Motocicleta o cuadratrack
#> 18                                             18.3. Su hogar tiene: Vehículo automotor
#> 19                                             18.4. Su hogar tiene: Carreta o carretón
#> 20                                18.5. Su hogar tiene: Deslizador, balsa, canoa o bote
#> 21                                     18.6. Su hogar tiene: Refrigerador o congeladora
#> 22                                                     18.7. Su hogar tiene: Microondas
#> 23                                           18.8. Su hogar tiene: Calefón, termotanque
#> 24                                             18.9. Su hogar tiene: Aire acondicionado
#> 25                                              18.10. Su hogar tiene: Lavadora de ropa
#> 26                                       19.1. Su hogar tiene: Radio o equipo de sonido
#> 27                                                      19.2. Su hogar tiene: Televisor
#> 28                                   19.3. Su hogar tiene: Computadora, laptop o tablet
#> 29                                               19.4. Su hogar tiene: Teléfono celular
#> 30                                   19.5. Su hogar tiene: Internet fijo en la vivienda
#> 31                                 19.6. Su hogar tiene: Internet móvil (megas o datos)
#> 32                               19.7. Su hogar tiene: Servicio de TV cable o satelital
#> 33                                     19.8. Su hogar tiene: Servicio de telefonía fija
#>       tabla   categorias       tipo                    tema capitulo pregunta
#> 1  vivienda 7 categorías categorica materiales_construccion        C        3
#> 2  vivienda 2 categorías categorica materiales_construccion        C        4
#> 3  vivienda 5 categorías categorica materiales_construccion        C        5
#> 4  vivienda 9 categorías categorica materiales_construccion        C        6
#> 5  vivienda 9 categorías categorica       servicios_basicos        C        7
#> 6  vivienda 3 categorías categorica       servicios_basicos        C        8
#> 7  vivienda 5 categorías categorica       servicios_basicos        C        9
#> 8  vivienda 8 categorías categorica       servicios_basicos        C       10
#> 9  vivienda 7 categorías categorica       servicios_basicos        C       11
#> 10 vivienda 2 categorías categorica          vivienda_hogar        C       12
#> 11 vivienda 8 categorías categorica          vivienda_hogar        C       13
#> 12 vivienda 9 categorías categorica          vivienda_hogar        C       14
#> 13 vivienda 3 categorías categorica       servicios_basicos        C       15
#> 14 vivienda 6 categorías categorica       servicios_basicos        C       16
#> 15 vivienda 8 categorías categorica          vivienda_hogar        C       17
#> 16 vivienda 3 categorías categorica      equipamiento_hogar        C     18.1
#> 17 vivienda 3 categorías categorica      equipamiento_hogar        C     18.2
#> 18 vivienda 3 categorías categorica      equipamiento_hogar        C     18.3
#> 19 vivienda 3 categorías categorica      equipamiento_hogar        C     18.4
#> 20 vivienda 3 categorías categorica      equipamiento_hogar        C     18.5
#> 21 vivienda 3 categorías categorica      equipamiento_hogar        C     18.6
#> 22 vivienda 3 categorías categorica      equipamiento_hogar        C     18.7
#> 23 vivienda 3 categorías categorica      equipamiento_hogar        C     18.8
#> 24 vivienda 3 categorías categorica      equipamiento_hogar        C     18.9
#> 25 vivienda 3 categorías categorica      equipamiento_hogar        C    18.10
#> 26 vivienda 3 categorías categorica                     tic        C     19.1
#> 27 vivienda 3 categorías categorica                     tic        C     19.2
#> 28 vivienda 3 categorías categorica                     tic        C     19.3
#> 29 vivienda 3 categorías categorica                     tic        C     19.4
#> 30 vivienda 3 categorías categorica                     tic        C     19.5
#> 31 vivienda 3 categorías categorica                     tic        C     19.6
#> 32 vivienda 3 categorías categorica                     tic        C     19.7
#> 33 vivienda 3 categorías categorica                     tic        C     19.8
#>    pregunta_num       origen            universo
#> 1             3 cuestionario viviendas_presentes
#> 2             4 cuestionario viviendas_presentes
#> 3             5 cuestionario viviendas_presentes
#> 4             6 cuestionario viviendas_presentes
#> 5             7 cuestionario viviendas_presentes
#> 6             8 cuestionario viviendas_presentes
#> 7             9 cuestionario viviendas_presentes
#> 8            10 cuestionario viviendas_presentes
#> 9            11 cuestionario viviendas_presentes
#> 10           12 cuestionario viviendas_presentes
#> 11           13 cuestionario viviendas_presentes
#> 12           14 cuestionario viviendas_presentes
#> 13           15 cuestionario viviendas_presentes
#> 14           16 cuestionario viviendas_presentes
#> 15           17 cuestionario viviendas_presentes
#> 16           18 cuestionario viviendas_presentes
#> 17           18 cuestionario viviendas_presentes
#> 18           18 cuestionario viviendas_presentes
#> 19           18 cuestionario viviendas_presentes
#> 20           18 cuestionario viviendas_presentes
#> 21           18 cuestionario viviendas_presentes
#> 22           18 cuestionario viviendas_presentes
#> 23           18 cuestionario viviendas_presentes
#> 24           18 cuestionario viviendas_presentes
#> 25           18 cuestionario viviendas_presentes
#> 26           19 cuestionario viviendas_presentes
#> 27           19 cuestionario viviendas_presentes
#> 28           19 cuestionario viviendas_presentes
#> 29           19 cuestionario viviendas_presentes
#> 30           19 cuestionario viviendas_presentes
#> 31           19 cuestionario viviendas_presentes
#> 32           19 cuestionario viviendas_presentes
#> 33           19 cuestionario viviendas_presentes
#> 
#> 4 columnas sin datos aquí: grupo_ine, bloque, denominador, valores_fuente
```

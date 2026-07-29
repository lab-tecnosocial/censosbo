# Explorar el censo por tema

El CPV-2024 tiene 393 variables. Buscarlas por nombre funciona cuando ya
sabes qué buscas, pero no ayuda a responder «¿qué hay sobre educación?»
ni —más importante— «¿a quién se le preguntó esto?». Esta viñeta cubre
las dos cosas.

## Los temas

Cada variable pertenece a uno de 21 temas, y el mismo vocabulario se
aplica a los cinco censos. Diecisiete son los que el propio INE declara
en su catálogo ANDA; los otros cuatro los añade el paquete y están
marcados en la columna `fuente`.

``` r

censo_temas()[, c("tema", "etiqueta", "capitulo", "n_variables")]
#>                          tema                                     etiqueta
#> 1        ubicacion_geografica                         Ubicación geográfica
#> 2              identificacion                  Identificación de registros
#> 3              vivienda_hogar                             Vivienda y hogar
#> 4     materiales_construccion                   Materiales de construcción
#> 5           servicios_basicos                  Servicios básicos del hogar
#> 6          equipamiento_hogar                       Equipamiento del hogar
#> 7                         tic Tecnologías de la información y comunicación
#> 8    emigracion_internacional                     Emigración internacional
#> 9                  mortalidad                                   Mortalidad
#> 10                  poblacion                                    Población
#> 11                 ciudadania                                   Ciudadanía
#> 12     salud_seguridad_social                     Salud y seguridad social
#> 13               discapacidad                                 Discapacidad
#> 14                  educacion                                    Educación
#> 15                    idiomas                                      Idiomas
#> 16         autoidentificacion                           Autoidentificación
#> 17                  migracion                                    Migración
#> 18          movilidad_trabajo            Movilidad cotidiana para trabajar
#> 19 caracteristicas_economicas                   Características económicas
#> 20                 fecundidad                                   Fecundidad
#>    capitulo n_variables
#> 1         A          22
#> 2         A           8
#> 3         B          32
#> 4         C          27
#> 5         C          48
#> 6         C          10
#> 7         C          15
#> 8         D           6
#> 9         E           8
#> 10        G          18
#> 11        G           2
#> 12        G          37
#> 13        G           5
#> 14        G          23
#> 15        G           8
#> 16        G           3
#> 17        G          46
#> 18        G           7
#> 19        G          54
#> 20        G          14
```

El conteo se calcula en el momento, así que puedes acotarlo a una tabla:

``` r

censo_temas(tabla = "vivienda")[, c("tema", "etiqueta", "n_variables")]
#>                       tema                                     etiqueta
#> 1     ubicacion_geografica                         Ubicación geográfica
#> 2           identificacion                  Identificación de registros
#> 3           vivienda_hogar                             Vivienda y hogar
#> 4  materiales_construccion                   Materiales de construcción
#> 5        servicios_basicos                  Servicios básicos del hogar
#> 6       equipamiento_hogar                       Equipamiento del hogar
#> 7                      tic Tecnologías de la información y comunicación
#> 8 emigracion_internacional                     Emigración internacional
#> 9               mortalidad                                   Mortalidad
#>   n_variables
#> 1           4
#> 2           1
#> 3           8
#> 4           4
#> 5           7
#> 6          10
#> 7          10
#> 8           2
#> 9           2
```

Para ver las variables de un tema,
[`codebook()`](https://lab-tecnosocial.github.io/censosbo/reference/codebook.md)
acepta el argumento `tema`:

``` r

codebook(tema = "educacion", tabla = "persona")[, c("variable", "etiqueta", "universo")]
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
#>           universo
#> 1   todas_personas
#> 2   todas_personas
#> 3   personas_5_mas
#> 4   personas_5_mas
#> 5   personas_5_mas
#> 6   personas_5_mas
#> 7   personas_5_mas
#> 8  personas_19_mas
#> 9  personas_19_mas
#> 10  todas_personas
#> 11  todas_personas
```

## Descargar solo un tema

[`vars_tema()`](https://lab-tecnosocial.github.io/censosbo/reference/vars_tema.md)
devuelve los nombres en el orden del cuestionario, listos para el
argumento `variables`:

``` r

vars_tema("educacion", tabla = "persona")
#>  [1] "p38_asiste"     "p39_tipoest"    "p40_lee"        "p41a_nivel"    
#>  [5] "p41b_curso"     "p41a_nivel_act" "p41b_curso_act" "aestudio"      
#>  [9] "asiste"         "gedadedu"       "nivel_edu"
```

``` r

get_personas_2024(
  departamento = "Cochabamba",
  variables = vars_tema("educacion", tabla = "persona")
)
```

Las derivadas del INE van al final. Si solo quieres las preguntas tal
cual se hicieron, filtra por `origen`:

``` r

vars_tema("caracteristicas_economicas", tabla = "persona", origen = "cuestionario")
#> [1] "p43_pago"     "p44_nego"     "p45_agro"     "p46_dest"     "p47_otro"    
#> [6] "p48_nocu"     "p49_ocu_1d"   "p50_semp"     "p51_actec_2d"
```

## El universo: a quién se le preguntó

Esta es la columna que más errores evita. El cuestionario del CPV-2024
lleva impresos cuatro filtros de edad y sexo, y varias variables
derivadas se calculan sobre poblaciones aún más restringidas.
Compararlas sin tenerlo en cuenta produce cifras equivocadas sin ningún
aviso.

``` r

codebook(c("p40_lee", "p43_pago", "p53_ecivil", "p54_hvtot", "nivel_edu"),
         tabla = "persona")[, c("variable", "etiqueta", "universo")]
#>     variable
#> 1    p40_lee
#> 2   p43_pago
#> 3 p53_ecivil
#> 4  p54_hvtot
#> 5  nivel_edu
#>                                                                                                                                          etiqueta
#> 1                                                                                                                        40. Sabe leer y escribir
#> 2                                                                                             43. La semana pasada, trabajó por un pago o ingreso
#> 3                                                                                                          53. Cuál es su estado civil o conyugal
#> 4 54. En total, Cuántas hijas e hijos nacidos vivos ha tenido, incluyendo a los que no vivan con usted o hayan fallecido después de nacer (Total)
#> 5                              Nivel educativo alcanzado agrupado (19 o más años de edad, residentes en el país y que respondieron a la pregunta)
#>          universo
#> 1  personas_5_mas
#> 2  personas_7_mas
#> 3 personas_12_mas
#> 4  mujeres_12_mas
#> 5 personas_19_mas
```

Ahí se ve por qué importa: `nivel_edu` **no** describe a toda la
población, sino a las personas de 19 años o más. Si calculas el
porcentaje con secundaria sobre el total de personas, el denominador
incluye a menores que nunca pudieron responder y el resultado sale hacia
abajo. El universo correcto es el que declara la variable.

Para ver todas las variables que comparten un universo:

``` r

cb <- codebook(tabla = "persona")
table(cb$universo, useNA = "no")
#> 
#>  mujeres_12_mas   mujeres_15_49 personas_12_mas personas_19_mas  personas_5_mas 
#>              12               2               1               2              13 
#>  personas_7_mas  todas_personas 
#>              29              55
```

La versión textual del INE, con sus palabras exactas, está en
[`codebook_docs()`](https://lab-tecnosocial.github.io/censosbo/reference/codebook_docs.md):

``` r

codebook_docs("p40_lee", campos = "universo_literal")$universo_literal
#> [1] "Solo para personas de 5 años o más de edad."
```

## Qué mide exactamente una variable

[`codebook_docs()`](https://lab-tecnosocial.github.io/censosbo/reference/codebook_docs.md)
da acceso a la documentación conceptual oficial: la definición, la
pregunta tal como se leyó en campo y las instrucciones que recibió el
censista.

``` r

codebook_docs("p32_pueblo_per", campos = "definicion")$definicion
#> [1] "Autoidentificación: Es la expresión individual de identificación, cercanía o pertenencia a alguna nación o pueblo indígena originario campesino o afroboliviano, basada en la interacción con su entorno social, adoptando formas de pensamiento y comportamiento en términos de idioma, cultura y/o costumbres que hacen que la persona que se expresa se sienta parte de un grupo social diferente de otro. - Naciones o Pueblos Indígena Originario Campesinos (NPIOC): Son aquellos conjuntos de personas que descienden de poblaciones asentadas con anterioridad a la invasión española y comparten identidad cultural, idioma, tradición histórica, instituciones, territorialidad y/o cosmovisión. Estos se encuentran dentro de las actuales fronteras del territorio boliviano. - Pueblo afroboliviano: Es la colectividad de ascendencia africana llegada a territorio boliviano durante la época colonial, la cual preserva y reproduce total o parcialmente sus tradiciones espirituales, religiosas, culturales y artísticas como la música y danza."
```

``` r

codebook_docs("v17_tenencia", campos = "pregunta_literal")$pregunta_literal
#> [1] "17. La vivienda que ocupan es: 1 Propia y totalmente pagada 2 Propia y la están pagando 3 Prestada por parientes o amigos 4 Alquilada 5 En contrato anticrético 6 En contrato mixto (anticrético y alquiler) 7 Cedida por servicios 8 Otra"
```

Y para las variables que el INE construyó, la regla con la que las
calculó:

``` r

codebook_docs("nivel_edu", campos = "regla_derivacion")$regla_derivacion
#> [1] "Variable derivada a partir de la variable P41A_NIVEL_ACT), “Nivel educativo alcanzado: sistema actual”. Agrupa el nivel educativo alcanzado en las siguientes categorías: 1. Ninguno (categorías 1 al 3 de la variable P41A_NIVEL_ACT), 2. Primaria (categoría 7 de P41A_NIVEL_ACT), 3. Secundaria (categoría 8 de P41A_NIVEL_ACT) y 4. Superior (categorías 9 al 13 de P41A_NIVEL_ACT)."
```

Distinguir una pregunta de una construcción del INE es útil por sí
mismo:

``` r

table(codebook(tabla = "persona")$origen)
#> 
#>  cuestionario      derivada     geografia identificador 
#>            72            42             4             1
```

## Capítulos: la estructura del cuestionario

El cuestionario del CPV-2024 tiene siete capítulos, de la A a la G.
`capitulo` reproduce esa estructura, así que puedes recorrer el censo en
el mismo orden en que se aplicó:

``` r

codebook(capitulo = "C", origen = "cuestionario")[, c("pregunta", "variable", "etiqueta")]
#>    pregunta       variable
#> 1         3      v03_pared
#> 2         4      v04_revoq
#> 3         5      v05_techo
#> 4         6       v06_piso
#> 5         7    v07_aguapro
#> 6         8   v08_aguadist
#> 7         9    v09_energia
#> 8        10     v10_combus
#> 9        11     v11_basura
#> 10       12     v12_cocina
#> 11       13    v13_habitac
#> 12       14     v14_dormit
#> 13       15    v15_servsan
#> 14       16    v16_desague
#> 15       17   v17_tenencia
#> 16     18.1      v18a_bici
#> 17     18.2      v18b_moto
#> 18     18.3      v18c_auto
#> 19     18.4   v18d_carreta
#> 20     18.5      v18e_bote
#> 21     18.6     v18f_refri
#> 22     18.7     v18g_micro
#> 23     18.8   v18h_calefon
#> 24     18.9      v18i_aire
#> 25    18.10  v18j_lavadora
#> 26     19.1     v19a_radio
#> 27     19.2        v19b_tv
#> 28     19.3     v19c_compu
#> 29     19.4   v19d_celular
#> 30     19.5  v19e_inetfijo
#> 31     19.6 v19f_inetmovil
#> 32     19.7   v19g_tvcable
#> 33     19.8   v19h_telfijo
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
```

Un detalle que conviene saber: **capítulo y tema son dos ejes
independientes**, no una jerarquía. `v01_tipoviv` está en el capítulo B
y `v17_tenencia` en el C, y las dos son del tema `vivienda_hogar`,
porque el cuestionario separó el tipo de vivienda de su tenencia aunque
conceptualmente vayan juntas.

``` r

codebook(tema = "vivienda_hogar", tabla = "vivienda")[, c("variable", "capitulo", "pregunta")]
#>       variable capitulo pregunta
#> 1  v01_tipoviv        B        1
#> 2 v02_condocup        B        2
#> 3   v12_cocina        C       12
#> 4  v13_habitac        C       13
#> 5   v14_dormit        C       14
#> 6 v17_tenencia        C       17
#> 7     tot_pers        B     <NA>
#> 8      tip_hog        B     <NA>
```

## Comparar entre censos

Los temas son el eje transversal: el mismo vocabulario se aplica a los
cinco censos, porque el INE publica un diccionario DDI de todos ellos.

``` r

for (anio in c(1976, 1992, 2001, 2012, 2024)) {
  # En 1976 la tabla de personas se llama `poblacion`.
  tabla <- if (anio == 1976) "poblacion" else "persona"
  cb <- codebook(tema = "educacion", tabla = tabla, anio = anio)
  cat(anio, "->", nrow(cb), "variables:", paste(cb$variable, collapse = ", "), "\n")
}
#> 1976 -> 5 variables: p10, p11, p14, anioes1, nivela 
#> 1992 -> 5 variables: P10, P11, P12, P13, P14 
#> 2001 -> 7 variables: P36, P37, P38, P39NIV, P39CUR, P40NIV, P40CUR 
#> 2012 -> 3 variables: P35, P36, P37A_NIVELNUE 
#> 2024 -> 11 variables: p38_asiste, p39_tipoest, p40_lee, p41a_nivel, p41b_curso, p41a_nivel_act, p41b_curso_act, nivel_edu, aestudio, asiste, gedadedu
```

Un tema existe solo en un censo: **religión**, que preguntó únicamente
el de 1992.

``` r

codebook(tema = "religion", anio = 1992)[, c("variable", "etiqueta")]
#>   variable                         etiqueta
#> 1      V16 No pertenecen a ninguna religión
#> 2     V16B                Religión católica
#> 3     V16C              Religión evangélica
#> 4     V16D                    Otra religión
#> 5     V16E                Religión ignorada
```

Los capítulos, en cambio, **solo existen en 2024**: los cuestionarios
anteriores tienen otra estructura, el de 2001 no numera sus etiquetas y
los de 1976 y 1992 numeran las secciones de vivienda y de persona en
paralelo (`v03` es el material de las paredes y `p03` el sexo). Lo que
sí traen los cuatro anteriores es la agrupación oficial del INE de su
época, en la columna `grupo_ine`:

``` r

table(codebook(anio = 1992)$grupo_ine, useNA = "no")
#> 
#>            Actividad Económica Características de la Vivienda 
#>                              5                             10 
#>   Características Demográficas                      Educación 
#>                             13                              5 
#>                     Fecundidad                      Migración 
#>                              6                             15 
#>                     Mortalidad                       Religión 
#>                              1                              3 
#>                          Salud              Servicios Básicos 
#>                              8                              7
```

### El universo también cambió entre censos

Esta es la razón principal por la que vale la pena tener el metadato de
los cinco censos: el INE movió el filtro de edad de varias preguntas,
así que comparar una serie temporal sin igualar el universo mide
poblaciones distintas en cada punto.

``` r

for (anio in c(1976, 1992, 2001, 2024)) {
  v <- switch(as.character(anio), "1976" = "p10", "1992" = "P10",
              "2001" = "P36", "2024" = "p40_lee")
  tabla <- if (anio == 1976) "poblacion" else "persona"
  cat(anio, "alfabetismo ->", codebook(v, tabla = tabla, anio = anio)$universo, "\n")
}
#> 1976 alfabetismo -> personas_5_mas 
#> 1992 alfabetismo -> personas_6_mas 
#> 2001 alfabetismo -> personas_4_mas 
#> 2024 alfabetismo -> personas_5_mas
```

[`get_temporal()`](https://lab-tecnosocial.github.io/censosbo/reference/get_temporal.md)
avisa de esto automáticamente cuando se piden variables armonizadas cuyo
universo no coincide entre los años solicitados.

## Los indicadores de manzano y comunidad

Las fichas del geoportal tienen su propio desglose, más fino que el
tema: 15 bloques. Conviven con la taxonomía, así que puedes usar el que
te convenga.

``` r

censo_bloques_meta[, c("bloque", "etiqueta", "tema")]
#>          bloque                  etiqueta                       tema
#> 1        unidad             Unidad censal             identificacion
#> 2     poblacion                 Población                  poblacion
#> 3     educacion                 Educación                  educacion
#> 4   salud_lugar Salud · dónde se atienden     salud_seguridad_social
#> 5  salud_seguro            Salud · seguro     salud_seguridad_social
#> 6    nacimiento       Lugar de nacimiento                  migracion
#> 7    residencia       Residencia habitual                  migracion
#> 8     ocupacion                 Ocupación caracteristicas_economicas
#> 9     actividad       Actividad económica caracteristicas_economicas
#> 10     vivienda                  Vivienda             vivienda_hogar
#> 11    servicios         Servicios básicos          servicios_basicos
#> 12          tic                       TIC                        tic
#> 13     material Materiales de la vivienda    materiales_construccion
#> 14 hacinamiento              Hacinamiento             vivienda_hogar
#> 15        hogar             Tipo de hogar             vivienda_hogar
```

Cada indicador es un conteo, y para leerlo como porcentaje hace falta el
total sobre el que se calcula. Eso está en `denominador`:

``` r

codebook(tabla = "ficha")[3:8, c("variable", "bloque", "denominador")]
#>          variable    bloque denominador
#> 3            idep    unidad        <NA>
#> 4           iprov    unidad        <NA>
#> 5            imun    unidad        <NA>
#> 6     pob_total_h poblacion        <NA>
#> 7     pob_total_m poblacion        <NA>
#> 8 pob_edad_0a19_h poblacion pob_total_h
```

Las variables cuyo `denominador` es `NA` son los totales mismos.

## Fuentes y atribución

La taxonomía y los metadatos de contexto se construyen a partir de dos
fuentes oficiales del INE Bolivia:

- El **cuestionario censal del CPV-2024**, de donde salen los capítulos,
  la numeración de preguntas y los filtros de universo impresos en el
  formulario.
- Los **diccionarios DDI del catálogo ANDA**, estudios 132 (CPV-2024), 8
  (CPV-2012), 10 (CNPV-2001), 47 (CNPV-1992) y 46 (CNPV-1976), de donde
  salen los temas oficiales, el universo de cada variable, las
  definiciones conceptuales, las preguntas literales y las reglas de
  derivación.

Los textos de `codebook_docs_meta` se reproducen literalmente; el INE
los publica bajo la condición «Uso público». El objeto guarda la
procedencia exacta de los archivos usados:

``` r

attr(codebook_docs_meta, "ddi")[, c("anio", "estudio", "idno", "fecha")]
#>   anio estudio                 idno      fecha
#> 1 2024     132     BOL-INE-CPV-2024 2026-07-29
#> 2 2012       8     BOL-INE-CPV-2012 2026-07-29
#> 3 2001      10    BOL-INE-CNPV-2001 2026-07-29
#> 4 1992      47    BOL-INE-CNPV-1992 2026-07-29
#> 5 1976      46 BOL-INE-CNPV-1976-V3 2026-07-29
```

Un aviso que el propio contraste con estas fuentes hizo evidente: el DDI
del INE tiene errores puntuales. En el CPV-2012, la variable de estado
civil viene con las categorías de otra pregunta. Por eso el paquete
**nunca sobrescribe** las etiquetas de valor que ya trae el diccionario
de microdatos; las discrepancias se registran para revisión en
`data-raw/ddi/reporte_valores.md`.

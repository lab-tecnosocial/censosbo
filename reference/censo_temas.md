# Consulta los temas de un censo, con el número de variables de cada uno

Devuelve el catálogo de \[censo_temas_meta\] contando, en vivo, cuántas
variables tiene cada tema en el censo y la tabla que se pidan. El conteo
se calcula sobre el codebook en el momento de la llamada, así que nunca
se desincroniza.

## Usage

``` r
censo_temas(tema = NULL, capitulo = NULL, tabla = NULL, anio = 2024)
```

## Arguments

- tema:

  Caracteres. Filtra a uno o varios temas por su slug.

- capitulo:

  Caracteres. Filtra por capítulo del cuestionario del CPV-2024: la
  letra (\`"C"\`) o parte de su nombre (\`"vivienda"\`).

- tabla:

  Caracteres. Restringe el conteo a una tabla (e.g. \`"persona"\`). Con
  este argumento se omiten los temas que no tienen ninguna variable ahí.

- anio:

  Entero. \`2024\` (defecto), \`2012\` o \`2001\`.

## Value

Un data.frame con \`tema\`, \`etiqueta\`, \`capitulo\`,
\`capitulo_etiqueta\`, \`fuente\`, \`n_variables\` y \`descripcion\`,
ordenado por capítulo y cuestionario.

## See also

\[vars_tema()\] para obtener los nombres de las variables de un tema, y
\[codebook()\] para sus etiquetas y categorías.

## Examples

``` r
# Los 20 temas del CPV-2024, con cuántas variables tiene cada uno
censo_temas()
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
#>    capitulo               capitulo_etiqueta   fuente n_variables
#> 1         A      Ubicación e identificación censosbo          22
#> 2         A      Ubicación e identificación censosbo           8
#> 3         B                Tipo de vivienda INE-ANDA          32
#> 4         C  Características de la vivienda censosbo          27
#> 5         C  Características de la vivienda INE-ANDA          48
#> 6         C  Características de la vivienda INE-ANDA          10
#> 7         C  Características de la vivienda INE-ANDA          15
#> 8         D        Emigración internacional INE-ANDA           6
#> 9         E                      Mortalidad INE-ANDA           8
#> 10        G Características de cada persona INE-ANDA          18
#> 11        G Características de cada persona INE-ANDA           2
#> 12        G Características de cada persona INE-ANDA          37
#> 13        G Características de cada persona INE-ANDA           5
#> 14        G Características de cada persona INE-ANDA          23
#> 15        G Características de cada persona INE-ANDA           8
#> 16        G Características de cada persona INE-ANDA           3
#> 17        G Características de cada persona INE-ANDA          46
#> 18        G Características de cada persona INE-ANDA           7
#> 19        G Características de cada persona INE-ANDA          54
#> 20        G Características de cada persona INE-ANDA          14
#>                                                                                                                                                                                                                                                                                                                                                       descripcion
#> 1                                                                                                       Claves geográficas (departamento, provincia, municipio) y área urbana/rural. Extensión de censosbo: el INE no la lista como tema porque no son preguntas del cuestionario, pero son las variables con las que se filtra y agrupa casi cualquier análisis.
#> 2                                                                                                                                                                                                                                  Identificadores de vivienda, unidad censal y ficha. Extensión de censosbo: no son datos censales sino claves para unir tablas.
#> 3                                                                               Tipo de vivienda, condición de ocupación, tenencia, número de habitaciones y dormitorios, hacinamiento y tipología del hogar. Incluye P12-P14 (cuartos) porque describen la vivienda, no su equipamiento; el desglose fino de las fichas sigue disponible en la columna `bloque`.
#> 4                                                                          Materiales de paredes, revoque, techos y pisos. Extensión de censosbo: el INE los incluye en `Vivienda y Hogar`, pero son 27 variables y las fichas de manzano ya los tratan como bloque propio (`material`), así que separarlos mantiene la correspondencia 1:1 con esos indicadores.
#> 5                                                                                                                                                                                                                                     Agua (origen y distribución), energía eléctrica, combustible para cocinar, eliminación de basura, baño o letrina y desagüe.
#> 6                                                                                                                                                                                                     Bienes del hogar de transporte y electrodomésticos: bicicleta, motocicleta, vehículo, refrigerador, microondas, lavadora y otros. Pregunta 18 del CPV-2024.
#> 7                                                                                                                                                                                                                                Radio, televisor, computadora, teléfono celular, internet fijo y móvil, TV por cable y telefonía fija. Pregunta 19 del CPV-2024.
#> 8                                                                                                                                                                                                                                           Personas que vivían en el hogar y ahora residen en otro país: país de destino, sexo, año de salida y edad al emigrar.
#> 9                                                                                                                         Personas fallecidas en los cinco años previos al censo: mes y año, edad al morir, sexo y causa. En 2001 incluye las cuatro variables de mortalidad materna, que el INE agrupa aparte y viven en la tabla de vivienda (ver `grupo_ine`).
#> 10 Sexo, edad, grupos de edad, parentesco con la jefatura del hogar y estado civil. P24 (parentesco) va aquí y no en `vivienda_hogar` porque es un atributo de la persona; la estructura del hogar se mira desde `tip_hog`. P53 (estado civil) también, porque los temas oficiales del INE no contemplan nupcialidad y lo sitúan en características demográficas.
#> 11                                                                                                                                                                                                                                                                                            Inscripción en el registro civil y tenencia de cédula de identidad.
#> 12                                                                                                                                                                                                                                                                     Dónde acude la persona ante problemas de salud, afiliación a seguros y cobertura de salud.
#> 13                                                                                                                                                                                                                                              Dificultad permanente para ver, oír, caminar y comunicarse o aprender, más la condición de discapacidad derivada.
#> 14                                                                                                                                                                                                                                                         Alfabetismo, asistencia escolar, tipo de establecimiento, nivel educativo alcanzado y años de estudio.
#> 15                                                                                                                                                                                                                                                                                                 Idiomas o lenguas que habla según mayor uso, e idioma materno.
#> 16                                                                                                                                                                                                                                                                   Autoidentificación con alguna nación o pueblo indígena originario campesino o afroboliviano.
#> 17                                                                                                                                                                                                                Lugar de nacimiento, residencia habitual y residencia cinco años antes del censo, con sus códigos de departamento, provincia, municipio y país.
#> 18                                                                                                                                                                                                   Ubicación del lugar de trabajo y sus códigos geográficos. El INE lo separa de `caracteristicas_economicas` porque mide desplazamiento, no inserción laboral.
#> 19                                                                                                                                                                                                   Condición de actividad, ocupación, categoría ocupacional y actividad económica, incluidas las derivaciones del INE según las clasificaciones 13ª y 19ª CIET.
#> 20                                                                       Hijas e hijos nacidos vivos y sobrevivientes, edad al primer hijo, fecha del último nacimiento y atención del parto. P59 (quién atendió el parto) va aquí y no en salud para mantener íntegro el bloque P54-P59; quien prefiera la otra lectura puede aislarla con `pregunta_num == 59`.

# Solo los temas presentes en la tabla de vivienda
censo_temas(tabla = "vivienda")
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
#>   capitulo              capitulo_etiqueta   fuente n_variables
#> 1        A     Ubicación e identificación censosbo           4
#> 2        A     Ubicación e identificación censosbo           1
#> 3        B               Tipo de vivienda INE-ANDA           8
#> 4        C Características de la vivienda censosbo           4
#> 5        C Características de la vivienda INE-ANDA           7
#> 6        C Características de la vivienda INE-ANDA          10
#> 7        C Características de la vivienda INE-ANDA          10
#> 8        D       Emigración internacional INE-ANDA           2
#> 9        E                     Mortalidad INE-ANDA           2
#>                                                                                                                                                                                                                                                                              descripcion
#> 1                              Claves geográficas (departamento, provincia, municipio) y área urbana/rural. Extensión de censosbo: el INE no la lista como tema porque no son preguntas del cuestionario, pero son las variables con las que se filtra y agrupa casi cualquier análisis.
#> 2                                                                                                                                                         Identificadores de vivienda, unidad censal y ficha. Extensión de censosbo: no son datos censales sino claves para unir tablas.
#> 3      Tipo de vivienda, condición de ocupación, tenencia, número de habitaciones y dormitorios, hacinamiento y tipología del hogar. Incluye P12-P14 (cuartos) porque describen la vivienda, no su equipamiento; el desglose fino de las fichas sigue disponible en la columna `bloque`.
#> 4 Materiales de paredes, revoque, techos y pisos. Extensión de censosbo: el INE los incluye en `Vivienda y Hogar`, pero son 27 variables y las fichas de manzano ya los tratan como bloque propio (`material`), así que separarlos mantiene la correspondencia 1:1 con esos indicadores.
#> 5                                                                                                                                                            Agua (origen y distribución), energía eléctrica, combustible para cocinar, eliminación de basura, baño o letrina y desagüe.
#> 6                                                                                                                            Bienes del hogar de transporte y electrodomésticos: bicicleta, motocicleta, vehículo, refrigerador, microondas, lavadora y otros. Pregunta 18 del CPV-2024.
#> 7                                                                                                                                                       Radio, televisor, computadora, teléfono celular, internet fijo y móvil, TV por cable y telefonía fija. Pregunta 19 del CPV-2024.
#> 8                                                                                                                                                                  Personas que vivían en el hogar y ahora residen en otro país: país de destino, sexo, año de salida y edad al emigrar.
#> 9                                                Personas fallecidas en los cinco años previos al censo: mes y año, edad al morir, sexo y causa. En 2001 incluye las cuatro variables de mortalidad materna, que el INE agrupa aparte y viven en la tabla de vivienda (ver `grupo_ine`).

# Qué temas cubre el censo 2001
censo_temas(anio = 2001)
#>                          tema                    etiqueta capitulo
#> 1        ubicacion_geografica        Ubicación geográfica        A
#> 2              vivienda_hogar            Vivienda y hogar        B
#> 3     materiales_construccion  Materiales de construcción        C
#> 4           servicios_basicos Servicios básicos del hogar        C
#> 5          equipamiento_hogar      Equipamiento del hogar        C
#> 6                  mortalidad                  Mortalidad        E
#> 7                   poblacion                   Población        G
#> 8                  ciudadania                  Ciudadanía        G
#> 9                   educacion                   Educación        G
#> 10                    idiomas                     Idiomas        G
#> 11         autoidentificacion          Autoidentificación        G
#> 12                  migracion                   Migración        G
#> 13 caracteristicas_economicas  Características económicas        G
#> 14                 fecundidad                  Fecundidad        G
#>                  capitulo_etiqueta   fuente n_variables
#> 1       Ubicación e identificación censosbo          17
#> 2                 Tipo de vivienda INE-ANDA           7
#> 3   Características de la vivienda censosbo           4
#> 4   Características de la vivienda INE-ANDA           7
#> 5   Características de la vivienda INE-ANDA           8
#> 6                       Mortalidad INE-ANDA           7
#> 7  Características de cada persona INE-ANDA           7
#> 8  Características de cada persona INE-ANDA           1
#> 9  Características de cada persona INE-ANDA           7
#> 10 Características de cada persona INE-ANDA           9
#> 11 Características de cada persona INE-ANDA           2
#> 12 Características de cada persona INE-ANDA          28
#> 13 Características de cada persona INE-ANDA           6
#> 14 Características de cada persona INE-ANDA           7
#>                                                                                                                                                                                                                                                                                                                                                       descripcion
#> 1                                                                                                       Claves geográficas (departamento, provincia, municipio) y área urbana/rural. Extensión de censosbo: el INE no la lista como tema porque no son preguntas del cuestionario, pero son las variables con las que se filtra y agrupa casi cualquier análisis.
#> 2                                                                               Tipo de vivienda, condición de ocupación, tenencia, número de habitaciones y dormitorios, hacinamiento y tipología del hogar. Incluye P12-P14 (cuartos) porque describen la vivienda, no su equipamiento; el desglose fino de las fichas sigue disponible en la columna `bloque`.
#> 3                                                                          Materiales de paredes, revoque, techos y pisos. Extensión de censosbo: el INE los incluye en `Vivienda y Hogar`, pero son 27 variables y las fichas de manzano ya los tratan como bloque propio (`material`), así que separarlos mantiene la correspondencia 1:1 con esos indicadores.
#> 4                                                                                                                                                                                                                                     Agua (origen y distribución), energía eléctrica, combustible para cocinar, eliminación de basura, baño o letrina y desagüe.
#> 5                                                                                                                                                                                                     Bienes del hogar de transporte y electrodomésticos: bicicleta, motocicleta, vehículo, refrigerador, microondas, lavadora y otros. Pregunta 18 del CPV-2024.
#> 6                                                                                                                         Personas fallecidas en los cinco años previos al censo: mes y año, edad al morir, sexo y causa. En 2001 incluye las cuatro variables de mortalidad materna, que el INE agrupa aparte y viven en la tabla de vivienda (ver `grupo_ine`).
#> 7  Sexo, edad, grupos de edad, parentesco con la jefatura del hogar y estado civil. P24 (parentesco) va aquí y no en `vivienda_hogar` porque es un atributo de la persona; la estructura del hogar se mira desde `tip_hog`. P53 (estado civil) también, porque los temas oficiales del INE no contemplan nupcialidad y lo sitúan en características demográficas.
#> 8                                                                                                                                                                                                                                                                                             Inscripción en el registro civil y tenencia de cédula de identidad.
#> 9                                                                                                                                                                                                                                                          Alfabetismo, asistencia escolar, tipo de establecimiento, nivel educativo alcanzado y años de estudio.
#> 10                                                                                                                                                                                                                                                                                                 Idiomas o lenguas que habla según mayor uso, e idioma materno.
#> 11                                                                                                                                                                                                                                                                   Autoidentificación con alguna nación o pueblo indígena originario campesino o afroboliviano.
#> 12                                                                                                                                                                                                                Lugar de nacimiento, residencia habitual y residencia cinco años antes del censo, con sus códigos de departamento, provincia, municipio y país.
#> 13                                                                                                                                                                                                   Condición de actividad, ocupación, categoría ocupacional y actividad económica, incluidas las derivaciones del INE según las clasificaciones 13ª y 19ª CIET.
#> 14                                                                       Hijas e hijos nacidos vivos y sobrevivientes, edad al primer hijo, fecha del último nacimiento y atención del parto. P59 (quién atendió el parto) va aquí y no en salud para mantener íntegro el bloque P54-P59; quien prefiera la otra lectura puede aislarla con `pregunta_num == 59`.
```

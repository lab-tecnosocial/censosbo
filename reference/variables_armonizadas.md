# Muestra el mapeo de variables comparables entre censos de Bolivia

Retorna la tabla de variables armonizadas que pueden usarse en análisis
temporales o comparativos entre los censos de 1976, 1992, 2001, 2012 y
el CPV-2024.

## Usage

``` r
variables_armonizadas(tabla = NULL)
```

## Arguments

- tabla:

  Filtrar por tabla de origen: \`"persona"\`, \`"vivienda"\` o \`NULL\`
  para todas. Por defecto \`NULL\`.

## Value

Un data.frame con las variables armonizadas y sus equivalentes en cada
año de censo. La columna \`armonizada\` indica si los códigos son
comparables entre censos (\`TRUE\`) o crudos de cada año (\`FALSE\`).

## Examples

``` r
variables_armonizadas()
#>                variable                                             etiqueta
#> 1                  sexo                                                 Sexo
#> 2                  edad                                         Edad en años
#> 3            grupo_edad                          Grupos de edad quinquenales
#> 4            parentesco                  Relación con el/la jefe/a del hogar
#> 5          estado_civil                              Estado conyugal o civil
#> 6             sabe_leer                                 Sabe leer y escribir
#> 7             nivel_edu                                 Nivel de instrucción
#> 8    asistencia_escolar                          Asistencia educativa actual
#> 9                   pea                         Condición de actividad (PEA)
#> 10                  pet                        Población en Edad de Trabajar
#> 11  categoria_ocupacion                               Categoría en el empleo
#> 12   identidad_indigena               Autoidentificación con pueblo indígena
#> 13       idioma_materno                           Idioma materno o principal
#> 14   migracion_nac_dpto  Migración: departamento de nacimiento vs residencia
#> 15   migracion_rec_dpto Migración reciente: residencia hace 5 años vs actual
#> 16  hijos_nacidos_vivos                 Total de hijos e hijas nacidos vivos
#> 17 hijos_sobrevivientes         Total de hijos e hijas que viven actualmente
#> 18                 area                                  Área urbana o rural
#> 19         departamento                                         Departamento
#> 20     material_paredes              Material de construcción de las paredes
#> 21       material_techo                   Material de construcción del techo
#> 22        material_piso                                    Material del piso
#> 23          fuente_agua                  Fuente de agua para beber y cocinar
#> 24    energia_electrica                  Disponibilidad de energía eléctrica
#> 25   servicio_sanitario                 Disponibilidad de servicio sanitario
#> 26    tenencia_vivienda                              Tenencia de la vivienda
#> 27   habitaciones_total                      Total de habitaciones del hogar
#>                                                                                                                                                        descripcion
#> 1                                                                                        Sexo del individuo. Harmonizado a 1=Mujer, 2=Hombre para todos los censos
#> 2                                                                                                                             Edad del individuo en años cumplidos
#> 3                                                                                                       Grupo de edad en intervalos de 5 años (0-4, 5-9, ..., 80+)
#> 4                                                Parentesco o relación del individuo con el jefe o jefa del hogar. NO armonizada: los códigos varían entre censos.
#> 5                     Situación conyugal del individuo. Harmonizado a 4 categorías: 1=Soltero/a, 2=Casado/a o conviviente, 3=Separado/a o divorciado/a, 4=Viudo/a.
#> 6                                                                                            Indica si el individuo sabe leer y escribir. Harmonizado a 1=Sí, 2=No
#> 7               Nivel educativo más alto alcanzado. Para comparación temporal se harmoniza a 4 categorías: 0=Sin instrucción, 1=Primaria, 2=Secundaria, 3=Superior
#> 8                                                                       Indica si el individuo asiste actualmente a un centro educativo. 1=Sí asiste, 2=No asiste.
#> 9       Condición de actividad económica de la Población Económicamente Activa. 1=Ocupado, 2=Cesante, 3=Aspirante. Los inactivos (fuera de la PEA) quedan como NA.
#> 10                                                                Indica si el individuo está en edad de trabajar. Harmonizado a 1=Sí (en edad de trabajar), 2=No.
#> 11                                   Categoría ocupacional del individuo. 1=Empleado/Obrero, 2=Cuenta propia, 3=Empleador/Patrón, 4=Familiar no remunerado, 5=Otro
#> 12                                  Indica si el individuo se autoidentifica con alguna nación o pueblo indígena originario campesino o afroboliviano. 1=Sí, 2=No.
#> 13                          Idioma aprendido en la niñez o idioma principal. 1=Castellano, 2=Quechua, 3=Aymara, 4=Guaraní, 5=Otro nativo boliviano, 6=Otro idioma.
#> 14          Compara el departamento de nacimiento con el de residencia actual. 1=Nacido en el mismo dpto, 2=Nacido en otro dpto del país, 3=Nacido en el exterior.
#> 15                Compara el departamento de residencia hace 5 años con el actual. 1=Mismo dpto, 2=Otro dpto del país, 3=Estaba en el exterior, 4=No había nacido.
#> 16                                                                        Número total de hijos nacidos vivos que ha tenido la persona (para mujeres de 12+ años).
#> 17                                                                                             Número de hijos nacidos vivos que están vivos al momento del censo.
#> 18                                                                          Área de residencia: 1=Urbana, 2=Rural. Columna directa en todas las tablas de persona.
#> 19                                                                                                                                  Código de departamento (01-09)
#> 20                     Material predominante de las paredes exteriores. 1=Ladrillo/Bloque/Hormigón, 2=Adobe/Tapial, 3=Madera/Tabique/Caña/Palma, 4=Piedra, 5=Otro.
#> 21                                                  Material predominante del techo. 1=Calamina/Plancha/Teja, 2=Losa de hormigón, 3=Paja/Caña/Palma/Barro, 4=Otro.
#> 22                                                                 Material predominante del piso. 1=Tierra, 2=Cemento/Ladrillo, 3=Mosaico/Parquet/Madera, 4=Otro.
#> 23 Fuente principal de agua. 1=Cañería/red pública, 2=Otra fuente protegida (pozo con bomba, carro, pileta), 3=Fuente no protegida (río, acequia, pozo sin bomba).
#> 24                                                                                        Si el hogar cuenta con energía eléctrica (cualquier fuente). 1=Sí, 2=No.
#> 25                                                                                                Si el hogar tiene baño, water o letrina. 1=Sí tiene, 2=No tiene.
#> 26                                                         Forma en que el hogar ocupa la vivienda. 1=Propia, 2=Alquilada, 3=Cedida/anticrético/servicios, 4=Otra.
#> 27                                                                                           Número de habitaciones que ocupa el hogar (sin contar baño y cocina).
#>       tabla armonizada  v1976 v1992  v2001         v2012            v2024
#> 1   persona       TRUE    p03   P03    P28           P24         p25_sexo
#> 2   persona       TRUE    p04   P04    P29           P25         p26_edad
#> 3   persona       TRUE    p04   P04    P29           P25         p26_edad
#> 4   persona      FALSE    p02   P02    P31           P23     p24_parentes
#> 5   persona       TRUE    p05   P05    P48           P45       p53_ecivil
#> 6   persona       TRUE    p10   P10    P36           P35          p40_lee
#> 7   persona       TRUE nivela   P12 P39NIV P37A_NIVELNUE        nivel_edu
#> 8   persona       TRUE    p11   P11    P37           P36       p38_asiste
#> 9   persona       TRUE    pea  NPEA   <NA>           PEA           pea_13
#> 10  persona       TRUE    pet  NPET   <NA>           PET           pet_13
#> 11  persona       TRUE    p18   P18    P46           P43         p50_semp
#> 12  persona       TRUE   <NA>  <NA>   P491          P29C   p32_pueblo_per
#> 13  persona       TRUE    p09  <NA>    P35          P30B p341_idiomat_cod
#> 14  persona       TRUE lugnac  P07A  DEP34          P32J    p35j_deptocod
#> 15  persona       TRUE  resh5  P08A  DEP41          P34H    p37j_deptocod
#> 16  persona       TRUE    p20   P20    P50           P46        p54_hvtot
#> 17  persona       TRUE    p21   P21    P51           P47        p55_hstot
#> 18  persona       TRUE   area  area   area          area             area
#> 19  persona       TRUE    dep  idep   idep          idep             idep
#> 20 vivienda       TRUE    v03   V03    V06           P03        v03_pared
#> 21 vivienda       TRUE    v04   V04    V08           P05        v05_techo
#> 22 vivienda       TRUE    v05   V05    V09           P06         v06_piso
#> 23 vivienda       TRUE    v07   V07    V10           P07      v07_aguapro
#> 24 vivienda       TRUE    v09   V09    V15           P11      v09_energia
#> 25 vivienda       TRUE   v081   V08    V12           P09      v15_servsan
#> 26 vivienda       TRUE    v14   V14    V21           P19     v17_tenencia
#> 27 vivienda       TRUE    v10   V10    V18           P14      v13_habitac
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             notas
#> 1                                                                                                                                                                                                                                                                                                                                                           1976/1992/2001: codificación original 1=Hombre, 2=Mujer (invertida). 2012/2024: 1=Mujer, 2=Hombre. get_temporal() harmoniza todo a 1=Mujer, 2=Hombre.
#> 2                                                                                                                                                                                                                                                                                                                                                  2001: P29 re-exportado con .dicx corregido (bug fieldsize exportaba 3 bits en vez de 7). 2012: P25 re-exportado desde .dicx (el .dic binario no la exportaba).
#> 3                                                                                                                                                                                                                            Se calcula en todos los censos desde la edad individual en años con (edad %/% 5) * 5, por lo que los intervalos son idénticos y comparables entre años. (Antes 1976/1992 usaban las variables ya agrupadas edad5/GEDAD, cuyos códigos NO eran quinquenios y rompían la comparación.)
#> 4                                                                                                                                                                                                                                                                                                                                                          NO ARMONIZADA: get_temporal() devuelve los códigos crudos de cada censo, que no son comparables. Consulta codebook_ANIO() por año para interpretarlos.
#> 5  Harmonizado al máximo nivel comparable (limitado por 1992, que agrupa casado/conviviente y separado/divorciado). 1976: 1=Soltero→1, 2=Casado→2, 3=Viudo→4, 4=Divorciado→3 (sin categoría conviviente ni separado). 1992: 1=Casado/conviviente→2, 2=Viudo→4, 3=Separado/divorciado→3, 4=Soltero→1. 2001/2012: 1=Soltero→1, 2=Casado→2, 3=Conviviente→2, 4=Separado→3, 5=Divorciado→3, 6=Viudo→4. 2024: 1=Casado→2, 2=Conviviente→2, 3=Separado→3, 4=Divorciado→3, 5=Viudo→4, 6=Soltero→1, 9=Sin especificar→NA.
#> 6                                                                                                                                                                                                                                                                                                                                                                                                                      1992 (P10): códigos 7=Sí, 8=No (distinto al resto). get_temporal() harmoniza a 1=Sí, 2=No.
#> 7                                             1976: 'nivela' es var. derivada (1=Ninguno..5=Técnico). 1992: P12 solo cubre quienes asistieron; Ninguno se obtiene combinando con P11 en get_temporal(). 2001: P39NIV con códigos reales 11=Ninguno,12=Preescolar,13=Básico,14=Intermedio,15=Medio,16=Primaria,17=Secundaria,18=Licenciatura,19=Técnico,20=Normal,21-23=Otros. 2012: P37A_NIVELNUE usa códigos no secuenciales (1,2,3,9,10,11-18,99). La Ley Avelino Siñani (2010) cambió la nomenclatura en 2012.
#> 8                                                                                                                                                                                                                                                                                       1992: 1=Asiste, 2=No asiste pero asistió, 3=Nunca asistió → harmonizado a 1=Asiste, 2=No. 2001: CÓDIGOS INVERTIDOS — 1=NO asiste, 2=SÍ (pública), 3=SÍ (privada). 2012: 1/2/3=SÍ (pública/privada/convenio), 4=No asiste.
#> 9                                                                                                                                                                                                             Codificación idéntica en todos los años: 1=Ocupado, 2=Cesante, 3=Aspirante. NO disponible en 2001 (retorna NA). 2024: se usa pea_13 (Población Económicamente Activa, 13° CIET); NO confundir con fft_19 (fuera de la fuerza de trabajo) ni ft_19 (condición de actividad de la fuerza de trabajo).
#> 10                                                                                                                                                                                                                         Harmonizado a 1=Sí, 2=No. 1976: 1=PET→1, 2=PENT→2. 1992 NPET: 1=PET→1, 0=PENT→2. 2012 PET: 1=trabajar→1, 0=no trabajar→2. 2024 pet_13: 1=PET→1, 2=PENT→2, 9=no especificó→NA. NO disponible en 2001 (retorna NA). La edad mínima de referencia puede variar entre censos (7+ en 2024).
#> 11                                                                                                              Solo aplica a personas ocupadas (PEA). 1976 p18: 1/2=Obrero/Empleado→1, 4=Cta propia→2, 5=Patrón→3, 3=Familiar→4. 1992 P18: 1/2=Obrero/Empleado→1, 3=Cta propia→2, 4=Patrón→3, 7=Familiar→4, 5/6=Otro→5. 2012 P43: 1/5=Obrero/TrabHogar→1, 2=Cta propia→2, 3=Empleador→3, 4=Familiar→4, 6=Coop→5. 2024 p50_semp: 2/5=Obrero/TrabHogar→1, 1=Cta propia→2, 3=Empleador→3, 4=Familiar→4, 6/7=Otro→5.
#> 12                                                                                                                                                                                                                                                                                         NO disponible en 1976 ni 1992 (retorna NA). 2001 P491: 1-6=pueblo indígena→1, 7=NINGUNO→2. 2012 P29C: código de pueblo (1-123)→1, 0=NOTAPPLICABLE (no se identifica)→2, otros→NA. 2024 p32_pueblo_per: 1=Sí→1, 2=No→2.
#> 13                                                                       LIMITACIÓN METODOLÓGICA: 1976 p09 captura 'idioma que habla' (no materno), con combinaciones bilingüísticas (ej. código 5=Castellano/Aymara → se clasifica como Aymara). 1992 NO disponible (solo flags binarios de idiomas hablados, no maternal). 2001-2024: primer idioma aprendido en la niñez. 2012/2024: códigos 1-37 para lenguas nativas (6=Castellano, 2=Aymara, 27=Quechua, 12=Guaraní); códigos >=38 son idiomas extranjeros.
#> 14                                                                                                                                                                           Variable DERIVADA: compara columna de dpto de nacimiento con dpto de residencia (idep o dep). 1976: lugnac=1-9 (dpto nac), 10=exterior. 1992: P07A=dpto nac (1-9). 2001: DEP34=dpto nac (1-9). 2012: P32J=dpto nac (1-9), 99=ignorado. 2024: p35j_deptocod=dpto nac (1-9). La comparación con idep actual se hace en get_temporal().
#> 15                                                                                                                                                                                                                                                                                         Variable DERIVADA: compara dpto hace 5 años con dpto actual (idep o dep). 1976: resh5=10→exterior, 11→NA. 2024: p37_lugres5=4 (no había nacido) → se usa como indicador alternativo; p37j_deptocod para comparar dpto.
#> 16                                                                                                                                                                                                                                                 Solo aplica a mujeres de 12 o más años. Hombres y mujeres menores de edad retornan 0 o NA. 1992: P20 (el diccionario del parquet confirma P20=nacidos vivos, P21=vivos actualmente). 2024: p54_hvtot es el total (existe también p54a/p54b por sexo del hijo).
#> 17                                                                                                                                                                                                                                                                                                                                                                          Subconjunto de hijos_nacidos_vivos. Solo aplica a mujeres 12+. 1992: P21 (el diccionario del parquet confirma P21=vivos actualmente).
#> 18                                                                                                                                                                                                                             Columna 'area' presente en todos los parquets de persona. 1976: fuente SPSS directa. 1992/2012: derivada de URBRUR de vivienda (pre-unida). 2001: derivada de TURUR de vivienda (pre-unida). 2024: derivada de urbrur de vivienda (pre-unida). Siempre 1=Urbana, 2=Rural, sin NAs.
#> 19                                                                                                                                                                                                                                                                                                                                               En 1976: columna 'dep' (numérica 1-9). En censos REDATAM: 'idep' se calcula desde REDCODEN via join con munic.parquet; get_temporal() lo fuerza automáticamente.
#> 20                                                                                                                                                                                                                                                        1976/1992: 1=Adobe revocado→2, 2=Adobe/tapial→2, 3=Ladrillo/bloque/cemento→1, 4=Piedra→4, 5=Madera→3, 6=Caña/palma→3, 7=Otros→5. 2001/2012/2024: 1=Ladrillo→1, 2=Adobe/tapial→2, 3=Tabique/quinche→3, 4=Piedra→4, 5=Madera→3, 6=Caña/palma→3, 7=Otro→5.
#> 21                                                                                                                                                                                                                                                                                                                                                                    Códigos muy consistentes entre censos: 1=Calamina→1, 2=Tejas→1, 3=Losa hormigón→2, 4=Paja/caña/palma→3, 5=Otro→4. Idéntico en los 5 censos.
#> 22                                                                                                                                                                                                                                                                                                                                                           1976/1992: 1=Madera→3, 2=Mosaico→3, 3=Ladrillo→2, 4=Cemento→2, 5=Tierra→1, 6=Otros→4. 2001/2012/2024: 1=Tierra→1, y demás materiales mapeados a 2-4.
#> 23                                                                                                                                                                              1976 usa v07 (procedencia), no v06 (distribución). 1976: 1/2=Red→1, 3/4=Pozo/aljibe→2, 5=Río/lago→3, 6=Carro→2, 7=Otra→2. 1992: 1=Red→1, 2=Pozo→2, 3=Río→3, 4=Carro→2, 5=Otra→2. 2001: 1=Cañería→1, 2=Pileta→1, 3=Carro→2, 4=Pozo bomba→2, 5=Pozo sin bomba→3, 6/7=Río/lago→3. 2024: 3=Cosecha lluvia→3, 6=Vertiente protegida→2.
#> 24                                                                                                                                                                                                                                                                                                                    1976/1992: 1=Sí, 2=No. 2001 V15: 5=Sí→1, 6=No→2 (codificación distinta). 2012 P11: 1-4=cualquier fuente (red/motor/solar/otra)→1, 5=No tiene→2. 2024: 1-4=cualquier fuente→1, 5=No tiene→2.
#> 25                                                                                                                                                                                                                                                                                                             1976: 1/2=Tiene→1, 3=No→2. 1992: 1/2=Tiene (con/sin descarga)→1, 3=No→2. 2001: 1=Tiene→1, 2=No→2. 2012 P09: 1/2=Tiene (privado/compartido)→1, 3=No→2. 2024: 1/2=Tiene (solo/compartido)→1, 3=No→2.
#> 26                                                                                                                                                                                                                                                                           Categorías muy consistentes entre censos. 1→1 (Propia), 2→2 (Alquiler), anticrético/cedida/servicios→3, otro→4. 2024: código 1/2=Propia pagada/pagando→1, código 4=Alquilada→2, códigos 3/5/6/7=Cedida/anticr/servicios→3, 8=Otra→4.
#> 27                                                                                                                                                                                                                                                                                               Variable numérica en 1976/1992/2001. 2012 P14: valores 1-7 directos, 8='8 y más', 98/99=NA. 2024 v13_habitac codificada como categorías ordinales (1=Una, ..., 8=Ocho o más). Se recomienda tratar como ordinal.
variables_armonizadas(tabla = "vivienda")
#>              variable                                etiqueta
#> 20   material_paredes Material de construcción de las paredes
#> 21     material_techo      Material de construcción del techo
#> 22      material_piso                       Material del piso
#> 23        fuente_agua     Fuente de agua para beber y cocinar
#> 24  energia_electrica     Disponibilidad de energía eléctrica
#> 25 servicio_sanitario    Disponibilidad de servicio sanitario
#> 26  tenencia_vivienda                 Tenencia de la vivienda
#> 27 habitaciones_total         Total de habitaciones del hogar
#>                                                                                                                                                        descripcion
#> 20                     Material predominante de las paredes exteriores. 1=Ladrillo/Bloque/Hormigón, 2=Adobe/Tapial, 3=Madera/Tabique/Caña/Palma, 4=Piedra, 5=Otro.
#> 21                                                  Material predominante del techo. 1=Calamina/Plancha/Teja, 2=Losa de hormigón, 3=Paja/Caña/Palma/Barro, 4=Otro.
#> 22                                                                 Material predominante del piso. 1=Tierra, 2=Cemento/Ladrillo, 3=Mosaico/Parquet/Madera, 4=Otro.
#> 23 Fuente principal de agua. 1=Cañería/red pública, 2=Otra fuente protegida (pozo con bomba, carro, pileta), 3=Fuente no protegida (río, acequia, pozo sin bomba).
#> 24                                                                                        Si el hogar cuenta con energía eléctrica (cualquier fuente). 1=Sí, 2=No.
#> 25                                                                                                Si el hogar tiene baño, water o letrina. 1=Sí tiene, 2=No tiene.
#> 26                                                         Forma en que el hogar ocupa la vivienda. 1=Propia, 2=Alquilada, 3=Cedida/anticrético/servicios, 4=Otra.
#> 27                                                                                           Número de habitaciones que ocupa el hogar (sin contar baño y cocina).
#>       tabla armonizada v1976 v1992 v2001 v2012        v2024
#> 20 vivienda       TRUE   v03   V03   V06   P03    v03_pared
#> 21 vivienda       TRUE   v04   V04   V08   P05    v05_techo
#> 22 vivienda       TRUE   v05   V05   V09   P06     v06_piso
#> 23 vivienda       TRUE   v07   V07   V10   P07  v07_aguapro
#> 24 vivienda       TRUE   v09   V09   V15   P11  v09_energia
#> 25 vivienda       TRUE  v081   V08   V12   P09  v15_servsan
#> 26 vivienda       TRUE   v14   V14   V21   P19 v17_tenencia
#> 27 vivienda       TRUE   v10   V10   V18   P14  v13_habitac
#>                                                                                                                                                                                                                                                                                                                                notas
#> 20                                                                           1976/1992: 1=Adobe revocado→2, 2=Adobe/tapial→2, 3=Ladrillo/bloque/cemento→1, 4=Piedra→4, 5=Madera→3, 6=Caña/palma→3, 7=Otros→5. 2001/2012/2024: 1=Ladrillo→1, 2=Adobe/tapial→2, 3=Tabique/quinche→3, 4=Piedra→4, 5=Madera→3, 6=Caña/palma→3, 7=Otro→5.
#> 21                                                                                                                                                                                       Códigos muy consistentes entre censos: 1=Calamina→1, 2=Tejas→1, 3=Losa hormigón→2, 4=Paja/caña/palma→3, 5=Otro→4. Idéntico en los 5 censos.
#> 22                                                                                                                                                                              1976/1992: 1=Madera→3, 2=Mosaico→3, 3=Ladrillo→2, 4=Cemento→2, 5=Tierra→1, 6=Otros→4. 2001/2012/2024: 1=Tierra→1, y demás materiales mapeados a 2-4.
#> 23 1976 usa v07 (procedencia), no v06 (distribución). 1976: 1/2=Red→1, 3/4=Pozo/aljibe→2, 5=Río/lago→3, 6=Carro→2, 7=Otra→2. 1992: 1=Red→1, 2=Pozo→2, 3=Río→3, 4=Carro→2, 5=Otra→2. 2001: 1=Cañería→1, 2=Pileta→1, 3=Carro→2, 4=Pozo bomba→2, 5=Pozo sin bomba→3, 6/7=Río/lago→3. 2024: 3=Cosecha lluvia→3, 6=Vertiente protegida→2.
#> 24                                                                                                                                       1976/1992: 1=Sí, 2=No. 2001 V15: 5=Sí→1, 6=No→2 (codificación distinta). 2012 P11: 1-4=cualquier fuente (red/motor/solar/otra)→1, 5=No tiene→2. 2024: 1-4=cualquier fuente→1, 5=No tiene→2.
#> 25                                                                                                                                1976: 1/2=Tiene→1, 3=No→2. 1992: 1/2=Tiene (con/sin descarga)→1, 3=No→2. 2001: 1=Tiene→1, 2=No→2. 2012 P09: 1/2=Tiene (privado/compartido)→1, 3=No→2. 2024: 1/2=Tiene (solo/compartido)→1, 3=No→2.
#> 26                                                                                              Categorías muy consistentes entre censos. 1→1 (Propia), 2→2 (Alquiler), anticrético/cedida/servicios→3, otro→4. 2024: código 1/2=Propia pagada/pagando→1, código 4=Alquilada→2, códigos 3/5/6/7=Cedida/anticr/servicios→3, 8=Otra→4.
#> 27                                                                                                                  Variable numérica en 1976/1992/2001. 2012 P14: valores 1-7 directos, 8='8 y más', 98/99=NA. 2024 v13_habitac codificada como categorías ordinales (1=Una, ..., 8=Ocho o más). Se recomienda tratar como ordinal.
```

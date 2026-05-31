# Consulta el diccionario de variables del CPV-2024

Permite buscar variables del censo por nombre, tabla o texto libre en
las etiquetas.

## Usage

``` r
codebook(variable = NULL, tabla = NULL, buscar = NULL)
```

## Arguments

- variable:

  Vector de caracteres. Nombre(s) de variable a consultar. Si \`NULL\`,
  devuelve todas.

- tabla:

  Caracteres. Filtra por tabla: \`"persona"\`, \`"vivienda"\`,
  \`"emigracion"\` o \`"mortalidad"\`. Si \`NULL\`, devuelve todas las
  tablas.

- buscar:

  Caracteres. Texto libre para buscar en las etiquetas y nombres de
  variables (no distingue mayúsculas/minúsculas).

## Value

Un data.frame con las variables que coinciden con los filtros.

## Examples

``` r
# Ver etiqueta de una variable específica
codebook("p25_sexo")
#>   variable              etiqueta   tabla       tipo     valores_codigos
#> 2 p25_sexo 25. Es mujer u hombre persona categorica 1, 2, Mujer, Hombre

# Variables relacionadas con educación
codebook(buscar = "educa")
#>          variable
#> 40    p39_tipoest
#> 42     p41a_nivel
#> 43     p41b_curso
#> 79 p41a_nivel_act
#> 81      nivel_edu
#> 83         asiste
#> 84       gedadedu
#>                                                                                                              etiqueta
#> 40                                                        39. El centro o establecimiento educativo al que asiste es:
#> 42                                    41.A. Cuál es el último curso o año que aprobó y en que nivel educativo (Nivel)
#> 43                              41.B. Cuál es el último curso o año que aprobó y en que nivel educativo (Curso o Año)
#> 79                                                   Nivel educativo alcanzado: sistema actual (5 o más años de edad)
#> 81 Nivel educativo alcanzado agrupado (19 o más años de edad, residentes en el país y que respondieron a la pregunta)
#> 83                                      Asistencia educativa (residentes en el país y que respondieron a la pregunta)
#> 84                  Grupo de edad según asistencia educativa (residentes en el país y que respondieron a la pregunta)
#>      tabla       tipo
#> 40 persona categorica
#> 42 persona categorica
#> 43 persona   numerica
#> 79 persona categorica
#> 81 persona categorica
#> 83 persona categorica
#> 84 persona categorica
#>                                                                                                                                                                                                                                        valores_codigos
#> 40                                                                                                                                                                                            1, 2, 9, Público o de convenio, Privado, Sin especificar
#> 42 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 99, Ninguno, Curso de alfabetización, Inicial (Pre kínder, kínder), Básico, Intermedio, Medio, Primaria, Secundaria, Técnico Medio, Técnico Superior, Licenciatura, Maestría, Doctorado, Sin especificar
#> 43                                                                                                                                                                                                                                                NULL
#> 79                                     1, 2, 3, 7, 8, 9, 10, 11, 12, 13, 99, Ninguno, Curso de Alfabetización, Inicial (Pre kínder, kínder), Primaria, Secundaria, Técnico Medio, Técnico Superior, Licenciatura, Maestría, Doctorado, Sin especificar
#> 81                                                                                                                                                                                                 1, 2, 3, 4, Ninguno, Primaria, Secundaria, Superior
#> 83                                                                                                                                                                                                                                        1, 2, Sí, No
#> 84                                                                                                                                                                      1, 2, 3, 4, 5, 6, 7, 0 - 3, 4 - 5, 6 - 11, 12 - 17, 18 - 24, 25 - 59, 60 o más

# Todas las variables de vivienda
codebook(tabla = "vivienda")
#>           variable
#> 115         urbrur
#> 116    v01_tipoviv
#> 117   v02_condocup
#> 118      v03_pared
#> 119      v04_revoq
#> 120      v05_techo
#> 121       v06_piso
#> 122    v07_aguapro
#> 123   v08_aguadist
#> 124    v09_energia
#> 125     v10_combus
#> 126     v11_basura
#> 127     v12_cocina
#> 128    v13_habitac
#> 129     v14_dormit
#> 130    v15_servsan
#> 131    v16_desague
#> 132   v17_tenencia
#> 133      v18a_bici
#> 134      v18b_moto
#> 135      v18c_auto
#> 136   v18d_carreta
#> 137      v18e_bote
#> 138     v18f_refri
#> 139     v18g_micro
#> 140   v18h_calefon
#> 141      v18i_aire
#> 142  v18j_lavadora
#> 143     v19a_radio
#> 144        v19b_tv
#> 145     v19c_compu
#> 146   v19d_celular
#> 147  v19e_inetfijo
#> 148 v19f_inetmovil
#> 149   v19g_tvcable
#> 150   v19h_telfijo
#> 151       v20a_emi
#> 152    v20b_totemi
#> 153       v21a_fal
#> 154    v21b_totfal
#> 155       tot_pers
#> 156        tip_hog
#> 157         v19e_f
#> 158         v19h_d
#>                                                                                      etiqueta
#> 115                                                                       Área Urbana - Rural
#> 116                                                     1. La vivienda es: (Tipo de vivienda)
#> 117                              2. La vivienda esta: (Condición de ocupación de la vivienda)
#> 118      3. Cual es el material de construcción más utilizado en las paredes de esta vivienda
#> 119                                4. Las paredes interiores de esta vivienda. Tienen revoque
#> 120       5. Cuál es el material de construcción más utilizado en los techos de esta vivienda
#> 121                        6. Cuál es el material más utilizado en los pisos de esta vivienda
#> 122                           7. Principalmente, el agua que usan en la vivienda proviene de:
#> 123                                         8. El agua que usan en la vivienda se distribuye:
#> 124                         9. De donde proviene la energía eléctrica que usan en la vivienda
#> 125                   10. Cuál es el principal combustible o energía que utiliza para cocinar
#> 126                                    11. Habitualmente. Qué hacen con la basura que generan
#> 127                                                    12. Tienen un cuarto solo para cocinar
#> 128                       13. Cuántos cuartos o habitaciones ocupan, sin contar baño y cocina
#> 129                 14. De estos cuartos o habitaciones, Cuántos se utilizan solo para dormir
#> 130                                                                15. Tienen, baño o letrina
#> 131                                                      16. El baño o letrina tiene desagüe:
#> 132                                  17. La vivienda que ocupan es: (Tenencia de la vivienda)
#> 133                                                           18.1. Su hogar tiene: Bicicleta
#> 134                                           18.2. Su hogar tiene: Motocicleta o cuadratrack
#> 135                                                  18.3. Su hogar tiene: Vehículo automotor
#> 136                                                  18.4. Su hogar tiene: Carreta o carretón
#> 137                                     18.5. Su hogar tiene: Deslizador, balsa, canoa o bote
#> 138                                          18.6. Su hogar tiene: Refrigerador o congeladora
#> 139                                                          18.7. Su hogar tiene: Microondas
#> 140                                                18.8. Su hogar tiene: Calefón, termotanque
#> 141                                                  18.9. Su hogar tiene: Aire acondicionado
#> 142                                                   18.10. Su hogar tiene: Lavadora de ropa
#> 143                                            19.1. Su hogar tiene: Radio o equipo de sonido
#> 144                                                           19.2. Su hogar tiene: Televisor
#> 145                                        19.3. Su hogar tiene: Computadora, laptop o tablet
#> 146                                                    19.4. Su hogar tiene: Teléfono celular
#> 147                                        19.5. Su hogar tiene: Internet fijo en la vivienda
#> 148                                      19.6. Su hogar tiene: Internet móvil (megas o datos)
#> 149                                    19.7. Su hogar tiene: Servicio de TV cable o satelital
#> 150                                          19.8. Su hogar tiene: Servicio de telefonía fija
#> 151 20.A. Alguna persona que vivía con usted(es) en este hogar, actualmente vive en otro país
#> 152                                                                    20.B. Cuantas personas
#> 153   21.A. Desde 2019 a la fecha, murió alguna persona que vivía con usted(es) en este hogar
#> 154                                                                    21.B. Cuantas personas
#> 155                                                                            Total personas
#> 156                                                                        Tipología de hogar
#> 157                                             Internet fijo en la vivienda o internet móvil
#> 158                                             Servicio de telefonía fija o teléfono celular
#>        tabla       tipo
#> 115 vivienda categorica
#> 116 vivienda categorica
#> 117 vivienda categorica
#> 118 vivienda categorica
#> 119 vivienda categorica
#> 120 vivienda categorica
#> 121 vivienda categorica
#> 122 vivienda categorica
#> 123 vivienda categorica
#> 124 vivienda categorica
#> 125 vivienda categorica
#> 126 vivienda categorica
#> 127 vivienda categorica
#> 128 vivienda categorica
#> 129 vivienda categorica
#> 130 vivienda categorica
#> 131 vivienda categorica
#> 132 vivienda categorica
#> 133 vivienda categorica
#> 134 vivienda categorica
#> 135 vivienda categorica
#> 136 vivienda categorica
#> 137 vivienda categorica
#> 138 vivienda categorica
#> 139 vivienda categorica
#> 140 vivienda categorica
#> 141 vivienda categorica
#> 142 vivienda categorica
#> 143 vivienda categorica
#> 144 vivienda categorica
#> 145 vivienda categorica
#> 146 vivienda categorica
#> 147 vivienda categorica
#> 148 vivienda categorica
#> 149 vivienda categorica
#> 150 vivienda categorica
#> 151 vivienda categorica
#> 152 vivienda   numerica
#> 153 vivienda categorica
#> 154 vivienda   numerica
#> 155 vivienda   numerica
#> 156 vivienda categorica
#> 157 vivienda categorica
#> 158 vivienda categorica
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                valores_codigos
#> 115                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        1, 2, Urbana, Rural
#> 116 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, Casa, Choza, pahuichi, Departamento, Cuarto(s) o habitación(es) suelta(s), Vivienda improvisada o vivienda móvil, Establecimiento no destinado para vivienda, Hotel, hostal, residencial o alojamiento, Hospital o clínica con internación, Cuartel o establecimiento militar o policial, Residencia u otro de adultos mayores, Albergue de niñas(os) y adolescentes, Recinto penitenciario o de reintegración, Campamento de trabajo, Otra (Instituto de rehabilitación, convento), Persona que vive en la calle, En tránsito: terminal, aeropuerto, puerto u otro
#> 117                                                                                                                                                                                                                                                                                                                                                                         0, 1, 2, 3, 4, 5, Ocupada con personas presentes sin Jefe, Ocupada con personas presentes, Ocupada con personas temporalmente ausentes, Desocupada para alquilar y/o vender, Desocupada terminándose de construir o reparar, Desocupada abandonada
#> 118                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     1, 2, 3, 4, 5, 6, 7, Ladrillo, bloque de cemento, hormigón, Adobe, tapial, Tabique, quinche, Piedra, Madera, Caña, palma, tronco, Otro
#> 119                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               1, 2, Sí, No
#> 120                                                                                                                                                                                                                                                                                                                                                                                                                                                             1, 2, 3, 4, 5, Calamina o plancha, Teja (de cemento, arcilla o fibrocemento), Losa de hormigón armado, Paja, palma, caña, barro, jatata, motacú, chuchio, Otro
#> 121                                                                                                                                                                                                                                                                                                                                                                                                                                                                   1, 2, 3, 4, 5, 6, 7, 8, 9, Tierra, Tablón de madera, Machimbre, parquet, Cerámica, porcelanato, Cemento, Mosaico, baldosa, Ladrillo, Piso Flotante, Otro
#> 122                                                                                                                                                                                                                                                                                                                                                        1, 2, 3, 4, 5, 6, 7, 8, 9, Cañería de red, Pileta pública, Cosecha de agua de lluvia, Pozo excavado o perforado con bomba, Pozo no protegido o sin bomba, Manantial o vertiente protegida, Río, acequia o vertiente no protegida, Carro repartidor (aguatero), Otro
#> 123                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 1, 2, 3, Por cañería dentro de la vivienda, Por cañería fuera de la vivienda, pero dentro del lote o terreno, No se distribuye por cañería
#> 124                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                1, 2, 3, 4, 5, Servicio público de energía eléctrica, Motor propio (Generador), Panel solar, Otro, No tiene
#> 125                                                                                                                                                                                                                                                                                                                                                                                                                                                            1, 2, 3, 4, 5, 6, 7, 8, Gas en garrafa, Gas por cañería (a domicilio), Leña, Guano, bosta o taquia, Electricidad, Energía solar (cocina solar), Otro, No cocina
#> 126                                                                                                                                                                                                                                                                                                                                                                                                    1, 2, 3, 4, 5, 6, 7, La depositan en el contenedor o basurero público, La entregan al carro basurero (servicio público), La botan en un terreno baldío o la calle, La botan al río, La queman, La entierran, Otra forma
#> 127                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               1, 2, Sí, No
#> 128                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             1, 2, 3, 4, 5, 6, 7, 8, Uno, Dos, Tres, Cuatro, Cinco, Seis, Siete, Ocho o más
#> 129                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    0, 1, 2, 3, 4, 5, 6, 7, 8, Cero, Uno, Dos, Tres, Cuatro, Cinco, Seis, Siete, Ocho o más
#> 130                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           1, 2, 3, Sí, usado solo por su hogar, Sí, compartido con otros hogares, No tiene
#> 131                                                                                                                                                                                                                                                                                                                                                                                                                                                    1, 2, 3, 4, 5, 6, A la red de alcantarillado, A una cámara séptica, A un pozo ciego, A un pozo de absorción, A la superficie (calle, quebrada o río), Es baño ecológico
#> 132                                                                                                                                                                                                                                                                                                                                                                                                 1, 2, 3, 4, 5, 6, 7, 8, Propia y totalmente pagada, Propia y la están pagando, Prestada por parientes o amigos, Alquilada, En contrato anticrético, En contrato mixto (anticrético y alquiler), Cedida por servicios, Otra
#> 133                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           1, 2, 9, Sí, No, Sin especificar
#> 134                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           1, 2, 9, Sí, No, Sin especificar
#> 135                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           1, 2, 9, Sí, No, Sin especificar
#> 136                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           1, 2, 9, Sí, No, Sin especificar
#> 137                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           1, 2, 9, Sí, No, Sin especificar
#> 138                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           1, 2, 9, Sí, No, Sin especificar
#> 139                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           1, 2, 9, Sí, No, Sin especificar
#> 140                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           1, 2, 9, Sí, No, Sin especificar
#> 141                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           1, 2, 9, Sí, No, Sin especificar
#> 142                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           1, 2, 9, Sí, No, Sin especificar
#> 143                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           1, 2, 9, Sí, No, Sin especificar
#> 144                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           1, 2, 9, Sí, No, Sin especificar
#> 145                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           1, 2, 9, Sí, No, Sin especificar
#> 146                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           1, 2, 9, Sí, No, Sin especificar
#> 147                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           1, 2, 9, Sí, No, Sin especificar
#> 148                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           1, 2, 9, Sí, No, Sin especificar
#> 149                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           1, 2, 9, Sí, No, Sin especificar
#> 150                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           1, 2, 9, Sí, No, Sin especificar
#> 151                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               1, 2, Sí, No
#> 152                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       NULL
#> 153                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               1, 2, Sí, No
#> 154                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       NULL
#> 155                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       NULL
#> 156                                                                                                                                                                                                                                                                                                                                                                                                                   1, 2, 3, 4, 5, 6, 7, 8, Hogar unipersonal, Hogar de pareja nuclear, Hogar monoparental, Hogar nuclear completo, Hogar extendido, Hogar compuesto, Otro tipo de hogar, Hogar de menores sin jefe de hogar
#> 157                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           1, 2, 9, Sí, No, Sin especificar
#> 158                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           1, 2, 9, Sí, No, Sin especificar

# Búsqueda combinada
codebook(tabla = "persona", buscar = "idioma")
#>             variable
#> 16 p331_idiohab1_cod
#> 17 p332_idiohab2_cod
#> 18 p333_idiohab3_cod
#> 19   p334_idiohab_no
#> 20  p341_idiomat_cod
#> 21   p342_idiomat_no
#> 85  idioma_mayor_uso
#> 86        idioma_mat
#>                                                                          etiqueta
#> 16                 33.1. Idiomas o lenguas que habla, según el mayor uso: Primero
#> 17                 33.2. Idiomas o lenguas que habla, según el mayor uso: Segundo
#> 18                 33.3. Idiomas o lenguas que habla, según el mayor uso: Tercero
#> 19                33.4. Idiomas o lenguas que habla, según el mayor uso: No habla
#> 20           34.1. Primer idioma o lengua en el que aprendió a hablar en su niñez
#> 21 34.2.Primer idioma o lengua en el que aprendió a hablar en su niñez : No habla
#> 85                  Idioma de mayor uso (personas que respondieron a la pregunta)
#> 86                       Idioma materno (personas que respondieron a la pregunta)
#>      tabla       tipo
#> 16 persona categorica
#> 17 persona categorica
#> 18 persona categorica
#> 19 persona categorica
#> 20 persona categorica
#> 21 persona categorica
#> 85 persona categorica
#> 86 persona categorica
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         valores_codigos
#> 16 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 991, 992, 994, 999, Araona, Aymara, Baure, Bésiro, Canichana, Castellano, Kabineña, Cayubaba, Chácobo, Tsimane´, Ese Ejja, Guaraní, Guarasu´we, Gwarayu, Itonama, Leco, Macha´juyay Kallawaya, Machineri, Maropa, Mojeño Ignaciano, Mojeño Trinitario, Moré, Mosetén, Movima, Pacahuara, Puquina, Quechua, Sirionó, Tacana, Tapiete, Toromona, Uru-Chipaya, Weenhayek, Yaminawa, Yuqui, Yurakaré, Zamuco, Albanés, Alemán, Árabe, Búlgaro, Catalán, Chino, Coreano, Croata, Danés, Escocés, Finlandés, Francés, Holandés, Húngaro, Inglés, Italiano, Japonés, Noruego, Portugués, Rumano, Ruso, Serbio, Sueco, Tailandés, Turco, Ucraniano, Vasco, Vietnamés, Hebreo, Polaco, Checo, Griego, Persa, Suizo, Latin, Taiwanés, Africano, Gallego, Valenciano, Quinamaya, Qom (toba), Afroboliviano, Joaquiniano, Otras declaraciones, Otro idioma extranjero, Lenguaje de señas, Sin especificar
#> 17 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 991, 992, 994, 999, Araona, Aymara, Baure, Bésiro, Canichana, Castellano, Kabineña, Cayubaba, Chácobo, Tsimane´, Ese Ejja, Guaraní, Guarasu´we, Gwarayu, Itonama, Leco, Macha´juyay Kallawaya, Machineri, Maropa, Mojeño Ignaciano, Mojeño Trinitario, Moré, Mosetén, Movima, Pacahuara, Puquina, Quechua, Sirionó, Tacana, Tapiete, Toromona, Uru-Chipaya, Weenhayek, Yaminawa, Yuqui, Yurakaré, Zamuco, Albanés, Alemán, Árabe, Búlgaro, Catalán, Chino, Coreano, Croata, Danés, Escocés, Finlandés, Francés, Holandés, Húngaro, Inglés, Italiano, Japonés, Noruego, Portugués, Rumano, Ruso, Serbio, Sueco, Tailandés, Turco, Ucraniano, Vasco, Vietnamés, Hebreo, Polaco, Checo, Griego, Persa, Suizo, Latin, Taiwanés, Africano, Gallego, Valenciano, Quinamaya, Qom (toba), Afroboliviano, Joaquiniano, Otras declaraciones, Otro idioma extranjero, Lenguaje de señas, Sin especificar
#> 18 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 991, 992, 994, 999, Araona, Aymara, Baure, Bésiro, Canichana, Castellano, Kabineña, Cayubaba, Chácobo, Tsimane´, Ese Ejja, Guaraní, Guarasu´we, Gwarayu, Itonama, Leco, Macha´juyay Kallawaya, Machineri, Maropa, Mojeño Ignaciano, Mojeño Trinitario, Moré, Mosetén, Movima, Pacahuara, Puquina, Quechua, Sirionó, Tacana, Tapiete, Toromona, Uru-Chipaya, Weenhayek, Yaminawa, Yuqui, Yurakaré, Zamuco, Albanés, Alemán, Árabe, Búlgaro, Catalán, Chino, Coreano, Croata, Danés, Escocés, Finlandés, Francés, Holandés, Húngaro, Inglés, Italiano, Japonés, Noruego, Portugués, Rumano, Ruso, Serbio, Sueco, Tailandés, Turco, Ucraniano, Vasco, Vietnamés, Hebreo, Polaco, Checo, Griego, Persa, Suizo, Latin, Taiwanés, Africano, Gallego, Valenciano, Quinamaya, Qom (toba), Afroboliviano, Joaquiniano, Otras declaraciones, Otro idioma extranjero, Lenguaje de señas, Sin especificar
#> 19                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          1, No habla
#> 20 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 991, 992, 994, 999, Araona, Aymara, Baure, Bésiro, Canichana, Castellano, Kabineña, Cayubaba, Chácobo, Tsimane´, Ese Ejja, Guaraní, Guarasu´we, Gwarayu, Itonama, Leco, Macha´juyay Kallawaya, Machineri, Maropa, Mojeño Ignaciano, Mojeño Trinitario, Moré, Mosetén, Movima, Pacahuara, Puquina, Quechua, Sirionó, Tacana, Tapiete, Toromona, Uru-Chipaya, Weenhayek, Yaminawa, Yuqui, Yurakaré, Zamuco, Albanés, Alemán, Árabe, Búlgaro, Catalán, Chino, Coreano, Croata, Danés, Escocés, Finlandés, Francés, Holandés, Húngaro, Inglés, Italiano, Japonés, Noruego, Portugués, Rumano, Ruso, Serbio, Sueco, Tailandés, Turco, Ucraniano, Vasco, Vietnamés, Hebreo, Polaco, Checo, Griego, Persa, Suizo, Latin, Taiwanés, Africano, Gallego, Valenciano, Quinamaya, Qom (toba), Afroboliviano, Joaquiniano, Otras declaraciones, Otro idioma extranjero, Lenguaje de señas, Sin especificar
#> 21                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          1, No habla
#> 85                      1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 32, 33, 34, 35, 36, 37, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 991, 992, 994, 998, Araona, Aymara, Baure, Bésiro, Canichana, Castellano, Kabineña, Cayubaba, Chácobo, Tsimane´, Ese Ejja, Guaraní, Guarasu´we, Gwarayu, Itonama, Leco, Macha´juyay Kallawaya, Machineri, Maropa, Mojeño Ignaciano, Mojeño Trinitario, Moré, Mosetén, Movima, Pacahuara, Puquina, Quechua, Sirionó, Tacana, Tapiete, Uru-Chipaya, Weenhayek, Yaminawa, Yuqui, Yurakaré, Zamuco, Albanés, Alemán, Árabe, Búlgaro, Catalán, Chino, Coreano, Croata, Danés, Escocés, Finlandés, Francés, Holandés, Húngaro, Inglés, Italiano, Japonés, Noruego, Portugués, Rumano, Ruso, Serbio, Sueco, Tailandés, Turco, Ucraniano, Vasco, Vietnamés, Hebreo, Polaco, Checo, Griego, Persa, Suizo, Latin, Taiwanés, Africano, Gallego, Valenciano, Quinamaya, Qom (toba), Afroboliviano, Joaquiniano, Otras declaraciones, Otro idioma extranjero, Lenguaje de señas, No habla
#> 86                      1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 32, 33, 34, 35, 36, 37, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 991, 992, 994, 998, Araona, Aymara, Baure, Bésiro, Canichana, Castellano, Kabineña, Cayubaba, Chácobo, Tsimane´, Ese Ejja, Guaraní, Guarasu´we, Gwarayu, Itonama, Leco, Macha´juyay Kallawaya, Machineri, Maropa, Mojeño Ignaciano, Mojeño Trinitario, Moré, Mosetén, Movima, Pacahuara, Puquina, Quechua, Sirionó, Tacana, Tapiete, Uru-Chipaya, Weenhayek, Yaminawa, Yuqui, Yurakaré, Zamuco, Albanés, Alemán, Árabe, Búlgaro, Catalán, Chino, Coreano, Croata, Danés, Escocés, Finlandés, Francés, Holandés, Húngaro, Inglés, Italiano, Japonés, Noruego, Portugués, Rumano, Ruso, Serbio, Sueco, Tailandés, Turco, Ucraniano, Vasco, Vietnamés, Hebreo, Polaco, Checo, Griego, Persa, Suizo, Latin, Taiwanés, Africano, Gallego, Valenciano, Quinamaya, Qom (toba), Afroboliviano, Joaquiniano, Otras declaraciones, Otro idioma extranjero, Lenguaje de señas, No habla
```

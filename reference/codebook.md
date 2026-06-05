# Consulta el diccionario de variables de un censo de Bolivia

Permite buscar variables del censo por nombre, tabla o texto libre en
las etiquetas.

## Usage

``` r
codebook_1976(variable = NULL, tabla = NULL, buscar = NULL)

codebook_1992(variable = NULL, tabla = NULL, buscar = NULL)

codebook_2001(variable = NULL, tabla = NULL, buscar = NULL)

codebook_2012(variable = NULL, tabla = NULL, buscar = NULL)

codebook_2024(variable = NULL, tabla = NULL, buscar = NULL)

codebook(variable = NULL, tabla = NULL, buscar = NULL, anio = 2024)
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
  variables (no distingue mayúsculas/minúsculas).

- anio:

  Entero. Año del censo: \`2024\` (defecto), \`1976\`, \`1992\`,
  \`2001\` o \`2012\`.

## Value

Un data.frame con las variables que coinciden con los filtros.

## Examples

``` r
# Ver etiqueta de una variable específica del CPV-2024
codebook("p25_sexo")
#>   variable              etiqueta   tabla       tipo     valores_codigos
#> 2 p25_sexo 25. Es mujer u hombre persona categorica 1, 2, Mujer, Hombre

# Variables de sexo en el censo 2012
codebook(buscar = "sexo", anio = 2012)
#>    variable etiqueta        tabla       tipo     valores_codigos
#> 71     P20E     Sexo   emigracion categorica 1, 2, Mujer, Hombre
#> 76     P22E     Sexo discapacidad categorica 1, 2, Mujer, Hombre

# Todas las variables de vivienda del censo 1992
codebook(tabla = "vivienda", anio = 1992)
#>        variable                                         etiqueta    tabla
#> 10          I12                              Área rural dispersa vivienda
#> 11         I122                                  Categoría rural vivienda
#> 12          V01                                 Tipo de vivienda vivienda
#> 13          V02                           Condición de ocupación vivienda
#> 14          V03                                          Paredes vivienda
#> 15          V04                                           Techos vivienda
#> 16          V05                                            Pisos vivienda
#> 17          V06      Abastecimiento de agua para beber y cocinar vivienda
#> 18          V07                             Procedencia del agua vivienda
#> 19          V08                               Servicio sanitario vivienda
#> 20         V081                       Uso del servicio sanitario vivienda
#> 21         V082                   Desague del servicio sanitario vivienda
#> 22          V09                          Tiene energía eléctrica vivienda
#> 23          V10    Cuantos cuartos o habitaciones ocupa su hogar vivienda
#> 24          V11                     Cuantos utilizan para dormir vivienda
#> 25          V12          Tiene un cuarto especial para la cocina vivienda
#> 26          V13     Principal combustible utilizado para cocinar vivienda
#> 27          V14                          Tenencia de la vivienda vivienda
#> 28         V15A             Dependencias del Ministerio de Salud vivienda
#> 29         V15B                            Caja de Seguro Social vivienda
#> 30         V15C                    Dependencias de ONG o iglesia vivienda
#> 31         V15D                               Servicios Privados vivienda
#> 32         V15E                                         Farmacia vivienda
#> 33         V15F Jampiri, Yatiri, Curandero, Kallawaya, Naturista vivienda
#> 34         V15G                   Otro tipo de atención de Salud vivienda
#> 35         V15H                              No atiende su Salud vivienda
#> 36         V15I                    Ignorado en atención de Salud vivienda
#> 37          V16                 No pertenecen a ninguna religión vivienda
#> 38         V16B                                Religión católica vivienda
#> 39         V16C                              Religión evangélica vivienda
#> 40         V16D                                    Otra religión vivienda
#> 41         V16E                                Religión ignorada vivienda
#> 42          V17 En este hogar murió alguna persona el año pasado vivienda
#> 43         V18H                                    Total hombres vivienda
#> 44         V18M                                    Total mujeres vivienda
#> 45         V18T                                  Total población vivienda
#> 46          V20                                       Tipo Hogar vivienda
#> 47          V21                                    Tipo Vivienda vivienda
#> 48          V22                           Categoría Urbano/Rural vivienda
#> 49       URBRUR                                     Urbano/Rural vivienda
#> 50   NBI_GRUP_V                                       NBI_GRUPOS vivienda
#> 51 NBI_POBRES_V                                       NBI_POBRES vivienda
#>          tipo
#> 10 categorica
#> 11 categorica
#> 12 categorica
#> 13 categorica
#> 14 categorica
#> 15 categorica
#> 16 categorica
#> 17 categorica
#> 18 categorica
#> 19 categorica
#> 20 categorica
#> 21 categorica
#> 22 categorica
#> 23   numerica
#> 24 categorica
#> 25 categorica
#> 26 categorica
#> 27 categorica
#> 28 categorica
#> 29 categorica
#> 30   numerica
#> 31 categorica
#> 32   numerica
#> 33   numerica
#> 34   numerica
#> 35   numerica
#> 36   numerica
#> 37   numerica
#> 38   numerica
#> 39   numerica
#> 40   numerica
#> 41 categorica
#> 42 categorica
#> 43   numerica
#> 44   numerica
#> 45 categorica
#> 46   numerica
#> 47   numerica
#> 48   numerica
#> 49 categorica
#> 50 categorica
#> 51 categorica
#>                                                                                                                                                                                                                                                                                                                                                                    valores_codigos
#> 10                                                                                                                                                                                                                                                                                                                                                                        SIZE, 16
#> 11                                                                                                                                                                                                                                                                0, 1, 2, 3, 4, 5, 6, 7, 8, Comunidad, Estancia, Hacienda, Ex-Hacienda, Rancho, Sindicato, Colonia, Barraca, Otra
#> 12 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, Casa independiente, Departamento, Habitaciones sueltas, Choza, pahuichi, Local no construido para vivienda, Vivienda improvisada, Hotel, residencia o alojamiento, Cuarte, establecimiento militar o policial, Hospital, clínica o sanatorio, Carcel o establecimiento correccional, Convento o internado, Otra colectiva, Ambulante
#> 13                                                                                                                                                                                        1, 2, 3, 4, 5, 6, Ocupada - ocupantes presentes, Ocupada - ocupantes ausentes, Desocupada - alquiler, venta, Desocupada - en construcción, reparación, Desocupada -  Abandonada, Rechazo
#> 14                                                                                                                                                                                                                            1, 2, 3, 4, 5, 6, 7, Adobe revocado, Adobe sin revocar o tapial, Ladrillo, bloques de cemento, hormigón, Piedra, Madera, Caña, palma, troncos, Otros
#> 15                                                                                                                                                                                                                                                                 1, 2, 3, 4, 5, Calamina o plancha, Tejas(cemento, arcilla, etc), Losa hormigón armado, Paja, caña, palma, Otros
#> 16                                                                                                                                                                                                                                                                                                  1, 2, 3, 4, 5, 6, Madera, Mosaico o baldosas, Ladrillo, Cemento, Tierra, Otros
#> 17                                                                                                                                                                                     1, 2, 3, 4, Por cañería dentro de la vivienda, Por cañería fuera de la vivienda, pero dentro del edificio, lote o terreno, Por cañería fiera del lote o terreno, No recibe agua por cañería
#> 18                                                                                                                                                                                                                                                                      1, 2, 3, 4, 5, Red pública o privada, Pozo o noria, Rio, lago, vertiente o acequia, Carro repartidor, Otra
#> 19                                                                                                                                                                                                                                                                                                   1, 2, 3, Tiene con descarga instantánea de agua, Tiene sin descarga, No Tiene
#> 20                                                                                                                                                                                                                                                                                                                       1, 2, Privado de este hogar, Compartido con otros hogares
#> 21                                                                                                                                                                                                                                                                                              1, 2, 3, Alcantarillado público, Cámara séptica, Otro(Pozo ciego, superficie, etc)
#> 22                                                                                                                                                                                                                                                                                                                                                                    1, 2, Si, No
#> 23                                                                                                                                                                                                                                                                                                                                                                            NULL
#> 24                                                                                                                                                                                                                                                                                                                                                                   ALIAS, COCINA
#> 25                                                                                                                                                                                                                                                                                                                                                                    1, 2, Si, No
#> 26                                                                                                                                                                                                                                                               1, 2, 3, 4, 5, 6, 7, 8, Leña, Guano, bosta o taquia, Carbón, Kerosene, Gas licuado, Electricidad, No cocina, Otro
#> 27                                                                                                                                                                                                                                                 1, 2, 3, 4, 5, 6, 7, Propia, Alquilada, Contrato anticrético, Contrato mixto, Cedida por servicios, Cedida por parentesco, Otra
#> 28                                                                                                                                                                                                                                                                                                                                                               2037.rbf', SIZE 8
#> 29                                                                                                                                                                                                                                                                                                                                                                          TO, 40
#> 30                                                                                                                                                                                                                                                                                                                                                                            NULL
#> 31                                                                                                                                                                                                                                                                                                                                               Curandero,, Kallawaya, Naturista9
#> 32                                                                                                                                                                                                                                                                                                                                                                            NULL
#> 33                                                                                                                                                                                                                                                                                                                                                                            NULL
#> 34                                                                                                                                                                                                                                                                                                                                                                            NULL
#> 35                                                                                                                                                                                                                                                                                                                                                                            NULL
#> 36                                                                                                                                                                                                                                                                                                                                                                            NULL
#> 37                                                                                                                                                                                                                                                                                                                                                                            NULL
#> 38                                                                                                                                                                                                                                                                                                                                                                            NULL
#> 39                                                                                                                                                                                                                                                                                                                                                                            NULL
#> 40                                                                                                                                                                                                                                                                                                                                                                            NULL
#> 41                                                                                                                                                                                                                                                                                                                                                     POBLACION, ALIAS NO_HOMBRES
#> 42                                                                                                                                                                                                                                                                                                                                                                    1, 2, Si, No
#> 43                                                                                                                                                                                                                                                                                                                                                                            NULL
#> 44                                                                                                                                                                                                                                                                                                                                                                            NULL
#> 45                                                                                                                                                                                                                                                                                                                                       0, 9000, POBLACION_TOTAL, POBLACION_TOTAL
#> 46                                                                                                                                                                                                                                                                                                                                                                            NULL
#> 47                                                                                                                                                                                                                                                                                                                                                                            NULL
#> 48                                                                                                                                                                                                                                                                                                                                                                            NULL
#> 49                                                                                                                                                                                                                                                                                                                                                             1, 2, Urbana, Rural
#> 50                                                                                                                                                                                                                                                                                                                       1, 2, 3, 4, 5, NBS, Umbral, Moderada, Indigente, Marginal
#> 51                                                                                                                                                                                                                                                                                                                                                         1, 2, No pobres, Pobres
```

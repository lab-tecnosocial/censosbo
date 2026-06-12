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
#>   variable              etiqueta   tabla     valores_codigos       tipo
#> 1 p25_sexo 25. Es mujer u hombre persona 1, 2, Mujer, Hombre categorica

# Variables de sexo en el censo 2012
codebook(buscar = "sexo", anio = 2012)
#>   variable etiqueta        tabla       tipo     valores_codigos
#> 1     P20E     Sexo   emigracion categorica 1, 2, Mujer, Hombre
#> 2     P22E     Sexo discapacidad categorica 1, 2, Mujer, Hombre

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
#>          tipo
#> 1  categorica
#> 2  categorica
#> 3  categorica
#> 4  categorica
#> 5  categorica
#> 6  categorica
#> 7  categorica
#> 8  categorica
#> 9  categorica
#> 10 categorica
#> 11 categorica
#> 12 categorica
#> 13 categorica
#> 14   numerica
#> 15 categorica
#> 16 categorica
#> 17 categorica
#> 18 categorica
#> 19 categorica
#> 20 categorica
#> 21   numerica
#> 22 categorica
#> 23   numerica
#> 24   numerica
#> 25   numerica
#> 26   numerica
#> 27   numerica
#> 28   numerica
#> 29   numerica
#> 30   numerica
#> 31   numerica
#> 32 categorica
#> 33 categorica
#> 34   numerica
#> 35   numerica
#> 36 categorica
#> 37   numerica
#> 38   numerica
#> 39   numerica
#> 40 categorica
#> 41 categorica
#> 42 categorica
#>                                                                                                                                                                                                                                                                                                                                                                    valores_codigos
#> 1                                                                                                                                                                                                                                                                                                                                                                         SIZE, 16
#> 2                                                                                                                                                                                                                                                                 0, 1, 2, 3, 4, 5, 6, 7, 8, Comunidad, Estancia, Hacienda, Ex-Hacienda, Rancho, Sindicato, Colonia, Barraca, Otra
#> 3  1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, Casa independiente, Departamento, Habitaciones sueltas, Choza, pahuichi, Local no construido para vivienda, Vivienda improvisada, Hotel, residencia o alojamiento, Cuarte, establecimiento militar o policial, Hospital, clínica o sanatorio, Carcel o establecimiento correccional, Convento o internado, Otra colectiva, Ambulante
#> 4                                                                                                                                                                                         1, 2, 3, 4, 5, 6, Ocupada - ocupantes presentes, Ocupada - ocupantes ausentes, Desocupada - alquiler, venta, Desocupada - en construcción, reparación, Desocupada -  Abandonada, Rechazo
#> 5                                                                                                                                                                                                                             1, 2, 3, 4, 5, 6, 7, Adobe revocado, Adobe sin revocar o tapial, Ladrillo, bloques de cemento, hormigón, Piedra, Madera, Caña, palma, troncos, Otros
#> 6                                                                                                                                                                                                                                                                  1, 2, 3, 4, 5, Calamina o plancha, Tejas(cemento, arcilla, etc), Losa hormigón armado, Paja, caña, palma, Otros
#> 7                                                                                                                                                                                                                                                                                                   1, 2, 3, 4, 5, 6, Madera, Mosaico o baldosas, Ladrillo, Cemento, Tierra, Otros
#> 8                                                                                                                                                                                      1, 2, 3, 4, Por cañería dentro de la vivienda, Por cañería fuera de la vivienda, pero dentro del edificio, lote o terreno, Por cañería fiera del lote o terreno, No recibe agua por cañería
#> 9                                                                                                                                                                                                                                                                       1, 2, 3, 4, 5, Red pública o privada, Pozo o noria, Rio, lago, vertiente o acequia, Carro repartidor, Otra
#> 10                                                                                                                                                                                                                                                                                                   1, 2, 3, Tiene con descarga instantánea de agua, Tiene sin descarga, No Tiene
#> 11                                                                                                                                                                                                                                                                                                                       1, 2, Privado de este hogar, Compartido con otros hogares
#> 12                                                                                                                                                                                                                                                                                              1, 2, 3, Alcantarillado público, Cámara séptica, Otro(Pozo ciego, superficie, etc)
#> 13                                                                                                                                                                                                                                                                                                                                                                    1, 2, Si, No
#> 14                                                                                                                                                                                                                                                                                                                                                                            NULL
#> 15                                                                                                                                                                                                                                                                                                                                                                   ALIAS, COCINA
#> 16                                                                                                                                                                                                                                                                                                                                                                    1, 2, Si, No
#> 17                                                                                                                                                                                                                                                               1, 2, 3, 4, 5, 6, 7, 8, Leña, Guano, bosta o taquia, Carbón, Kerosene, Gas licuado, Electricidad, No cocina, Otro
#> 18                                                                                                                                                                                                                                                 1, 2, 3, 4, 5, 6, 7, Propia, Alquilada, Contrato anticrético, Contrato mixto, Cedida por servicios, Cedida por parentesco, Otra
#> 19                                                                                                                                                                                                                                                                                                                                                               2037.rbf', SIZE 8
#> 20                                                                                                                                                                                                                                                                                                                                                                          TO, 40
#> 21                                                                                                                                                                                                                                                                                                                                                                            NULL
#> 22                                                                                                                                                                                                                                                                                                                                               Curandero,, Kallawaya, Naturista9
#> 23                                                                                                                                                                                                                                                                                                                                                                            NULL
#> 24                                                                                                                                                                                                                                                                                                                                                                            NULL
#> 25                                                                                                                                                                                                                                                                                                                                                                            NULL
#> 26                                                                                                                                                                                                                                                                                                                                                                            NULL
#> 27                                                                                                                                                                                                                                                                                                                                                                            NULL
#> 28                                                                                                                                                                                                                                                                                                                                                                            NULL
#> 29                                                                                                                                                                                                                                                                                                                                                                            NULL
#> 30                                                                                                                                                                                                                                                                                                                                                                            NULL
#> 31                                                                                                                                                                                                                                                                                                                                                                            NULL
#> 32                                                                                                                                                                                                                                                                                                                                                     POBLACION, ALIAS NO_HOMBRES
#> 33                                                                                                                                                                                                                                                                                                                                                                    1, 2, Si, No
#> 34                                                                                                                                                                                                                                                                                                                                                                            NULL
#> 35                                                                                                                                                                                                                                                                                                                                                                            NULL
#> 36                                                                                                                                                                                                                                                                                                                                       0, 9000, POBLACION_TOTAL, POBLACION_TOTAL
#> 37                                                                                                                                                                                                                                                                                                                                                                            NULL
#> 38                                                                                                                                                                                                                                                                                                                                                                            NULL
#> 39                                                                                                                                                                                                                                                                                                                                                                            NULL
#> 40                                                                                                                                                                                                                                                                                                                                                             1, 2, Urbana, Rural
#> 41                                                                                                                                                                                                                                                                                                                       1, 2, 3, 4, 5, NBS, Umbral, Moderada, Indigente, Marginal
#> 42                                                                                                                                                                                                                                                                                                                                                         1, 2, No pobres, Pobres
```

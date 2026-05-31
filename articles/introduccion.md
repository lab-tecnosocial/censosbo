# Introducción a censosbo

## ¿Qué es censosbo?

`censosbo` es un paquete de R que facilita el acceso a los microdatos
del **Censo de Población y Vivienda 2024 (CPV-2024)** de Bolivia,
publicados por el Instituto Nacional de Estadística (INE).

Los datos originales en CSV pesan más de 3 GB, por lo que el paquete los
distribuye como archivos **Parquet** comprimidos (mucho más livianos y
rápidos), que se descargan **bajo demanda** y se guardan en un caché
local. No se necesita descargar todo: se puede pedir solo el
departamento de interés.

## Instalación

``` r

# Instalar desde GitHub
remotes::install_github("lab-tecnosocial/censosbo")
```

## Tablas disponibles

El CPV-2024 incluye cuatro tablas accesibles con `censosbo`:

| Función | Tabla | Filas | Variables | Descripción |
|----|----|---:|---:|----|
| [`get_personas()`](https://lab-tecnosocial.github.io/censosbo/reference/get_personas.md) | Persona | ~11.4M | 118 | Datos individuales de cada persona |
| [`get_viviendas()`](https://lab-tecnosocial.github.io/censosbo/reference/get_viviendas.md) | Vivienda | ~4.5M | 48 | Características de cada vivienda |
| [`get_emigracion()`](https://lab-tecnosocial.github.io/censosbo/reference/get_emigracion.md) | Emigración | ~501K | 8 | Emigrantes al exterior (últimos 5 años) |
| [`get_mortalidad()`](https://lab-tecnosocial.github.io/censosbo/reference/get_mortalidad.md) | Mortalidad | ~383K | 10 | Fallecimientos en el hogar (últimos 12 meses) |

Las tablas se pueden unir usando la clave compuesta
`idep + iprov + imun + i00` (identificador de hogar).

## Geografía: departamentos, provincias y municipios

El paquete incluye la división político-administrativa completa de
Bolivia sin necesidad de descargar nada:

``` r

# Los 9 departamentos con sus códigos
departamentos()
#>     idep nombre_dep
#> 1     01 Chuquisaca
#> 30    02     La Paz
#> 117   03 Cochabamba
#> 165   04      Oruro
#> 200   05     Potosí
#> 242   06     Tarija
#> 253   07 Santa Cruz
#> 309   08       Beni
#> 329   09      Pando
```

``` r

# Número de municipios por departamento
geo_bolivia |>
  count(idep, nombre_dep, name = "municipios") |>
  ggplot(aes(x = reorder(nombre_dep, municipios), y = municipios)) +
  geom_col(fill = "#003087") +
  geom_text(aes(label = municipios), hjust = -0.2, size = 3.5) +
  coord_flip() +
  ylim(0, 95) +
  labs(
    title   = "Municipios por departamento — Bolivia",
    x       = NULL,
    y       = "Número de municipios",
    caption = "Fuente: INE Bolivia, CPV-2024"
  ) +
  theme_minimal(base_size = 12)
```

![](introduccion_files/figure-html/municipios-por-dep-1.png)

``` r

# Provincias de Santa Cruz
provincias("Santa Cruz")
#>     idep nombre_dep iprov            nombre_prov
#> 253   07 Santa Cruz    01          Andrés Ibáñez
#> 258   07 Santa Cruz    02                 Warnes
#> 260   07 Santa Cruz    03                Velasco
#> 263   07 Santa Cruz    04                 Ichilo
#> 267   07 Santa Cruz    05              Chiquitos
#> 270   07 Santa Cruz    06                   Sara
#> 273   07 Santa Cruz    07             Cordillera
#> 280   07 Santa Cruz    08           Valle Grande
#> 285   07 Santa Cruz    09                Florida
#> 289   07 Santa Cruz    10     Obispo Santisteban
#> 294   07 Santa Cruz    11        Ñuflo de Chávez
#> 300   07 Santa Cruz    12         Ángel Sandoval
#> 301   07 Santa Cruz    13 Manuel María Caballero
#> 303   07 Santa Cruz    14           Germán Busch
#> 306   07 Santa Cruz    15               Guarayos
```

``` r

# Municipios de la provincia Cercado (Cochabamba)
municipios(departamento = "03", provincia = "01")
#>     idep nombre_dep iprov nombre_prov imun nombre_mun
#> 117   03 Cochabamba    01     Cercado   01 Cochabamba
```

## Diccionario de variables

El paquete incluye un diccionario completo de las 168 variables del
CPV-2024:

``` r

# Variables disponibles por tabla del CPV-2024
codebook_meta |>
  count(tabla, tipo) |>
  ggplot(aes(x = reorder(tabla, n), y = n, fill = tipo)) +
  geom_col() +
  coord_flip() +
  scale_fill_manual(
    values = c(categorica = "#003087", numerica = "#F4C430"),
    labels = c(categorica = "Categórica", numerica = "Numérica")
  ) +
  labs(
    title   = "Variables del CPV-2024 por tabla y tipo",
    x       = NULL,
    y       = "Número de variables",
    fill    = "Tipo",
    caption = "Fuente: INE Bolivia, CPV-2024"
  ) +
  theme_minimal(base_size = 12)
```

![](introduccion_files/figure-html/codebook-grafico-1.png)

``` r

# Buscar variables relacionadas con educación
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
```

``` r

# Ver los códigos de una variable categórica
codebook_valores("p25_sexo")
#>   codigo etiqueta
#> 1      1    Mujer
#> 2      2   Hombre
```

``` r

# Ver variables de la tabla de emigración
codebook(tabla = "emigracion")
#>             variable                           etiqueta      tabla       tipo
#> 159        e203_sexo               20.3. La persona es: emigracion categorica
#> 160       e204_ansal    20.4. En qué año salió del país emigracion   numerica
#> 161        e205_edad            20.5. A qué edad se fue emigracion   numerica
#> 162 pais_destino_cod 20.2. En que país vive actualmente emigracion categorica
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   valores_codigos
#> 159                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       1, 2, 9, Mujer, Hombre, Sin Especificar
#> 160                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          NULL
#> 161                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          NULL
#> 162 4, 8, 12, 16, 20, 24, 28, 31, 32, 36, 40, 44, 48, 50, 51, 52, 56, 60, 64, 68, 70, 72, 76, 84, 90, 92, 96, 100, 104, 108, 112, 116, 120, 124, 132, 136, 140, 144, 148, 152, 156, 158, 162, 166, 170, 174, 175, 178, 180, 184, 188, 191, 192, 196, 203, 204, 208, 212, 214, 218, 222, 226, 231, 232, 233, 234, 238, 239, 242, 246, 248, 250, 254, 258, 260, 262, 266, 268, 270, 275, 276, 288, 292, 296, 300, 304, 308, 312, 316, 320, 324, 328, 332, 336, 340, 344, 348, 352, 356, 360, 364, 368, 372, 376, 380, 384, 388, 392, 398, 400, 404, 408, 410, 414, 417, 418, 422, 426, 428, 430, 434, 438, 440, 442, 446, 450, 454, 458, 462, 466, 470, 474, 478, 480, 484, 492, 496, 498, 499, 500, 504, 508, 512, 516, 520, 524, 528, 531, 533, 534, 535, 540, 548, 554, 558, 562, 566, 570, 574, 578, 580, 583, 584, 585, 586, 591, 598, 600, 604, 608, 612, 616, 620, 624, 626, 630, 634, 638, 642, 643, 646, 652, 654, 659, 660, 662, 663, 666, 670, 674, 678, 682, 686, 688, 689, 690, 694, 702, 703, 704, 705, 706, 710, 716, 724, 728, 729, 732, 740, 744, 748, 752, 756, 760, 762, 764, 768, 772, 776, 780, 784, 788, 792, 795, 796, 798, 800, 804, 807, 818, 826, 831, 832, 833, 834, 840, 850, 854, 858, 860, 862, 876, 882, 887, 894, 987, 988, 991, 992, 993, 994, 995, 996, 997, 998, 999, Afganistán, Albania, Argelia, Samoa Americana, Andorra, Angola, Antigua y Barbuda, Azerbaiyán, Argentina, Australia, Austria, Bahamas, Bahrein, Bangladesh, Armenia, Barbados, Bélgica, Bermuda, Bhután, Bolivia (Estado Plurinacional de, Bosnia y Herzegovina, Botswana, Brasil, Belice, Islas Salomón, Islas Vírgenes Británicas, Brunei Darussalam, Bulgaria, Myanmar, Burundi, Belarús, Camboya, Camerún, Canadá, Cabo Verde, Islas Caimán, República Centroafricana, Sri Lanka, Chad, Chile, China, Taiwán (Provincia de China), Isla Christmas, Islas Cocos (Keeling), Colombia, Comoras, Mayotte, Congo, República Democrática del Congo, Islas Cook, Costa Rica, Croacia, Cuba, Chipre, República Checa, Benin, Dinamarca, Dominica, República Dominicana, Ecuador, El Salvador, Guinea Ecuatorial, Etiopía, Eritrea, Estonia, Islas Feroe, Islas Malvinas (Falkland), Georgia del Sur y las Islas Sandwich del Sur, Fiji, Finlandia, Islas Åland, Francia, Guayana Francesa, Polinesia Francesa, Territorio de las Tierras Australes Francesas, Djibouti, Gabón, Georgia, Gambia, Estado de Palestina, Alemania, Ghana, Gibraltar, Kiribati, Grecia, Groenlandia, Granada, Guadalupe, Guam, Guatemala, Guinea, Guyana, Haití, Santa Sede, Honduras, China, región administrativa especial de Hong Kong, Hungría, Islandia, India, Indonesia, Irán (República Islámica del), Iraq, Irlanda, Israel, Italia, Costa de Marfil, Jamaica, Japón, Kazajstán, Jordania, Kenya, República Popular Democrática de Corea, República de Corea, Kuwait, Kirguistán, República Democrática Popular Lao, Líbano, Lesotho, Letonia, Liberia, Libia, Liechtenstein, Lituania, Luxemburgo, China, región administrativa especial de Macao, Madagascar, Malawi, Malasia, Maldivas, Malí, Malta, Martinica, Mauritania, Mauricio, México, Mónaco, Mongolia, República de Moldova, Montenegro, Montserrat, Marruecos, Mozambique, Omán, Namibia, Nauru, Nepal, Países Bajos, Curazao, Aruba, San Martín (parte Holandesa), Bonaire, San Eustaquio y Saba, Nueva Caledonia, Vanuatu, Nueva Zelandia, Nicaragua, Níger, Nigeria, Niue, Isla Norfolk, Noruega, Islas Marianas Septentrionales, Micronesia (Estados Federados de), Islas Marshall, Palau, Pakistán, Panamá, Papua Nueva Guinea, Paraguay, Perú, Filipinas, Pitcairn, Polonia, Portugal, Guinea-Bissau, Timor-Leste, Puerto Rico, Qatar, Reunión, Rumania, Federación de Rusia, Rwanda, San Barthélemy, Santa Elena, Saint Kitts y Nevis, Anguila, Santa Lucía, San Martín (parte francesa), San Pedro y Miquelón, San Vicente y las Granadinas, San Marino, Santo Tomé y Príncipe, Arabia Saudita, Senegal, Serbia, Kosovo, Seychelles, Sierra Leona, Singapur, Eslovaquia, Viet Nam, Eslovenia, Somalia, Sudáfrica, Zimbabwe, España, Sudán del Sur, Sudán, Sáhara Occidental, Suriname, Islas Svalbard y Jan Mayen, Eswatini, Suecia, Suiza, República Árabe Siria, Tayikistán, Tailandia, Togo, Tokelau, Tonga, Trinidad y Tobago, Emiratos Árabes Unidos, Túnez, Turquía, Turkmenistán, Islas Turcas y Caicos, Tuvalu, Uganda, Ucrania, Macedonia del Norte, Egipto, Reino Unido de Gran Bretaña e Irlanda del Norte, Guernsey, Jersey, Isla de Man, República Unida de Tanzanía, Estados Unidos de América, Islas Vírgenes de los Estados Unidos, Burkina Faso, Uruguay, Uzbekistán, Venezuela (República Bolivariana de), Islas Wallis y Futuna, Samoa, Yemen, Zambia, Caracteres aleatorios o descripción ilegible, Otro municipio, África, América, Asia, Europa, Oceanía, Otro país extranjero, No corresponde a país, No sabe, Sin Especificar
```

## Primera descarga de microdatos

Al llamar
[`get_personas()`](https://lab-tecnosocial.github.io/censosbo/reference/get_personas.md)
por primera vez, el paquete descarga el archivo Parquet del departamento
elegido y lo guarda en caché. Las siguientes llamadas ya no descargan
nada.

``` r

library(censosbo)

# Descargar datos de Santa Cruz (código "07", ~155 MB)
personas_sc <- get_personas(departamento = "Santa Cruz")
personas_sc
#> FileSystemDataset with 2 Parquet files
#> idep: string
#> iprov: string
#> imun: string
#> i00: string
#> p01_nacion: int32
#> ...
#> 118 columns
```

El resultado por defecto es un **Arrow Dataset** — los datos quedan en
disco, no en RAM. Solo se cargan a memoria cuando los pides
explícitamente con
[`collect()`](https://dplyr.tidyverse.org/reference/compute.html).

## Filtros geográficos

Todas las funciones `get_*()` aceptan los mismos argumentos geográficos:

``` r

# Por nombre de departamento
get_personas(departamento = "La Paz")

# Por código de dos dígitos (equivalente al anterior)
get_personas(departamento = "02")

# Varios departamentos a la vez
get_personas(departamento = c("La Paz", "Cochabamba", "Santa Cruz"))

# Por provincia (código dentro del departamento)
get_personas(departamento = "07", provincia = "01")

# Por municipio
get_personas(departamento = "07", municipio = "01")
```

## Selección de variables

Por defecto se devuelven todas las variables. Para análisis más rápidos,
se pueden pedir solo las columnas necesarias:

``` r

# Solo sexo y edad de Santa Cruz
get_personas(
  departamento = "07",
  variables    = c("p25_sexo", "p26_edad")
)
#> Las columnas idep, iprov, imun, i00 siempre se incluyen
```

Usa
[`codebook()`](https://lab-tecnosocial.github.io/censosbo/reference/codebook.md)
para ver qué variables existen en cada tabla.

## Formatos de retorno

El argumento `as` controla el tipo de objeto retornado:

``` r

# "arrow" (defecto): lazy, no carga en RAM — para datos grandes
ds_arrow <- get_personas(departamento = "07", as = "arrow")

# "tibble": trae los datos a memoria RAM — para conjuntos pequeños
df <- get_personas(departamento = "07", as = "tibble")

# "duckdb": conexión DBI para SQL — para queries complejas o JOINs
con <- get_personas(departamento = "07", as = "duckdb")
DBI::dbGetQuery(con, "SELECT COUNT(*) AS total FROM personas")
DBI::dbDisconnect(con)
```

## Uso con dplyr

El formato Arrow es compatible directamente con `dplyr`. Los verbos se
traducen a operaciones sobre el archivo Parquet sin cargar todo en RAM:

``` r

library(dplyr)

# Distribución por sexo en Cochabamba (sin traer todo a RAM)
get_personas(departamento = "03") |>
  count(p25_sexo) |>
  collect()
#> # A tibble: 2 × 2
#>   p25_sexo       n
#>   <int>      <int>
#> 1        1  831062
#> 2        2  855433

# Edad promedio por área urbano/rural en Oruro
get_personas(
  departamento = "04",
  variables    = c("p26_edad", "urbrur")
) |>
  group_by(urbrur) |>
  summarise(edad_prom = mean(p26_edad, na.rm = TRUE)) |>
  collect()
```

## Consultas SQL con DuckDB

Para análisis más complejos o JOINs entre tablas:

``` r

library(DBI)

con <- get_personas(departamento = "07", as = "duckdb")

DBI::dbGetQuery(con, "
  SELECT p25_sexo, COUNT(*) AS total, ROUND(AVG(p26_edad), 1) AS edad_prom
  FROM personas
  GROUP BY p25_sexo
  ORDER BY p25_sexo
")

DBI::dbDisconnect(con)
```

## Gestión del caché

Los datos descargados se guardan localmente y se reutilizan en sesiones
futuras:

``` r

# Ver la ruta del caché local
censosbo_cache_dir()
#> [1] "/home/runner/.cache/R/censosbo"
```

``` r

# Ver qué archivos están descargados y cuánto pesan
censosbo_cache_info()

# Limpiar el caché si necesitas liberar espacio
censosbo_cache_clear()
```

## Siguientes pasos

- **[Análisis
  demográfico](https://lab-tecnosocial.github.io/censosbo/articles/analisis-demografico.md)**:
  pirámide de edades, nivel educativo, pueblos indígenas.
- **[Análisis de
  vivienda](https://lab-tecnosocial.github.io/censosbo/articles/analisis-vivienda.md)**:
  agua, energía, hacinamiento, joins personas-viviendas.
- **[Análisis
  avanzado](https://lab-tecnosocial.github.io/censosbo/articles/analisis-avanzado.md)**:
  DuckDB, Arrow, datos más grandes que la RAM.

## Cómo citar

``` r

citation("censosbo")
```

> Ojeda Copa, A. (2024). *censosbo: Acceso y análisis de los datos del
> Censo de Bolivia 2024*. R package version 0.1.0.
> <https://github.com/lab-tecnosocial/censosbo>

También cita la fuente original:

> Instituto Nacional de Estadística (INE). (2024). *Censo de Población y
> Vivienda 2024 — Base de datos de microdatos*. Bolivia.
> <https://anda.ine.gob.bo/index.php/catalog/132>

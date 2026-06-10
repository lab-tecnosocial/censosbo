# Análisis temporal entre censos (1976–2024)

`censosbo` incluye funciones para comparar variables clave entre todos
los censos bolivianos (1976, 1992, 2001, 2012 y 2024). Las variables
originales son diferentes en cada censo; la librería aplica una
armonización y devuelve un data.frame en formato largo (“tidy”) con una
columna `anio` que identifica el censo.

## Variables y grupos disponibles

``` r

# Lista completa de variables armonizadas
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
#> 9                   pea                      Población Económicamente Activa
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
#> 4                                                                                                 Parentesco o relación del individuo con el jefe o jefa del hogar
#> 5                                                                                                                                 Situación conyugal del individuo
#> 6                                                                                            Indica si el individuo sabe leer y escribir. Harmonizado a 1=Sí, 2=No
#> 7           Nivel educativo más alto alcanzado. Para comparación longitudinal se harmoniza a 4 categorías: 0=Sin instrucción, 1=Primaria, 2=Secundaria, 3=Superior
#> 8                                                                       Indica si el individuo asiste actualmente a un centro educativo. 1=Sí asiste, 2=No asiste.
#> 9                                                                                                                    Indicador: si el individuo pertenece a la PEA
#> 10                                                                                                                 Indica si el individuo está en edad de trabajar
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
#>       tabla  v1976 v1992  v2001         v2012            v2024
#> 1   persona    p03   P03    P28           P24         p25_sexo
#> 2   persona    p04   P04    P29           P25         p26_edad
#> 3   persona  edad5 GEDAD    P29           P25         p26_edad
#> 4   persona    p02   P02    P31           P23     p24_parentes
#> 5   persona    p05   P05    P48           P45       p53_ecivil
#> 6   persona    p10   P10    P36           P35          p40_lee
#> 7   persona nivela   P12 P39NIV P37A_NIVELNUE        nivel_edu
#> 8   persona    p11   P11    P37           P36       p38_asiste
#> 9   persona    pea  NPEA   <NA>           PEA           fft_19
#> 10  persona    pet  NPET   <NA>           PET            ft_19
#> 11  persona    p18   P18    P46           P43         p50_semp
#> 12  persona   <NA>  <NA>   P491          P29C   p32_pueblo_per
#> 13  persona    p09  <NA>    P35          P30B p341_idiomat_cod
#> 14  persona lugnac  P07A  DEP34          P32J    p35j_deptocod
#> 15  persona  resh5  P08A  DEP41          P34H    p37j_deptocod
#> 16  persona    p20   P20    P50           P46        p54_hvtot
#> 17  persona    p21   P21    P51           P47        p55_hstot
#> 18  persona   area  area   area          area             area
#> 19  persona    dep  idep   idep          idep             idep
#> 20 vivienda    v03   V03    V06           P03        v03_pared
#> 21 vivienda    v04   V04    V08           P05        v05_techo
#> 22 vivienda    v05   V05    V09           P06         v06_piso
#> 23 vivienda    v07   V07    V10           P07      v07_aguapro
#> 24 vivienda    v09   V09    V15           P11      v09_energia
#> 25 vivienda   v081   V08    V12           P09      v15_servsan
#> 26 vivienda    v14   V14    V21           P19     v17_tenencia
#> 27 vivienda    v10   V10    V18           P14      v13_habitac
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                      notas
#> 1                                                                                                                                                                                                                                                                                                                1976/1992/2001: codificación original 1=Hombre, 2=Mujer (invertida). 2012/2024: 1=Mujer, 2=Hombre. get_longitudinal() harmoniza todo a 1=Mujer, 2=Hombre.
#> 2                                                                                                                                                                                                                                                                                                           2001: P29 re-exportado con .dicx corregido (bug fieldsize exportaba 3 bits en vez de 7). 2012: P25 re-exportado desde .dicx (el .dic binario no la exportaba).
#> 3                                                                                                                                                                                                                                                                                                                                  1976/1992: variable ya agrupada en la fuente. 2001/2012/2024: se calcula automáticamente desde la edad individual con (edad %/% 5) * 5.
#> 4                                                                                                                                                                                                                                                                                                                                                                                                           Códigos varían entre censos: consultar codebook_ANIO() por año
#> 5                                                                                                                                                                                                                                                                                                                                                                                         Categorías similares entre censos; verificar codebook para equivalencias exactas
#> 6                                                                                                                                                                                                                                                                                                                                                                           1992 (P10): códigos 7=Sí, 8=No (distinto al resto). get_longitudinal() harmoniza a 1=Sí, 2=No.
#> 7  1976: 'nivela' es var. derivada (1=Ninguno..5=Técnico). 1992: P12 solo cubre quienes asistieron; Ninguno se obtiene combinando con P11 en get_longitudinal(). 2001: P39NIV con códigos reales 11=Ninguno,12=Preescolar,13=Básico,14=Intermedio,15=Medio,16=Primaria,17=Secundaria,18=Licenciatura,19=Técnico,20=Normal,21-23=Otros. 2012: P37A_NIVELNUE usa códigos no secuenciales (1,2,3,9,10,11-18,99). La Ley Avelino Siñani (2010) cambió la nomenclatura en 2012.
#> 8                                                                                                                                                                                                                                                1992: 1=Asiste, 2=No asiste pero asistió, 3=Nunca asistió → harmonizado a 1=Asiste, 2=No. 2001: CÓDIGOS INVERTIDOS — 1=NO asiste, 2=SÍ (pública), 3=SÍ (privada). 2012: 1/2/3=SÍ (pública/privada/convenio), 4=No asiste.
#> 9                                                                                                                                                                                                                                                                                                                                                         NO disponible directamente en 2001 (requiere cálculo desde variables de actividad). En 2024: fft_19 codifica PEA
#> 10                                                                                                                                                                                                                                                                                                                                                                                               NO disponible directamente en 2001. Edad mínima puede variar entre censos
#> 11                                                                       Solo aplica a personas ocupadas (PEA). 1976 p18: 1/2=Obrero/Empleado→1, 4=Cta propia→2, 5=Patrón→3, 3=Familiar→4. 1992 P18: 1/2=Obrero/Empleado→1, 3=Cta propia→2, 4=Patrón→3, 7=Familiar→4, 5/6=Otro→5. 2012 P43: 1/5=Obrero/TrabHogar→1, 2=Cta propia→2, 3=Empleador→3, 4=Familiar→4, 6=Coop→5. 2024 p50_semp: 2/5=Obrero/TrabHogar→1, 1=Cta propia→2, 3=Empleador→3, 4=Familiar→4, 6/7=Otro→5.
#> 12                                                                                                                                                                                                                                                  NO disponible en 1976 ni 1992 (retorna NA). 2001 P491: 1-6=pueblo indígena→1, 7=NINGUNO→2. 2012 P29C: código de pueblo (1-123)→1, 0=NOTAPPLICABLE (no se identifica)→2, otros→NA. 2024 p32_pueblo_per: 1=Sí→1, 2=No→2.
#> 13                                LIMITACIÓN METODOLÓGICA: 1976 p09 captura 'idioma que habla' (no materno), con combinaciones bilingüísticas (ej. código 5=Castellano/Aymara → se clasifica como Aymara). 1992 NO disponible (solo flags binarios de idiomas hablados, no maternal). 2001-2024: primer idioma aprendido en la niñez. 2012/2024: códigos 1-37 para lenguas nativas (6=Castellano, 2=Aymara, 27=Quechua, 12=Guaraní); códigos >=38 son idiomas extranjeros.
#> 14                                                                                                                                Variable DERIVADA: compara columna de dpto de nacimiento con dpto de residencia (idep o dep). 1976: lugnac=1-9 (dpto nac), 10=exterior. 1992: P07A=dpto nac (1-9). 2001: DEP34=dpto nac (1-9). 2012: P32J=dpto nac (1-9), 99=ignorado. 2024: p35j_deptocod=dpto nac (1-9). La comparación con idep actual se hace en get_longitudinal().
#> 15                                                                                                                                                                                                                                                  Variable DERIVADA: compara dpto hace 5 años con dpto actual (idep o dep). 1976: resh5=10→exterior, 11→NA. 2024: p37_lugres5=4 (no había nacido) → se usa como indicador alternativo; p37j_deptocod para comparar dpto.
#> 16                                                                                                                                                                                                          Solo aplica a mujeres de 12 o más años. Hombres y mujeres menores de edad retornan 0 o NA. 1992: P20 (el diccionario del parquet confirma P20=nacidos vivos, P21=vivos actualmente). 2024: p54_hvtot es el total (existe también p54a/p54b por sexo del hijo).
#> 17                                                                                                                                                                                                                                                                                                                                   Subconjunto de hijos_nacidos_vivos. Solo aplica a mujeres 12+. 1992: P21 (el diccionario del parquet confirma P21=vivos actualmente).
#> 18                                                                                                                                                                                      Columna 'area' presente en todos los parquets de persona. 1976: fuente SPSS directa. 1992/2012: derivada de URBRUR de vivienda (pre-unida). 2001: derivada de TURUR de vivienda (pre-unida). 2024: derivada de urbrur de vivienda (pre-unida). Siempre 1=Urbana, 2=Rural, sin NAs.
#> 19                                                                                                                                                                                                                                                                                                    En 1976: columna 'dep' (numérica 1-9). En censos REDATAM: 'idep' se calcula desde REDCODEN via join con munic.parquet; get_longitudinal() lo fuerza automáticamente.
#> 20                                                                                                                                                                                                                 1976/1992: 1=Adobe revocado→2, 2=Adobe/tapial→2, 3=Ladrillo/bloque/cemento→1, 4=Piedra→4, 5=Madera→3, 6=Caña/palma→3, 7=Otros→5. 2001/2012/2024: 1=Ladrillo→1, 2=Adobe/tapial→2, 3=Tabique/quinche→3, 4=Piedra→4, 5=Madera→3, 6=Caña/palma→3, 7=Otro→5.
#> 21                                                                                                                                                                                                                                                                                                                             Códigos muy consistentes entre censos: 1=Calamina→1, 2=Tejas→1, 3=Losa hormigón→2, 4=Paja/caña/palma→3, 5=Otro→4. Idéntico en los 5 censos.
#> 22                                                                                                                                                                                                                                                                                                                    1976/1992: 1=Madera→3, 2=Mosaico→3, 3=Ladrillo→2, 4=Cemento→2, 5=Tierra→1, 6=Otros→4. 2001/2012/2024: 1=Tierra→1, y demás materiales mapeados a 2-4.
#> 23                                                                                                                                       1976 usa v07 (procedencia), no v06 (distribución). 1976: 1/2=Red→1, 3/4=Pozo/aljibe→2, 5=Río/lago→3, 6=Carro→2, 7=Otra→2. 1992: 1=Red→1, 2=Pozo→2, 3=Río→3, 4=Carro→2, 5=Otra→2. 2001: 1=Cañería→1, 2=Pileta→1, 3=Carro→2, 4=Pozo bomba→2, 5=Pozo sin bomba→3, 6/7=Río/lago→3. 2024: 3=Cosecha lluvia→3, 6=Vertiente protegida→2.
#> 24                                                                                                                                                                                                                                                                             1976/1992: 1=Sí, 2=No. 2001 V15: 5=Sí→1, 6=No→2 (codificación distinta). 2012 P11: 1-4=cualquier fuente (red/motor/solar/otra)→1, 5=No tiene→2. 2024: 1-4=cualquier fuente→1, 5=No tiene→2.
#> 25                                                                                                                                                                                                                                                                      1976: 1/2=Tiene→1, 3=No→2. 1992: 1/2=Tiene (con/sin descarga)→1, 3=No→2. 2001: 1=Tiene→1, 2=No→2. 2012 P09: 1/2=Tiene (privado/compartido)→1, 3=No→2. 2024: 1/2=Tiene (solo/compartido)→1, 3=No→2.
#> 26                                                                                                                                                                                                                                    Categorías muy consistentes entre censos. 1→1 (Propia), 2→2 (Alquiler), anticrético/cedida/servicios→3, otro→4. 2024: código 1/2=Propia pagada/pagando→1, código 4=Alquilada→2, códigos 3/5/6/7=Cedida/anticr/servicios→3, 8=Otra→4.
#> 27                                                                                                                                                                                                                                                        Variable numérica en 1976/1992/2001. 2012 P14: valores 1-7 directos, 8='8 y más', 98/99=NA. 2024 v13_habitac codificada como categorías ordinales (1=Una, ..., 8=Ocho o más). Se recomienda tratar como ordinal.
```

``` r

# Grupos temáticos predefinidos
grupos_variables()
#> $demografico
#> [1] "sexo"         "edad"         "grupo_edad"   "parentesco"   "estado_civil"
#> 
#> $educacion
#> [1] "sexo"               "edad"               "sabe_leer"         
#> [4] "nivel_edu"          "asistencia_escolar"
#> 
#> $economia
#> [1] "sexo"                "edad"                "pea"                
#> [4] "pet"                 "categoria_ocupacion"
#> 
#> $cultural
#> [1] "sexo"               "edad"               "identidad_indigena"
#> [4] "idioma_materno"    
#> 
#> $migracion
#> [1] "sexo"               "edad"               "migracion_nac_dpto"
#> [4] "migracion_rec_dpto"
#> 
#> $fertilidad
#> [1] "sexo"                 "edad"                 "hijos_nacidos_vivos" 
#> [4] "hijos_sobrevivientes"
```

Cada grupo combina variables complementarias para un análisis temático
coherente. Los grupos disponibles son: `demografico`, `educacion`,
`economia`, `cultural`, `migracion` y `fertilidad`.

## Función `get_temporal()`

La función acepta variables individuales o un grupo predefinido:

``` r

# Por grupo temático
datos <- get_temporal(
  grupo = "educacion",
  anios = c(1992, 2001, 2012, 2024)
)

# Por variables individuales
datos <- get_temporal(
  variables    = c("sexo", "nivel_edu", "sabe_leer"),
  anios        = c(1976, 1992, 2001, 2012, 2024),
  departamento = NULL   # todo el país
)
```

El resultado siempre incluye las columnas `anio`, las variables
solicitadas, más `area` (1=Urbana, 2=Rural) y `departamento` (código
01–09) como auxiliares de estratificación.

| Parámetro | Descripción |
|----|----|
| `variables` | Vector con nombres armonizados (de [`variables_armonizadas()`](https://lab-tecnosocial.github.io/censosbo/reference/variables_armonizadas.md)) |
| `grupo` | Nombre de un grupo predefinido (alternativa a `variables`) |
| `anios` | Años a incluir: subconjunto de `c(1976, 1992, 2001, 2012, 2024)` |
| `departamento` | Código `"01"`–`"09"` o nombre del departamento. `NULL` = todo el país |
| `verbose` | Mostrar mensajes de progreso (por defecto `TRUE`) |

------------------------------------------------------------------------

## Grupo: Educación

Incluye `sexo`, `edad`, `sabe_leer`, `nivel_edu`, `asistencia_escolar`.

``` r

edu <- get_temporal(grupo = "educacion",
                        anios = c(1992, 2001, 2012, 2024))

# Tasa de alfabetismo por año
edu |>
  filter(!is.na(sabe_leer), edad >= 15) |>
  count(anio, sabe_leer) |>
  group_by(anio) |>
  mutate(pct = n / sum(n)) |>
  filter(sabe_leer == 1) |>
  ggplot(aes(anio, pct)) +
  geom_line(linewidth = 1.2, color = "#003087") +
  geom_point(size = 3, color = "#003087") +
  geom_text(aes(label = scales::percent(pct, 0.1)), vjust = -0.8, size = 3.5) +
  scale_y_continuous(labels = scales::percent_format(), limits = c(0.6, 1)) +
  scale_x_continuous(breaks = c(1992, 2001, 2012, 2024)) +
  labs(title = "Tasa de alfabetismo (15+ años) — Bolivia",
       x = "Año censal", y = "% que sabe leer y escribir",
       caption = "Fuente: INE Bolivia, censos 1992–2024. Elaborado con censosbo.") +
  theme_minimal()
```

``` r

# Asistencia escolar (5-24 años) por área urbana/rural
edu |>
  filter(!is.na(asistencia_escolar), edad >= 5, edad <= 24) |>
  count(anio, area, asistencia_escolar) |>
  group_by(anio, area) |>
  mutate(pct = n / sum(n)) |>
  filter(asistencia_escolar == 1) |>
  mutate(area_label = ifelse(area == 1, "Urbana", "Rural")) |>
  ggplot(aes(factor(anio), pct, fill = area_label)) +
  geom_col(position = "dodge") +
  scale_y_continuous(labels = scales::percent_format()) +
  scale_fill_manual(values = c("Urbana" = "#2196F3", "Rural" = "#FF9800")) +
  labs(title = "Asistencia escolar (5-24 años) por área y censo",
       x = "Año censal", y = "% que asiste", fill = "Área") +
  theme_minimal()
```

``` r

# Distribución del nivel educativo
edu |>
  filter(!is.na(nivel_edu)) |>
  count(anio, nivel_edu) |>
  group_by(anio) |>
  mutate(pct = n / sum(n)) |>
  ggplot(aes(factor(anio), pct, fill = factor(nivel_edu))) +
  geom_col() +
  scale_fill_manual(
    values = c("0" = "#d73027", "1" = "#fdae61", "2" = "#74add1", "3" = "#313695"),
    labels = c("0" = "Sin instrucción", "1" = "Primaria",
               "2" = "Secundaria", "3" = "Superior"),
    name = "Nivel"
  ) +
  scale_y_continuous(labels = scales::percent_format()) +
  labs(title = "Nivel educativo — Bolivia, 1992–2024",
       x = "Año censal", y = "Proporción") +
  theme_minimal()
```

> **Nota sobre asistencia escolar:** En 2001 los códigos originales
> estaban invertidos (1=No asiste, 2/3=Sí asiste). `censosbo` aplica la
> corrección automáticamente.

------------------------------------------------------------------------

## Grupo: Economía

Incluye `sexo`, `edad`, `pea`, `pet`, `categoria_ocupacion`.

``` r

eco <- get_temporal(grupo = "economia",
                        anios = c(1976, 1992, 2001, 2012, 2024))

# Categoría de ocupación entre la PEA
eco |>
  filter(!is.na(categoria_ocupacion)) |>
  count(anio, categoria_ocupacion) |>
  group_by(anio) |>
  mutate(pct = n / sum(n)) |>
  mutate(cat_label = factor(categoria_ocupacion,
    levels = 1:5,
    labels = c("Empleado/Obrero", "Cuenta propia", "Empleador", "Familiar", "Otro")
  )) |>
  ggplot(aes(factor(anio), pct, fill = cat_label)) +
  geom_col() +
  scale_y_continuous(labels = scales::percent_format()) +
  scale_fill_brewer(palette = "Set2") +
  labs(title = "Categoría en el empleo por censo — Bolivia",
       x = "Año censal", y = "% de ocupados", fill = "Categoría") +
  theme_minimal()
```

> **Nota:** `pea` y `pet` no están disponibles directamente en el censo
> 2001. Se incluirán como `NA` con un aviso. Para 2001 usa directamente
> las variables de actividad económica del censo.

------------------------------------------------------------------------

## Grupo: Cultura

Incluye `sexo`, `edad`, `identidad_indigena`, `idioma_materno`. Solo
disponible desde 2001.

``` r

cult <- get_temporal(grupo = "cultural",
                         anios = c(2001, 2012, 2024))

# Autoidentificación indígena
cult |>
  filter(!is.na(identidad_indigena)) |>
  count(anio, identidad_indigena) |>
  group_by(anio) |>
  mutate(pct = n / sum(n)) |>
  filter(identidad_indigena == 1) |>
  ggplot(aes(factor(anio), pct)) +
  geom_col(fill = "#9C27B0", alpha = 0.8) +
  scale_y_continuous(labels = scales::percent_format()) +
  labs(title = "Autoidentificación indígena por año censal (2001-2024)",
       x = "Año censal", y = "% que se identifica como indígena") +
  theme_minimal()
```

``` r

# Distribución de idioma materno
cult |>
  filter(!is.na(idioma_materno)) |>
  count(anio, idioma_materno) |>
  group_by(anio) |>
  mutate(pct = n / sum(n)) |>
  mutate(idioma = factor(idioma_materno, 1:6,
    c("Castellano", "Quechua", "Aymara", "Guaraní", "Otro nativo", "Otro"))) |>
  ggplot(aes(factor(anio), pct, fill = idioma)) +
  geom_col() +
  scale_y_continuous(labels = scales::percent_format()) +
  scale_fill_brewer(palette = "Set1") +
  labs(title = "Idioma materno por año censal",
       x = "Año censal", y = "Proporción", fill = "Idioma") +
  theme_minimal()
```

> **Limitaciones metodológicas:** - `identidad_indigena` no disponible
> en 1976 ni 1992. - `idioma_materno` en 1992: solo existían flags
> binarios de idiomas *hablados* (no materno); se devuelve `NA`. -
> `idioma_materno` en 1976: la variable capturaba el idioma *hablado*,
> no el materno; se incluye con advertencia.

------------------------------------------------------------------------

## Grupo: Migración

Incluye `sexo`, `edad`, `migracion_nac_dpto`, `migracion_rec_dpto`.

Las variables de migración son **derivadas**: comparan el departamento
de nacimiento (o de residencia hace 5 años) con el departamento de
residencia actual.

``` r

mig <- get_temporal(grupo = "migracion",
                        anios = c(1992, 2001, 2012, 2024))

# Migración de nacimiento
mig |>
  filter(!is.na(migracion_nac_dpto)) |>
  count(anio, migracion_nac_dpto) |>
  group_by(anio) |>
  mutate(pct = n / sum(n)) |>
  mutate(cat = factor(migracion_nac_dpto, 1:3,
    c("Mismo dpto", "Otro dpto del país", "Exterior"))) |>
  ggplot(aes(factor(anio), pct, fill = cat)) +
  geom_col() +
  scale_y_continuous(labels = scales::percent_format()) +
  scale_fill_manual(values = c("Mismo dpto" = "#4CAF50",
                               "Otro dpto del país" = "#FFC107",
                               "Exterior" = "#F44336")) +
  labs(title = "Lugar de nacimiento vs. departamento de residencia",
       x = "Año censal", y = "Proporción", fill = NULL) +
  theme_minimal()
```

| Código | Significado                                 |
|--------|---------------------------------------------|
| 1      | Nació en el mismo departamento donde reside |
| 2      | Nació en otro departamento del país         |
| 3      | Nació en el exterior                        |

Para `migracion_rec_dpto` (residencia hace 5 años), el código 4 = “no
había nacido hace 5 años”.

------------------------------------------------------------------------

## Grupo: Fertilidad

Incluye `sexo`, `edad`, `hijos_nacidos_vivos`, `hijos_sobrevivientes`.
Solo significativo para mujeres 12+.

``` r

fert <- get_temporal(grupo = "fertilidad",
                         anios = c(1976, 1992, 2001, 2012, 2024))

# Promedio de hijos nacidos vivos por grupo de edad
fert |>
  filter(sexo == 1, edad >= 15, edad <= 49, !is.na(hijos_nacidos_vivos)) |>
  mutate(grupo = cut(edad, breaks = c(14, 19, 24, 29, 34, 39, 44, 49),
                     labels = c("15-19", "20-24", "25-29", "30-34",
                                "35-39", "40-44", "45-49"))) |>
  group_by(anio, grupo) |>
  summarise(media = mean(hijos_nacidos_vivos), .groups = "drop") |>
  ggplot(aes(grupo, media, color = factor(anio), group = anio)) +
  geom_line(linewidth = 1) + geom_point(size = 2) +
  scale_color_viridis_d(name = "Año censal") +
  labs(title = "Promedio de hijos nacidos vivos por edad de la madre",
       x = "Grupo de edad", y = "Promedio de hijos") +
  theme_minimal()
```

------------------------------------------------------------------------

## Vivienda: `get_temporal_vivienda()`

Para variables de la **tabla vivienda** existe una función equivalente:

``` r

viv <- get_temporal_vivienda(
  variables = c("material_paredes", "fuente_agua", "energia_electrica",
                "tenencia_vivienda", "habitaciones_total"),
  anios     = c(1992, 2001, 2012, 2024)
)
```

### Variables de vivienda disponibles

``` r

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
#>       tabla v1976 v1992 v2001 v2012        v2024
#> 20 vivienda   v03   V03   V06   P03    v03_pared
#> 21 vivienda   v04   V04   V08   P05    v05_techo
#> 22 vivienda   v05   V05   V09   P06     v06_piso
#> 23 vivienda   v07   V07   V10   P07  v07_aguapro
#> 24 vivienda   v09   V09   V15   P11  v09_energia
#> 25 vivienda  v081   V08   V12   P09  v15_servsan
#> 26 vivienda   v14   V14   V21   P19 v17_tenencia
#> 27 vivienda   v10   V10   V18   P14  v13_habitac
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

### Ejemplo: evolución del acceso a servicios básicos

``` r

viv_basicos <- get_temporal_vivienda(
  variables = c("fuente_agua", "energia_electrica"),
  anios     = c(1992, 2001, 2012, 2024)
)

bind_rows(
  viv_basicos |> filter(!is.na(energia_electrica)) |>
    count(anio, energia_electrica) |> group_by(anio) |>
    mutate(pct = n / sum(n)) |> filter(energia_electrica == 1) |>
    mutate(indicador = "Energía eléctrica"),
  viv_basicos |> filter(!is.na(fuente_agua)) |>
    count(anio, fuente_agua) |> group_by(anio) |>
    mutate(pct = n / sum(n)) |> filter(fuente_agua == 1) |>
    mutate(indicador = "Agua de red pública")
) |>
  ggplot(aes(anio, pct, color = indicador, group = indicador)) +
  geom_line(linewidth = 1.2) + geom_point(size = 3) +
  scale_y_continuous(labels = scales::percent_format(), limits = c(0, 1)) +
  labs(title = "Acceso a servicios básicos de vivienda (1992-2024)",
       x = "Año censal", y = "Proporción de hogares", color = NULL,
       caption = "Fuente: INE Bolivia. Elaborado con censosbo.") +
  theme_minimal()
```

### Ejemplo: material de paredes por censo

``` r

viv_mat <- get_temporal_vivienda(
  variables = c("material_paredes"),
  anios     = c(1992, 2001, 2012, 2024)
)

viv_mat |>
  filter(!is.na(material_paredes)) |>
  count(anio, material_paredes) |>
  group_by(anio) |>
  mutate(pct = n / sum(n)) |>
  mutate(mat = factor(material_paredes, 1:5,
    c("Ladrillo/Hormigón", "Adobe/Tapial", "Madera/Caña/Palma", "Piedra", "Otro"))) |>
  ggplot(aes(factor(anio), pct, fill = mat)) +
  geom_col() +
  scale_y_continuous(labels = scales::percent_format()) +
  scale_fill_brewer(palette = "RdYlGn", direction = -1) +
  labs(title = "Material de paredes por año censal",
       x = "Año censal", y = "Proporción de viviendas", fill = "Material") +
  theme_minimal()
```

------------------------------------------------------------------------

## Filtrar por departamento

Tanto
[`get_temporal()`](https://lab-tecnosocial.github.io/censosbo/reference/get_temporal.md)
como
[`get_temporal_vivienda()`](https://lab-tecnosocial.github.io/censosbo/reference/get_temporal_vivienda.md)
aceptan un filtro por departamento:

``` r

# Por nombre
edu_lp <- get_temporal(grupo = "educacion",
                            anios = c(2001, 2012, 2024),
                            departamento = "La Paz")

# Por código
viv_sc <- get_temporal_vivienda(
  variables    = c("fuente_agua", "energia_electrica"),
  anios        = c(2012, 2024),
  departamento = "05"   # Santa Cruz
)
```

------------------------------------------------------------------------

## Variables con limitaciones conocidas

``` r

variables_armonizadas() |>
  select(variable, tabla, notas) |>
  filter(!is.na(notas)) |>
  knitr::kable()
```

| variable | tabla | notas |
|:---|:---|:---|
| sexo | persona | 1976/1992/2001: codificación original 1=Hombre, 2=Mujer (invertida). 2012/2024: 1=Mujer, 2=Hombre. get_longitudinal() harmoniza todo a 1=Mujer, 2=Hombre. |
| edad | persona | 2001: P29 re-exportado con .dicx corregido (bug fieldsize exportaba 3 bits en vez de 7). 2012: P25 re-exportado desde .dicx (el .dic binario no la exportaba). |
| grupo_edad | persona | 1976/1992: variable ya agrupada en la fuente. 2001/2012/2024: se calcula automáticamente desde la edad individual con (edad %/% 5) \* 5. |
| parentesco | persona | Códigos varían entre censos: consultar codebook_ANIO() por año |
| estado_civil | persona | Categorías similares entre censos; verificar codebook para equivalencias exactas |
| sabe_leer | persona | 1992 (P10): códigos 7=Sí, 8=No (distinto al resto). get_longitudinal() harmoniza a 1=Sí, 2=No. |
| nivel_edu | persona | 1976: ‘nivela’ es var. derivada (1=Ninguno..5=Técnico). 1992: P12 solo cubre quienes asistieron; Ninguno se obtiene combinando con P11 en get_longitudinal(). 2001: P39NIV con códigos reales 11=Ninguno,12=Preescolar,13=Básico,14=Intermedio,15=Medio,16=Primaria,17=Secundaria,18=Licenciatura,19=Técnico,20=Normal,21-23=Otros. 2012: P37A_NIVELNUE usa códigos no secuenciales (1,2,3,9,10,11-18,99). La Ley Avelino Siñani (2010) cambió la nomenclatura en 2012. |
| asistencia_escolar | persona | 1992: 1=Asiste, 2=No asiste pero asistió, 3=Nunca asistió → harmonizado a 1=Asiste, 2=No. 2001: CÓDIGOS INVERTIDOS — 1=NO asiste, 2=SÍ (pública), 3=SÍ (privada). 2012: 1/2/3=SÍ (pública/privada/convenio), 4=No asiste. |
| pea | persona | NO disponible directamente en 2001 (requiere cálculo desde variables de actividad). En 2024: fft_19 codifica PEA |
| pet | persona | NO disponible directamente en 2001. Edad mínima puede variar entre censos |
| categoria_ocupacion | persona | Solo aplica a personas ocupadas (PEA). 1976 p18: 1/2=Obrero/Empleado→1, 4=Cta propia→2, 5=Patrón→3, 3=Familiar→4. 1992 P18: 1/2=Obrero/Empleado→1, 3=Cta propia→2, 4=Patrón→3, 7=Familiar→4, 5/6=Otro→5. 2012 P43: 1/5=Obrero/TrabHogar→1, 2=Cta propia→2, 3=Empleador→3, 4=Familiar→4, 6=Coop→5. 2024 p50_semp: 2/5=Obrero/TrabHogar→1, 1=Cta propia→2, 3=Empleador→3, 4=Familiar→4, 6/7=Otro→5. |
| identidad_indigena | persona | NO disponible en 1976 ni 1992 (retorna NA). 2001 P491: 1-6=pueblo indígena→1, 7=NINGUNO→2. 2012 P29C: código de pueblo (1-123)→1, 0=NOTAPPLICABLE (no se identifica)→2, otros→NA. 2024 p32_pueblo_per: 1=Sí→1, 2=No→2. |
| idioma_materno | persona | LIMITACIÓN METODOLÓGICA: 1976 p09 captura ‘idioma que habla’ (no materno), con combinaciones bilingüísticas (ej. código 5=Castellano/Aymara → se clasifica como Aymara). 1992 NO disponible (solo flags binarios de idiomas hablados, no maternal). 2001-2024: primer idioma aprendido en la niñez. 2012/2024: códigos 1-37 para lenguas nativas (6=Castellano, 2=Aymara, 27=Quechua, 12=Guaraní); códigos \>=38 son idiomas extranjeros. |
| migracion_nac_dpto | persona | Variable DERIVADA: compara columna de dpto de nacimiento con dpto de residencia (idep o dep). 1976: lugnac=1-9 (dpto nac), 10=exterior. 1992: P07A=dpto nac (1-9). 2001: DEP34=dpto nac (1-9). 2012: P32J=dpto nac (1-9), 99=ignorado. 2024: p35j_deptocod=dpto nac (1-9). La comparación con idep actual se hace en get_longitudinal(). |
| migracion_rec_dpto | persona | Variable DERIVADA: compara dpto hace 5 años con dpto actual (idep o dep). 1976: resh5=10→exterior, 11→NA. 2024: p37_lugres5=4 (no había nacido) → se usa como indicador alternativo; p37j_deptocod para comparar dpto. |
| hijos_nacidos_vivos | persona | Solo aplica a mujeres de 12 o más años. Hombres y mujeres menores de edad retornan 0 o NA. 1992: P20 (el diccionario del parquet confirma P20=nacidos vivos, P21=vivos actualmente). 2024: p54_hvtot es el total (existe también p54a/p54b por sexo del hijo). |
| hijos_sobrevivientes | persona | Subconjunto de hijos_nacidos_vivos. Solo aplica a mujeres 12+. 1992: P21 (el diccionario del parquet confirma P21=vivos actualmente). |
| area | persona | Columna ‘area’ presente en todos los parquets de persona. 1976: fuente SPSS directa. 1992/2012: derivada de URBRUR de vivienda (pre-unida). 2001: derivada de TURUR de vivienda (pre-unida). 2024: derivada de urbrur de vivienda (pre-unida). Siempre 1=Urbana, 2=Rural, sin NAs. |
| departamento | persona | En 1976: columna ‘dep’ (numérica 1-9). En censos REDATAM: ‘idep’ se calcula desde REDCODEN via join con munic.parquet; get_longitudinal() lo fuerza automáticamente. |
| material_paredes | vivienda | 1976/1992: 1=Adobe revocado→2, 2=Adobe/tapial→2, 3=Ladrillo/bloque/cemento→1, 4=Piedra→4, 5=Madera→3, 6=Caña/palma→3, 7=Otros→5. 2001/2012/2024: 1=Ladrillo→1, 2=Adobe/tapial→2, 3=Tabique/quinche→3, 4=Piedra→4, 5=Madera→3, 6=Caña/palma→3, 7=Otro→5. |
| material_techo | vivienda | Códigos muy consistentes entre censos: 1=Calamina→1, 2=Tejas→1, 3=Losa hormigón→2, 4=Paja/caña/palma→3, 5=Otro→4. Idéntico en los 5 censos. |
| material_piso | vivienda | 1976/1992: 1=Madera→3, 2=Mosaico→3, 3=Ladrillo→2, 4=Cemento→2, 5=Tierra→1, 6=Otros→4. 2001/2012/2024: 1=Tierra→1, y demás materiales mapeados a 2-4. |
| fuente_agua | vivienda | 1976 usa v07 (procedencia), no v06 (distribución). 1976: 1/2=Red→1, 3/4=Pozo/aljibe→2, 5=Río/lago→3, 6=Carro→2, 7=Otra→2. 1992: 1=Red→1, 2=Pozo→2, 3=Río→3, 4=Carro→2, 5=Otra→2. 2001: 1=Cañería→1, 2=Pileta→1, 3=Carro→2, 4=Pozo bomba→2, 5=Pozo sin bomba→3, 6/7=Río/lago→3. 2024: 3=Cosecha lluvia→3, 6=Vertiente protegida→2. |
| energia_electrica | vivienda | 1976/1992: 1=Sí, 2=No. 2001 V15: 5=Sí→1, 6=No→2 (codificación distinta). 2012 P11: 1-4=cualquier fuente (red/motor/solar/otra)→1, 5=No tiene→2. 2024: 1-4=cualquier fuente→1, 5=No tiene→2. |
| servicio_sanitario | vivienda | 1976: 1/2=Tiene→1, 3=No→2. 1992: 1/2=Tiene (con/sin descarga)→1, 3=No→2. 2001: 1=Tiene→1, 2=No→2. 2012 P09: 1/2=Tiene (privado/compartido)→1, 3=No→2. 2024: 1/2=Tiene (solo/compartido)→1, 3=No→2. |
| tenencia_vivienda | vivienda | Categorías muy consistentes entre censos. 1→1 (Propia), 2→2 (Alquiler), anticrético/cedida/servicios→3, otro→4. 2024: código 1/2=Propia pagada/pagando→1, código 4=Alquilada→2, códigos 3/5/6/7=Cedida/anticr/servicios→3, 8=Otra→4. |
| habitaciones_total | vivienda | Variable numérica en 1976/1992/2001. 2012 P14: valores 1-7 directos, 8=‘8 y más’, 98/99=NA. 2024 v13_habitac codificada como categorías ordinales (1=Una, …, 8=Ocho o más). Se recomienda tratar como ordinal. |

Resumen de limitaciones principales:

| Variable | Limitación |
|----|----|
| `pea`, `pet` | No disponibles en 2001 |
| `identidad_indigena` | Solo 2001–2024 |
| `idioma_materno` | 1992: solo flags de idioma hablado; 1976: idioma hablado, no materno |
| `servicio_sanitario` | No disponible en 2012 |
| `habitaciones_total` | 2024: variable categórica (1=Una, 2=Dos, … 8=Ocho o más) |
| `migracion_nac_dpto` | Variable derivada; 1992 no tiene flag para exterior |

Las variables no disponibles en un año determinado se incluyen como `NA`
con un aviso de `cli_warn()`.

------------------------------------------------------------------------

## Acceso directo a los censos

Si necesitas variables no armonizadas o mayor control, accede
directamente a cada censo:

``` r

# Nivel educativo 2012 con códigos originales
edu_2012 <- get_personas_2012() |>
  count(nivel = P37A_NIVELNUE) |>
  collect() |>
  mutate(anio = 2012L)

# Ver qué variables existen en el censo 1976
codebook_1976(tabla = "poblacion")
codebook_2012(buscar = "nivel")
```

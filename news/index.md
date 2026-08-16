# Changelog

## censosbo 2.0.2

Tres correcciones salidas de probar el paquete como lo estrena alguien
nuevo: instalado desde GitHub, con el caché vacío. Ninguna cambia
resultados; las tres quitan fricción donde el paquete parecía no tener
el dato que sí tenía.

- **Los nombres y las búsquedas ya no dependen de las tildes.**
  `municipio = "Zudanez"` abortaba con «no encontrado en el catálogo» y
  `buscar = "instruccion"` devolvía cero filas, en los dos casos sin
  pista de que lo único que faltaba era un acento. Ahora `departamento`,
  `provincia` y `municipio` aceptan los nombres con o sin acentos —55 de
  los 343 municipios llevan tilde o eñe, y `"Potosi"` ya vale por
  `"Potosí"`— y `buscar` encuentra `"Nivel más alto de instrucción"`
  escribiendo `instruccion`.

  No se pierde precisión: los nueve nombres de municipio que colisionan
  al ignorar los acentos (`Entre Ríos`, `San Pedro`, `Totora`…) son los
  nueve que ya estaban repetidos entre departamentos, así que siguen
  pidiendo `departamento` para desambiguar, como antes.

- **Pedir un tema que no se preguntó en ese censo ahora lo dice.**
  `codebook(tema = "religion", anio = 2024)` devolvía cero filas en
  silencio; `religion` está en la taxonomía pero solo se preguntó
  en 1992. Ahora aborta indicando en qué censos sí está. Como efecto
  colateral se corrige el mensaje de tema no reconocido, que prometía
  «21 temas disponibles» mientras
  [`censo_temas()`](https://lab-tecnosocial.github.io/censosbo/reference/censo_temas.md)
  mostraba 20: contaba la taxonomía completa en vez de los temas del
  censo consultado.

- **README:** dos ejemplos de la sección de censos históricos no
  funcionaban (`codebook_1992(buscar = "sexo")` no encuentra nada porque
  en 1992 la etiqueta es «Es hombre o mujer»). Corregidos, y el bloque
  pasa a evaluarse al construir el README para que no vuelva a pasar. Se
  documenta también que `install_github()` no trae las viñetas a menos
  que se pida `build_vignettes = TRUE`, con enlace a la versión online.

Y tres más salidas de la revisión del consumidor `censos-explorer`:

- **Las funciones de un censo avisan del universo de las variables que
  pides.** El universo estaba publicado en
  [`codebook()`](https://lab-tecnosocial.github.io/censosbo/reference/codebook.md)
  desde hace versiones, pero solo se *avisaba* en
  [`get_temporal()`](https://lab-tecnosocial.github.io/censosbo/reference/get_temporal.md),
  y ahí únicamente cuando difería entre censos. Faltaba justo el caso de
  riesgo: pedir `nivel_edu` de un solo año y dividir por el total de
  filas, que es un error de doce puntos porcentuales. Ahora
  [`get_personas_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/get_personas_2024.md),
  [`get_censo()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md)
  y las demás informan una vez por llamada:

      ℹ No toda la población respondió esta variable:
        nivel_edu: personas de 19 años o más
      ℹ Un porcentaje sobre el total de filas usaría un denominador mayor que ese universo.

  Solo cuando pides variables explícitamente (con `variables = NULL`
  serían decenas de avisos) y solo con `verbose = TRUE`, así que los
  consumidores headless no lo ven. Es un mensaje informativo, no un
  warning.

  Limitación heredada del INE: el DDI de **2012** solo declara
  `todas_personas` y `todas_viviendas`, así que para ese censo el aviso
  no salta. Queda documentado en
  [`?codebook_meta`](https://lab-tecnosocial.github.io/censosbo/reference/codebook_meta.md).

- **La viñeta de manzanos y comunidades explicaba mal un desfase que ya
  no existe.** Afirmaba que el INE cuenta las viviendas distinto en el
  geoportal y en los microdatos. No era así: la diferencia eran los
  10.287 registros de calle y tránsito, y desde la 1.7.0 las dos fuentes
  cuadran en los 343 municipios. Reescrita como lo que es —una
  validación cruzada— y el artículo ahora **comprueba** esa igualdad al
  construirse, en vez de afirmarla.

- **CI:** las seis pruebas de reconciliación contra las cifras oficiales
  del INE no se ejecutaban nunca de forma automática. Nuevo workflow
  mensual (y a demanda) que descarga los microdatos y las corre, y que
  falla si acaban en `skipped` en vez de dar un verde que no comprobó
  nada.

## censosbo 2.0.1

- **El caché vuelve a crearse sin pedir confirmación.** La 2.0.0
  preguntaba la primera vez, en sesión interactiva, siguiendo una
  lectura conservadora de la política de CRAN. Instalando desde GitHub
  eso es fricción por un requisito que todavía no aplica, así que se
  retira: descargar implica cachear, como siempre.

  Nada más cambia.
  [`censosbo_cache_dir()`](https://lab-tecnosocial.github.io/censosbo/reference/censosbo_cache_dir.md),
  [`censosbo_cache_info()`](https://lab-tecnosocial.github.io/censosbo/reference/censosbo_cache_info.md)
  y
  [`censosbo_cache_clear()`](https://lab-tecnosocial.github.io/censosbo/reference/censosbo_cache_clear.md)
  funcionan igual, y las opciones `censosbo.cache_dir` y
  `censosbo.consent` se siguen reconociendo.

  La política de CRAN tiene además una vía que **no** exige
  consentimiento: guardar el caché en
  [`tools::R_user_dir()`](https://rdrr.io/r/tools/userdir.html)
  declarando `R >= 4.0`, siempre que el contenido se gestione
  activamente. Cuando lleguen los comentarios de la revisión se decidirá
  por cuál ir. El estado exacto que se envió a CRAN está preservado en
  la rama `cran-2.0.0`.

## censosbo 2.0.0

CRAN release: 2026-08-07

Esta versión prepara el paquete para **CRAN**. El cambio de mayor a
2.0.0 es por la retirada de `update_censosbo()`; el resto es
infraestructura que no altera ningún resultado.

### Cambio incompatible

- **`update_censosbo()` se retira.** Una función que reinstala el propio
  paquete desde GitHub no puede convivir con la distribución por CRAN:
  evita el canal oficial y modifica la instalación del usuario sin pasar
  por él.

  Para actualizar, ahora: `install.packages("censosbo")` (o
  `remotes::install_github("lab-tecnosocial/censosbo")` para la versión
  en desarrollo). Y si la nueva versión corrige **datos** y no solo
  código, borrar el caché para que se vuelvan a descargar:

  ``` r

  censosbo_cache_clear()
  ```

### Preparación para CRAN

Nada de esto cambia lo que devuelven las funciones. Se documenta porque
explica por qué se movieron archivos que parecían estar bien donde
estaban.

- **Las tablas internas con texto en español pasan a `R/sysdata.rda`**
  (etiquetas de los códigos armonizados, textos de universo, nombres de
  departamento). CRAN exige que el código de R sea ASCII puro, y
  escribir `"Sin instrucción"` como `"Sin instrucci\u00f3n"` habría
  vuelto ilegible un dato que hay que poder leer y editar. Ahora se
  editan en `data-raw/build_sysdata.R`, con un test que compara byte a
  byte contra una referencia para que ninguna máquina con otra
  codificación pueda corromper las tildes en silencio.

- Los mensajes de error y aviso se escriben con escapes `\uXXXX` en el
  código. El texto que ve el usuario es idéntico.

- **El primer uso del caché pide confirmación** en sesión interactiva,
  como pide la política de CRAN para escribir fuera del directorio
  temporal. En scripts, CI o contenedores —cualquier sesión no
  interactiva— no pregunta y descarga igual. Para autorizarlo de
  antemano: `options(censosbo.consent = TRUE)`.

- Siete viñetas pasan a ser **artículos solo-web**: siguen publicadas en
  <https://lab-tecnosocial.github.io/censosbo/> y no cambian de
  contenido, pero no viajan dentro del paquete. Las tres que sí lo hacen
  (*Introducción*, *Diccionario*, *Temas*) vienen precompiladas, así que
  instalar el paquete ya no descarga nada.

- `duckdb` y `DBI` pasan de dependencias obligatorias a opcionales: solo
  hacen falta para `as = "duckdb"`, y el paquete avisa de cómo
  instalarlos si se pide ese backend sin tenerlos. Quien no use SQL se
  ahorra compilarlos. `sf` sigue siendo obligatorio, porque las capas
  `geo_*` que trae el paquete son objetos `sf` y sin él no se podrían ni
  imprimir.

- `Title` y `Description` pasan a inglés, como pide CRAN. La
  documentación, las viñetas y los mensajes siguen íntegramente en
  español.

- **El requisito de versión de R pasa a `>= 4.2`**, que es el mínimo
  real: lo impone `arrow`. El `>= 4.1.0` que se declaraba antes era una
  promesa falsa — con R 4.1 la instalación falla al resolver esa
  dependencia.

## censosbo 1.7.0

> ⚠️ **Esta versión cambia el número de filas que devuelven las
> funciones `get_viviendas_*()`**, así que rompe cualquier código que
> dependiera del conteo anterior. Si necesitas el comportamiento de la
> 1.6.0, pasa `universo = "todos"`. Los consumidores que leen
> `vivienda.parquet` directamente (sin pasar por las funciones de R)
> **no** heredan la corrección y hay que arreglarlos aparte:
> `censos-explorer` y `q-censosbo` están en ese caso.

### El universo de vivienda: `get_viviendas_2024()` ya cuenta como el INE

**Cambio de comportamiento.**
[`get_viviendas_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/get_viviendas_2024.md)
devolvía 4.490.488 filas y las llamaba viviendas. 10.287 de ellas no lo
son: son personas censadas fuera de una vivienda, marcadas en
`v01_tipoviv` como *persona que vive en la calle* (código 15, 3.311
registros) o *en tránsito: terminal, aeropuerto, puerto u otro* (código
16, 6.976). El INE no las cuenta como viviendas en ningún tabulado.

Ahora el defecto es el universo oficial: **4.480.201 viviendas**, la
cifra de los tabulados del CPV-2024. También cuadra por área (2.898.140
urbanas, 1.582.061 rurales) y, agregando por municipio, coincide al
registro con las viviendas del geoportal en **los 343 municipios** —con
la entidad cruda solo coincidían 20.

- **Argumento `universo` nuevo** en
  [`get_viviendas_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/get_viviendas_2024.md),
  `get_censo(anio, "vivienda")` y los atajos
  [`get_viviendas_1976()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md)/`_1992()`/`_2001()`/`_2012()`:

  | `universo`       |      2024 | Qué es                                          |
  |------------------|----------:|-------------------------------------------------|
  | `"viviendas"`    | 4.480.201 | El universo oficial del INE (defecto)           |
  | `"particulares"` | 4.463.773 | Casas, departamentos, chozas, cuartos sueltos…  |
  | `"colectivas"`   |    16.428 | Hoteles, hospitales, cuarteles, penitenciarías… |
  | `"todos"`        | 4.490.488 | La entidad cruda de REDATAM, como antes         |

  **Si necesitas el comportamiento anterior, usa `universo = "todos"`.**

- **Los censos anteriores tienen el mismo problema y el mismo arreglo.**
  Cada uno nombra la categoría a su manera: 1992 *Ambulante* (4.939
  registros), 2001 *Transeúntes* (9.392), 2012 *En tránsito* y *Persona
  que vive en la calle* (12.971). Los totales por defecto pasan a
  1.701.168, 2.281.022 y 3.159.350. El censo 1976 no preguntó por calle
  ni tránsito: ahí no cambia nada.

- **[`tipos_vivienda()`](https://lab-tecnosocial.github.io/censosbo/reference/tipos_vivienda.md)**,
  función nueva: los códigos de tipo de vivienda de un censo con su
  etiqueta, su grupo (`particular`, `colectiva`, `no_vivienda`,
  `sin_clasificar`) y si entran en el universo oficial. Sirve para
  auditar qué descarta cada valor de `universo` en vez de tener que
  confiar en la documentación.

- Los códigos que aparecen en los microdatos pero no en el diccionario
  del censo (el 88 de 1976, el 0 de 1992) **se conservan** en
  `"viviendas"`: no consta que sean calle ni tránsito, así que
  descartarlos sería una decisión sin respaldo.
  [`tipos_vivienda()`](https://lab-tecnosocial.github.io/censosbo/reference/tipos_vivienda.md)
  los muestra como `sin_clasificar` en vez de esconderlos.

### Documentación corregida

- **[`get_unidades_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/get_unidades_2024.md)
  decía algo falso.** Afirmaba que la diferencia del 0,23% entre las
  viviendas del geoportal y las de los microdatos «procede del propio
  INE, que cuenta las viviendas de forma distinta en el geoportal y en
  los microdatos», y recomendaba
  [`get_viviendas_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/get_viviendas_2024.md)
  para el total de un territorio —justo la cifra inflada. No eran dos
  formas de contar: eran los registros de calle y tránsito. Con el
  universo oficial las dos fuentes cuadran exactamente. Lo mismo estaba
  escrito en `dev-docs/fuentes-ine-geoportal.md`.

- **El universo `todas_viviendas` del diccionario induce a error** y
  ahora se describe como lo que es: todos los registros de la entidad
  `vivienda`, incluidas las personas en la calle o en tránsito.

- **Una tasa oficial no es dividir una categoría entre todas las
  filas.** La viñeta de análisis demográfico calculaba el alfabetismo de
  15+ años sobre toda la población de esa edad y daba 94,94%; el
  tabulado oficial publica 95,8633%. La diferencia son los 80.297
  registros con `p40_lee = 9` (*Sin especificar*), que el INE deja fuera
  del denominador: excluirlos da 95,8630% y explica la brecha salvo
  0,0003 puntos. La viñeta ahora enseña la receta y por qué hace falta.

### Tests de reconciliación con el INE

`tests/testthat/test-reconciliacion-oficial.R`, suite nueva. Que la
suite pasara demostraba consistencia interna, no que las cifras
coincidieran con lo publicado —que es lo que se cita. Ahora quedan
fijadas: población total y por sexo, los cuatro universos de vivienda,
viviendas por área, el cuadre municipio a municipio con el geoportal,
los totales de los censos históricos y el denominador del alfabetismo.

Necesita los microdatos completos en caché (~1 GB), así que se salta por
defecto:

``` bash
CENSOSBO_TEST_RECONCILIACION=true Rscript -e 'devtools::test(filter = "reconciliacion")'
```

## censosbo 1.6.0

### Cartografía municipal completa y sin huecos

`geo_municipios` pasa a los **343 municipios del CPV-2024**, sobre
límites nuevos de SDSN Bolivia cruzados con los códigos y nombres del
INE. Antes eran 339 polígonos de cartografía electoral. La procedencia
de cada columna está en la viñeta *Mapas coropléticos*.

- **Los cuatro GAIOC creados desde 2016 ya se dibujan**: TIOC-Raqaypampa
  (Cochabamba), San Pedro de Macha y TIOC-Jatun Ayllu Yura (Potosí), y
  TIOC-Territorio Indígena Multiétnico (Beni). No eran huecos en el
  mapa: su territorio aparecía dentro del municipio madre —Mizque,
  Colquechaca, Tomave, San Ignacio y Santa Ana—, así que sus datos
  salían mal atribuidos sin que se notara. Son 7.599 km² que estaban
  asignados al municipio equivocado.

- **Desaparecen las franjas blancas entre municipios.** La capa anterior
  se simplificó sin preservar la topología y quedaban 1.126 huecos
  espurios (461 km²) entre vecinos, visibles en cualquier zoom. La nueva
  se simplifica con `rmapshaper::ms_simplify()`, que respeta los arcos
  compartidos: los únicos huecos que quedan son reales (Salar de Uyuni,
  lagos Poopó y Uru Uru).

- **Dos columnas nuevas**: `capital` (capital municipal) y
  `superficie_km2`, con la que se calculan densidades sin recalcular
  áreas.

- `geo_departamentos` ahora se deriva por disolución de
  `geo_municipios`, de modo que los bordes departamentales caen
  exactamente sobre los municipales.

- Los códigos `idep`/`iprov`/`imun` de cada polígono **no se leen de la
  fuente cartográfica**, que los trae desalineados en 7 municipios de
  Omasuyos (La Paz) y Ñuflo de Chávez (Santa Cruz). Se deducen por voto
  espacial mayoritario contra los ~21.000 puntos de comunidades del
  CPV-2024, que llevan el código usado en los microdatos. Con eso, la
  población municipal de la fuente coincide exacta en los 343 municipios
  con el conteo de los microdatos, y el 97,3% de los puntos del CPV-2024
  cae en su municipio (antes, 95,9%).

[`mapa_mun()`](https://lab-tecnosocial.github.io/censosbo/reference/mapa_mun.md)
ya no avisa de «municipios sin cobertura cartográfica»: la advertencia
queda solo para códigos que no existen en la división actual, lo típico
al mapear censos anteriores a 2012.

## censosbo 1.5.1

### Correcciones

- El aviso de universo de
  [`get_temporal()`](https://lab-tecnosocial.github.io/censosbo/reference/get_temporal.md)
  daba un consejo que no se podía seguir. Decía «Filtra `edad >= 6`»,
  pero la función solo devuelve las variables pedidas, así que sin
  `"edad"` entre ellas el filtro fallaba con `object 'edad' not found`.
  Ahora, cuando la columna no está, el aviso dice cómo conseguirla:
  «Añade “edad” a `variables` y filtra `edad >= 6`». Los grupos
  predefinidos (`grupo = "educacion"`) ya la incluían, así que esto solo
  afectaba a quien pedía variables sueltas.
- Documentación al día con la cobertura real de los cinco censos: los
  `@format` de `codebook_meta` y `codebook_historico_meta` describían
  cinco columnas de las quince, y los roxygen de `censo_temas_meta`,
  `codebook_docs_meta`,
  [`censo_temas()`](https://lab-tecnosocial.github.io/censosbo/reference/censo_temas.md),
  [`vars_tema()`](https://lab-tecnosocial.github.io/censosbo/reference/vars_tema.md)
  y
  [`codebook_docs()`](https://lab-tecnosocial.github.io/censosbo/reference/codebook_docs.md)
  seguían diciendo 20 temas y tres censos, junto con las viñetas
  `diccionario` y `censos-historicos`.

## censosbo 1.5.0

### Un vocabulario temático para las variables censales

Los cinco censos tienen 809 variables entre todos, y el diccionario solo
decía nombre, etiqueta, tabla y tipo. No había forma de preguntar «¿qué
variables hay de educación?» ni —lo que más importa— **a quién se le
preguntó cada cosa**. Esta versión añade las dos cosas, a partir de dos
fuentes oficiales del INE: los cuestionarios censales y los diccionarios
DDI del catálogo ANDA (estudios 132, 8, 10, 47 y 46, es decir **los
cinco censos**).

#### Nuevas columnas en el codebook

[`codebook()`](https://lab-tecnosocial.github.io/censosbo/reference/codebook.md)
devuelve diez columnas más. Van **al final**, después de las cinco
originales, cuyo nombre y orden se conservan:

- `tema` — uno de 21 temas. Diecisiete son los que el propio INE declara
  en su catálogo; los otros cuatro los añade el paquete
  (`ubicacion_geografica`, `identificacion`, `materiales_construccion` y
  `religion`, esta última porque solo el censo de 1992 preguntó por
  pertenencia religiosa).
- `universo` — a quién se aplicó la pregunta: `personas_5_mas`,
  `mujeres_12_mas`, `viviendas_presentes`… **Es la columna que evita el
  error más frecuente en análisis censal**: calcular un porcentaje sobre
  el denominador equivocado. Por ejemplo, `nivel_edu` está construida
  sobre personas de 19 años o más, no sobre toda la población.
- `capitulo` — los siete capítulos (A–G) del cuestionario del CPV-2024.
- `pregunta` y `pregunta_num` — el número de pregunta del formulario,
  para recorrer el censo en el mismo orden en que se aplicó.
- `origen` — distingue una pregunta directa (`cuestionario`) de una
  variable que el INE o REDATAM construyeron (`derivada`), de las claves
  geográficas y los identificadores.
- `grupo_ine` — la agrupación oficial de cada censo anterior, que 2024
  no trae.
- `bloque` y `denominador` — para los 194 indicadores de manzano y
  comunidad.
- `valores_fuente` — si las etiquetas de valor vienen de REDATAM o del
  DDI.

Los 21 temas se aplican a los cinco censos, así que
`codebook(tema = "educacion", anio = ...)` es comparable entre ellos.
Los capítulos son solo de 2024: los cuestionarios anteriores tienen otra
estructura y varios numeran las secciones de vivienda y de persona en
paralelo.

#### Funciones nuevas

- [`censo_temas()`](https://lab-tecnosocial.github.io/censosbo/reference/censo_temas.md)
  — el catálogo de temas con el número de variables de cada uno, contado
  en vivo y filtrable por tabla y año.

- [`vars_tema()`](https://lab-tecnosocial.github.io/censosbo/reference/vars_tema.md)
  — los nombres de las variables de un tema, en el orden del
  cuestionario, listos para pasar a `variables`:

  ``` r

  get_personas_2024(
    departamento = "Cochabamba",
    variables = vars_tema("educacion", tabla = "persona")
  )
  ```

- [`codebook_docs()`](https://lab-tecnosocial.github.io/censosbo/reference/codebook_docs.md)
  — la documentación conceptual oficial del INE: qué mide la variable,
  la pregunta tal como se leyó en campo, las instrucciones al censista
  y, para las derivadas, la regla con que se calcularon. Cubre 445
  variables de los cinco censos.

[`codebook()`](https://lab-tecnosocial.github.io/censosbo/reference/codebook.md)
acepta `tema`, `capitulo` y `origen`, añadidos **después** de `anio`
para no romper las llamadas posicionales.

#### `get_temporal()` avisa cuando el universo cambia entre censos

Armonizar los códigos no iguala la población a la que se preguntó, y el
INE movió el filtro de edad de varias preguntas entre censos. Ahora **el
paquete lo detecta y avisa**:

    ! `sabe_leer` no se preguntó a la misma población en todos los censos:
        1992: personas de 6 años o más
        2001: personas de 4 años o más
        2024: personas de 5 años o más
      i Añade "edad" a `variables` y filtra `edad >= 6` antes de comparar.

Siete variables armonizadas están afectadas. `nivel_edu` es la más
extrema: 6 años en 1992, 4 en 2001 y **19** en 2024. Antes esto estaba
escrito en la documentación para dos variables; ahora salta en el punto
de uso para todas, con el dato del propio INE.

`get_temporal(grupo = )` también acepta ya los slugs de
[`censo_temas()`](https://lab-tecnosocial.github.io/censosbo/reference/censo_temas.md),
para no tener que recordar cuál de los dos vocabularios usa cada
función. Los seis grupos originales siguen siendo válidos.

#### Datasets nuevos

`censo_temas_meta` (21 temas), `censo_bloques_meta` (los 15 bloques de
las fichas) y `codebook_docs_meta` (445 filas de documentación
conceptual, con la procedencia de los cinco DDI en el atributo `"ddi"`).
`variable_temporal_map` gana una columna `tema` que conecta los nombres
armonizados con la taxonomía.

#### Salida más legible

Con quince columnas, imprimir el codebook en consola se había vuelto
ilegible. Ahora [`print()`](https://rdrr.io/r/base/print.html) oculta
las columnas que no aplican al subconjunto consultado —y dice cuáles
son— y resume `valores_codigos` por su número de categorías en vez de
volcar todas. El objeto sigue siendo un `data.frame` con todas las
columnas.

#### Correcciones

- **[`etiquetar_valores()`](https://lab-tecnosocial.github.io/censosbo/reference/etiquetar_valores.md)
  elegía la tabla equivocada.** Cuando una variable existe en varias
  tablas y solo algunas traen las categorías —`idep` en el censo 2001
  las tiene en `persona` y no en `vivienda`—, se cogía la primera fila
  del diccionario y la columna se quedaba sin etiquetar. Ahora se usa la
  primera que sí las tiene.

- **`i00` ya está documentada.** El número de vivienda dentro del predio
  se devolvía en todas las consultas pero no estaba en el diccionario,
  así que
  [`etiquetar_variables()`](https://lab-tecnosocial.github.io/censosbo/reference/etiquetar_variables.md)
  no la etiquetaba.

- Cuando se piden columnas que no existen en la tabla consultada pero sí
  en otra, el aviso ahora lo dice:
  `"v07_aguapro existe en la tabla vivienda; usa get_viviendas_2024()"`.

- Dos gráficos de las viñetas declaraban un universo que no era el que
  mostraban. El de nivel educativo decía «15+ años» cuando en realidad
  era 19+, y el mapa de alfabetismo no aclaraba su umbral; ahora usa
  15+, el de las tasas oficiales.

#### Cambios de comportamiento

- `codebook(buscar = )` ahora busca también en el tema, así que
  `codebook(buscar = "salud")` devuelve el tema completo y puede dar más
  filas que antes.
- En los censos 2001 y 1976, un par de variables pasaron a tener
  etiquetas de valor tomadas del DDI del INE.
  [`etiquetar_valores()`](https://lab-tecnosocial.github.io/censosbo/reference/etiquetar_valores.md)
  devolverá un factor donde antes devolvía el código: puede afectar a
  gráficos o tablas ya hechos.

#### Nota sobre las etiquetas de valor

Los DDI de los cuatro censos anteriores traen categorías que el
diccionario de microdatos no tiene, y se usaron para rellenar los
huecos. **No se sobrescribió nada preexistente**, y con razón: el
contraste reveló que el DDI del INE tiene errores puntuales — en el
CPV-2012, la variable de estado civil viene con las categorías de otra
pregunta. Las discrepancias quedan registradas para revisión en
`data-raw/ddi/reporte_valores.md`, clasificadas por severidad.

#### Para quien consuma el paquete

Las columnas nuevas también viajan a los `diccionario_variables.parquet`
publicados en los GitHub Releases. Los consumidores que cacheen ese
archivo por nombre —el plugin de QGIS lo hace— tienen que vaciar la
caché una vez para verlas. Ver `dev-docs/consumidores-taxonomia.md`.

## censosbo 1.4.1

- **Las descargas reintentan ante fallos transitorios.** GitHub Releases
  devuelve 500 o 503 esporádicamente, y un único fallo abortaba toda la
  operación — algo molesto cuando se piden los nueve archivos de persona
  o los nueve de manzanos. Ahora se reintenta tres veces con espera
  creciente y solo se aborta si fallan todos los intentos. De paso, los
  tres descargadores
  ([`.download_parquet()`](https://lab-tecnosocial.github.io/censosbo/reference/dot-download_parquet.md),
  [`.download_ficha()`](https://lab-tecnosocial.github.io/censosbo/reference/dot-download_ficha.md)
  y
  [`.download_censo()`](https://lab-tecnosocial.github.io/censosbo/reference/dot-download_censo.md))
  comparten un solo helper en vez de repetir la misma lógica de descarga
  atómica.

## censosbo 1.4.0

### `get_censo()` ahora cubre también el CPV-2024

[`get_censo()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md)
se presentaba como la API genérica por año, pero rechazaba `anio = 2024`
— y la propia documentación de
[`get_personas_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/get_personas_2024.md)
ofrecía `get_censo(2024, "persona", ...)` como equivalente, un ejemplo
que no funcionaba. Ahora acepta los cinco censos: con `anio = 2024`
delega en
[`get_personas_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/get_personas_2024.md),
[`get_viviendas_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/get_viviendas_2024.md),
[`get_emigracion_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/get_emigracion_2024.md)
o
[`get_mortalidad_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/get_mortalidad_2024.md)
según `tabla`, con resultado idéntico al de esas funciones.

``` r

get_censo(2024, "persona", departamento = "07")   # = get_personas_2024()
```

### Correcciones

- **Los mapas fallaban en una sesión limpia.** `sf` estaba en `Imports:`
  del DESCRIPTION pero nada lo importaba en `NAMESPACE`, así que
  [`library(censosbo)`](https://lab-tecnosocial.github.io/censosbo/) no
  cargaba su namespace ni registraba sus métodos S3. Sin ellos, filtrar
  un objeto `sf` caía en `[.data.frame`, que degrada la columna de
  geometría a una lista corriente, y `mapa_mun(..., departamento = ...)`
  abortaba con
  `attr(obj, "sf_column") does not point to a geometry column`. Afectaba
  también a `geo_municipios` y `geo_departamentos` manipulados por el
  usuario.
- **[`etiquetar_variables()`](https://lab-tecnosocial.github.io/censosbo/reference/etiquetar_variables.md)
  dejaba columnas sin nombre.** Las 11 variables derivadas del censo
  1976 que no traen descripción en el diccionario del INE (`nivela`,
  `pea`, `pet`, `anioes1`, …) se renombraban a `""`. Ahora conservan su
  nombre original.
- **[`mapa_dep()`](https://lab-tecnosocial.github.io/censosbo/reference/mapa_dep.md)
  y
  [`mapa_mun()`](https://lab-tecnosocial.github.io/censosbo/reference/mapa_mun.md)
  ignoraban los códigos geográficos numéricos.** Un `idep` entero (`1`,
  `2`, …) no emparejaba con `"01"`, `"02"`, … del catálogo y el mapa
  salía entero en gris, sin ningún aviso. Ahora se normalizan a 2
  dígitos, igual que en
  [`etiquetar_geografia()`](https://lab-tecnosocial.github.io/censosbo/reference/etiquetar_geografia.md).
- **[`get_temporal()`](https://lab-tecnosocial.github.io/censosbo/reference/get_temporal.md)
  perdía `nivel_edu` en 1992** en las filas donde `P11` era `NA`: la
  condición del [`ifelse()`](https://rdrr.io/r/base/ifelse.html)
  propagaba el `NA` al resultado.
- [`censosbo_cache_clear()`](https://lab-tecnosocial.github.io/censosbo/reference/censosbo_cache_clear.md)
  ya limpia también el subdirectorio `fichas/` cuando queda vacío (antes
  solo lo hacía con `historico/`).
- `mapa_dep(mostrar_nombres = TRUE)` y
  `mapa_mun(mostrar_nombres = TRUE)` ya no emiten los avisos de `sf`
  sobre centroides en coordenadas geográficas, que eran irrelevantes
  para posicionar una etiqueta.
- `citation("censosbo")` reportaba siempre la versión 1.0.0; ahora lee
  la versión y el año del paquete instalado.

### Documentación: cifras verificadas y ejemplos que se ejecutan

Se revisaron todas las cifras de la documentación contra los datos
publicados y se corrigieron las que no cuadraban:

- **`geo_municipios` tiene 339 municipios, no 336**, y los que faltan
  son 4, no 7 (los TIOC Raqaypampa, Jatun Ayllu Yura y Territorio
  Indígena Multiétnico, más San Pedro de Macha).
- **Tamaños en disco y RAM.** Los tamaños de los censos históricos
  estaban desactualizados (1976 figuraba con 63 MB y son 46; 2012
  persona con 165 MB y son 120), y las estimaciones de RAM eran entre 5
  y 10 veces demasiado bajas:
  [`get_personas_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/get_personas_2024.md)
  completo ocupa ~5,6 GB al hacer
  [`collect()`](https://dplyr.tidyverse.org/reference/compute.html), no
  ~490 MB. El número de columnas de los censos históricos tampoco
  incluía las columnas geográficas denormalizadas.
- **Variables mal citadas del censo 1976**: la viñeta usaba `p02` como
  sexo y `p03` como edad, cuando `p02` es parentesco, `p03` sexo y `p04`
  edad.
- La viñeta de análisis temporal decía que `servicio_sanitario` no está
  disponible en 2012 (sí lo está, es `P09`) y usaba el código `"05"`
  para Santa Cruz (es `"07"`; `"05"` es Potosí). La de censos históricos
  daba 344 municipios para 2024 (son 343) y afirmaba que sin
  `departamento` no se añaden las columnas geográficas, cuando se añaden
  siempre.
- El README y la viñeta de introducción daban tablas de censos distintas
  entre sí, y la de introducción atribuía la conversión de los datos a
  un pipeline de Python que ya no se usa (es R: `haven`/`readr` +
  `arrow`).
- **Universos poblacionales en el análisis temporal.** `nivel_edu` y
  `estado_civil` cambian de población de referencia entre censos, así
  que sus distribuciones no son comparables sin filtrar por edad. Queda
  documentado en `variables_armonizadas()$notas`, en
  [`?get_temporal`](https://lab-tecnosocial.github.io/censosbo/reference/get_temporal.md)
  y en la viñeta, que ahora aplica el filtro correcto en el gráfico de
  nivel educativo.
- **Los ejemplos se ejecutan de verdad.** El README y las viñetas de
  censos históricos y análisis temporal tenían los bloques con
  `eval = FALSE` y salidas escritas a mano. Ahora se ejecutan al
  construir la documentación (con departamentos pequeños, para que la
  descarga sea liviana), así que las salidas que se ven son reales.
- La viñeta del diccionario documenta ya las tablas `unidad` y `ficha`
  (los 194 indicadores por manzano y comunidad), que faltaban.

## censosbo 1.3.0

### Datos por manzano y comunidad (CPV-2024)

El paquete llegaba hasta el municipio: 343 unidades. Ahora también da
acceso al nivel más fino que publica el INE, **268.604 unidades
censales** —manzanos urbanos y comunidades rurales— con 194 indicadores
cada una.

- **[`get_unidades_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/get_unidades_2024.md)**:
  universo completo de unidades con su población, viviendas y si tienen
  ficha disponible. Filtra por departamento, provincia, municipio y
  `area`.
- **[`get_fichas_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/get_fichas_2024.md)**:
  los 194 indicadores de la ficha resumen del INE — población por edad y
  sexo, educación, salud, migración, empleo, actividad económica,
  vivienda, servicios básicos, TIC, materiales de construcción,
  hacinamiento y tipo de hogar.
- **[`get_geo_manzanos()`](https://lab-tecnosocial.github.io/censosbo/reference/get_geo_manzanos.md)**
  y
  **[`get_geo_comunidades()`](https://lab-tecnosocial.github.io/censosbo/reference/get_geo_comunidades.md)**:
  geometrías en `sf` (EPSG:4326). Los manzanos están partidos por
  departamento; las comunidades rurales son en su mayoría puntos, no
  polígonos.
- **[`mapa_man()`](https://lab-tecnosocial.github.io/censosbo/reference/mapa_man.md)**:
  mapas de un municipio a nivel de manzano y comunidad.
- Nueva viñeta: *Manzanos y comunidades: el CPV-2024 al máximo detalle*.

Notas sobre estos datos:

- El INE **no libera la ficha de las unidades con poca población**, por
  reserva estadística. Eso deja fuera al 47 % de los manzanos, pero la
  cobertura efectiva sigue siendo alta: 150.744 unidades con ficha, el
  92 % de la población y el 90 % de las viviendas del país. La columna
  `ficha` de
  [`get_unidades_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/get_unidades_2024.md)
  marca cuáles la tienen.
- Los bloques `salud_lugar_*` y `tic_*` son de **respuesta múltiple**:
  sus categorías suman más que el total. Cada bloque incluye su propio
  total, que es el denominador correcto.
- `area` reutiliza el dominio de los microdatos (1 = Urbana, 2 = Rural),
  así que
  [`etiquetar_valores()`](https://lab-tecnosocial.github.io/censosbo/reference/etiquetar_valores.md)
  se comporta igual en ambas fuentes. Las funciones aceptan además
  `"urbano"` y `"rural"` por legibilidad.
- Los datos viven en su propio release (`data-fichas-v1.0.0`) y se
  cachean bajo `fichas/`, separados de los microdatos.

`codebook(tabla = "unidad")` y `codebook(tabla = "ficha")` documentan
las variables nuevas.

Una advertencia sobre los totales: la población agregada por municipio
coincide **exactamente** con
[`get_personas_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/get_personas_2024.md)
en los 343 municipios, pero las viviendas dan un 0,23% menos que
[`get_viviendas_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/get_viviendas_2024.md).
El déficit es sistemático (323 municipios por debajo, ninguno por
encima) y viene del propio INE, que cuenta las viviendas de forma
distinta en el geoportal y en los microdatos. Para el total de viviendas
de un territorio, usa
[`get_viviendas_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/get_viviendas_2024.md).

## censosbo 1.2.1

### Correcciones

- **`get_temporal(variables = "grupo_edad")`**: los grupos de edad
  quinquenales ahora se calculan desde la edad individual en **todos**
  los censos y son comparables entre años. Antes, 1976 y 1992 tomaban
  variables ya agrupadas (`edad5`/`GEDAD`), cuyos códigos no eran
  quinquenios: 1992 producía bins sin sentido y 1976 devolvía códigos
  crudos. (`grupo_edad` está en el grupo `demografico`, así que afectaba
  al análisis por defecto.)
- **Filtro por `municipio` con código sin `provincia`**: el código de
  municipio se repite entre provincias, por lo que `municipio = "01"`
  emparejaba un municipio por provincia (p.ej. 16 en Cochabamba) en
  silencio. Ahora se emite un **error** pidiendo indicar `provincia`
  para desambiguar (igual que ya ocurría con nombres repetidos entre
  departamentos). La comprobación de ambigüedad ahora cubre también los
  códigos, no solo los nombres.
- **Resultado vacío en
  [`get_censo()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md)**:
  la advertencia de filtro geográfico sin filas y el retorno `NULL`
  ahora ocurren con cualquier `as` (`"arrow"`, `"duckdb"`, `"tibble"`);
  antes solo con `"tibble"`, contradiciendo la documentación.

### Robustez

- **Descargas atómicas**: los Parquet se descargan a un archivo temporal
  `.part` y solo se renombran al completar. Una interrupción ya no deja
  un archivo truncado en caché que se reutilizaría indefinidamente.
- **[`censosbo_cache_clear()`](https://lab-tecnosocial.github.io/censosbo/reference/censosbo_cache_clear.md)**
  borra únicamente los archivos `.parquet` (y el subdirectorio
  `historico/` si queda vacío), en lugar de eliminar todo el directorio
  de caché. Evita perder otros archivos cuando el caché se redirige a
  una carpeta del proyecto con `options(censosbo.cache_dir = ...)`.

### Consistencia y DX

- [`codebook()`](https://lab-tecnosocial.github.io/censosbo/reference/codebook.md)
  y
  [`variables_armonizadas()`](https://lab-tecnosocial.github.io/censosbo/reference/variables_armonizadas.md)
  **validan el argumento `tabla`** y abortan con la lista de tablas
  disponibles ante un valor no reconocido (antes devolvían 0 filas en
  silencio).
- [`codebook_valores()`](https://lab-tecnosocial.github.io/censosbo/reference/codebook_valores.md)
  avisa cuando la variable existe en varias tablas e indica de cuál
  muestra los valores.
- La documentación de las conexiones DuckDB recomienda cerrarlas con
  `DBI::dbDisconnect(con, shutdown = TRUE)` para liberar la instancia.
- Correcciones de documentación: ejemplo de
  [`mapa_mun()`](https://lab-tecnosocial.github.io/censosbo/reference/mapa_mun.md)
  usaba una variable inexistente (`v10_agua` → `v07_aguapro`); tamaños
  de descarga de
  [`get_personas_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/get_personas_2024.md)
  sincronizados con el README;
  [`get_mortalidad_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/get_mortalidad_2024.md)
  añadida a la tabla de censos del README; `NEWS.md` se incluye ahora en
  el paquete instalado.

## censosbo 1.2.0

### Filtros geográficos por nombre y validación (provincia / municipio)

- `provincia` y `municipio` ahora aceptan **nombres además de códigos**
  en
  [`get_personas_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/get_personas_2024.md),
  [`get_viviendas_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/get_viviendas_2024.md),
  [`get_emigracion_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/get_emigracion_2024.md),
  [`get_mortalidad_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/get_mortalidad_2024.md)
  y en los censos históricos 1992/2001/2012 vía
  [`get_censo()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md).
  Ejemplo:
  `get_personas_2024(departamento = "Cochabamba", municipio = "Cochabamba")`.
  (El censo 1976 mantiene solo códigos: usó cantones.)
- Los valores inexistentes ahora producen un **error claro** en vez de
  un resultado de 0 filas en silencio. Un nombre repetido entre
  departamentos (p.ej. `"Totora"`, `"Cercado"`) pide indicar
  `departamento` para desambiguar.
- Si se pasa `provincia`/`municipio` **sin** `departamento`, este se
  **infiere** del catálogo, de modo que
  `get_personas_2024(municipio = "Cochabamba")` solo descarga el
  departamento correspondiente en vez de todo el país.
- El filtrado se hace por la **tupla completa** `(idep, iprov, imun)`,
  corrigiendo un sobre-emparejamiento latente (el código de municipio se
  repite entre provincias y hay nombres de municipio repetidos entre
  departamentos).

### Nuevas funciones y mejoras de etiquetado

- Nueva función
  **[`etiquetar_geografia()`](https://lab-tecnosocial.github.io/censosbo/reference/etiquetar_geografia.md)**:
  agrega `nombre_dep`, `nombre_prov` y `nombre_mun` a un data frame de
  microdatos a partir de sus códigos geográficos, eliminando el
  `left_join` manual con
  [`municipios()`](https://lab-tecnosocial.github.io/censosbo/reference/municipios.md).
  Es el equivalente geográfico de
  [`etiquetar_valores()`](https://lab-tecnosocial.github.io/censosbo/reference/etiquetar_valores.md).
- [`etiquetar_valores()`](https://lab-tecnosocial.github.io/censosbo/reference/etiquetar_valores.md)
  etiqueta **`area`** (Urbana/Rural de la tabla persona) de forma
  determinista. Antes dependía de qué otras columnas acompañaran a
  `area` (la variable solo figuraba en el diccionario de 1976), por lo
  que a veces la dejaba como entero sin aviso.
- [`etiquetar_valores()`](https://lab-tecnosocial.github.io/censosbo/reference/etiquetar_valores.md)
  ahora **avisa** cuando la detección automática del censo parece
  equivocada: si los valores de una columna reconocida no coinciden con
  los códigos del censo detectado, la deja cruda y sugiere usar `anio =`
  (en vez de devolver una columna toda-`NA` en silencio).
- [`codebook()`](https://lab-tecnosocial.github.io/censosbo/reference/codebook.md)
  /
  [`codebook_valores()`](https://lab-tecnosocial.github.io/censosbo/reference/codebook_valores.md)
  documentan la variable derivada **`area`** (persona) con sus valores
  `1 = Urbana`, `2 = Rural`, equivalente a `urbrur` (vivienda).

### Consistencia

- [`departamentos()`](https://lab-tecnosocial.github.io/censosbo/reference/departamentos.md),
  [`provincias()`](https://lab-tecnosocial.github.io/censosbo/reference/provincias.md)
  y
  [`municipios()`](https://lab-tecnosocial.github.io/censosbo/reference/municipios.md)
  devuelven **`tibble`** (antes `data.frame`), por lo que
  `print(x, n = )` y la exploración funcionan como en el resto del
  tidyverse.

## censosbo 1.1.0

### Geografía directa en censos históricos (sin “consultas estrella”)

- Las tablas de los censos 1992, 2001 y 2012 (`persona`, `vivienda`,
  `mortalidad`, `emigracion`, `discapacidad`) ahora incluyen las
  columnas geográficas **`idep`, `iprov` e `imun`** pre-unidas,
  idénticas en formato al CPV-2024 (string de 2 dígitos, `"01"`–`"09"`).
  El censo 1976 (`poblacion`, `vivienda`) expone `idep` e `iprov` (no
  `imun`: usó cantones, no municipios comparables).
- [`get_censo()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md)
  filtra ahora por geografía **directamente sobre estas columnas**, sin
  reconstruir la jerarquía REDATAM (`persona → vivienda → municipio`).
  Esto elimina el join estrella vía DuckDB y la descarga de
  `depto`/`provin`/`munic`, y hace que los Parquet sean usables tal cual
  desde otras herramientas (QGIS, Python, DuckDB) sin joins.
- [`codebook()`](https://lab-tecnosocial.github.io/censosbo/reference/codebook.md)
  documenta `idep`/`iprov`/`imun` (tipo `categorica`) en todos los
  censos.

> **Actualización de datos:** esta versión cambia los Parquet
> publicados. Si ya tenías datos en caché, ejecuta `update_censosbo()`
> (o
> [`censosbo_cache_clear()`](https://lab-tecnosocial.github.io/censosbo/reference/censosbo_cache_clear.md))
> para descargar la versión con las columnas geográficas.

## censosbo 1.0.4

### Correcciones

- [`get_censo()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md)
  ahora muestra un mensaje claro al recibir un año no válido (antes
  fallaba con un error interno de `cli` por nombres de variable con
  punto). Mismo arreglo en los mensajes de error de descarga.
- [`etiquetar_valores()`](https://lab-tecnosocial.github.io/censosbo/reference/etiquetar_valores.md)
  ahora usa las etiquetas **armonizadas** correctas con los datos de
  [`get_temporal()`](https://lab-tecnosocial.github.io/censosbo/reference/get_temporal.md)/[`get_temporal_vivienda()`](https://lab-tecnosocial.github.io/censosbo/reference/get_temporal_vivienda.md)
  (antes aplicaba por error el diccionario del CPV-2024, produciendo
  etiquetas incorrectas en `nivel_edu` y otras).
- [`departamentos()`](https://lab-tecnosocial.github.io/censosbo/reference/departamentos.md),
  [`provincias()`](https://lab-tecnosocial.github.io/censosbo/reference/provincias.md)
  y
  [`municipios()`](https://lab-tecnosocial.github.io/censosbo/reference/municipios.md)
  reinician los nombres de fila (`1:n`) en lugar de arrastrar los del
  filtrado interno.

### Armonización temporal

- **`estado_civil`** ahora se armoniza a 4 categorías comparables entre
  censos (1=Soltero/a, 2=Casado/a o conviviente, 3=Separado/a o
  divorciado/a, 4=Viudo/a), limitadas por la granularidad del censo
  1992.
- **`pea`** y **`pet`** corregidas: el mapeo apuntaba a columnas
  equivocadas del CPV-2024 (`fft_19`/`ft_19`). Ahora usan `pea_13`
  (1=Ocupado, 2=Cesante, 3=Aspirante) y `pet_13` (1=Sí, 2=No),
  consistentes con los censos previos.
- `variable_temporal_map` y
  [`variables_armonizadas()`](https://lab-tecnosocial.github.io/censosbo/reference/variables_armonizadas.md)
  incluyen una nueva columna `armonizada` que indica si los códigos son
  comparables entre censos.
- [`get_temporal()`](https://lab-tecnosocial.github.io/censosbo/reference/get_temporal.md)
  advierte cuando se solicita una variable no armonizada (`parentesco`),
  cuyos códigos crudos no son comparables entre años.

## censosbo 1.0.3

- Tipos de variable corregidos en los diccionarios.

## censosbo 1.0.2

- Ajustes menores en datos y sus etiquetas

## censosbo 1.0.1

- Mejoras en ejemplos de documentación

## censosbo 1.0.0

Primera versión de lanzamiento. `censosbo` proporciona acceso
programático a los microdatos de los cinco censos de Bolivia (1976,
1992, 2001, 2012 y CPV-2024) y herramientas integradas para análisis
demográfico, temporal y visualización geográfica.

### Acceso a microdatos

- [`get_personas_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/get_personas_2024.md),
  [`get_viviendas_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/get_viviendas_2024.md),
  [`get_emigracion_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/get_emigracion_2024.md),
  [`get_mortalidad_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/get_mortalidad_2024.md):
  acceso al CPV-2024 (11.4 M personas, 4.5 M viviendas). Los datos del
  CPV-2024 se descargan por departamento en archivos Parquet
  particionados (~4–77 MB cada uno).
- `get_censo(anio, tabla, ...)`: API unificada para censos históricos
  (1976, 1992, 2001, 2012). Atajos por año:
  [`get_poblacion_1976()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md),
  [`get_personas_1992()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md),
  [`get_personas_2001()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md),
  [`get_personas_2012()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md),
  y demás funciones por tabla y año.
- Soporte nativo para `dplyr`, Apache Arrow (carga diferida) y DuckDB
  (consultas SQL). El formato de retorno se controla con
  `as = c("arrow", "tibble", "duckdb")`.
- Filtros geográficos por departamento, provincia y municipio en todas
  las funciones de descarga.

### Análisis temporal

- [`get_temporal()`](https://lab-tecnosocial.github.io/censosbo/reference/get_temporal.md):
  datos comparables entre todos los censos (1976–2024) para 11 variables
  armonizadas: `sexo`, `edad`, `grupo_edad`, `parentesco`,
  `estado_civil`, `sabe_leer`, `nivel_edu`, `pea`, `pet`, `area`,
  `departamento`.
- [`get_temporal_vivienda()`](https://lab-tecnosocial.github.io/censosbo/reference/get_temporal_vivienda.md):
  equivalente para la tabla de vivienda.
- [`variables_armonizadas()`](https://lab-tecnosocial.github.io/censosbo/reference/variables_armonizadas.md)
  y
  [`grupos_variables()`](https://lab-tecnosocial.github.io/censosbo/reference/grupos_variables.md):
  exploración del mapa de armonización y los grupos temáticos
  predefinidos (`demografico`, `educacion`, `economia`, `cultural`,
  `migracion`, `fertilidad`).

### Diccionario de variables

- [`codebook()`](https://lab-tecnosocial.github.io/censosbo/reference/codebook.md),
  [`codebook_valores()`](https://lab-tecnosocial.github.io/censosbo/reference/codebook_valores.md):
  búsqueda en el diccionario de las 168 variables del CPV-2024.
- [`codebook_1976()`](https://lab-tecnosocial.github.io/censosbo/reference/codebook.md),
  [`codebook_1992()`](https://lab-tecnosocial.github.io/censosbo/reference/codebook.md),
  [`codebook_2001()`](https://lab-tecnosocial.github.io/censosbo/reference/codebook.md),
  [`codebook_2012()`](https://lab-tecnosocial.github.io/censosbo/reference/codebook.md),
  [`codebook_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/codebook.md):
  atajos por año para censos históricos.
- [`etiquetar_valores()`](https://lab-tecnosocial.github.io/censosbo/reference/etiquetar_valores.md),
  [`etiquetar_variables()`](https://lab-tecnosocial.github.io/censosbo/reference/etiquetar_variables.md):
  convierte códigos numéricos a etiquetas legibles y renombra columnas
  con las descripciones del INE.

### Mapas coropléticos

- [`mapa_dep()`](https://lab-tecnosocial.github.io/censosbo/reference/mapa_dep.md):
  mapa coroplético a nivel departamental. Geometrías de los 9
  departamentos incluidas en el paquete (`geo_departamentos`).
- [`mapa_mun()`](https://lab-tecnosocial.github.io/censosbo/reference/mapa_mun.md):
  mapa coroplético a nivel municipal. Geometrías de 336 de los 343
  municipios incluidas en el paquete (`geo_municipios`).
- Todas las funciones devuelven objetos `ggplot` modificables con capas
  y temas adicionales de ggplot2.

### Geografía

- [`departamentos()`](https://lab-tecnosocial.github.io/censosbo/reference/departamentos.md),
  [`provincias()`](https://lab-tecnosocial.github.io/censosbo/reference/provincias.md),
  [`municipios()`](https://lab-tecnosocial.github.io/censosbo/reference/municipios.md):
  navegación de la división político-administrativa de Bolivia.
- Datos incluidos: `geo_bolivia` (343 municipios con nombres y códigos),
  `geo_departamentos` (9 objetos sf), `geo_municipios` (336 objetos sf).

### Gestión del caché

- [`censosbo_cache_dir()`](https://lab-tecnosocial.github.io/censosbo/reference/censosbo_cache_dir.md),
  [`censosbo_cache_info()`](https://lab-tecnosocial.github.io/censosbo/reference/censosbo_cache_info.md),
  [`censosbo_cache_clear()`](https://lab-tecnosocial.github.io/censosbo/reference/censosbo_cache_clear.md):
  los archivos Parquet se descargan una sola vez y se almacenan en caché
  local (`~/Library/Caches/org.R-project.R/R/censosbo/` por defecto).
- Opción `censosbo.cache_dir` para redirigir el caché al directorio del
  proyecto.

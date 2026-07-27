# Changelog

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
> publicados. Si ya tenías datos en caché, ejecuta
> [`update_censosbo()`](https://lab-tecnosocial.github.io/censosbo/reference/update_censosbo.md)
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

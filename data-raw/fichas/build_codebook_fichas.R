## Añade a codebook_meta las variables de las tablas `unidad` y `ficha`
## (datos agregados del CPV-2024 por manzano urbano y comunidad rural).
##
## Es un patch idempotente: borra las filas de esas dos tablas y las vuelve a
## escribir desde campos.csv, así se puede re-ejecutar sin duplicar nada y sin
## depender del Excel del INE que usa build_codebook.R.
##
## Ejecutar desde la raíz del paquete:
##   Rscript data-raw/fichas/build_codebook_fichas.R

source("data-raw/clasificar_tipos.R")
source("data-raw/fichas/denominadores.R")

load("data/codebook_meta.rda")

campos <- utils::read.csv("data-raw/fichas/campos.csv",
                          stringsAsFactors = FALSE, encoding = "UTF-8")
stopifnot(nrow(campos) == 160, !anyDuplicated(campos$variable))

# Los 34 de la ficha ampliada de vivienda (materiales, hacinamiento, hogar).
campos_viv <- utils::read.csv("data-raw/fichas/campos_vivienda.csv",
                              stringsAsFactors = FALSE, encoding = "UTF-8")
stopifnot(nrow(campos_viv) == 34, !anyDuplicated(campos_viv$variable))

# `bloque` se CONSERVA. Antes se descartaba aquí, y por eso la agrupación
# temática de las fichas acabó duplicada a mano en censos-explorer y en
# q-censosbo. Ahora viaja con el codebook y es su única fuente.
campos <- rbind(campos[, c("variable", "etiqueta", "bloque")],
                campos_viv[, c("variable", "etiqueta", "bloque")])
stopifnot(nrow(campos) == 194, !anyDuplicated(campos$variable))

bloques_ref <- utils::read.csv("data-raw/taxonomia/bloque_tema.csv",
                               stringsAsFactors = FALSE, na.strings = c("", "NA"))
stopifnot(all(campos$bloque %in% bloques_ref$bloque))

fila <- function(variable, etiqueta, tabla, bloque = NA_character_,
                 denominador = NA_character_) {
  data.frame(variable = variable, etiqueta = etiqueta, tabla = tabla,
             tipo = NA_character_, bloque = bloque, denominador = denominador,
             stringsAsFactors = FALSE)
}

# ── Variables comunes a ambas tablas ─────────────────────────────────────────

geo_defs <- c(
  codigo = "Código de la unidad censal (manzano o comunidad)",
  area   = "Área Urbana - Rural",
  idep   = "Código de departamento (01-09)",
  iprov  = "Código de provincia dentro del departamento",
  imun   = "Código de municipio dentro de la provincia"
)

# Las comunes llevan bloque `unidad`, que es el grupo con el que los selectores
# de los consumidores muestran las claves de la unidad censal.
comunes <- function(tabla) {
  do.call(rbind, Map(fila, names(geo_defs), unname(geo_defs), tabla,
                     MoreArgs = list(bloque = "unidad")))
}

# ── Tabla `unidad`: el universo de unidades ──────────────────────────────────

unidad_defs <- c(
  nombre    = "Nombre de la unidad censal",
  personas  = "Personas empadronadas en la unidad",
  viviendas = "Viviendas empadronadas en la unidad",
  ficha     = "Lógico: si el INE libera la ficha de indicadores de esta unidad"
)

filas_unidad <- rbind(
  comunes("unidad"),
  do.call(rbind, Map(fila, names(unidad_defs), unname(unidad_defs), "unidad",
                     MoreArgs = list(bloque = "unidad")))
)

# ── Tabla `ficha`: los 194 indicadores ───────────────────────────────────────

filas_ficha <- rbind(
  comunes("ficha"),
  fila(campos$variable, campos$etiqueta, "ficha", campos$bloque,
       .denominador_ficha(campos$bloque, campos$variable))
)
# `""` significa "es un total, no tiene denominador". En el codebook se guarda
# como NA, que es lo que R entiende por ausencia.
filas_ficha$denominador[!nzchar(filas_ficha$denominador)] <- NA_character_

nuevas <- rbind(filas_unidad, filas_ficha)

# El clasificador compartido decide el tipo. Los conteos son numéricos; los
# códigos geográficos y `area` salen como categóricos por GEO_CODE_VARS y por el
# nombre. `ficha` es lógica, así que se fija a mano.
nuevas$tipo <- vapply(seq_len(nrow(nuevas)), function(i) {
  clasificar_tipo(nuevas$variable[i], NULL, storage_type = NA_character_)
}, character(1))
nuevas$tipo[nuevas$variable %in% c("codigo", "nombre")] <- "texto"
nuevas$tipo[nuevas$variable == "area"] <- "categorica"
nuevas$tipo[nuevas$variable == "ficha"] <- "categorica"

# `valores_codigos` es una list-column; estas variables no tienen códigos salvo
# `area` y `ficha`.
nuevas$valores_codigos <- vector("list", nrow(nuevas))

# `area` reutiliza el mismo dominio que la variable `area` de los microdatos
# (1 = Urbana, 2 = Rural). Un solo vocabulario para el mismo concepto: así
# `etiquetar_valores()` se comporta igual en las dos fuentes y los resultados
# se pueden comparar sin traducir códigos.
for (i in which(nuevas$variable == "area")) {
  nuevas$valores_codigos[[i]] <- data.frame(
    codigo   = c("1", "2"),
    etiqueta = c("Urbana", "Rural"),
    stringsAsFactors = FALSE
  )
}
# `ficha` se deja SIN valores_codigos a propósito. Es una columna lógica y así
# se usa: `sum(ficha)`, `personas[ficha]`, `filter(ficha)`. Si tuviera códigos,
# `etiquetar_valores()` la convertiría en factor y todas esas operaciones
# fallarían con "'sum' not meaningful for factors". La etiqueta ya explica qué
# significa; traducir TRUE/FALSE no aporta nada y rompe el uso natural.

# ── Patch idempotente ────────────────────────────────────────────────────────

# Cada denominador debe apuntar a una variable real de la misma tabla: si el port
# de la regla se desalinea con los campos del INE, queremos saberlo aquí.
den <- stats::na.omit(filas_ficha$denominador)
faltan <- setdiff(den, filas_ficha$variable)
stopifnot(length(faltan) == 0)

# Alinear columnas en AMBAS direcciones antes del rbind. Hacen falta las dos
# porque este script puede correr sobre dos estados distintos del codebook:
#
#   - recién reconstruido por build_codebook.R  -> solo las 5 columnas originales,
#     y hay que añadirle `bloque` y `denominador`, que aporta este script;
#   - ya enriquecido por add_taxonomia_to_codebook.R -> trae las de taxonomía, y
#     hay que añadírselas a `nuevas` vacías (las rellena el patch después).
#
# Alinear en una sola dirección rompía el pipeline completo desde el xlsx del INE.
rellenar <- function(df, cols) {
  for (col in setdiff(cols, names(df))) {
    df[[col]] <- if (col == "valores_codigos") vector("list", nrow(df))
                 else if (col == "pregunta_num") NA_integer_
                 else NA_character_
  }
  df
}
nuevas <- rellenar(nuevas, names(codebook_meta))
codebook_meta <- rellenar(codebook_meta, names(nuevas))

stopifnot(identical(sort(names(nuevas)), sort(names(codebook_meta))))
nuevas <- nuevas[, names(codebook_meta)]

codebook_meta <- codebook_meta[!codebook_meta$tabla %in% c("unidad", "ficha"), ]
codebook_meta <- rbind(codebook_meta, nuevas)
rownames(codebook_meta) <- NULL

message("Variables añadidas: ", nrow(nuevas),
        " (unidad: ", nrow(filas_unidad), ", ficha: ", nrow(filas_ficha), ")")
message("codebook_meta ahora tiene ", nrow(codebook_meta), " filas")
print(table(codebook_meta$tabla))

usethis::use_data(codebook_meta, overwrite = TRUE)

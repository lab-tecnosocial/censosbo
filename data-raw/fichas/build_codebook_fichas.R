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

load("data/codebook_meta.rda")

campos <- utils::read.csv("data-raw/fichas/campos.csv",
                          stringsAsFactors = FALSE, encoding = "UTF-8")
stopifnot(nrow(campos) == 160, !anyDuplicated(campos$variable))

# Los 34 de la ficha ampliada de vivienda (materiales, hacinamiento, hogar).
campos_viv <- utils::read.csv("data-raw/fichas/campos_vivienda.csv",
                              stringsAsFactors = FALSE, encoding = "UTF-8")
stopifnot(nrow(campos_viv) == 34, !anyDuplicated(campos_viv$variable))
campos <- rbind(campos[, c("variable", "etiqueta")],
                campos_viv[, c("variable", "etiqueta")])
stopifnot(nrow(campos) == 194, !anyDuplicated(campos$variable))

fila <- function(variable, etiqueta, tabla) {
  data.frame(variable = variable, etiqueta = etiqueta, tabla = tabla,
             tipo = NA_character_, stringsAsFactors = FALSE)
}

# ── Variables comunes a ambas tablas ─────────────────────────────────────────

geo_defs <- c(
  codigo = "Código de la unidad censal (manzano o comunidad)",
  area   = "Área Urbana - Rural",
  idep   = "Código de departamento (01-09)",
  iprov  = "Código de provincia dentro del departamento",
  imun   = "Código de municipio dentro de la provincia"
)

comunes <- function(tabla) {
  do.call(rbind, Map(fila, names(geo_defs), unname(geo_defs), tabla))
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
  do.call(rbind, Map(fila, names(unidad_defs), unname(unidad_defs), "unidad"))
)

# ── Tabla `ficha`: los 160 indicadores ───────────────────────────────────────

filas_ficha <- rbind(
  comunes("ficha"),
  fila(campos$variable, campos$etiqueta, "ficha")
)

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

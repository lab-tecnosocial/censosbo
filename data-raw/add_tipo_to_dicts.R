## Agrega la columna `tipo` a todos los diccionario_variables.parquet.
##
## Mantiene los parquets consistentes con codebook_meta / codebook_historico_meta:
## para las variables que están en el .rda toma el `tipo` ya calculado allí
## (join por entidad+variable); las filas extra del parquet (REF_ID, entidades
## geográficas) se clasifican directamente con el mismo clasificador compartido.
##
## Ejecutar DESPUÉS de build_codebook.R y build_codebooks_historicos.R, desde la
## raíz del paquete:  source("data-raw/add_tipo_to_dicts.R")

library(arrow)
source("data-raw/clasificar_tipos.R")

# Limpieza de etiquetas equivalente a build_codebooks_historicos.R, para que la
# detección de centinelas vea las mismas categorías que el .rda.
valores_de <- function(etiq_df, entidad, variable) {
  has_ent <- "entidad" %in% names(etiq_df)
  mask <- etiq_df$variable == variable & (if (has_ent) etiq_df$entidad == entidad else TRUE)
  sub <- etiq_df[mask, c("codigo", "etiqueta")]
  if (nrow(sub) == 0) return(NULL)
  sub <- sub[sub$codigo != variable, ]                       # fila encabezado REDATAM
  sub <- sub[!sub$etiqueta %in% c("MISSING", "NOTAPPLICABLE"), ]
  sub <- sub[grepl("^[[:print:]]+$", sub$codigo) & grepl("^[[:print:]]+$", sub$etiqueta), ]
  if (nrow(sub) == 0) NULL else sub
}

# Procesa un directorio que contenga diccionario_variables.parquet,
# diccionario_etiquetas.parquet y los parquets de datos del censo.
agregar_tipo <- function(dir, meta) {
  vpath <- file.path(dir, "diccionario_variables.parquet")
  epath <- file.path(dir, "diccionario_etiquetas.parquet")
  if (!file.exists(vpath)) return(invisible(NULL))

  vars <- as.data.frame(read_parquet(vpath))
  etiq <- if (file.exists(epath)) as.data.frame(read_parquet(epath)) else
    data.frame(variable = character(0), codigo = character(0), etiqueta = character(0))

  # Normalizar nombres de columnas auxiliares (1976 usa "tabla"/"etiqueta_variable").
  ent_col <- if ("entidad" %in% names(vars)) "entidad" else if ("tabla" %in% names(vars)) "tabla" else NA
  if ("tabla" %in% names(etiq) && !"entidad" %in% names(etiq))
    names(etiq)[names(etiq) == "tabla"] <- "entidad"

  sm <- storage_map(data_parquets_de(dir))

  # Índice del .rda por tabla(minúsculas)+variable -> tipo.
  meta_key <- paste(tolower(meta$tabla), meta$variable)

  tipo <- vapply(seq_len(nrow(vars)), function(i) {
    variable <- vars$variable[i]
    entidad  <- if (!is.na(ent_col)) vars[[ent_col]][i] else NA_character_
    key <- paste(tolower(entidad), variable)
    j <- match(key, meta_key)
    if (!is.na(j)) return(meta$tipo[j])                      # tomar del .rda
    # Fila no presente en el .rda (REF_ID, entidad geográfica): clasificar directo.
    clasificar_tipo(variable, valores_de(etiq, entidad, variable), sm[tolower(variable)])
  }, character(1))

  # Insertar `tipo` tras la columna de etiqueta de la variable.
  vars$tipo <- tipo
  label_col <- intersect(c("label", "etiqueta_variable", "etiqueta"), names(vars))[1]
  if (!is.na(label_col)) {
    pos <- match(label_col, names(vars))
    ord <- append(setdiff(names(vars), "tipo"), "tipo", after = pos)
    vars <- vars[, ord]
  }

  write_parquet(vars, vpath)
  message(sprintf("  %-60s  %s", vpath,
                  paste(names(table(tipo)), table(tipo), collapse = " ")))
}

load("data/codebook_meta.rda")
load("data/codebook_historico_meta.rda")

message("CPV-2024:")
agregar_tipo("original-data/r/cpv-2024/parquets", codebook_meta)

message("\nCensos históricos:")
for (anio in c("1976", "1992", "2001", "2012")) {
  meta <- codebook_historico_meta[[anio]]
  for (raiz in c("original-data/r/censos-historicos",
                 "original-data/python/censos-historicos")) {
    agregar_tipo(file.path(raiz, paste0("censo_", anio)), meta)
  }
}
message("\nListo: columna `tipo` agregada a todos los diccionario_variables.parquet.")

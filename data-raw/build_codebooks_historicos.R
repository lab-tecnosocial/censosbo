## Genera codebook_historico_meta.rda desde los diccionarios Parquet de los censos
## históricos (1976, 1992, 2001, 2012).
## Ejecutar desde la raíz del paquete: source("data-raw/build_codebooks_historicos.R")

library(arrow)

base_dir <- "temporal-data/otros-censos"

# Columnas de nombre de tabla según el censo
# 1976: columna "tabla"; 1992/2001/2012: columna "entidad"
# Columnas de etiqueta: 1976 = "etiqueta_variable"; 1992+ = "label"

parse_censo_codebook <- function(anio) {
  censo_dir <- file.path(base_dir, paste0("censo_", anio))
  vars_path <- file.path(censo_dir, "diccionario_variables.parquet")
  etiq_path <- file.path(censo_dir, "diccionario_etiquetas.parquet")

  stopifnot(file.exists(vars_path), file.exists(etiq_path))

  vars_df <- read_parquet(vars_path)
  etiq_df <- read_parquet(etiq_path)

  # Normalizar nombres de columnas
  if ("tabla" %in% names(vars_df)) {
    names(vars_df)[names(vars_df) == "tabla"] <- "entidad"
  }
  if ("etiqueta_variable" %in% names(vars_df)) {
    names(vars_df)[names(vars_df) == "etiqueta_variable"] <- "label"
  }
  if ("tabla" %in% names(etiq_df)) {
    names(etiq_df)[names(etiq_df) == "tabla"] <- "entidad"
  }

  # Filtrar filas de REF_ID (son internas de REDATAM, no variables sustantivas)
  vars_df <- vars_df[!grepl("_REF_ID$|^REF_ID$|^Parent entity", vars_df$variable, ignore.case = TRUE), ]
  vars_df <- vars_df[!grepl("_REF_ID$|^REF_ID$|^Parent entity", vars_df$label, ignore.case = TRUE), ]

  # Normalizar nombre de entidad a minúsculas
  vars_df$tabla <- tolower(trimws(vars_df$entidad))

  # Construir columna valores_codigos (lista de data.frames)
  vars_df$valores_codigos <- lapply(seq_len(nrow(vars_df)), function(i) {
    var  <- vars_df$variable[i]
    ent  <- vars_df$entidad[i]
    mask <- etiq_df$variable == var & etiq_df$entidad == ent
    subset_etiq <- etiq_df[mask, c("codigo", "etiqueta")]
    if (nrow(subset_etiq) == 0) return(NULL)
    # Excluir fila de encabezado REDATAM (donde codigo == nombre de variable)
    subset_etiq <- subset_etiq[subset_etiq$codigo != var, ]
    # Excluir valores técnicos REDATAM
    excluir <- c("MISSING", "NOTAPPLICABLE")
    subset_etiq <- subset_etiq[!subset_etiq$etiqueta %in% excluir, ]
    if (nrow(subset_etiq) == 0) return(NULL)
    subset_etiq
  })

  result <- data.frame(
    variable         = vars_df$variable,
    etiqueta         = vars_df$label,
    tabla            = vars_df$tabla,
    tipo             = ifelse(vapply(vars_df$valores_codigos, is.null, logical(1)),
                              "numerica", "categorica"),
    stringsAsFactors = FALSE
  )
  result$valores_codigos <- vars_df$valores_codigos

  # Eliminar duplicados (pueden aparecer en tablas geo)
  result <- result[!duplicated(paste(result$tabla, result$variable)), ]
  rownames(result) <- NULL
  result
}

codebook_historico_meta <- list()

for (anio in c(1976, 1992, 2001, 2012)) {
  message("\nProcesando censo ", anio, "...")
  tryCatch({
    cb <- parse_censo_codebook(anio)
    codebook_historico_meta[[as.character(anio)]] <- cb
    message("  ", nrow(cb), " variables en ", length(unique(cb$tabla)), " tablas")
    print(table(cb$tabla))
  }, error = function(e) {
    warning("Error en censo ", anio, ": ", conditionMessage(e))
  })
}

usethis::use_data(codebook_historico_meta, overwrite = TRUE)
message("\ncodebook_historico_meta guardado en data/codebook_historico_meta.rda")

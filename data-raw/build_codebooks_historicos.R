## Genera codebook_historico_meta.rda desde los diccionarios Parquet de los censos
## históricos (1976, 1992, 2001, 2012).
## Ejecutar desde la raíz del paquete: source("data-raw/build_codebooks_historicos.R")

library(arrow)

base_dir <- "original-data/r/censos-historicos"

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

  # Bug 3: el censo 2001 tiene sus labels en vars_df doblemente codificados
  # (UTF-8 leído como Latin-1 y re-codificado a UTF-8). Se revierten tomando
  # los bytes del string UTF-8 actual y reinterpretándolos directamente como UTF-8.
  if (anio == 2001L) {
    vars_df$label <- vapply(vars_df$label, function(s) {
      if (is.na(s) || !grepl("Ã|Â", s)) return(s)
      rawToChar(iconv(s, from = "UTF-8", to = "latin1", toRaw = TRUE)[[1]])
    }, character(1), USE.NAMES = FALSE)
  }

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
    # Bug 2: excluir filas con caracteres no imprimibles en codigo o etiqueta
    # (artefactos binarios de REDATAM que generan códigos corruptos)
    subset_etiq <- subset_etiq[grepl("^[[:print:]]+$", subset_etiq$codigo), ]
    subset_etiq <- subset_etiq[grepl("^[[:print:]]+$", subset_etiq$etiqueta), ]
    if (nrow(subset_etiq) == 0) return(NULL)
    # Normalizar códigos numéricos enteros: "1.0" → "1" (artefacto del parquet 1976)
    subset_etiq$codigo <- vapply(subset_etiq$codigo, function(x) {
      n <- suppressWarnings(as.numeric(x))
      if (!is.na(n) && n == trunc(n)) as.character(as.integer(n)) else x
    }, character(1), USE.NAMES = FALSE)
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

  # Bug 2: correcciones manuales para variables cuyo label es NA en el Parquet
  # (el encabezado REDATAM tenía "label" como placeholder en lugar del texto real)
  label_fixes <- list(
    "1992" = list(REDCODEN = "Código geográfico REDATAM"),
    "2001" = list(REDCODEN = "Código geográfico REDATAM"),
    "2012" = list(
      REDCODEN = "Código geográfico REDATAM",
      P19      = "Condición de tenencia de la vivienda",
      P24      = "¿Es mujer u hombre?",
      P32J     = "Departamento o país de nacimiento",
      P44      = "Actividad económica del establecimiento donde trabaja",
      P22F1    = "Dificultad para ver"
    )
  )
  fixes <- label_fixes[[as.character(anio)]]
  if (!is.null(fixes)) {
    for (var in names(fixes)) {
      idx <- which(result$variable == var & is.na(result$etiqueta))
      if (length(idx) > 0) result$etiqueta[idx] <- fixes[[var]]
    }
  }

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

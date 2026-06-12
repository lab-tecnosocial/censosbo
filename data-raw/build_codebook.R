## Genera codebook_meta.rda desde el Diccionario de Variables CPV 2024.xlsx.
## Requiere: readxl, arrow, usethis

library(readxl)
source("data-raw/clasificar_tipos.R")

xlsx_path <- "original-data/fuentes/cpv-2024/Diccionario de variables CPV 2024.xlsx"
stopifnot(file.exists(xlsx_path))

hojas <- readxl::excel_sheets(xlsx_path)
message("Hojas: ", paste(hojas, collapse = ", "))

# Mapeo hoja → nombre de tabla en el paquete
tabla_map <- c(
  PERSONA  = "persona",
  VIVIENDA = "vivienda",
  EMIGRA   = "emigracion",
  MORTA    = "mortalidad"
)

# Parsear una hoja del Excel en una lista de variables
# Estructura de cada hoja (tras skip=2):
#   Col 1: tipo de fila ("Etiqueta", "Nombre", "Tipo", "Categorías", "1","2",..., NA=separador)
#   Col 2: valor correspondiente
parse_sheet <- function(hoja, tabla_name) {
  df <- readxl::read_excel(xlsx_path, sheet = hoja, skip = 2,
                           col_names = FALSE, .name_repair = "minimal")
  col_tipo  <- as.character(df[[1]])
  col_valor <- as.character(df[[2]])

  vars <- list()
  current <- NULL

  for (i in seq_along(col_tipo)) {
    tipo  <- col_tipo[i]
    valor <- col_valor[i]
    if (is.na(tipo) || tipo == "") {
      # Separador de variables
      if (!is.null(current) && !is.null(current$variable)) {
        vars[[length(vars) + 1]] <- current
      }
      current <- NULL
      next
    }
    if (tipo == "Etiqueta") {
      current <- list(etiqueta = valor, variable = NULL, tipo = NA,
                      valores_codigos = list())
    } else if (tipo == "Nombre" && !is.null(current)) {
      current$variable <- tolower(trimws(valor))
    } else if (tipo == "Tipo" && !is.null(current)) {
      current$tipo <- tolower(trimws(valor))
    } else if (!is.null(current) && grepl("^[0-9]+$", trimws(tipo))) {
      # Fila de categoría: tipo = código, valor = etiqueta de categoría
      current$valores_codigos[[length(current$valores_codigos) + 1]] <-
        data.frame(codigo = trimws(tipo), etiqueta = valor,
                   stringsAsFactors = FALSE)
    }
  }
  # Guardar la última variable si quedó sin separador
  if (!is.null(current) && !is.null(current$variable)) {
    vars[[length(vars) + 1]] <- current
  }

  # Convertir a data.frame. El `tipo` se asigna más abajo con el clasificador
  # compartido (clasificar_tipos.R); aquí solo se arman los valores_codigos crudos.
  if (length(vars) == 0) return(NULL)
  result <- data.frame(
    variable         = vapply(vars, function(v) v$variable %||% NA_character_, character(1)),
    etiqueta         = vapply(vars, function(v) v$etiqueta %||% NA_character_, character(1)),
    tabla            = tabla_name,
    stringsAsFactors = FALSE
  )
  result$valores_codigos <- lapply(vars, function(v) {
    if (length(v$valores_codigos) == 0) NULL else do.call(rbind, v$valores_codigos)
  })
  result
}

`%||%` <- function(x, y) if (is.null(x) || (length(x) == 1 && is.na(x))) y else x

all_vars <- list()
for (hoja in names(tabla_map)) {
  if (!hoja %in% hojas) next
  tabla_name <- tabla_map[[hoja]]
  message("Procesando hoja '", hoja, "' → tabla '", tabla_name, "'...")
  res <- parse_sheet(hoja, tabla_name)
  if (!is.null(res) && nrow(res) > 0) {
    # Filtrar filas sin nombre de variable
    res <- res[!is.na(res$variable) & nchar(res$variable) > 0, ]
    all_vars[[tabla_name]] <- res
    message("  ", nrow(res), " variables")
  }
}

codebook_meta <- do.call(rbind, all_vars)
rownames(codebook_meta) <- NULL

# Clasificar `tipo` con el clasificador compartido. El tipo de almacenamiento
# real se lee de los parquets de datos del CPV-2024 (los CSV del INE no traen
# tipos útiles: el Excel marca todo como "integer").
dir24 <- "original-data/r/cpv-2024/parquets"
sm24  <- storage_map(c(
  file.path(dir24, "persona_dep01.parquet"),
  file.path(dir24, "vivienda.parquet"),
  file.path(dir24, "emigracion.parquet"),
  file.path(dir24, "mortalidad.parquet")
))
codebook_meta$tipo <- vapply(seq_len(nrow(codebook_meta)), function(i) {
  clasificar_tipo(codebook_meta$variable[i], codebook_meta$valores_codigos[[i]],
                  sm24[tolower(codebook_meta$variable[i])])
}, character(1))
# Para variables no categóricas no se conservan categorías (suelen ser solo
# centinelas como "Sin especificar").
codebook_meta$valores_codigos <- lapply(seq_len(nrow(codebook_meta)), function(i) {
  if (codebook_meta$tipo[i] == "categorica") codebook_meta$valores_codigos[[i]] else NULL
})

message("\nTotal de variables: ", nrow(codebook_meta))
message("Por tipo:")
print(table(codebook_meta$tipo))
message("Por tabla:")
print(table(codebook_meta$tabla))
message("\nEjemplos:")
print(head(codebook_meta[, c("variable", "etiqueta", "tabla", "tipo")], 5))
cat("\nEjemplo codebook_valores('p25_sexo'):\n")
idx <- which(codebook_meta$variable == "p25_sexo")
if (length(idx) > 0) print(codebook_meta$valores_codigos[[idx[1]]])

usethis::use_data(codebook_meta, overwrite = TRUE)
message("codebook_meta guardado en data/codebook_meta.rda")

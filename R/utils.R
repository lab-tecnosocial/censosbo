.CENSOSBO_RELEASE_TAG <- "data-v1.0.0"
.CENSOSBO_REPO <- "lab-tecnosocial/censosbo"
.CENSOSBO_BASE_URL <- paste0(
  "https://github.com/", .CENSOSBO_REPO,
  "/releases/download/", .CENSOSBO_RELEASE_TAG, "/"
)

.CENSO_RELEASE_TAGS <- c(
  "1976" = "data-1976-v1.0.0",
  "1992" = "data-1992-v1.0.0",
  "2001" = "data-2001-v1.0.0",
  "2012" = "data-2012-v1.0.0"
)

.DEP_CODES <- c(
  "01" = "Chuquisaca", "02" = "La Paz",    "03" = "Cochabamba",
  "04" = "Oruro",      "05" = "Potosí",    "06" = "Tarija",
  "07" = "Santa Cruz", "08" = "Beni",      "09" = "Pando"
)

# Convierte nombres o números de departamento a códigos de 2 dígitos
.resolve_dep_codes <- function(departamento) {
  if (is.null(departamento)) return(NULL)
  dep <- as.character(departamento)

  # Normalizar códigos numéricos a 2 dígitos
  numeric_mask <- grepl("^[0-9]+$", dep)
  dep[numeric_mask] <- sprintf("%02d", as.integer(dep[numeric_mask]))

  # Resolver nombres a códigos
  name_mask <- !numeric_mask
  if (any(name_mask)) {
    matched <- match(tolower(dep[name_mask]), tolower(.DEP_CODES))
    if (any(is.na(matched))) {
      cli::cli_abort(c(
        "Departamento no reconocido: {dep[name_mask][is.na(matched)]}",
        "i" = "Usa {.code departamentos()} para ver los nombres válidos."
      ))
    }
    dep[name_mask] <- names(.DEP_CODES)[matched]
  }

  invalid <- !dep %in% names(.DEP_CODES)
  if (any(invalid)) {
    cli::cli_abort(c(
      "Código(s) de departamento inválido(s): {dep[invalid]}",
      "i" = "Los departamentos válidos son del 01 al 09."
    ))
  }
  dep
}

# Tamaños en MB para mensajes de progreso (medidos de data-v1.0.0)
.PARQUET_SIZE_MB <- list(
  persona_dep01 = 15,  persona_dep02 = 75,  persona_dep03 = 51,
  persona_dep04 = 14,  persona_dep05 = 22,  persona_dep06 = 13,
  persona_dep07 = 77,  persona_dep08 = 12,  persona_dep09 = 4,
  vivienda = 55, emigracion = 2, mortalidad = 2
)

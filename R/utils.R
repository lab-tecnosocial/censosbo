.CENSOSBO_RELEASE_TAG <- "data-v1.0.0"
.CENSOSBO_REPO <- "lab-tecnosocial/censosbo"
.CENSOSBO_BASE_URL <- paste0(
  "https://github.com/", .CENSOSBO_REPO,
  "/releases/download/", .CENSOSBO_RELEASE_TAG, "/"
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

# Tamaños estimados en MB para mensajes de progreso
.PARQUET_SIZE_MB <- list(
  persona_dep01 = 30,  persona_dep02 = 150, persona_dep03 = 100,
  persona_dep04 = 28,  persona_dep05 = 43,  persona_dep06 = 26,
  persona_dep07 = 155, persona_dep08 = 24,  persona_dep09 = 7,
  vivienda = 100, emigracion = 5, mortalidad = 4
)

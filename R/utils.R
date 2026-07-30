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

# Datos agregados del CPV-2024 por manzano urbano y comunidad rural.
# Van en su propio release porque no son microdatos y se actualizan aparte.
.FICHAS_RELEASE_TAG <- "data-fichas-v1.0.0"
.FICHAS_BASE_URL <- paste0(
  "https://github.com/", .CENSOSBO_REPO,
  "/releases/download/", .FICHAS_RELEASE_TAG, "/"
)

# .DEP_CODES (código de departamento -> nombre) vive en R/sysdata.rda porque
# "Potosí" lleva tilde y CRAN exige código ASCII. Se edita en
# data-raw/build_sysdata.R.

# Quita tildes y diéresis, y convierte la eñe. Quien escribe en una consola de R
# teclea "Potosi" o "Zudanez", no "Potosí" ni "Zudáñez": 55 de los 343 municipios
# llevan tilde o eñe, y las etiquetas del diccionario dicen cosas como "Nivel más
# alto de instrucción". Sin plegar los acentos, `municipio = "Zudanez"` abortaba y
# `buscar = "instruccion"` devolvía cero filas, en los dos casos sin ninguna pista
# de que lo único que faltaba era un acento.
#
# chartr() y no iconv(to = "ASCII//TRANSLIT"): iconv depende de la locale y de la
# implementación de iconv del sistema, y en algunas plataformas devuelve "?" o NA
# -- convertiría un fallo de búsqueda en un error incomprensible, y solo en las
# máquinas de algunos usuarios. El juego de caracteres del español es cerrado y
# pequeño, así que la tabla explícita es más segura y no depende del entorno.
.plegar_acentos <- function(x) {
  # Escapado con \uXXXX porque el código del paquete es ASCII puro (los comentarios
  # no cuentan: `R CMD check` ignora los tokens COMMENT). El orden es
  # a-e-i-o-u-dieresis-enie, primero minusculas y luego mayusculas.
  chartr(
    "\u00e1\u00e9\u00ed\u00f3\u00fa\u00fc\u00f1\u00c1\u00c9\u00cd\u00d3\u00da\u00dc\u00d1",
    "aeiouunAEIOUUN",
    x
  )
}

# Forma canónica para comparar un nombre que escribió el usuario con uno del
# catálogo: sin acentos, sin mayúsculas y sin espacios sobrantes.
.norm_nombre <- function(x) {
  tolower(trimws(.plegar_acentos(as.character(x))))
}

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
    matched <- match(.norm_nombre(dep[name_mask]), .norm_nombre(.DEP_CODES))
    if (any(is.na(matched))) {
      cli::cli_abort(c(
        "Departamento no reconocido: {dep[name_mask][is.na(matched)]}",
        "i" = "Usa {.code departamentos()} para ver los nombres v\u00e1lidos."
      ))
    }
    dep[name_mask] <- names(.DEP_CODES)[matched]
  }

  invalid <- !dep %in% names(.DEP_CODES)
  if (any(invalid)) {
    cli::cli_abort(c(
      "C\u00f3digo(s) de departamento inv\u00e1lido(s): {dep[invalid]}",
      "i" = "Los departamentos v\u00e1lidos son del 01 al 09."
    ))
  }
  dep
}

# Tamaños en MB para mensajes de progreso (medidos de data-v1.0.0)
.PARQUET_SIZE_MB <- list(
  persona_dep01 = 15,  persona_dep02 = 75,  persona_dep03 = 51,
  persona_dep04 = 14,  persona_dep05 = 22,  persona_dep06 = 13,
  persona_dep07 = 77,  persona_dep08 = 12,  persona_dep09 = 4,
  vivienda = 55, emigracion = 2, mortalidad = 2,
  # Datos agregados por manzano y comunidad (release data-fichas-*)
  unidad = 2.4, ficha = 15.4, geo_comunidad = 0.6,
  geo_manzano_dep01 = 1.2, geo_manzano_dep02 = 6,   geo_manzano_dep03 = 5.5,
  geo_manzano_dep04 = 1.6, geo_manzano_dep05 = 1.7, geo_manzano_dep06 = 1.1,
  geo_manzano_dep07 = 6.7, geo_manzano_dep08 = 0.8, geo_manzano_dep09 = 0.3
)

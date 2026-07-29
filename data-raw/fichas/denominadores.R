## Denominador de cada indicador de las fichas de manzano y comunidad.
##
## Los 194 indicadores del geoportal son conteos, y para leerlos como porcentaje
## hace falta saber sobre qué total se calculan. Ese dato no estaba en el paquete:
## vivía en `q-censosbo/scripts/build_dicc_fichas.py`, que generaba un CSV copiado
## a mano en q-censosbo y en censos-explorer. Esto es el port 1:1 de esa lógica,
## para que el denominador tenga una sola fuente y viaje con el codebook.
##
## Un test de no regresión (tests/testthat/test-fichas.R) compara la salida contra
## el CSV que hoy usan esos dos proyectos, celda a celda.

## Bloques desagregados por sexo: el denominador es el total del bloque para el
## mismo sexo, no el total general. El valor es el prefijo de las variables del
## bloque, que no siempre coincide con su nombre (`educacion` -> `edu`).
BLOQUES_SEXO <- c(
  poblacion    = "pob",
  educacion    = "edu",
  salud_lugar  = "salud_lugar",
  salud_seguro = "salud_seguro",
  nacimiento   = "nac",
  residencia   = "res",
  ocupacion    = "ocup",
  actividad    = "act"
)

## Los bloques de la ficha ampliada de vivienda cuentan viviendas particulares
## con personas presentes, no el total de viviendas (ver ?get_fichas_2024).
BASE_VIVIENDA_PRESENTES <- c("material", "hacinamiento", "hogar")

#' Denominador de un indicador de ficha
#'
#' @param bloque Bloque temático del indicador.
#' @param variable Nombre del indicador.
#' @return El nombre de la variable-total que sirve de denominador, o `""` si la
#'   variable ya es un total (y por tanto no se expresa como porcentaje de nada).
.denominador_ficha <- function(bloque, variable) {
  n <- length(variable)
  out <- character(n)

  for (i in seq_len(n)) {
    v <- variable[i]
    b <- bloque[i]

    # Los totales no tienen denominador: son la base de los demás.
    if (grepl("_total", v, fixed = TRUE)) { out[i] <- ""; next }

    if (!is.na(b) && b %in% names(BLOQUES_SEXO)) {
      # pob_60mas_h -> pob_total_h
      sufijo <- sub("^.*_", "", v)
      out[i] <- sprintf("%s_total_%s", BLOQUES_SEXO[[b]], sufijo)
      next
    }
    if (!is.na(b) && b == "servicios") {
      # serv_agua_caneria -> serv_agua_total
      sub_bloque <- strsplit(v, "_", fixed = TRUE)[[1]][2]
      out[i] <- sprintf("serv_%s_total", sub_bloque)
      next
    }
    if (!is.na(b) && b == "vivienda") {
      # El denominador de la tenencia es su propio total; el del tipo de vivienda
      # y la condición de ocupación es el total de viviendas.
      out[i] <- if (startsWith(v, "viv_tenencia_")) "viv_tenencia_total" else "viv_total"
      next
    }
    if (!is.na(b) && b == "tic") { out[i] <- "tic_total"; next }
    if (!is.na(b) && b %in% BASE_VIVIENDA_PRESENTES) {
      out[i] <- "viv_tipo_presentes"
      next
    }
    out[i] <- ""
  }
  out
}

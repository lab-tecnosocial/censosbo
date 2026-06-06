#' Variables armonizadas para análisis longitudinal
#'
#' Devuelve la tabla de correspondencia entre variables de los censos de Bolivia
#' (1976, 1992, 2001, 2012 y CPV-2024), con las variables que pueden compararse
#' a lo largo del tiempo.
#'
#' @format Un data.frame con columnas:
#' \describe{
#'   \item{variable}{Nombre armonizado (e.g., `"sexo"`, `"nivel_edu"`)}
#'   \item{etiqueta}{Descripción en español}
#'   \item{descripcion}{Descripción detallada y notas de comparabilidad}
#'   \item{v1976, v1992, v2001, v2012, v2024}{Nombre de la columna en cada censo (`NA` si no disponible)}
#'   \item{notas}{Advertencias sobre diferencias metodológicas entre censos}
#' }
#' @source Elaboración propia a partir de los diccionarios oficiales del INE Bolivia.
"variable_longitudinal_map"

#' Muestra el mapeo de variables comparables entre censos de Bolivia
#'
#' Retorna la tabla de variables armonizadas que pueden usarse en análisis
#' longitudinales o comparativos entre los censos de 1976, 1992, 2001, 2012
#' y el CPV-2024.
#'
#' @return Un data.frame con las variables armonizadas y sus equivalentes en
#'   cada año de censo.
#' @export
#' @examples
#' variables_armonizadas()
variables_armonizadas <- function() {
  variable_longitudinal_map
}

#' Obtiene datos longitudinales comparables entre censos de Bolivia
#'
#' Descarga y armoniza variables clave de múltiples censos para análisis de
#' tendencias y comparaciones históricas. El resultado es un data.frame en
#' formato largo ("tidy"), con una fila por individuo y una columna `anio`
#' que identifica el censo de origen.
#'
#' @param variables Vector de caracteres. Nombres de variables armonizadas a
#'   incluir. Usa [variables_armonizadas()] para ver las opciones disponibles.
#' @param anios Vector de enteros. Años de censo a incluir (cualquier subconjunto
#'   de `c(1976, 1992, 2001, 2012, 2024)`). Por defecto todos.
#' @param departamento Vector de caracteres. Código(s) `"01"`-`"09"` o
#'   nombre(s) de departamento. Si `NULL`, incluye todo el país.
#' @param verbose Lógico. Mostrar mensajes de progreso. Por defecto `TRUE`.
#'
#' @return Un tibble con columnas `anio`, seguida de las variables solicitadas.
#'   Las columnas ausentes en un censo aparecen como `NA` con un aviso.
#'
#' @details
#' **Variables con limitaciones conocidas:**
#' - `area` (urbano/rural): no disponible en el censo 2001 ni en 2024 (está en
#'   la tabla de vivienda, no de persona). Se incluye como `NA` con advertencia.
#' - `nivel_edu`: la Ley Avelino Siñani (2010) cambió la nomenclatura en 2012.
#'   Se armoniza automáticamente a 4 categorías comparables.
#' - `grupo_edad`: solo disponible directamente en 1976; se calcula para el resto.
#' - `pea`, `pet`: no disponibles directamente en 1992 y 2001; se retornan como `NA`.
#'
#' **Sobre municipios:**
#' El filtro geográfico en `get_longitudinal()` opera a nivel de departamento
#' para garantizar comparabilidad. El número de municipios cambió entre censos
#' (1992: 339, 2001: 343, 2012: 339, 2024: 344).
#'
#' @importFrom dplyr as_tibble case_when bind_rows
#' @export
#' @examples
#' \dontrun{
#' # Serie temporal de sexo y edad para Santa Cruz
#' datos <- get_longitudinal(
#'   variables = c("sexo", "edad"),
#'   anios = c(1992, 2001, 2012, 2024),
#'   departamento = "07"
#' )
#' library(dplyr)
#' datos |> count(anio, sexo)
#'
#' # Evolución del nivel educativo en todo el país
#' get_longitudinal(c("nivel_edu"), anios = c(1976, 1992, 2001, 2012, 2024))
#' }
get_longitudinal <- function(
    variables,
    anios       = c(1976L, 1992L, 2001L, 2012L, 2024L),
    departamento = NULL,
    verbose     = TRUE
) {
  anios <- as.integer(anios)
  anios_validos <- c(1976L, 1992L, 2001L, 2012L, 2024L)
  if (any(!anios %in% anios_validos)) {
    cli::cli_abort(c(
      "Año(s) no válido(s): {.val {anios[!anios %in% anios_validos]}}",
      "i" = "Los años disponibles son: {.val {anios_validos}}"
    ))
  }

  mapa <- variable_longitudinal_map
  vars_validas <- mapa$variable
  vars_invalidas <- setdiff(variables, vars_validas)
  if (length(vars_invalidas) > 0) {
    cli::cli_abort(c(
      "Variable(s) no encontrada(s): {.val {vars_invalidas}}",
      "i" = "Usa {.fn variables_armonizadas} para ver las opciones disponibles."
    ))
  }

  partes <- vector("list", length(anios))
  names(partes) <- as.character(anios)

  for (a in anios) {
    key <- paste0("v", a)
    if (!key %in% names(mapa)) {
      cli::cli_warn("Columna de mapeo no encontrada para el año {a}. Se omite.")
      next
    }

    # Variables disponibles en este censo (tienen columna mapeada)
    submapa <- mapa[mapa$variable %in% variables, ]
    cols_originales <- submapa[[key]]
    vars_disponibles <- submapa$variable[!is.na(cols_originales)]
    vars_ausentes    <- submapa$variable[is.na(cols_originales)]

    # area 1992/2001/2012: no tiene columna propia en persona pero se
    # obtiene via join con vivienda → no emitir warning de "no disponible"
    area_needs_viv <- "area" %in% variables && a %in% c(1992L, 2001L, 2012L)
    vars_realmente_ausentes <- if (area_needs_viv) setdiff(vars_ausentes, "area") else vars_ausentes

    if (length(vars_realmente_ausentes) > 0) {
      cli::cli_warn(c(
        "!" = "Variables no disponibles en el censo {a}: {.val {vars_realmente_ausentes}}",
        "i" = "Se incluirán como {.code NA}."
      ))
    }

    if (verbose) cli::cli_inform("Obteniendo datos del censo {a}...")

    tryCatch({
      cols_a_pedir <- cols_originales[!is.na(cols_originales)]
      # 1992: P12 solo cubre quienes asistieron; P11 permite recuperar Ninguno
      if (a == 1992L && "nivel_edu" %in% variables) {
        cols_a_pedir <- unique(c(cols_a_pedir, "P11"))
      }
      if (area_needs_viv) {
        cols_a_pedir <- unique(c(cols_a_pedir, "VIVIENDA_REF_ID"))
      }
      df_raw <- if (a == 2024L) {
        get_personas_2024(departamento = departamento, variables = cols_a_pedir,
                          as = "tibble", verbose = FALSE)
      } else if (a == 1976L) {
        get_censo(a, "poblacion", departamento = departamento, variables = cols_a_pedir,
                  as = "tibble", verbose = FALSE)
      } else {
        get_censo(a, "persona", departamento = departamento, variables = cols_a_pedir,
                  as = "tibble", verbose = FALSE)
      }

      if (is.null(df_raw) || nrow(df_raw) == 0) {
        cli::cli_warn("Sin datos para el censo {a} con los filtros aplicados.")
        next
      }

      # Construir data.frame armonizado: una fila por individuo
      n <- nrow(df_raw)
      df_armonizado <- data.frame(anio = rep(a, n), stringsAsFactors = FALSE)

      for (var in variables) {
        col_orig <- mapa[[key]][mapa$variable == var]
        if (length(col_orig) == 0 || is.na(col_orig)) {
          df_armonizado[[var]] <- NA
        } else if (col_orig %in% names(df_raw)) {
          df_armonizado[[var]] <- .harmonize_col(df_raw[[col_orig]], var, a)
        } else {
          df_armonizado[[var]] <- NA
        }
      }

      # 1992: sobreescribir nivel_edu con 0 (Ninguno) para quienes nunca asistieron (P11=3)
      if (a == 1992L && "nivel_edu" %in% variables &&
          "P11" %in% names(df_raw) && "nivel_edu" %in% names(df_armonizado)) {
        p11 <- suppressWarnings(as.integer(df_raw[["P11"]]))
        df_armonizado[["nivel_edu"]] <- ifelse(p11 == 3L, 0L, df_armonizado[["nivel_edu"]])
      }

      # area 1992/2001/2012: join con vivienda para obtener columna de urbano/rural
      if (area_needs_viv && "VIVIENDA_REF_ID" %in% names(df_raw)) {
        viv_col  <- if (a == 2001L) "TURUR" else "URBRUR"
        viv_path <- .download_censo(a, "vivienda.parquet", overwrite = FALSE, verbose = FALSE)
        viv_area <- arrow::read_parquet(viv_path,
                                        col_select = c("VIVIENDA_REF_ID", viv_col))
        viv_area <- dplyr::as_tibble(viv_area)
        ref_col  <- df_raw[, "VIVIENDA_REF_ID", drop = FALSE]
        merged   <- merge(ref_col, viv_area, by = "VIVIENDA_REF_ID", all.x = TRUE)
        urb_num  <- suppressWarnings(as.integer(merged[[viv_col]]))
        # TURUR (2001) y URBRUR (1992/2012): 1=Urbana, 2=Rural
        df_armonizado[["area"]] <- dplyr::case_when(
          urb_num %in% c(1L, 2L) ~ urb_num, TRUE ~ NA_integer_
        )
      }

      rownames(df_armonizado) <- NULL
      partes[[as.character(a)]] <- df_armonizado

    }, error = function(e) {
      cli::cli_warn("Error obteniendo datos del censo {a}: {conditionMessage(e)}")
    })
  }

  partes_validas <- Filter(Negate(is.null), partes)
  if (length(partes_validas) == 0) {
    cli::cli_abort("No se obtuvieron datos de ningún censo.")
  }

  result <- do.call(rbind, partes_validas)
  rownames(result) <- NULL
  dplyr::as_tibble(result)
}

# Aplica transformaciones de armonización según la variable y el año
.harmonize_col <- function(x, variable, anio) {
  if (variable == "sexo")      return(.harmonize_sexo(x, anio))
  if (variable == "sabe_leer") return(.harmonize_sabe_leer(x, anio))
  if (variable == "nivel_edu") return(.harmonize_nivel_edu(x, anio))
  if (variable == "edad") {
    return(suppressWarnings(as.integer(x)))
  }
  if (variable == "grupo_edad" && anio != 1976L) {
    edad_num <- suppressWarnings(as.integer(x))
    return(ifelse(is.na(edad_num), NA_integer_, (edad_num %/% 5L) * 5L))
  }
  x
}

# Harmoniza sexo → 1=Mujer, 2=Hombre en todos los censos
.harmonize_sexo <- function(x, anio) {
  x_num <- suppressWarnings(as.integer(x))
  if (anio %in% c(1976L, 1992L, 2001L)) {
    # Original: 1=Hombre, 2=Mujer → invertir a 1=Mujer, 2=Hombre
    dplyr::case_when(x_num == 1L ~ 2L, x_num == 2L ~ 1L, TRUE ~ NA_integer_)
  } else {
    # 2012, 2024: ya tienen 1=Mujer, 2=Hombre
    dplyr::case_when(x_num %in% c(1L, 2L) ~ x_num, TRUE ~ NA_integer_)
  }
}

# Harmoniza sabe_leer → 1=Sí, 2=No en todos los censos
.harmonize_sabe_leer <- function(x, anio) {
  x_num <- suppressWarnings(as.integer(x))
  if (anio == 1992L) {
    # P10: 7=Sí, 8=No, 0=NOTAPPLICABLE, 9=MISSING
    dplyr::case_when(x_num == 7L ~ 1L, x_num == 8L ~ 2L, TRUE ~ NA_integer_)
  } else {
    # 1976 p10: 1=Sí, 2=No, 8/9/15=otro
    # 2001 P36, 2012 P35, 2024 p40_lee: 1=Sí, 2=No, 0/9/10=otro
    dplyr::case_when(x_num == 1L ~ 1L, x_num == 2L ~ 2L, TRUE ~ NA_integer_)
  }
}

# Armoniza nivel educativo a 4 categorías comparables entre censos
# 0 = Sin instrucción, 1 = Primaria, 2 = Secundaria, 3 = Superior
.harmonize_nivel_edu <- function(x, anio) {
  x_num <- suppressWarnings(as.integer(x))
  if (anio == 1976L) {
    # nivela (variable derivada): 1=Ninguno, 2=Primaria, 3=Secundaria,
    # 4=Superior, 5=Técnico/Normal, 9=S/dato
    dplyr::case_when(
      x_num == 1L ~ 0L,
      x_num == 2L ~ 1L,
      x_num == 3L ~ 2L,
      x_num %in% c(4L, 5L) ~ 3L,
      TRUE ~ NA_integer_
    )
  } else if (anio == 1992L) {
    # P12 (ciclo más alto asistido, sistema antiguo):
    # 2=Básico(→Primaria), 3=Intermedio(→Primaria), 4=Medio(→Secundaria),
    # 5=Técnica, 6=Normal, 7=Universidad(→Superior), 9=Missing
    # Nota: Ninguno (P11=3, nunca asistió) se aplica en get_longitudinal() como sobreescritura
    dplyr::case_when(
      x_num %in% c(2L, 3L) ~ 1L,
      x_num == 4L ~ 2L,
      x_num %in% c(5L, 6L, 7L) ~ 3L,
      TRUE ~ NA_integer_
    )
  } else if (anio == 2001L) {
    # P39NIV con códigos reales del censo 2001:
    # 11=Ninguno, 12=Preescolar, 13=Básico, 14=Intermedio, 15=Medio,
    # 16=Primaria actual, 17=Secundaria actual, 18=Licenciatura,
    # 19=Técnico, 20=Normal, 21=Militar/Policial, 22=Técnico instituto, 23=Otro
    dplyr::case_when(
      x_num %in% c(11L, 12L) ~ 0L,
      x_num %in% c(13L, 14L, 16L) ~ 1L,
      x_num %in% c(15L, 17L) ~ 2L,
      x_num %in% c(18L, 19L, 20L, 21L, 22L) ~ 3L,
      TRUE ~ NA_integer_
    )
  } else if (anio == 2012L) {
    # P37A_NIVELNUE (códigos no secuenciales):
    # 0=NOTAPPLICABLE(→NA), 1=Ninguno, 2=Alfabetización, 3=Inicial(→Sin instrucción),
    # 9=Primaria(1-6), 10=Secundaria(1-6), 11-18=Superior, 99=S/dato(→NA)
    dplyr::case_when(
      x_num %in% c(1L, 2L, 3L) ~ 0L,
      x_num == 9L ~ 1L,
      x_num == 10L ~ 2L,
      x_num %in% c(11L, 12L, 13L, 14L, 15L, 16L, 17L, 18L) ~ 3L,
      TRUE ~ NA_integer_
    )
  } else if (anio == 2024L) {
    # nivel_edu: 1=Ninguno, 2=Primaria, 3=Secundaria, 4=Superior
    dplyr::case_when(
      x_num == 1L ~ 0L,
      x_num == 2L ~ 1L,
      x_num == 3L ~ 2L,
      x_num == 4L ~ 3L,
      TRUE ~ NA_integer_
    )
  } else {
    NA_integer_
  }
}

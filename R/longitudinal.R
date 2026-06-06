#' Variables armonizadas para análisis longitudinal
#'
#' Tabla de correspondencia entre variables de los censos de Bolivia
#' (1976, 1992, 2001, 2012 y CPV-2024), con las variables que pueden compararse
#' a lo largo del tiempo.
#'
#' @format Un data.frame con columnas:
#' \describe{
#'   \item{variable}{Nombre armonizado (e.g., `"sexo"`, `"nivel_edu"`)}
#'   \item{etiqueta}{Descripción en español}
#'   \item{descripcion}{Descripción detallada y notas de comparabilidad}
#'   \item{tabla}{Tabla de origen: `"persona"` o `"vivienda"`}
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
#' @param tabla Filtrar por tabla de origen: `"persona"`, `"vivienda"` o `NULL`
#'   para todas. Por defecto `NULL`.
#'
#' @return Un data.frame con las variables armonizadas y sus equivalentes en
#'   cada año de censo.
#' @export
#' @examples
#' variables_armonizadas()
#' variables_armonizadas(tabla = "vivienda")
variables_armonizadas <- function(tabla = NULL) {
  mapa <- variable_longitudinal_map
  if (!is.null(tabla)) {
    mapa <- mapa[mapa$tabla == tabla, ]
  }
  mapa
}

#' Grupos temáticos predefinidos de variables armonizadas
#'
#' Devuelve la lista de grupos temáticos disponibles y las variables que contiene
#' cada uno, para usar con el parámetro `grupo` de [get_longitudinal()].
#'
#' @return Una lista nombrada donde cada elemento es un vector de nombres de
#'   variables armonizadas.
#' @export
#' @examples
#' grupos_variables()
#' grupos_variables()$educacion
grupos_variables <- function() {
  list(
    demografico = c("sexo", "edad", "grupo_edad", "parentesco", "estado_civil"),
    educacion   = c("sexo", "edad", "sabe_leer", "nivel_edu", "asistencia_escolar"),
    economia    = c("sexo", "edad", "pea", "pet", "categoria_ocupacion"),
    cultural    = c("sexo", "edad", "identidad_indigena", "idioma_materno"),
    migracion   = c("sexo", "edad", "migracion_nac_dpto", "migracion_rec_dpto"),
    fertilidad  = c("sexo", "edad", "hijos_nacidos_vivos", "hijos_sobrevivientes")
  )
}

#' Obtiene datos longitudinales comparables de la tabla persona entre censos
#'
#' Descarga y armoniza variables clave de múltiples censos para análisis de
#' tendencias y comparaciones históricas. El resultado es un data.frame en
#' formato largo ("tidy"), con una fila por individuo y una columna `anio`
#' que identifica el censo de origen.
#'
#' @param variables Vector de caracteres. Nombres de variables armonizadas a
#'   incluir. Usa [variables_armonizadas()] para ver las opciones disponibles.
#'   Si se especifica `grupo`, este parámetro se ignora.
#' @param grupo Nombre de un grupo temático predefinido (ver [grupos_variables()]):
#'   `"demografico"`, `"educacion"`, `"economia"`, `"cultural"`, `"migracion"`,
#'   `"fertilidad"`. Si se especifica, `variables` se ignora.
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
#' - `nivel_edu`: la Ley Avelino Siñani (2010) cambió la nomenclatura en 2012.
#' - `identidad_indigena`, `idioma_materno`: NO disponibles en 1976 o 1992.
#' - `pea`, `pet`: no disponibles en 2001.
#' - `migracion_nac_dpto`, `migracion_rec_dpto`: variables derivadas de comparación
#'    de departamento de nacimiento/residencia con el actual. Pueden contener NAs
#'    cuando la información de origen no fue registrada en el censo.
#' - `idioma_materno` en 1976: captura "idioma que habla", no el materno.
#'
#' Para variables de vivienda usa [get_longitudinal_vivienda()].
#'
#' @importFrom dplyr as_tibble case_when
#' @export
#' @examples
#' \dontrun{
#' # Usando grupo temático
#' datos <- get_longitudinal(grupo = "educacion", anios = c(1992, 2001, 2012, 2024))
#' library(dplyr)
#' datos |> count(anio, asistencia_escolar)
#'
#' # Evolución del nivel educativo en todo el país
#' get_longitudinal(variables = c("nivel_edu", "sexo"),
#'                  anios = c(1976, 1992, 2001, 2012, 2024))
#'
#' # Identidad cultural (solo 2001-2024)
#' get_longitudinal(grupo = "cultural", anios = c(2001, 2012, 2024))
#' }
get_longitudinal <- function(
    variables   = NULL,
    grupo       = NULL,
    anios       = c(1976L, 1992L, 2001L, 2012L, 2024L),
    departamento = NULL,
    verbose     = TRUE
) {
  if (!is.null(grupo)) {
    grupos <- grupos_variables()
    if (!grupo %in% names(grupos)) {
      cli::cli_abort(c(
        "Grupo no válido: {.val {grupo}}",
        "i" = "Grupos disponibles: {.val {names(grupos)}}"
      ))
    }
    variables <- grupos[[grupo]]
  }
  if (is.null(variables)) {
    cli::cli_abort("Especifica {.arg variables} o {.arg grupo}.")
  }

  anios <- as.integer(anios)
  anios_validos <- c(1976L, 1992L, 2001L, 2012L, 2024L)
  if (any(!anios %in% anios_validos)) {
    cli::cli_abort(c(
      "Año(s) no válido(s): {.val {anios[!anios %in% anios_validos]}}",
      "i" = "Los años disponibles son: {.val {anios_validos}}"
    ))
  }

  mapa <- variable_longitudinal_map[variable_longitudinal_map$tabla == "persona", ]
  vars_validas <- mapa$variable
  vars_invalidas <- setdiff(variables, vars_validas)
  if (length(vars_invalidas) > 0) {
    cli::cli_abort(c(
      "Variable(s) no encontrada(s) en tabla persona: {.val {vars_invalidas}}",
      "i" = "Usa {.fn variables_armonizadas} para ver las opciones disponibles.",
      "i" = "Para variables de vivienda usa {.fn get_longitudinal_vivienda}."
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

    submapa <- mapa[mapa$variable %in% variables, ]
    cols_originales <- submapa[[key]]
    vars_ausentes <- submapa$variable[is.na(cols_originales)]

    if (length(vars_ausentes) > 0) {
      cli::cli_warn(c(
        "!" = "Variables no disponibles en el censo {a}: {.val {vars_ausentes}}",
        "i" = "Se incluirán como {.code NA}."
      ))
    }

    if (verbose) cli::cli_inform("Obteniendo datos del censo {a}...")

    tryCatch({
      cols_a_pedir <- cols_originales[!is.na(cols_originales)]

      # Siempre incluir 'area' e 'idep'/'dep' como variables auxiliares de estratificación
      if (!"area" %in% variables) cols_a_pedir <- unique(c(cols_a_pedir, "area"))
      dep_aux <- if (a == 1976L) "dep" else "idep"
      if (!"departamento" %in% variables) cols_a_pedir <- unique(c(cols_a_pedir, dep_aux))

      # Columnas extra para nivel_edu 1992 (necesita P11 para "nunca asistió")
      if (a == 1992L && "nivel_edu" %in% variables) {
        cols_a_pedir <- unique(c(cols_a_pedir, "P11"))
      }

      # Columnas extra para migración (departamento actual + indicadores de lugar)
      needs_mig <- any(c("migracion_nac_dpto", "migracion_rec_dpto") %in% variables)
      if (needs_mig) {
        dep_col <- if (a == 1976L) "dep" else "idep"
        cols_a_pedir <- unique(c(cols_a_pedir, dep_col))
        if ("migracion_nac_dpto" %in% variables) {
          flag_nac <- .mig_flag_col("nac", a)
          if (!is.na(flag_nac)) cols_a_pedir <- unique(c(cols_a_pedir, flag_nac))
        }
        if ("migracion_rec_dpto" %in% variables) {
          flag_rec <- .mig_flag_col("rec", a)
          if (!is.na(flag_rec)) cols_a_pedir <- unique(c(cols_a_pedir, flag_rec))
        }
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

      n <- nrow(df_raw)
      df_armonizado <- data.frame(anio = rep(a, n), stringsAsFactors = FALSE)

      for (var in variables) {
        col_orig <- mapa[[key]][mapa$variable == var]
        if (length(col_orig) == 0 || is.na(col_orig)) {
          df_armonizado[[var]] <- NA_integer_
          next
        }

        if (var %in% c("migracion_nac_dpto", "migracion_rec_dpto")) {
          dep_col  <- if (a == 1976L) "dep" else "idep"
          tipo_mig <- if (var == "migracion_nac_dpto") "nac" else "rec"
          flag_col_name <- .mig_flag_col(tipo_mig, a)
          flag_vec <- if (!is.na(flag_col_name) && flag_col_name %in% names(df_raw))
            df_raw[[flag_col_name]] else NULL
          df_armonizado[[var]] <- .harmonize_migracion(
            dpto_origen  = df_raw[[col_orig]],
            anio         = a,
            dep_actual   = df_raw[[dep_col]],
            flag         = flag_vec,
            tipo         = tipo_mig
          )
        } else if (col_orig %in% names(df_raw)) {
          df_armonizado[[var]] <- .harmonize_col(df_raw[[col_orig]], var, a)
        } else {
          df_armonizado[[var]] <- NA_integer_
        }
      }

      # 1992: sobreescribir nivel_edu = 0 para quienes nunca asistieron (P11=3)
      if (a == 1992L && "nivel_edu" %in% variables &&
          "P11" %in% names(df_raw) && "nivel_edu" %in% names(df_armonizado)) {
        p11 <- suppressWarnings(as.integer(df_raw[["P11"]]))
        df_armonizado[["nivel_edu"]] <- ifelse(p11 == 3L, 0L, df_armonizado[["nivel_edu"]])
      }

      # Añadir area e idep/dep como columnas auxiliares si no son variables pedidas
      if (!"area" %in% variables && "area" %in% names(df_raw)) {
        df_armonizado[["area"]] <- suppressWarnings(as.integer(df_raw[["area"]]))
      }
      dep_aux <- if (a == 1976L) "dep" else "idep"
      if (!"departamento" %in% variables && dep_aux %in% names(df_raw)) {
        df_armonizado[["departamento"]] <- suppressWarnings(as.integer(df_raw[[dep_aux]]))
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

# Nombre de la columna "flag" adicional para derivar variables de migración
.mig_flag_col <- function(tipo, anio) {
  if (tipo == "nac") {
    switch(as.character(anio),
      "1992" = "P07",       # 1=Aquí (mismo lugar de nacimiento)
      "2001" = "P34A",      # 1=mismo muni, 2=otro Bolivia, 3=exterior
      "2012" = "P32A",      # 1=Aquí, 2=otro lugar Bolivia, 3=exterior
      "2024" = "p35_lugnac", # 1=este municipio, 2=otro muni, 3=otro país
      NA_character_
    )
  } else {
    switch(as.character(anio),
      "1992" = "P08",        # 1=vivía aquí hace 5 años
      "2001" = "P41A",       # 1=mismo muni, 2=otro Bolivia, 3=exterior
      "2012" = "P34A",       # 1=Aquí, 2=otro lugar, 3=exterior, 4=no había nacido
      "2024" = "p37_lugres5", # 1=aquí, 2=otro muni, 3=otro país, 4=no había nacido
      NA_character_
    )
  }
}


#' Obtiene datos longitudinales comparables de la tabla vivienda entre censos
#'
#' Descarga y armoniza variables de vivienda de múltiples censos para análisis
#' de tendencias en condiciones habitacionales. El resultado tiene una fila por
#' vivienda y una columna `anio` que identifica el censo de origen.
#'
#' @param variables Vector de caracteres. Nombres de variables armonizadas de
#'   vivienda. Usa [variables_armonizadas(tabla = "vivienda")] para ver las
#'   opciones disponibles.
#' @param anios Vector de enteros. Años de censo a incluir. Por defecto todos.
#' @param departamento Vector de caracteres. Código(s) de departamento (`"01"`-`"09"`).
#'   Si `NULL`, incluye todo el país.
#' @param verbose Lógico. Mostrar mensajes de progreso. Por defecto `TRUE`.
#'
#' @return Un tibble con columnas `anio` + variables solicitadas. Una fila por
#'   vivienda. Las variables no disponibles en un año aparecen como `NA`.
#'
#' @details
#' Variables disponibles para comparación longitudinal de vivienda:
#' `material_paredes`, `material_techo`, `material_piso`, `fuente_agua`,
#' `energia_electrica`, `servicio_sanitario` (no disponible en 2012),
#' `tenencia_vivienda`, `habitaciones_total`.
#'
#' @export
#' @examples
#' \dontrun{
#' # Evolución del acceso a agua potable
#' agua <- get_longitudinal_vivienda(
#'   variables = c("fuente_agua", "energia_electrica"),
#'   anios = c(1992, 2001, 2012, 2024)
#' )
#' library(dplyr)
#' agua |> count(anio, fuente_agua) |> group_by(anio) |>
#'   mutate(pct = n / sum(n))
#' }
get_longitudinal_vivienda <- function(
    variables,
    anios        = c(1976L, 1992L, 2001L, 2012L, 2024L),
    departamento = NULL,
    verbose      = TRUE
) {
  anios <- as.integer(anios)
  anios_validos <- c(1976L, 1992L, 2001L, 2012L, 2024L)
  if (any(!anios %in% anios_validos)) {
    cli::cli_abort(c(
      "Año(s) no válido(s): {.val {anios[!anios %in% anios_validos]}}",
      "i" = "Los años disponibles son: {.val {anios_validos}}"
    ))
  }

  mapa <- variable_longitudinal_map[variable_longitudinal_map$tabla == "vivienda", ]
  vars_invalidas <- setdiff(variables, mapa$variable)
  if (length(vars_invalidas) > 0) {
    cli::cli_abort(c(
      "Variable(s) no encontrada(s) en tabla vivienda: {.val {vars_invalidas}}",
      "i" = "Usa {.fn variables_armonizadas} con {.code tabla = 'vivienda'} para ver las opciones."
    ))
  }

  partes <- vector("list", length(anios))
  names(partes) <- as.character(anios)

  for (a in anios) {
    key <- paste0("v", a)

    submapa <- mapa[mapa$variable %in% variables, ]
    cols_originales <- submapa[[key]]
    vars_ausentes <- submapa$variable[is.na(cols_originales)]

    if (length(vars_ausentes) > 0) {
      cli::cli_warn(c(
        "!" = "Variables de vivienda no disponibles en censo {a}: {.val {vars_ausentes}}",
        "i" = "Se incluirán como {.code NA}."
      ))
    }

    if (verbose) cli::cli_inform("Obteniendo datos de vivienda del censo {a}...")

    tryCatch({
      cols_a_pedir <- cols_originales[!is.na(cols_originales)]

      df_raw <- if (a == 2024L) {
        get_viviendas_2024(departamento = departamento, variables = cols_a_pedir,
                           as = "tibble", verbose = FALSE)
      } else {
        get_censo(a, "vivienda", departamento = departamento, variables = cols_a_pedir,
                  as = "tibble", verbose = FALSE)
      }

      if (is.null(df_raw) || nrow(df_raw) == 0) {
        cli::cli_warn("Sin datos de vivienda para el censo {a}.")
        next
      }

      n <- nrow(df_raw)
      df_armonizado <- data.frame(anio = rep(a, n), stringsAsFactors = FALSE)

      for (var in variables) {
        col_orig <- mapa[[key]][mapa$variable == var]
        if (length(col_orig) == 0 || is.na(col_orig)) {
          df_armonizado[[var]] <- NA_integer_
        } else if (col_orig %in% names(df_raw)) {
          df_armonizado[[var]] <- .harmonize_viv_col(df_raw[[col_orig]], var, a)
        } else {
          df_armonizado[[var]] <- NA_integer_
        }
      }

      rownames(df_armonizado) <- NULL
      partes[[as.character(a)]] <- df_armonizado

    }, error = function(e) {
      cli::cli_warn("Error obteniendo datos de vivienda del censo {a}: {conditionMessage(e)}")
    })
  }

  partes_validas <- Filter(Negate(is.null), partes)
  if (length(partes_validas) == 0) {
    cli::cli_abort("No se obtuvieron datos de vivienda de ningún censo.")
  }

  result <- do.call(rbind, partes_validas)
  rownames(result) <- NULL
  dplyr::as_tibble(result)
}


# ===========================================================================
# Funciones internas de armonización — tabla PERSONA
# ===========================================================================

# Despacha a la función correcta según variable y año
.harmonize_col <- function(x, variable, anio) {
  if (variable == "sexo")               return(.harmonize_sexo(x, anio))
  if (variable == "sabe_leer")          return(.harmonize_sabe_leer(x, anio))
  if (variable == "nivel_edu")          return(.harmonize_nivel_edu(x, anio))
  if (variable == "asistencia_escolar") return(.harmonize_asistencia_escolar(x, anio))
  if (variable == "categoria_ocupacion") return(.harmonize_categoria_ocupacion(x, anio))
  if (variable == "identidad_indigena") return(.harmonize_identidad_indigena(x, anio))
  if (variable == "idioma_materno")     return(.harmonize_idioma_materno(x, anio))
  if (variable %in% c("hijos_nacidos_vivos", "hijos_sobrevivientes")) {
    x_num <- suppressWarnings(as.integer(x))
    # Filtrar códigos REDATAM NOTAPPLICABLE/MISSING: 26 (1992), 98-100 (2001/2012), 99 (1976)
    # y cualquier valor > 25 (máximo biológico razonable)
    return(ifelse(is.na(x_num) | x_num > 25L, NA_integer_, x_num))
  }
  if (variable == "edad") {
    return(suppressWarnings(as.integer(x)))
  }
  if (variable == "grupo_edad" && anio != 1976L) {
    edad_num <- suppressWarnings(as.integer(x))
    return(ifelse(is.na(edad_num), NA_integer_, (edad_num %/% 5L) * 5L))
  }
  x
}

# sexo → 1=Mujer, 2=Hombre
.harmonize_sexo <- function(x, anio) {
  x_num <- suppressWarnings(as.integer(x))
  if (anio %in% c(1976L, 1992L, 2001L)) {
    dplyr::case_when(x_num == 1L ~ 2L, x_num == 2L ~ 1L, TRUE ~ NA_integer_)
  } else {
    dplyr::case_when(x_num %in% c(1L, 2L) ~ x_num, TRUE ~ NA_integer_)
  }
}

# sabe_leer → 1=Sí, 2=No
.harmonize_sabe_leer <- function(x, anio) {
  x_num <- suppressWarnings(as.integer(x))
  if (anio == 1992L) {
    dplyr::case_when(x_num == 7L ~ 1L, x_num == 8L ~ 2L, TRUE ~ NA_integer_)
  } else {
    dplyr::case_when(x_num == 1L ~ 1L, x_num == 2L ~ 2L, TRUE ~ NA_integer_)
  }
}

# nivel_edu → 0=Sin instrucción, 1=Primaria, 2=Secundaria, 3=Superior
.harmonize_nivel_edu <- function(x, anio) {
  x_num <- suppressWarnings(as.integer(x))
  if (anio == 1976L) {
    dplyr::case_when(
      x_num == 1L ~ 0L, x_num == 2L ~ 1L, x_num == 3L ~ 2L,
      x_num %in% c(4L, 5L) ~ 3L, TRUE ~ NA_integer_
    )
  } else if (anio == 1992L) {
    dplyr::case_when(
      x_num %in% c(2L, 3L) ~ 1L, x_num == 4L ~ 2L,
      x_num %in% c(5L, 6L, 7L) ~ 3L, TRUE ~ NA_integer_
    )
  } else if (anio == 2001L) {
    dplyr::case_when(
      x_num %in% c(11L, 12L) ~ 0L,
      x_num %in% c(13L, 14L, 16L) ~ 1L,
      x_num %in% c(15L, 17L) ~ 2L,
      x_num %in% c(18L, 19L, 20L, 21L, 22L) ~ 3L,
      TRUE ~ NA_integer_
    )
  } else if (anio == 2012L) {
    dplyr::case_when(
      x_num %in% c(1L, 2L, 3L) ~ 0L, x_num == 9L ~ 1L, x_num == 10L ~ 2L,
      x_num %in% 11L:18L ~ 3L, TRUE ~ NA_integer_
    )
  } else if (anio == 2024L) {
    dplyr::case_when(
      x_num == 1L ~ 0L, x_num == 2L ~ 1L, x_num == 3L ~ 2L, x_num == 4L ~ 3L,
      TRUE ~ NA_integer_
    )
  } else {
    NA_integer_
  }
}

# asistencia_escolar → 1=Sí asiste, 2=No asiste
.harmonize_asistencia_escolar <- function(x, anio) {
  x_num <- suppressWarnings(as.integer(x))
  if (anio == 1976L) {
    # p11: 1=SI ASISTE, 2=NO ASISTE
    dplyr::case_when(x_num == 1L ~ 1L, x_num == 2L ~ 2L, TRUE ~ NA_integer_)
  } else if (anio == 1992L) {
    # P11: 1=Asiste, 2=No asiste pero asistió, 3=Nunca asistió, 0=NOTAPPLICABLE
    dplyr::case_when(
      x_num == 1L ~ 1L,
      x_num %in% c(2L, 3L) ~ 2L,
      TRUE ~ NA_integer_
    )
  } else if (anio == 2001L) {
    # P37: INVERTIDO — 1=NO asiste, 2=SÍ (pública), 3=SÍ (privada)
    dplyr::case_when(
      x_num == 1L ~ 2L,
      x_num %in% c(2L, 3L) ~ 1L,
      TRUE ~ NA_integer_
    )
  } else if (anio == 2012L) {
    # P36: 1=Sí pública, 2=Sí privada, 3=Sí convenio, 4=No asiste
    dplyr::case_when(
      x_num %in% c(1L, 2L, 3L) ~ 1L,
      x_num == 4L ~ 2L,
      TRUE ~ NA_integer_
    )
  } else if (anio == 2024L) {
    # p38_asiste: 1-7=tipos de establecimiento (SÍ asiste), 8=No asiste, 9=Sin especificar
    dplyr::case_when(
      x_num %in% 1L:7L ~ 1L,
      x_num == 8L ~ 2L,
      TRUE ~ NA_integer_
    )
  } else {
    NA_integer_
  }
}

# categoria_ocupacion → 1=Empleado/Obrero, 2=Cuenta propia,
#   3=Empleador/Patrón, 4=Familiar no remunerado, 5=Otro
.harmonize_categoria_ocupacion <- function(x, anio) {
  x_num <- suppressWarnings(as.integer(x))
  if (anio == 1976L) {
    # p18: 1=Obrero, 2=Empleado, 3=Familiar no rem, 4=Cta propia, 5=Patrón/socio
    dplyr::case_when(
      x_num %in% c(1L, 2L) ~ 1L, x_num == 4L ~ 2L, x_num == 5L ~ 3L,
      x_num == 3L ~ 4L, TRUE ~ NA_integer_
    )
  } else if (anio == 1992L) {
    # P18: 1=Obrero(peón), 2=Empleado, 3=Cta propia, 4=Patrón/socio,
    #      5=Cooperativista, 6=Prof independiente, 7=Familiar no rem
    dplyr::case_when(
      x_num %in% c(1L, 2L) ~ 1L, x_num %in% c(3L, 6L) ~ 2L,
      x_num == 4L ~ 3L, x_num == 7L ~ 4L, x_num == 5L ~ 5L,
      TRUE ~ NA_integer_
    )
  } else if (anio == 2001L) {
    # P46: 3=Obrero/empleado, 4=Cta propia, 5=Patrón/socio,
    #      6=Cooperativista, 7=Familiar no rem
    dplyr::case_when(
      x_num == 3L ~ 1L, x_num == 4L ~ 2L, x_num == 5L ~ 3L,
      x_num == 7L ~ 4L, x_num == 6L ~ 5L, TRUE ~ NA_integer_
    )
  } else if (anio == 2012L) {
    # P43: 1=Obrero/empleado, 2=Cta propia, 3=Empleador/socio,
    #      4=Familiar no rem, 5=Trab hogar, 6=Cooperativista
    dplyr::case_when(
      x_num %in% c(1L, 5L) ~ 1L, x_num == 2L ~ 2L, x_num == 3L ~ 3L,
      x_num == 4L ~ 4L, x_num == 6L ~ 5L, TRUE ~ NA_integer_
    )
  } else if (anio == 2024L) {
    # p50_semp: 1=Cta propia, 2=Empleado/obrero, 3=Empleador/socio,
    #           4=Familiar no rem, 5=Trab hogar, 6=Cooperativista, 9=Sin especificar
    dplyr::case_when(
      x_num %in% c(2L, 5L) ~ 1L, x_num == 1L ~ 2L, x_num == 3L ~ 3L,
      x_num == 4L ~ 4L, x_num == 6L ~ 5L, TRUE ~ NA_integer_
    )
  } else {
    NA_integer_
  }
}

# identidad_indigena → 1=Sí, 2=No
.harmonize_identidad_indigena <- function(x, anio) {
  if (anio %in% c(1976L, 1992L)) return(rep(NA_integer_, length(x)))
  x_num <- suppressWarnings(as.integer(x))
  if (anio == 2001L) {
    # P491: 1-6=pueblo indígena, 7=NINGUNO
    dplyr::case_when(
      x_num %in% 1L:6L ~ 1L, x_num == 7L ~ 2L, TRUE ~ NA_integer_
    )
  } else if (anio == 2012L) {
    # P29C: código de pueblo (1-123) = sí identificado; 0=NOTAPPLICABLE = No se identifica → 2
    dplyr::case_when(
      x_num %in% 1L:123L ~ 1L,
      x_num == 0L ~ 2L,
      TRUE ~ NA_integer_
    )
  } else if (anio == 2024L) {
    # p32_pueblo_per: 1=Sí, 2=No
    dplyr::case_when(x_num == 1L ~ 1L, x_num == 2L ~ 2L, TRUE ~ NA_integer_)
  } else {
    NA_integer_
  }
}

# idioma_materno → 1=Castellano, 2=Quechua, 3=Aymara, 4=Guaraní,
#   5=Otro nativo boliviano, 6=Otro idioma (extranjero)
.harmonize_idioma_materno <- function(x, anio) {
  if (anio == 1992L) return(rep(NA_integer_, length(x)))
  x_num <- suppressWarnings(as.integer(x))
  if (anio == 1976L) {
    # p09 (idioma que HABLA, no materno):
    # 1=Castellano, 2=Aymara, 3=Quechua, 4=Otro nativo
    # 5=Cast/Aymara, 6=Cast/Quechua, 7=Cast/Otro, 8=Aymara/Quechua, 9=Cast/Ay/Qu
    dplyr::case_when(
      x_num == 1L ~ 1L,                    # solo Castellano
      x_num == 2L ~ 3L,                    # Aymara
      x_num == 3L ~ 2L,                    # Quechua
      x_num == 4L ~ 5L,                    # Otro nativo
      x_num == 5L ~ 3L,                    # Cast+Aymara → Aymara
      x_num == 6L ~ 2L,                    # Cast+Quechua → Quechua
      x_num == 7L ~ 5L,                    # Cast+Otro nativo
      x_num == 8L ~ 3L,                    # Aymara+Quechua → Aymara (primera)
      x_num == 9L ~ 3L,                    # Cast+Ay+Qu → Aymara
      TRUE ~ NA_integer_
    )
  } else if (anio == 2001L) {
    # P35: 1=Quechua, 2=Aymara, 3=Castellano, 4=Guaraní, 5=Otro nativo, 6=Extranjero, 7=No habla
    dplyr::case_when(
      x_num == 3L ~ 1L, x_num == 1L ~ 2L, x_num == 2L ~ 3L, x_num == 4L ~ 4L,
      x_num == 5L ~ 5L, x_num == 6L ~ 6L, TRUE ~ NA_integer_
    )
  } else if (anio %in% c(2012L, 2024L)) {
    # P30B / p341_idiomat_cod: código de idioma nativo boliviano
    # 6=Castellano, 27=Quechua, 2=Aymara, 12=Guaraní
    # 1-37 (excepto 2,6,12,27) = otros nativos bolivianos
    # >=38 = idiomas extranjeros / no aplica
    # 2024 extra: 92-95 = lenguas nativas (Quinamaya, Qom, Afroboliviano, Joaquiniano)
    nativos_base <- setdiff(1L:37L, c(2L, 6L, 12L, 27L))
    nativos_extra_2024 <- if (anio == 2024L) c(92L:95L) else integer(0)
    dplyr::case_when(
      x_num == 6L  ~ 1L,
      x_num == 27L ~ 2L,
      x_num == 2L  ~ 3L,
      x_num == 12L ~ 4L,
      x_num %in% c(nativos_base, nativos_extra_2024) ~ 5L,
      x_num >= 38L & x_num < 900L ~ 6L,
      TRUE ~ NA_integer_
    )
  } else {
    NA_integer_
  }
}

# migracion_nac_dpto / migracion_rec_dpto → 1=Mismo dpto, 2=Otro dpto, 3=Exterior, 4=No había nacido
.harmonize_migracion <- function(dpto_origen, anio, dep_actual, flag = NULL, tipo = "nac") {
  d_origen <- suppressWarnings(as.integer(dpto_origen))
  d_actual <- suppressWarnings(as.integer(dep_actual))

  if (!is.null(flag)) {
    flag_num <- suppressWarnings(as.integer(flag))

    if (anio == 1976L || anio %in% c(1992L)) {
      # 1976: sin flag útil para nacimiento; 1992: P07/P08 = 1 significa "aquí"
      misma_localidad <- flag_num == 1L
    } else {
      # 2001/2012: P34A/P32A: 1=mismo muni, 2=otro Bolivia, 3=exterior, 4=no nacido
      # 2024: p35_lugnac/p37_lugres5: mismos valores
      misma_localidad <- flag_num == 1L
    }

    # Calcular resultado
    exterior <- if (tipo == "rec" && anio %in% c(2012L, 2024L)) {
      flag_num == 3L
    } else if (tipo == "nac" && anio %in% c(2001L, 2012L, 2024L)) {
      flag_num == 3L
    } else {
      rep(FALSE, length(flag_num))
    }

    no_nacido <- if (tipo == "rec" && anio %in% c(2012L, 2024L)) {
      flag_num == 4L
    } else {
      rep(FALSE, length(flag_num))
    }

    dplyr::case_when(
      exterior                                        ~ 3L,
      no_nacido                                       ~ 4L,
      misma_localidad                                 ~ 1L,
      d_origen == d_actual & d_origen %in% 1L:9L     ~ 1L,
      d_origen %in% 1L:9L & d_origen != d_actual     ~ 2L,
      TRUE                                            ~ NA_integer_
    )
  } else {
    # Sin columna flag: solo comparación directa de departamentos
    if (anio == 1976L && tipo == "nac") {
      # lugnac: 1-9=dept nac, 10=exterior
      dplyr::case_when(
        d_origen == d_actual & d_origen %in% 1L:9L ~ 1L,
        d_origen %in% 1L:9L & d_origen != d_actual ~ 2L,
        d_origen == 10L                             ~ 3L,
        TRUE                                        ~ NA_integer_
      )
    } else if (anio == 1976L && tipo == "rec") {
      # resh5: 1-9=dept, 10=exterior, 11=sin especificar
      dplyr::case_when(
        d_origen == d_actual & d_origen %in% 1L:9L ~ 1L,
        d_origen %in% 1L:9L & d_origen != d_actual ~ 2L,
        d_origen == 10L                             ~ 3L,
        TRUE                                        ~ NA_integer_
      )
    } else {
      dplyr::case_when(
        d_origen == d_actual & d_origen %in% 1L:9L ~ 1L,
        d_origen %in% 1L:9L & d_origen != d_actual ~ 2L,
        TRUE                                        ~ NA_integer_
      )
    }
  }
}


# ===========================================================================
# Funciones internas de armonización — tabla VIVIENDA
# ===========================================================================

.harmonize_viv_col <- function(x, variable, anio) {
  if (variable == "material_paredes")  return(.harmonize_paredes(x, anio))
  if (variable == "material_techo")    return(.harmonize_techo(x, anio))
  if (variable == "material_piso")     return(.harmonize_piso(x, anio))
  if (variable == "fuente_agua")       return(.harmonize_agua(x, anio))
  if (variable == "energia_electrica") return(.harmonize_energia(x, anio))
  if (variable == "servicio_sanitario") return(.harmonize_sanitario(x, anio))
  if (variable == "tenencia_vivienda") return(.harmonize_tenencia(x, anio))
  if (variable == "habitaciones_total") return(suppressWarnings(as.integer(x)))
  x
}

# material_paredes → 1=Ladrillo/Bloque/Hormigón, 2=Adobe/Tapial,
#   3=Madera/Tabique/Caña/Palma, 4=Piedra, 5=Otro
.harmonize_paredes <- function(x, anio) {
  x_num <- suppressWarnings(as.integer(x))
  if (anio %in% c(1976L, 1992L)) {
    # 1=Adobe revocado, 2=Adobe tapial, 3=Ladrillo/bloque/cemento,
    # 4=Piedra, 5=Madera, 6=Caña/palma/troncos, 7=Otros
    dplyr::case_when(
      x_num %in% c(1L, 2L) ~ 2L, x_num == 3L ~ 1L, x_num == 4L ~ 4L,
      x_num %in% c(5L, 6L) ~ 3L, x_num == 7L ~ 5L, TRUE ~ NA_integer_
    )
  } else {
    # 2001/2012/2024: 1=Ladrillo/bloque/hormigón, 2=Adobe/tapial,
    # 3=Tabique/quinche, 4=Piedra, 5=Madera, 6=Caña/palma/tronco, 7=Otro
    dplyr::case_when(
      x_num == 1L ~ 1L, x_num == 2L ~ 2L,
      x_num %in% c(3L, 5L, 6L) ~ 3L, x_num == 4L ~ 4L,
      x_num == 7L ~ 5L, TRUE ~ NA_integer_
    )
  }
}

# material_techo → 1=Calamina/Plancha/Teja, 2=Losa hormigón, 3=Paja/Caña/Palma, 4=Otro
.harmonize_techo <- function(x, anio) {
  x_num <- suppressWarnings(as.integer(x))
  # Códigos idénticos en todos los años: 1=Calamina, 2=Tejas, 3=Losa, 4=Paja/caña/palma, 5=Otro
  dplyr::case_when(
    x_num %in% c(1L, 2L) ~ 1L, x_num == 3L ~ 2L,
    x_num == 4L ~ 3L, x_num == 5L ~ 4L, TRUE ~ NA_integer_
  )
}

# material_piso → 1=Tierra, 2=Cemento/Ladrillo, 3=Mosaico/Parquet/Madera, 4=Otro
.harmonize_piso <- function(x, anio) {
  x_num <- suppressWarnings(as.integer(x))
  if (anio %in% c(1976L, 1992L)) {
    # 1=Madera, 2=Mosaico/baldosas, 3=Ladrillo, 4=Cemento, 5=Tierra, 6=Otros
    dplyr::case_when(
      x_num == 5L ~ 1L, x_num %in% c(3L, 4L) ~ 2L,
      x_num %in% c(1L, 2L) ~ 3L, x_num == 6L ~ 4L, TRUE ~ NA_integer_
    )
  } else if (anio == 2001L) {
    # 1=Tierra, 2=Tablón madera, 3=Machihembre/parquet, 4=Alfombra/tapizón,
    # 5=Cemento, 6=Mosaico/baldosa/cerámica, 7=Ladrillo, 8=Otro
    dplyr::case_when(
      x_num == 1L ~ 1L, x_num %in% c(5L, 7L) ~ 2L,
      x_num %in% c(2L, 3L, 4L, 6L) ~ 3L, x_num == 8L ~ 4L, TRUE ~ NA_integer_
    )
  } else if (anio == 2012L) {
    # 1=Tierra, 2=Tablón madera, 3=Machihembre, 4=Parquet, 5=Cerámica,
    # 6=Cemento, 7=Mosaico/baldosa, 8=Ladrillo, 9=Otro
    dplyr::case_when(
      x_num == 1L ~ 1L, x_num %in% c(6L, 8L) ~ 2L,
      x_num %in% c(2L, 3L, 4L, 5L, 7L) ~ 3L, x_num == 9L ~ 4L, TRUE ~ NA_integer_
    )
  } else if (anio == 2024L) {
    # 1=Tierra, 2=Tablón madera, 3=Machimbre/parquet, 4=Cerámica/porcelanato,
    # 5=Cemento, 6=Mosaico/baldosa, 7=Ladrillo, 8=Piso flotante, 9=Otro
    dplyr::case_when(
      x_num == 1L ~ 1L, x_num %in% c(5L, 7L) ~ 2L,
      x_num %in% c(2L, 3L, 4L, 6L, 8L) ~ 3L, x_num == 9L ~ 4L, TRUE ~ NA_integer_
    )
  } else {
    NA_integer_
  }
}

# fuente_agua → 1=Cañería/red pública, 2=Otra fuente protegida, 3=Fuente no protegida
.harmonize_agua <- function(x, anio) {
  x_num <- suppressWarnings(as.integer(x))
  if (anio == 1976L) {
    # v07: 1=Red pública, 2=Red privada, 3=Pozo/noria, 4=Aljibe,
    #      5=Río/lago/vertiente, 6=Carro repartidor, 7=Otra
    dplyr::case_when(
      x_num %in% c(1L, 2L) ~ 1L, x_num %in% c(3L, 4L, 6L, 7L) ~ 2L,
      x_num == 5L ~ 3L, TRUE ~ NA_integer_
    )
  } else if (anio == 1992L) {
    # V07: 1=Red pública o privada, 2=Pozo o noria, 3=Río/lago/vertiente/acequia,
    #      4=Carro repartidor, 5=Otra
    dplyr::case_when(
      x_num == 1L ~ 1L, x_num %in% c(2L, 4L, 5L) ~ 2L,
      x_num == 3L ~ 3L, TRUE ~ NA_integer_
    )
  } else if (anio == 2001L) {
    # V10: 1=Cañería red, 2=Pileta pública, 3=Carro repartidor,
    #      4=Pozo bomba, 5=Pozo sin bomba, 6=Río/vertiente/acequia,
    #      7=Lago/laguna/curiche, 8=Otra
    dplyr::case_when(
      x_num %in% c(1L, 2L) ~ 1L, x_num %in% c(3L, 4L, 8L) ~ 2L,
      x_num %in% c(5L, 6L, 7L) ~ 3L, TRUE ~ NA_integer_
    )
  } else if (anio == 2012L) {
    # P07: 1=Cañería red, 2=Pileta pública, 3=Carro repartidor,
    #      4=Pozo bomba, 5=Pozo sin bomba, 6=Lluvia/río/vertiente/acequia,
    #      7=Lago/laguna/curichi
    dplyr::case_when(
      x_num %in% c(1L, 2L) ~ 1L, x_num %in% c(3L, 4L) ~ 2L,
      x_num %in% c(5L, 6L, 7L) ~ 3L, TRUE ~ NA_integer_
    )
  } else if (anio == 2024L) {
    # v07_aguapro: 1=Cañería red, 2=Pileta pública, 3=Cosecha lluvia,
    #              4=Pozo con bomba, 5=Pozo no protegido/sin bomba,
    #              6=Manantial/vertiente protegida, 7=Río/acequia/vertiente no prot,
    #              8=Carro repartidor, 9=Otro
    dplyr::case_when(
      x_num %in% c(1L, 2L) ~ 1L,
      x_num %in% c(4L, 6L, 8L, 9L) ~ 2L,
      x_num %in% c(3L, 5L, 7L) ~ 3L,
      TRUE ~ NA_integer_
    )
  } else {
    NA_integer_
  }
}

# energia_electrica → 1=Sí (cualquier fuente), 2=No
.harmonize_energia <- function(x, anio) {
  x_num <- suppressWarnings(as.integer(x))
  if (anio %in% c(1976L, 1992L)) {
    # 1=Sí, 2=No
    dplyr::case_when(x_num == 1L ~ 1L, x_num == 2L ~ 2L, TRUE ~ NA_integer_)
  } else if (anio == 2001L) {
    # V15: 5=Sí, 6=No (codificación diferente)
    dplyr::case_when(x_num == 5L ~ 1L, x_num == 6L ~ 2L, TRUE ~ NA_integer_)
  } else if (anio == 2012L) {
    # P09: 1=Sí privado, 2=Sí compartido, 3=No tiene
    dplyr::case_when(
      x_num %in% c(1L, 2L) ~ 1L, x_num == 3L ~ 2L, TRUE ~ NA_integer_
    )
  } else if (anio == 2024L) {
    # v09_energia: 1-4=cualquier fuente, 5=No tiene
    dplyr::case_when(
      x_num %in% 1L:4L ~ 1L, x_num == 5L ~ 2L, TRUE ~ NA_integer_
    )
  } else {
    NA_integer_
  }
}

# servicio_sanitario → 1=Sí tiene, 2=No tiene
.harmonize_sanitario <- function(x, anio) {
  x_num <- suppressWarnings(as.integer(x))
  if (anio == 1976L) {
    # v081: 1=Privado, 2=Compartido, 3=No tiene
    dplyr::case_when(
      x_num %in% c(1L, 2L) ~ 1L, x_num == 3L ~ 2L, TRUE ~ NA_integer_
    )
  } else if (anio == 1992L) {
    # V08: 1=Con descarga, 2=Sin descarga, 3=No tiene
    dplyr::case_when(
      x_num %in% c(1L, 2L) ~ 1L, x_num == 3L ~ 2L, TRUE ~ NA_integer_
    )
  } else if (anio == 2001L) {
    # V12: 1=Tiene baño, 2=No tiene baño
    dplyr::case_when(x_num == 1L ~ 1L, x_num == 2L ~ 2L, TRUE ~ NA_integer_)
  } else if (anio == 2012L) {
    # No disponible en el parquet de 2012
    rep(NA_integer_, length(x))
  } else if (anio == 2024L) {
    # v15_servsan: 1=Sí (solo), 2=Sí (compartido), 3=No tiene
    dplyr::case_when(
      x_num %in% c(1L, 2L) ~ 1L, x_num == 3L ~ 2L, TRUE ~ NA_integer_
    )
  } else {
    NA_integer_
  }
}

# tenencia_vivienda → 1=Propia, 2=Alquilada, 3=Cedida/anticrético/servicios, 4=Otra
.harmonize_tenencia <- function(x, anio) {
  x_num <- suppressWarnings(as.integer(x))
  if (anio %in% c(1976L, 1992L, 2001L, 2012L)) {
    # Todos tienen: 1=Propia, 2=Alquilada, 3=Anticrético, 4=Mixto/Servicios,
    # 5=Cedida/servicios, 6=Cedida/parientes, 7=Otra
    dplyr::case_when(
      x_num == 1L ~ 1L,
      x_num == 2L ~ 2L,
      x_num %in% c(3L, 4L, 5L, 6L) ~ 3L,
      x_num == 7L ~ 4L,
      TRUE ~ NA_integer_
    )
  } else if (anio == 2024L) {
    # v17_tenencia: 1=Propia pagada, 2=Propia pagando, 3=Prestada parientes,
    # 4=Alquilada, 5=Anticrético, 6=Mixto anticrético+alquiler,
    # 7=Cedida servicios, 8=Otra
    dplyr::case_when(
      x_num %in% c(1L, 2L) ~ 1L,
      x_num == 4L ~ 2L,
      x_num %in% c(3L, 5L, 6L, 7L) ~ 3L,
      x_num == 8L ~ 4L,
      TRUE ~ NA_integer_
    )
  } else {
    NA_integer_
  }
}

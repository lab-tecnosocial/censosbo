#' Variables armonizadas para análisis temporal
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
#'   \item{armonizada}{`TRUE` si `get_temporal()` remapea los códigos a un esquema
#'     comparable entre censos; `FALSE` si devuelve los códigos crudos de cada año
#'     (no comparables, p.ej. `parentesco`)}
#'   \item{v1976, v1992, v2001, v2012, v2024}{Nombre de la columna en cada censo (`NA` si no disponible)}
#'   \item{notas}{Advertencias sobre diferencias metodológicas entre censos}
#'   \item{tema}{Tema al que pertenece, con el vocabulario de
#'     [censo_temas_meta]. Permite pasar de la vista armonizada a la
#'     temática sin una tabla externa}
#' }
#' @source Elaboración propia a partir de los diccionarios oficiales del INE Bolivia.
"variable_temporal_map"

#' Muestra el mapeo de variables comparables entre censos de Bolivia
#'
#' Retorna la tabla de variables armonizadas que pueden usarse en análisis
#' temporales o comparativos entre los censos de 1976, 1992, 2001, 2012
#' y el CPV-2024.
#'
#' @param tabla Filtrar por tabla de origen: `"persona"`, `"vivienda"` o `NULL`
#'   para todas. Por defecto `NULL`.
#'
#' @return Un data.frame con las variables armonizadas y sus equivalentes en
#'   cada año de censo. La columna `armonizada` indica si los códigos son
#'   comparables entre censos (`TRUE`) o crudos de cada año (`FALSE`).
#' @export
#' @examples
#' variables_armonizadas()
#' variables_armonizadas(tabla = "vivienda")
variables_armonizadas <- function(tabla = NULL) {
  mapa <- variable_temporal_map
  if (!is.null(tabla)) {
    tablas_validas <- unique(mapa$tabla)
    if (!tabla %in% tablas_validas) {
      cli::cli_abort(c(
        "Tabla no reconocida: {.val {tabla}}",
        "i" = "Tablas disponibles: {.val {tablas_validas}}."
      ))
    }
    mapa <- mapa[mapa$tabla == tabla, ]
  }
  mapa
}

#' Grupos temáticos predefinidos de variables armonizadas
#'
#' Devuelve la lista de grupos temáticos disponibles y las variables que contiene
#' cada uno, para usar con el parámetro `grupo` de [get_temporal()].
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

# Advierte si entre las variables pedidas hay alguna no armonizada (códigos crudos
# no comparables entre censos). Usa la columna `armonizada` de variable_temporal_map.
.warn_no_armonizadas <- function(mapa, variables, verbose) {
  if (!isTRUE(verbose) || !"armonizada" %in% names(mapa)) return(invisible())
  no_arm <- mapa$variable[mapa$variable %in% variables & !mapa$armonizada]
  if (length(no_arm) > 0) {
    cli::cli_warn(c(
      "!" = "Variable(s) no armonizada(s): {.val {no_arm}}.",
      "i" = "Se devuelven los códigos crudos de cada censo, que NO son comparables entre años.",
      "i" = "Consulta {.code codebook_1976()}/{.code codebook_1992()}/... para interpretarlos por año."
    ))
  }
  invisible()
}

#' Obtiene datos temporales comparables de la tabla persona entre censos
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
#'   **Nota:** `area` (1=Urbana, 2=Rural) y `departamento` (código numérico) se
#'   incluyen siempre en el resultado, incluso si no fueron solicitados. Son
#'   útiles para estratificar o filtrar los datos.
#'
#' @section Los universos poblacionales no siempre coinciden:
#' La armonización iguala los **códigos**, no la **población a la que se
#' preguntó**. Comparar distribuciones sin igualar el universo produce
#' conclusiones falsas, y el INE cambió el filtro de edad de varias preguntas
#' entre censos.
#'
#' **`get_temporal()` lo detecta y avisa**: si alguna variable pedida no se
#' preguntó a la misma población en todos los años solicitados, emite un aviso con
#' el universo de cada censo y la edad mínima que los iguala. El dato viene de los
#' diccionarios DDI del catálogo ANDA, así que la advertencia es del INE, no una
#' estimación del paquete.
#'
#' Siete de las variables armonizadas están afectadas. Los casos más marcados:
#'
#' - `nivel_edu`: **19 años o más** en el CPV-2024 (es una derivada del INE) frente
#'   a 6 años en 1992 y 4 en 2001. Es la mayor divergencia de todas: sin filtrar,
#'   2024 aparece con muchos más `NA` y da la impresión de estar "más educado".
#' - `sabe_leer` y `asistencia_escolar`: el umbral se movió cuatro veces —
#'   5 años (1976), 6 (1992), 4 (2001) y 5 (2024).
#' - `estado_civil`: 12 años en 1976 y 2024, 15 en 2001.
#' - `hijos_nacidos_vivos` y `hijos_sobrevivientes`: mujeres de 12 años o más en
#'   1976, 1992 y 2024; personas de 15 años o más en 2001.
#' - `idioma_materno`: 5 años (1976) frente a 4 (2001) y todas en 2024.
#'
#' La columna `notas` de [variables_armonizadas()] recoge, además, las
#' advertencias sobre los **códigos** de cada variable.
#'
#' @section Los dos vocabularios temáticos:
#' `grupo` acepta los seis grupos de [grupos_variables()], que agrupan nombres
#' **armonizados**, y también los slugs de [censo_temas()], que agrupan las
#' variables **crudas** de cada censo. Los seis originales son alias permanentes;
#' pasar un slug de tema informa del grupo equivalente y devuelve lo mismo.
#'
#' @details
#' **Variables con limitaciones conocidas:**
#' - `nivel_edu`: la Ley Avelino Siñani (2010) cambió la nomenclatura en 2012.
#' - `identidad_indigena`, `idioma_materno`: NO disponibles en 1976 o 1992.
#' - `pea`, `pet`: no disponibles en 2001.
#' - `migracion_nac_dpto`, `migracion_rec_dpto`: variables derivadas de comparación
#'    de departamento de nacimiento/residencia con el actual. Pueden contener NAs
#'    cuando la información de origen no fue registrada en el censo.
#'    **Atención:** `migracion_rec_dpto` solo tiene los códigos 1 (mismo dpto) y
#'    2 (otro dpto) en 1992 y 2001. Los códigos 3 (exterior) y 4 (no había nacido)
#'    solo existen en 1976, 2012 y 2024. Comparar distribuciones entre todos los
#'    años puede ser engañoso.
#' - `idioma_materno` en 1976: captura "idioma que habla", no el materno.
#'
#' Para variables de vivienda usa [get_temporal_vivienda()].
#'
#' @importFrom dplyr as_tibble case_when
#' @export
#' @examples
#' \dontrun{
#' # Usando grupo temático
#' datos <- get_temporal(grupo = "educacion", anios = c(1992, 2001, 2012, 2024))
#' library(dplyr)
#' datos |> count(anio, asistencia_escolar)
#'
#' # Evolución del nivel educativo en todo el país
#' get_temporal(variables = c("nivel_edu", "sexo"),
#'              anios = c(1976, 1992, 2001, 2012, 2024))
#'
#' # Identidad cultural (solo 2001-2024)
#' get_temporal(grupo = "cultural", anios = c(2001, 2012, 2024))
#' }
get_temporal <- function(
    variables   = NULL,
    grupo       = NULL,
    anios       = c(1976L, 1992L, 2001L, 2012L, 2024L),
    departamento = NULL,
    verbose     = TRUE
) {
  if (!is.null(grupo)) {
    variables <- .resolver_grupo(grupo)
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

  mapa <- variable_temporal_map[variable_temporal_map$tabla == "persona", ]
  vars_validas <- mapa$variable
  vars_invalidas <- setdiff(variables, vars_validas)
  if (length(vars_invalidas) > 0) {
    cli::cli_abort(c(
      "Variable(s) no encontrada(s) en tabla persona: {.val {vars_invalidas}}",
      "i" = "Usa {.fn variables_armonizadas} para ver las opciones disponibles.",
      "i" = "Para variables de vivienda usa {.fn get_temporal_vivienda}."
    ))
  }

  .warn_no_armonizadas(mapa, variables, verbose)
  # El aviso más importante de esta función: armonizar los códigos no iguala la
  # población a la que se preguntó. Con el universo de cada censo en el codebook,
  # se puede detectar en vez de dejarlo escrito solo en la documentación.
  .avisar_universos(variables, anios)

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
                          as = "tibble", verbose = verbose)
      } else if (a == 1976L) {
        get_censo(a, "poblacion", departamento = departamento, variables = cols_a_pedir,
                  as = "tibble", verbose = verbose)
      } else {
        get_censo(a, "persona", departamento = departamento, variables = cols_a_pedir,
                  as = "tibble", verbose = verbose)
      }

      if (is.null(df_raw) || nrow(df_raw) == 0) {
        cli::cli_warn("Sin datos para el censo {a} con los filtros aplicados.")
        next
      }

      if (verbose) cli::cli_inform(c("i" = "Armonizando variables del censo {a}..."))

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
        # `!is.na(p11) &` evita que un P11 ausente convierta en NA un nivel_edu
        # que sí se pudo armonizar (ifelse propaga el NA de la condición).
        p11 <- suppressWarnings(as.integer(df_raw[["P11"]]))
        df_armonizado[["nivel_edu"]] <- ifelse(!is.na(p11) & p11 == 3L, 0L,
                                               df_armonizado[["nivel_edu"]])
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


#' Obtiene datos temporales comparables de la tabla vivienda entre censos
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
#' Variables disponibles para comparación temporal de vivienda:
#' `material_paredes`, `material_techo`, `material_piso`, `fuente_agua`,
#' `energia_electrica`, `servicio_sanitario`, `tenencia_vivienda`,
#' `habitaciones_total`.
#'
#' **Limitaciones conocidas:**
#' - `habitaciones_total` en 2024: variable codificada como categorías ordinales
#'   (1=Una, ..., 8=Ocho o más), no como número absoluto.
#'
#' @export
#' @examples
#' \dontrun{
#' # Evolución del acceso a agua potable
#' agua <- get_temporal_vivienda(
#'   variables = c("fuente_agua", "energia_electrica"),
#'   anios = c(1992, 2001, 2012, 2024)
#' )
#' library(dplyr)
#' agua |> count(anio, fuente_agua) |> group_by(anio) |>
#'   mutate(pct = n / sum(n))
#' }
get_temporal_vivienda <- function(
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

  mapa <- variable_temporal_map[variable_temporal_map$tabla == "vivienda", ]
  vars_invalidas <- setdiff(variables, mapa$variable)
  if (length(vars_invalidas) > 0) {
    cli::cli_abort(c(
      "Variable(s) no encontrada(s) en tabla vivienda: {.val {vars_invalidas}}",
      "i" = "Usa {.fn variables_armonizadas} con {.code tabla = 'vivienda'} para ver las opciones."
    ))
  }

  .warn_no_armonizadas(mapa, variables, verbose)
  # El aviso más importante de esta función: armonizar los códigos no iguala la
  # población a la que se preguntó. Con el universo de cada censo en el codebook,
  # se puede detectar en vez de dejarlo escrito solo en la documentación.
  .avisar_universos(variables, anios)

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

    tryCatch({
      cols_a_pedir <- cols_originales[!is.na(cols_originales)]

      df_raw <- if (a == 2024L) {
        get_viviendas_2024(departamento = departamento, variables = cols_a_pedir,
                           as = "tibble", verbose = verbose)
      } else {
        get_censo(a, "vivienda", departamento = departamento, variables = cols_a_pedir,
                  as = "tibble", verbose = verbose)
      }

      if (is.null(df_raw) || nrow(df_raw) == 0) {
        cli::cli_warn("Sin datos de vivienda para el censo {a}.")
        next
      }

      if (verbose) cli::cli_inform(c("i" = "Armonizando variables de vivienda del censo {a}..."))

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

# Etiquetas de los códigos armonizados que produce get_temporal()/get_temporal_vivienda().
# Fuente única de verdad: debe coincidir con los códigos destino de las funciones
# .harmonize_*() de abajo. Solo incluye variables efectivamente armonizadas (códigos
# comparables entre censos). Las variables passthrough (solo `parentesco`) NO se
# etiquetan porque sus códigos varían entre censos.
.HARMONIZED_VALUE_LABELS <- list(
  # tabla persona
  sexo                = c("1" = "Mujer", "2" = "Hombre"),
  area                = c("1" = "Urbana", "2" = "Rural"),
  estado_civil        = c("1" = "Soltero/a", "2" = "Casado/a o conviviente",
                          "3" = "Separado/a o divorciado/a", "4" = "Viudo/a"),
  pea                 = c("1" = "Ocupado", "2" = "Cesante", "3" = "Aspirante"),
  pet                 = c("1" = "Sí", "2" = "No"),
  sabe_leer           = c("1" = "Sí", "2" = "No"),
  nivel_edu           = c("0" = "Sin instrucción", "1" = "Primaria",
                          "2" = "Secundaria", "3" = "Superior"),
  asistencia_escolar  = c("1" = "Sí asiste", "2" = "No asiste"),
  categoria_ocupacion = c("1" = "Empleado/Obrero", "2" = "Cuenta propia",
                          "3" = "Empleador/Patrón", "4" = "Familiar no remunerado",
                          "5" = "Otro"),
  identidad_indigena  = c("1" = "Sí", "2" = "No"),
  idioma_materno      = c("1" = "Castellano", "2" = "Quechua", "3" = "Aymara",
                          "4" = "Guaraní", "5" = "Otro nativo boliviano",
                          "6" = "Otro idioma (extranjero)"),
  migracion_nac_dpto  = c("1" = "Mismo departamento", "2" = "Otro departamento",
                          "3" = "Exterior", "4" = "No había nacido"),
  migracion_rec_dpto  = c("1" = "Mismo departamento", "2" = "Otro departamento",
                          "3" = "Exterior", "4" = "No había nacido"),
  # tabla vivienda
  material_paredes    = c("1" = "Ladrillo/Bloque/Hormigón", "2" = "Adobe/Tapial",
                          "3" = "Madera/Tabique/Caña/Palma", "4" = "Piedra", "5" = "Otro"),
  material_techo      = c("1" = "Calamina/Plancha/Teja", "2" = "Losa de hormigón",
                          "3" = "Paja/Caña/Palma", "4" = "Otro"),
  material_piso       = c("1" = "Tierra", "2" = "Cemento/Ladrillo",
                          "3" = "Mosaico/Parquet/Madera", "4" = "Otro"),
  fuente_agua         = c("1" = "Cañería/Red pública", "2" = "Otra fuente protegida",
                          "3" = "Fuente no protegida"),
  energia_electrica   = c("1" = "Sí", "2" = "No"),
  servicio_sanitario  = c("1" = "Sí tiene", "2" = "No tiene"),
  tenencia_vivienda   = c("1" = "Propia", "2" = "Alquilada",
                          "3" = "Cedida/Anticrético/Servicios", "4" = "Otra")
)

# Despacha a la función de armonización correcta según variable y año
.harmonize_col <- function(x, variable, anio) {
  if (variable == "sexo")               return(.harmonize_sexo(x, anio))
  if (variable == "estado_civil")       return(.harmonize_estado_civil(x, anio))
  if (variable == "pea")                return(.harmonize_pea(x, anio))
  if (variable == "pet")                return(.harmonize_pet(x, anio))
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
  if (variable == "grupo_edad") {
    # La fuente es la edad individual en años en todos los censos (ver
    # variable_temporal_map: p04/P04/P29/P25/p26_edad), así que el binning
    # quinquenal es idéntico y comparable entre años.
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

# estado_civil → 1=Soltero/a, 2=Casado/a o conviviente,
#   3=Separado/a o divorciado/a, 4=Viudo/a
# Harmonizado al máximo nivel comparable, limitado por 1992 (agrupa casado/conviviente
# y separado/divorciado).
.harmonize_estado_civil <- function(x, anio) {
  x_num <- suppressWarnings(as.integer(x))
  if (anio == 1976L) {
    # p05: 1=Soltero, 2=Casado, 3=Viudo, 4=Divorciado
    dplyr::case_when(
      x_num == 1L ~ 1L, x_num == 2L ~ 2L, x_num == 3L ~ 4L, x_num == 4L ~ 3L,
      TRUE ~ NA_integer_
    )
  } else if (anio == 1992L) {
    # P05: 1=Casado/conviviente, 2=Viudo, 3=Separado/divorciado, 4=Soltero
    dplyr::case_when(
      x_num == 1L ~ 2L, x_num == 2L ~ 4L, x_num == 3L ~ 3L, x_num == 4L ~ 1L,
      TRUE ~ NA_integer_
    )
  } else if (anio %in% c(2001L, 2012L)) {
    # 1=Soltero, 2=Casado, 3=Conviviente, 4=Separado, 5=Divorciado, 6=Viudo
    dplyr::case_when(
      x_num == 1L ~ 1L, x_num %in% c(2L, 3L) ~ 2L,
      x_num %in% c(4L, 5L) ~ 3L, x_num == 6L ~ 4L, TRUE ~ NA_integer_
    )
  } else if (anio == 2024L) {
    # p53_ecivil: 1=Casado, 2=Conviviente, 3=Separado, 4=Divorciado,
    #             5=Viudo, 6=Soltero, 9=Sin especificar
    dplyr::case_when(
      x_num == 6L ~ 1L, x_num %in% c(1L, 2L) ~ 2L,
      x_num %in% c(3L, 4L) ~ 3L, x_num == 5L ~ 4L, TRUE ~ NA_integer_
    )
  } else {
    NA_integer_
  }
}

# pea (condición de actividad de la PEA) → 1=Ocupado, 2=Cesante, 3=Aspirante
# Codificación idéntica en todos los años; inactivos quedan como NA.
.harmonize_pea <- function(x, anio) {
  if (anio == 2001L) return(rep(NA_integer_, length(x)))
  x_num <- suppressWarnings(as.integer(x))
  dplyr::case_when(x_num %in% c(1L, 2L, 3L) ~ x_num, TRUE ~ NA_integer_)
}

# pet (en edad de trabajar) → 1=Sí, 2=No
.harmonize_pet <- function(x, anio) {
  if (anio == 2001L) return(rep(NA_integer_, length(x)))
  x_num <- suppressWarnings(as.integer(x))
  if (anio %in% c(1992L, 2012L)) {
    # NPET/PET: 1=en edad de trabajar, 0=no
    dplyr::case_when(x_num == 1L ~ 1L, x_num == 0L ~ 2L, TRUE ~ NA_integer_)
  } else {
    # 1976 pet: 1=PET, 2=PENT.  2024 pet_13: 1=PET, 2=PENT, 9=no especificó
    dplyr::case_when(x_num == 1L ~ 1L, x_num == 2L ~ 2L, TRUE ~ NA_integer_)
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

    # En todos los censos con flag, el código 1 significa "aquí / mismo lugar":
    #   1992 P07/P08=1 (aquí); 2001/2012 P34A/P32A=1 (mismo municipio);
    #   2024 p35_lugnac/p37_lugres5=1 (este municipio).
    misma_localidad <- flag_num == 1L

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
  if (variable == "habitaciones_total") {
    x_num <- suppressWarnings(as.integer(x))
    return(ifelse(is.na(x_num) | x_num >= 98L, NA_integer_, x_num))
  }
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
    # P11: 1=Red empresa, 2=Motor propio, 3=Panel solar, 4=Otra, 5=No tiene
    dplyr::case_when(
      x_num %in% 1L:4L ~ 1L, x_num == 5L ~ 2L, TRUE ~ NA_integer_
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
    # P09: 1=Privado, 2=Compartido, 3=No tiene
    dplyr::case_when(
      x_num %in% c(1L, 2L) ~ 1L, x_num == 3L ~ 2L, TRUE ~ NA_integer_
    )
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

# ==============================================================================
# Universos divergentes entre censos
# ==============================================================================

# Los DDI del ANDA declaran, para cada censo, a qué población se le hizo cada
# pregunta. Armonizar los códigos no basta: si `sabe_leer` se preguntó a los
# mayores de 5 años en 1976, de 6 en 1992, de 4 en 2001 y de 5 en 2024, comparar
# sus distribuciones sin filtrar por edad produce una serie que mide poblaciones
# distintas en cada punto. Esta función lo detecta a partir del metadato en vez de
# confiar en que el usuario haya leído la viñeta.

# Texto legible de cada universo, para el aviso.
.UNIVERSO_TEXTO <- c(
  todas_personas = "todas las personas",
  personas_4_mas = "personas de 4 años o más",
  personas_5_mas = "personas de 5 años o más",
  personas_6_mas = "personas de 6 años o más",
  personas_7_mas = "personas de 7 años o más",
  personas_12_mas = "personas de 12 años o más",
  personas_15_mas = "personas de 15 años o más",
  personas_19_mas = "personas de 19 años o más",
  mujeres_12_mas = "mujeres de 12 años o más",
  mujeres_15_49 = "mujeres de 15 a 49 años",
  todas_viviendas = "todas las viviendas",
  viviendas_particulares = "viviendas particulares",
  viviendas_presentes = "viviendas con personas presentes",
  hogares = "todos los hogares"
)

# Edad mínima que implica cada universo, para poder sugerir un filtro concreto.
.UNIVERSO_EDAD_MIN <- c(
  personas_4_mas = 4L, personas_5_mas = 5L, personas_6_mas = 6L,
  personas_7_mas = 7L, personas_12_mas = 12L, personas_15_mas = 15L,
  personas_19_mas = 19L, mujeres_12_mas = 12L, mujeres_15_49 = 15L
)

# Universo de una variable armonizada en un censo concreto, según el codebook.
.universo_armonizada <- function(variable, anio) {
  fila <- variable_temporal_map[variable_temporal_map$variable == variable, ]
  if (nrow(fila) == 0) return(NA_character_)
  v <- fila[[paste0("v", anio)]][1]
  if (is.na(v) || !nzchar(v)) return(NA_character_)

  cb <- .get_codebook_for_anio(anio)
  if (is.null(cb) || !"universo" %in% names(cb)) return(NA_character_)
  # En 1976 la tabla de personas se llama `poblacion`.
  tabla <- fila$tabla[1]
  if (anio == 1976L && identical(tabla, "persona")) tabla <- "poblacion"

  j <- which(toupper(cb$variable) == toupper(v) & cb$tabla == tabla)
  if (length(j) == 0) j <- which(toupper(cb$variable) == toupper(v))
  u <- unique(stats::na.omit(cb$universo[j]))
  if (length(u) == 0) NA_character_ else u[1]
}

#' Avisa de las variables cuyo universo cambia entre los censos pedidos
#'
#' @param variables nombres armonizados
#' @param anios censos solicitados
#' @return invisible(TRUE); emite un `cli_warn` por cada variable afectada
.avisar_universos <- function(variables, anios) {
  # Solo interesan los universos que restringen la población: los genéricos
  # ("todas las personas") y los geográficos no indican una diferencia real.
  for (v in variables) {
    us <- vapply(anios, function(a) .universo_armonizada(v, a), character(1))
    names(us) <- anios
    us <- us[!is.na(us) & us %in% names(.UNIVERSO_EDAD_MIN)]
    if (length(unique(us)) < 2) next

    detalle <- sprintf("%s: %s", names(us),
                       ifelse(us %in% names(.UNIVERSO_TEXTO),
                              .UNIVERSO_TEXTO[us], us))
    edad_max <- max(.UNIVERSO_EDAD_MIN[us], na.rm = TRUE)
    cli::cli_warn(c(
      "!" = "{.var {v}} no se preguntó a la misma población en todos los censos:",
      stats::setNames(detalle, rep(" ", length(detalle))),
      "i" = "Compararla sin igualar el universo mide poblaciones distintas en cada año.",
      "i" = "Filtra {.code edad >= {edad_max}} en todos los años antes de comparar."
    ))
  }
  invisible(TRUE)
}

# ==============================================================================
# Puente entre los dos vocabularios temáticos
# ==============================================================================

# `grupos_variables()` agrupa los nombres ARMONIZADOS (6 grupos) y `censo_temas()`
# los temas de las variables CRUDAS de cada censo (21 temas). Son dominios
# distintos, pero obligar a recordar dos vocabularios es una fricción evitable:
# `get_temporal(grupo = )` acepta los dos.
#
# Los seis nombres originales se mantienen como alias permanentes: son API pública
# desde antes de que existiera la taxonomía.
.GRUPO_A_TEMA <- c(
  demografico = "poblacion",
  educacion   = "educacion",
  economia    = "caracteristicas_economicas",
  cultural    = "autoidentificacion",   # + idiomas, ver .TEMA_A_GRUPO
  migracion   = "migracion",
  fertilidad  = "fecundidad"
)

# Slug de tema -> grupo armonizado. `cultural` cubre dos temas del vocabulario
# nuevo, así que ambos apuntan a él.
.TEMA_A_GRUPO <- c(
  poblacion = "demografico",
  educacion = "educacion",
  caracteristicas_economicas = "economia",
  autoidentificacion = "cultural",
  idiomas = "cultural",
  migracion = "migracion",
  fecundidad = "fertilidad"
)

.resolver_grupo <- function(grupo) {
  grupos <- grupos_variables()
  if (grupo %in% names(grupos)) return(grupos[[grupo]])

  # Aceptar también los slugs de censo_temas(), para no tener que recordar cuál
  # de los dos vocabularios usa cada función.
  slug <- tolower(trimws(grupo))
  if (slug %in% names(.TEMA_A_GRUPO)) {
    equivalente <- .TEMA_A_GRUPO[[slug]]
    cli::cli_inform(c(
      "i" = "{.val {slug}} es un tema de {.code censo_temas()}; en datos armonizados equivale al grupo {.val {equivalente}}."
    ))
    return(grupos[[equivalente]])
  }
  cli::cli_abort(c(
    "Grupo no válido: {.val {grupo}}",
    "i" = "Grupos armonizados: {.val {names(grupos)}}",
    "i" = "También se aceptan estos temas de {.code censo_temas()}: {.val {names(.TEMA_A_GRUPO)}}"
  ))
}

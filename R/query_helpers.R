# ===========================================================================
# Resolución de filtros geográficos (departamento / provincia / municipio)
# ===========================================================================
#
# Acepta CÓDIGOS ("03", "01") o NOMBRES ("Cochabamba", "Cercado") en cualquiera
# de los tres niveles, mezclables. Resuelve jerárquicamente contra `geo_bolivia`
# y filtra por la TUPLA completa (idep, iprov, imun), porque:
#   - `imun` NO es único por departamento (se repite por provincia),
#   - hay nombres de municipio repetidos entre departamentos.
# Por eso filtrar columnas de forma independiente sobre-emparejaría.

# Normaliza a código de 2 dígitos los valores numéricos; deja intactos los nombres.
.pad2 <- function(x) {
  x <- as.character(x)
  num <- grepl("^[0-9]+$", x)
  x[num] <- sprintf("%02d", as.integer(x[num]))
  x
}

# Filtra un subconjunto de geo_bolivia por un vector de valores (códigos o
# nombres) de un nivel. Valida existencia y detecta ambigüedad, tanto para
# códigos como para nombres:
#   - entre departamentos (aplica a provincia y municipio),
#   - entre provincias (solo municipio, con `check_prov = TRUE`): el código de
#     municipio se repite por provincia, así que `municipio = "01"` sin fijar la
#     provincia es ambiguo y debe abortar en vez de sobre-emparejar.
.match_geo_level <- function(geo, valores, code_col, name_col, nivel, sugerencia,
                             check_prov = FALSE) {
  valores <- as.character(valores)
  keep <- rep(FALSE, nrow(geo))
  for (v in valores) {
    if (grepl("^[0-9]+$", v)) {
      m <- geo[[code_col]] == sprintf("%02d", as.integer(v))
    } else {
      m <- .norm_nombre(geo[[name_col]]) == .norm_nombre(v)
    }
    if (!any(m)) {
      cli::cli_abort(c(
        "{nivel} no encontrado en el cat\u00e1logo: {.val {v}}",
        "i" = "Acepta c\u00f3digo (p.ej. {.val 01}) o nombre (p.ej. {.val Cochabamba}).",
        "i" = "Consulta los valores v\u00e1lidos con {.code {sugerencia}}."
      ))
    }
    # Ambigüedad entre departamentos (sin `departamento` fijado, el subconjunto
    # `geo` abarca varios; con él, queda uno solo y esta comprobación no dispara).
    deps_match <- unique(geo$idep[m])
    if (length(deps_match) > 1) {
      deps_nom <- unique(geo$nombre_dep[geo$idep %in% deps_match])
      cli::cli_abort(c(
        "El {nivel} {.val {v}} existe en varios departamentos.",
        "i" = "Especifica {.arg departamento} para desambiguar.",
        "i" = "Departamentos con ese {nivel}: {.val {deps_nom}}"
      ))
    }
    # Ambigüedad entre provincias (solo municipio): mismo criterio, un nivel abajo.
    if (check_prov) {
      provs_match <- unique(geo$iprov[m])
      if (length(provs_match) > 1) {
        provs_nom <- unique(geo$nombre_prov[geo$iprov %in% provs_match &
                                              geo$idep %in% deps_match])
        cli::cli_abort(c(
          "El {nivel} {.val {v}} existe en varias provincias (el c\u00f3digo de municipio se repite entre provincias).",
          "i" = "Especifica {.arg provincia} para desambiguar.",
          "i" = "Provincias con ese {nivel}: {.val {provs_nom}}"
        ))
      }
    }
    keep <- keep | m
  }
  geo[keep, , drop = FALSE]
}

# Resuelve los filtros geográficos a códigos de departamento + tuplas de filtrado.
#
# Devuelve una lista:
#   dep_codes: vector de códigos de departamento ("01".."09") implicados por el
#     filtro, o NULL si no se especificó ningún filtro. Sirve para (a) elegir qué
#     archivos descargar en get_personas_2024() y (b) inferir el departamento
#     cuando solo se dio provincia/municipio (evita descargar todo el país).
#   rows: subconjunto de geo_bolivia con columnas idep/iprov/imun para hacer
#     semi_join sobre los microdatos; NULL cuando el filtro llega solo a nivel
#     de departamento (o no hay filtro).
.resolve_geo <- function(departamento = NULL, provincia = NULL, municipio = NULL) {
  geo <- geo_bolivia
  dep_codes <- NULL
  filtrado_sub <- FALSE  # ¿se filtró más allá de departamento?

  if (!is.null(departamento)) {
    dep_codes <- .resolve_dep_codes(departamento)
    geo <- geo[geo$idep %in% dep_codes, , drop = FALSE]
  }
  if (!is.null(provincia)) {
    geo <- .match_geo_level(geo, provincia, "iprov", "nombre_prov",
                            "provincia", "provincias(departamento)")
    filtrado_sub <- TRUE
  }
  if (!is.null(municipio)) {
    geo <- .match_geo_level(geo, municipio, "imun", "nombre_mun",
                            "municipio", "municipios(departamento)",
                            check_prov = is.null(provincia))
    filtrado_sub <- TRUE
  }

  # Inferir departamento(s) cuando no se dio pero sí provincia/municipio.
  if (is.null(dep_codes) && filtrado_sub) {
    dep_codes <- sort(unique(geo$idep))
  }

  list(
    dep_codes = dep_codes,
    rows = if (filtrado_sub) unique(geo[, c("idep", "iprov", "imun")]) else NULL
  )
}

# Aplica un filtro geográfico ya resuelto a un Arrow Dataset.
.apply_geo <- function(ds, geo, filter_dep = TRUE) {
  key <- c("idep", "iprov", "imun")

  # Alinea los tipos de las columnas clave del data.frame de filtro con el
  # esquema del dataset ANTES de filtrar. Algunos Parquet usan `large_utf8`
  # (p.ej. vivienda) y otros `utf8` (persona); sin esto, el semi_join de arrow
  # falla con "Incompatible data types ... large_string vs string".
  keys_tbl <- NULL
  if (!is.null(geo$rows)) {
    sch <- tryCatch(ds$schema, error = function(e) NULL)
    if (!is.null(sch)) {
      tipos <- stats::setNames(
        lapply(key, function(cn) sch$GetFieldByName(cn)$type), key
      )
      keys_tbl <- arrow::arrow_table(geo$rows, schema = do.call(arrow::schema, tipos))
    } else {
      keys_tbl <- geo$rows
    }
  }

  if (filter_dep && !is.null(geo$dep_codes)) {
    dc <- geo$dep_codes
    ds <- dplyr::filter(ds, .data$idep %in% dc)
  }
  if (!is.null(keys_tbl)) {
    ds <- dplyr::semi_join(ds, keys_tbl, by = key)
  }
  ds
}

# Compatibilidad: resuelve y aplica en un paso (para las tablas de un solo archivo
# del CPV-2024: vivienda, emigracion, mortalidad).
.apply_geo_filters <- function(ds, departamento, provincia, municipio) {
  geo <- .resolve_geo(departamento, provincia, municipio)
  .apply_geo(ds, geo)
}

# Avisa, una sola vez por llamada, si alguna variable pedida se preguntó a una parte
# de la población y no a toda.
#
# El paquete ya publicaba el universo en `codebook()`, pero solo lo *avisaba* en
# `get_temporal()`, y ahí únicamente cuando difería entre censos. El caso de riesgo
# quedaba fuera: pedir `nivel_edu` de un solo censo y dividir por el total de filas.
# Le pasó a censos-explorer, que declaraba «personas de 19 años o más» y calculaba
# sobre la población entera: 21,59% donde correspondía 33,38%. Doce puntos. Publicar
# el dato no basta si el momento en que hace falta es otro.
#
# Dos decisiones para que informe sin volverse ruido:
#   - Solo cuando el usuario pide variables EXPLÍCITAMENTE. Con `variables = NULL` se
#     devuelven todas y aún no se sabe qué se va a analizar; avisar de las decenas de
#     variables con universo estrecho sería un muro que se aprende a ignorar.
#   - Respeta `verbose`, como el resto de los mensajes de progreso, así que los
#     consumidores headless no lo ven.
# Es `cli_inform` y no `cli_warn`: no hay nada mal en pedir la variable, y un warning
# en un pipeline limpio invita a envolver la llamada en `suppressWarnings()`, que es
# peor que no avisar.
.avisar_universo_pedido <- function(variables, anio, verbose = TRUE) {
  if (!isTRUE(verbose) || is.null(variables) || !length(variables)) {
    return(invisible(NULL))
  }
  meta <- tryCatch(.get_codebook_for_anio(anio), error = function(e) NULL)
  if (is.null(meta) || !"universo" %in% names(meta)) return(invisible(NULL))

  # Primera coincidencia por variable: una misma variable puede estar en varias
  # tablas, pero su universo es el mismo.
  us <- meta$universo[match(.norm_nombre(variables), .norm_nombre(meta$variable))]
  names(us) <- variables
  # Solo los universos que de verdad restringen. Los genéricos ("todas las
  # personas") y los que no están tabulados no dicen nada útil aquí.
  us <- us[!is.na(us) & us %in% names(.UNIVERSO_EDAD_MIN)]
  if (!length(us)) return(invisible(NULL))

  detalle <- sprintf("%s: %s", names(us),
                     ifelse(us %in% names(.UNIVERSO_TEXTO), .UNIVERSO_TEXTO[us], us))
  cli::cli_inform(c(
    "i" = "{cli::qty(length(us))}No toda la poblaci\u00f3n respondi\u00f3 {?esta variable/estas variables}:",
    stats::setNames(detalle, rep(" ", length(detalle))),
    "i" = "Un porcentaje sobre el total de filas usar\u00eda un denominador mayor que ese universo; filtra por el universo antes de calcularlo.",
    "i" = "El universo de cada variable est\u00e1 en {.code codebook(variable)$universo}."
  ))
  invisible(TRUE)
}

# Selecciona variables preservando siempre las columnas geográficas cuando existen
.apply_variable_selection <- function(ds, variables, anio = NULL, verbose = TRUE) {
  if (is.null(variables)) return(ds)
  if (!is.null(anio)) .avisar_universo_pedido(variables, anio, verbose)
  geo_always <- c("idep", "iprov", "imun", "i00")
  cols <- unique(c(geo_always, variables))
  available <- names(ds)
  # Solo advertir sobre columnas explícitamente solicitadas por el usuario (no geo_always)
  missing_user <- setdiff(variables, available)
  if (length(missing_user) > 0) {
    # Si la columna no está aquí pero sí en otra tabla, decirlo: es el error más
    # probable al usar vars_tema(), porque muchos temas abarcan varias tablas y es
    # fácil pasarle a get_personas_2024() una variable de vivienda.
    otras <- .tablas_de_variables(missing_user)
    cli::cli_warn(c(
      "Columnas no encontradas: {.val {missing_user}}",
      if (length(otras)) c("i" = "{otras}"),
      "i" = "Usa {.code codebook()} para ver las variables disponibles."
    ))
  }
  dplyr::select(ds, dplyr::all_of(intersect(cols, available)))
}

# Mensajes del tipo "v07_aguapro existe en la tabla vivienda; usa
# get_viviendas_2024()", para las columnas que el usuario pidió y no están en la
# tabla consultada pero sí en otra del mismo censo.
.tablas_de_variables <- function(vars) {
  hits <- codebook_meta[tolower(codebook_meta$variable) %in% tolower(vars), ]
  if (nrow(hits) == 0) return(character())
  getter <- c(persona = "get_personas_2024()", vivienda = "get_viviendas_2024()",
              emigracion = "get_emigracion_2024()", mortalidad = "get_mortalidad_2024()",
              unidad = "get_unidades_2024()", ficha = "get_fichas_2024()")
  vapply(split(hits, tolower(hits$variable)), function(h) {
    tablas <- unique(h$tabla)
    fn <- stats::na.omit(unname(getter[tablas]))
    sprintf("%s existe en %s%s", h$variable[1],
            if (length(tablas) == 1) paste("la tabla", tablas) else
              paste("las tablas", paste(tablas, collapse = ", ")),
            if (length(fn) == 1) paste0("; usa ", fn) else "")
  }, character(1), USE.NAMES = FALSE)
}

# ¿La consulta arrow no tiene filas? Se comprueba de forma barata trayendo solo
# la primera fila (no materializa todo el dataset), para poder avisar de un
# filtro geográfico vacío independientemente del formato `as` solicitado.
.ds_is_empty <- function(ds) {
  n <- tryCatch(
    nrow(dplyr::collect(utils::head(ds, 1L))),
    error = function(e) NA_integer_
  )
  isTRUE(n == 0L)
}

# Retorna el dataset en el formato solicitado
.return_as <- function(ds, as, table_name = "datos", verbose = TRUE) {
  switch(as,
    "arrow" = ds,
    "tibble" = {
      if (verbose) cli::cli_inform("Cargando datos a memoria RAM...")
      dplyr::collect(ds)
    },
    "duckdb" = {
      # duckdb y DBI son opcionales: solo hacen falta para este backend, y
      # arrastrarlos como dependencia obligatoria encarecia la instalacion a
      # todo el mundo por una via de salida que no todos usan.
      rlang::check_installed(c("duckdb", "DBI"), reason = "para el backend SQL ({.code as = \"duckdb\"})")
      con <- DBI::dbConnect(duckdb::duckdb(), dbdir = ":memory:")
      # duckdb_register_arrow acepta tanto Datasets como consultas arrow
      # (p.ej. tras un semi_join de filtrado geográfico).
      duckdb::duckdb_register_arrow(con, table_name, ds)
      con
    }
  )
}

## valores_codigos: que completar desde el DDI no haya tocado nada preexistente.
##
## El DDI de 2012 y 2001 trae etiquetas de valor que el de 2024 no tiene, y se
## usaron para rellenar las que estaban vacías. La promesa es que NADA de lo que
## ya venía de open-redatam se sobrescribió, y este fixture es lo que la respalda:
## `fixtures/valores_redatam_v1.csv` es el volcado de los valores_codigos tal como
## estaban antes de que el pipeline tocara el DDI.
##
## El contraste de las que ya tenían códigos vive en
## data-raw/ddi/reporte_valores.md y NO modifica el dato. Ese reporte encontró un
## error real en el metadato del INE: en 2012, P45_ESTADOCIVIL trae las categorías
## de la pregunta de condición de inactividad. Por eso no se sobrescribe nunca.

ORO <- utils::read.csv(
  testthat::test_path("fixtures", "valores_redatam_v1.csv"),
  stringsAsFactors = FALSE, colClasses = "character"
)

test_that("ningún valores_codigos de REDATAM fue alterado", {
  for (anio in unique(ORO$anio)) {
    cb <- codebook_historico_meta[[anio]]
    oro_anio <- ORO[ORO$anio == anio, ]
    for (clave in unique(paste(oro_anio$tabla, oro_anio$variable))) {
      esperado <- oro_anio[paste(oro_anio$tabla, oro_anio$variable) == clave, ]
      i <- which(paste(cb$tabla, cb$variable) == clave)
      expect_length(i, 1)
      actual <- cb$valores_codigos[[i]]
      expect_identical(as.character(actual$codigo), esperado$codigo,
                       info = paste(anio, clave, "- códigos"))
      expect_identical(as.character(actual$etiqueta), esperado$etiqueta,
                       info = paste(anio, clave, "- etiquetas"))
    }
  }
})

test_that("valores_fuente distingue el origen de las etiquetas de valor", {
  for (anio in c("2012", "2001")) {
    cb <- codebook_historico_meta[[anio]]
    expect_identical(setdiff(stats::na.omit(cb$valores_fuente), c("redatam", "ddi")),
                     character(0), info = anio)
    # Toda variable con códigos tiene fuente, y toda fuente tiene códigos.
    tiene_codigos <- vapply(cb$valores_codigos,
                            function(v) !is.null(v) && NROW(v) > 0, logical(1))
    expect_identical(tiene_codigos, !is.na(cb$valores_fuente), info = anio)
  }
})

test_that("las completadas desde el DDI son categóricas y tienen códigos usables", {
  for (anio in c("2012", "2001")) {
    cb <- codebook_historico_meta[[anio]]
    desde_ddi <- which(!is.na(cb$valores_fuente) & cb$valores_fuente == "ddi")
    for (i in desde_ddi) {
      expect_equal(cb$tipo[i], "categorica", info = paste(anio, cb$variable[i]))
      v <- cb$valores_codigos[[i]]
      expect_true(all(c("codigo", "etiqueta") %in% names(v)))
      expect_gte(nrow(v), 2)
      expect_false(anyDuplicated(v$codigo) > 0)
    }
  }
})

test_that("las completadas no estaban en el fixture dorado", {
  # Si una variable aparece como completada desde el DDI pero ya tenía códigos en
  # el fixture, es que se sobrescribió algo.
  for (anio in c("2012", "2001")) {
    cb <- codebook_historico_meta[[anio]]
    desde_ddi <- paste(cb$tabla, cb$variable)[
      !is.na(cb$valores_fuente) & cb$valores_fuente == "ddi"]
    ya_tenia <- paste(ORO$tabla, ORO$variable)[ORO$anio == anio]
    expect_identical(intersect(desde_ddi, ya_tenia), character(0), info = anio)
  }
})

test_that("las categóricas que siguen sin códigos son claves o clasificaciones", {
  # No es un hueco por corregir: son claves geográficas (que resuelve
  # etiquetar_geografia()) y códigos de ocupación o actividad económica, catálogos
  # de cientos de entradas que el ANDA no publica como etiquetas de valor.
  for (anio in c("2012", "2001")) {
    cb <- codebook_historico_meta[[anio]]
    vacio <- vapply(cb$valores_codigos,
                    function(v) is.null(v) || NROW(v) == 0, logical(1))
    pendientes <- cb$variable[vacio & cb$tipo == "categorica"]
    es_clave_o_codigo <- grepl("^(idep|iprov|imun|i0[0-9])$", pendientes, ignore.case = TRUE) |
      grepl("cod$", pendientes, ignore.case = TRUE)
    expect_true(all(es_clave_o_codigo),
                info = paste(anio, "-", paste(pendientes[!es_clave_o_codigo], collapse = ", ")))
  }
})

test_that("etiquetar_valores() aprovecha las etiquetas completadas", {
  # idep en 2001 se completó desde el DDI con los 9 departamentos.
  vals <- codebook_valores("idep", anio = 2001)
  expect_s3_class(vals, "data.frame")
  expect_gte(nrow(vals), 9)
  expect_true(any(grepl("Cochabamba", vals$etiqueta)))

  # Los códigos vienen rellenados a dos dígitos ("01".."09"), igual que en el
  # resto del paquete.
  expect_true(all(c("01", "03") %in% vals$codigo))

  df <- data.frame(idep = c("01", "03"), stringsAsFactors = FALSE)
  etiquetado <- etiquetar_valores(df, columnas = "idep", anio = 2001)
  expect_s3_class(etiquetado$idep, "factor")
  expect_false(anyNA(etiquetado$idep))
  expect_equal(as.character(etiquetado$idep), c("Chuquisaca", "Cochabamba"))
})

test_that("etiquetar_valores() elige la tabla que sí tiene las categorías", {
  # `idep` está en varias tablas del censo 2001 y solo `persona` trae las
  # categorías; antes se cogía la primera fila del codebook y la columna se
  # quedaba sin etiquetar.
  cb <- codebook_historico_meta[["2001"]]
  idx <- which(cb$variable == "idep")
  expect_gt(length(idx), 1)
  con_valores <- vapply(cb$valores_codigos[idx],
                        function(v) !is.null(v) && NROW(v) > 0, logical(1))
  expect_true(any(con_valores) && !all(con_valores))

  df <- data.frame(idep = "07", stringsAsFactors = FALSE)
  expect_equal(as.character(etiquetar_valores(df, columnas = "idep", anio = 2001)$idep),
               "Santa Cruz")
})

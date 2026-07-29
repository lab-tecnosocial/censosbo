test_that("el namespace de sf se carga con censosbo", {
  # sf está en Imports del DESCRIPTION, pero eso NO carga su namespace: hace
  # falta un importFrom en NAMESPACE. Sin él, los métodos S3 de sf no quedan
  # registrados y `geo_municipios[i, ]` cae en `[.data.frame`, que degrada la
  # columna sfc a una lista y rompe mapa_dep()/mapa_mun().
  expect_true("sf" %in% names(getNamespaceImports("censosbo")))
})

test_that("el subsetting de las geometrías incluidas conserva la clase sfc", {
  for (nm in c("geo_departamentos", "geo_municipios")) {
    e <- new.env()
    utils::data(list = nm, package = "censosbo", envir = e)
    x <- get(nm, envir = e)
    gcol <- attr(x, "sf_column")
    expect_s3_class(x[x$idep == "08", ][[gcol]], "sfc")
  }
})

test_that("mapa_dep() y mapa_mun() producen un ggplot que se puede construir", {
  skip_if_not_installed("ggplot2")
  dep <- data.frame(idep = sprintf("%02d", 1:9), valor = as.numeric(1:9))
  expect_no_error(ggplot2::ggplot_build(mapa_dep(dep, "valor")))
  # ggplot2 avisa (vía sf) de que posiciona el texto con st_point_on_surface
  # sobre lon/lat; es informativo y no afecta al resultado.
  expect_no_error(
    suppressWarnings(ggplot2::ggplot_build(mapa_dep(dep, "valor", mostrar_nombres = TRUE)))
  )

  e <- new.env()
  utils::data("geo_bolivia", package = "censosbo", envir = e)
  gb <- get("geo_bolivia", envir = e)
  mun <- gb[gb$idep == "08", c("idep", "iprov", "imun")]
  mun$valor <- seq_len(nrow(mun)) * 1.0
  # Con `departamento` se filtra el sf tras el join: es el camino que fallaba.
  expect_no_error(
    ggplot2::ggplot_build(
      suppressWarnings(mapa_mun(mun, "valor", departamento = "Beni"))
    )
  )
  expect_no_error(
    suppressWarnings(ggplot2::ggplot_build(
      mapa_mun(mun, "valor", departamento = "Beni", mostrar_nombres = TRUE)
    ))
  )
})

test_that("mapa_mun() avisa de los municipios sin geometría", {
  skip_if_not_installed("ggplot2")
  # Un código que no existe en la división actual: es lo que puede pasar al
  # mapear censos anteriores a 2012.
  datos <- data.frame(idep = c("03", "03"), iprov = c("99", "01"),
                      imun = c("99", "01"), valor = c(1, 2))
  expect_warning(mapa_mun(datos, "valor", departamento = "03"), "no tienen geometr")
})

test_that("geo_municipios cubre los 343 municipios del CPV-2024", {
  e <- new.env()
  utils::data("geo_municipios", package = "censosbo", envir = e)
  utils::data("geo_bolivia",    package = "censosbo", envir = e)
  gm <- get("geo_municipios", envir = e)
  gb <- get("geo_bolivia",    envir = e)

  expect_equal(nrow(gm), 343L)
  expect_setequal(paste0(gm$idep, gm$iprov, gm$imun),
                  paste0(gb$idep, gb$iprov, gb$imun))
  expect_false(any(is.na(gm$nombre_mun)))
  expect_false(any(is.na(gm$superficie_km2)))
})

test_that("los cuatro GAIOC creados desde 2016 se dibujan", {
  skip_if_not_installed("ggplot2")
  # Raqaypampa, San Pedro de Macha, Jatun Ayllu Yura y el TIM faltaban en la
  # cartografía electoral que se usaba antes.
  datos <- data.frame(
    idep  = c("03", "05", "05", "08"),
    iprov = c("13", "04", "12", "09"),
    imun  = c("04", "05", "04", "01"),
    valor = 1:4 * 1.0
  )
  p <- mapa_mun(datos, "valor")
  expect_equal(sum(!is.na(p$data$valor)), 4L)
  expect_no_warning(mapa_mun(datos, "valor"))
})

test_that("mapa_dep() y mapa_mun() aceptan códigos geográficos numéricos", {
  skip_if_not_installed("ggplot2")
  # Sin normalizar a 2 dígitos, un idep entero no emparejaba con "01".."09" y el
  # mapa salía entero en gris, sin ningún aviso.
  dep <- data.frame(idep = 1:9, valor = as.numeric(1:9))
  p <- mapa_dep(dep, "valor")
  expect_false(any(is.na(p$data$valor)))

  mun <- data.frame(idep = 8L, iprov = 1L, imun = 1L, valor = 3)
  pm <- suppressWarnings(mapa_mun(mun, "valor", departamento = "Beni"))
  expect_equal(sum(!is.na(pm$data$valor)), 1L)
})

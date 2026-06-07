## Genera geo_departamentos.rda y geo_municipios.rda
## Requiere: sf, usethis (solo para mantenedor)
## Ejecutar desde la raíz del paquete:
##   source("data-raw/build_geo_layers.R")
## O bien: Rscript data-raw/build_geo_layers.R

library(sf)
library(censosbo)  # para acceder a geo_bolivia

# ── 1. DEPARTAMENTOS ─────────────────────────────────────────────────────────

dep_raw <- sf::st_read(
  "original-data/geo/departamentos_electorales.geojson",
  quiet = TRUE
)

# Decodificar ADM1_PCODE: "BO08" → idep = "08"
geo_departamentos <- dep_raw[, c("NombreDepartamento", "ADM1_PCODE", "geometry")]
geo_departamentos$idep       <- sprintf("%02d", as.integer(substr(dep_raw$ADM1_PCODE, 3, 4)))
geo_departamentos$nombre_dep <- as.character(dep_raw$NombreDepartamento)
geo_departamentos <- geo_departamentos[, c("idep", "nombre_dep", "geometry")]
geo_departamentos <- geo_departamentos[order(geo_departamentos$idep), ]
row.names(geo_departamentos) <- NULL

stopifnot(nrow(geo_departamentos) == 9)
stopifnot(!any(is.na(geo_departamentos$idep)))
message("Departamentos: ", nrow(geo_departamentos), " (OK)")

# ── 2. MUNICIPIOS ─────────────────────────────────────────────────────────────

mun_raw <- sf::st_read(
  "original-data/geo/municipios_electorales.geojson",
  quiet = TRUE
)

# Decodificar ADM3_PCODE: "BO051302" → idep="05", iprov="13", imun="02"
code6 <- substr(mun_raw$ADM3_PCODE, 3, 8)
mun_sf <- mun_raw[, "geometry", drop = FALSE]
mun_sf$idep  <- substr(code6, 1, 2)
mun_sf$iprov <- substr(code6, 3, 4)
mun_sf$imun  <- substr(code6, 5, 6)

# Unir con geo_bolivia para agregar nombres canónicos (fuente INE-Redatam)
geo_municipios <- merge(
  mun_sf,
  geo_bolivia[, c("idep", "nombre_dep", "iprov", "nombre_prov", "imun", "nombre_mun")],
  by = c("idep", "iprov", "imun"),
  all.x = TRUE  # conservar los 336 del GeoJSON aunque no estén en geo_bolivia
)
geo_municipios <- geo_municipios[, c("idep", "nombre_dep", "iprov", "nombre_prov",
                                      "imun", "nombre_mun", "geometry")]
geo_municipios <- geo_municipios[order(geo_municipios$idep,
                                       geo_municipios$iprov,
                                       geo_municipios$imun), ]
row.names(geo_municipios) <- NULL

message("Municipios en GeoJSON: ", nrow(geo_municipios))

# Reportar los municipios de geo_bolivia sin geometría disponible
geo_keys <- paste(geo_municipios$idep, geo_municipios$iprov, geo_municipios$imun)
bol_keys <- paste(geo_bolivia$idep,    geo_bolivia$iprov,    geo_bolivia$imun)
sin_geo  <- geo_bolivia[!bol_keys %in% geo_keys, c("idep", "nombre_dep", "iprov", "imun", "nombre_mun")]
message("Municipios de geo_bolivia SIN geometría (", nrow(sin_geo), "):")
print(sin_geo)

# ── 3. GUARDAR ────────────────────────────────────────────────────────────────

usethis::use_data(geo_departamentos, overwrite = TRUE)
usethis::use_data(geo_municipios,    overwrite = TRUE)
message("\nGuardado geo_departamentos y geo_municipios en data/")

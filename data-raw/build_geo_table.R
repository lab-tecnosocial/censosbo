## Genera geo_bolivia.rda a partir del diccionario Redatam (CEN24.dicX).
## Requiere: xml2, usethis

library(xml2)

# Ruta a las fuentes del INE (disco externo, montado solo a demanda).
source("data-raw/_rutas.R")

dicx_path <- od("fuentes/cpv-2024/CEN24.dicX")
stopifnot(file.exists(dicx_path))

doc <- xml2::read_xml(dicx_path)

# Función para extraer value+label de valueLabels dado un xpath
extract_vl <- function(doc, xpath_parent) {
  elements <- xml2::xml_find_all(doc, paste0(xpath_parent, "/valueLabels/valueLabelElement"))
  if (length(elements) == 0) return(NULL)
  data.frame(
    value = xml2::xml_text(xml2::xml_find_first(elements, "value")),
    label = xml2::xml_text(xml2::xml_find_first(elements, "label")),
    stringsAsFactors = FALSE
  )
}

# 1. Departamentos (IDEP en entidad DEPTO)
deptos_raw <- extract_vl(doc, ".//entity[name='DEPTO']/variable[name='IDEP']")
stopifnot(!is.null(deptos_raw), nrow(deptos_raw) == 9)
deptos <- data.frame(
  idep       = sprintf("%02d", as.integer(deptos_raw$value)),
  nombre_dep = deptos_raw$label,
  stringsAsFactors = FALSE
)
message("Departamentos: ", nrow(deptos))

# 2. Provincias (REDCODEN en entidad PROVIN)
# REDCODEN de 3 dígitos: idep(1) + iprov_local(2)
# Ej: 217 → dept 2, prov 17 → idep="02", iprov="17"
provs_raw <- extract_vl(doc, ".//entity[name='DEPTO']/entity[name='PROVIN']/variable[name='REDCODEN']")
stopifnot(!is.null(provs_raw))
provs_raw$rc <- as.integer(provs_raw$value)
provs <- data.frame(
  idep        = sprintf("%02d", provs_raw$rc %/% 100),
  iprov       = sprintf("%02d", provs_raw$rc %%  100),
  nombre_prov = provs_raw$label,
  stringsAsFactors = FALSE
)
message("Provincias: ", nrow(provs))

# 3. Municipios (REDCODEN en entidad MUNIC)
# REDCODEN de 5 dígitos: idep(1) + iprov_local(2) + imun_local(2)
# Ej: 21701 → dept 2, prov 17, mun 01 → idep="02", iprov="17", imun="01"
muns_raw <- extract_vl(
  doc,
  ".//entity[name='DEPTO']/entity[name='PROVIN']/entity[name='MUNIC']/variable[name='REDCODEN']"
)
stopifnot(!is.null(muns_raw))
muns_raw$rc <- as.integer(muns_raw$value)
muns <- data.frame(
  idep       = sprintf("%02d", muns_raw$rc %/% 10000),
  iprov      = sprintf("%02d", (muns_raw$rc %% 10000) %/% 100),
  imun       = sprintf("%02d", muns_raw$rc %% 100),
  nombre_mun = muns_raw$label,
  stringsAsFactors = FALSE
)
message("Municipios: ", nrow(muns))

# 4. Ensamblar tabla completa
geo_bolivia <- merge(muns, provs,  by = c("idep", "iprov"), all.x = TRUE)
geo_bolivia <- merge(geo_bolivia, deptos, by = "idep", all.x = TRUE)
geo_bolivia <- geo_bolivia[, c("idep", "nombre_dep", "iprov", "nombre_prov", "imun", "nombre_mun")]
geo_bolivia <- geo_bolivia[order(geo_bolivia$idep, geo_bolivia$iprov, geo_bolivia$imun), ]
rownames(geo_bolivia) <- NULL

message("\nVerificación:")
message("  Municipios totales: ", nrow(geo_bolivia))
message("  Departamentos únicos: ", length(unique(geo_bolivia$idep)))
message("  Provincias únicas: ", length(unique(paste0(geo_bolivia$idep, geo_bolivia$iprov))))
message("  NA en nombre_dep: ", sum(is.na(geo_bolivia$nombre_dep)))
message("  NA en nombre_prov: ", sum(is.na(geo_bolivia$nombre_prov)))
message("  NA en nombre_mun: ", sum(is.na(geo_bolivia$nombre_mun)))

print(head(geo_bolivia, 10))

usethis::use_data(geo_bolivia, overwrite = TRUE)
message("geo_bolivia guardado en data/geo_bolivia.rda")

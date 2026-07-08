## Definición de las variables DERIVADAS del CPV-2024: columnas que existen en
## los microdatos pero que el Excel del INE no lista como variables propias.
## Compartido por build_codebook.R (rebuild completo) y add_derived_vars.R
## (patch sobre el .rda vigente). Idempotente.

.add_derived_codebook_vars <- function(cb) {
  # `area` (persona) replica los códigos de `urbrur` (vivienda): 1=Urbana, 2=Rural.
  if (!any(cb$variable == "area" & cb$tabla == "persona")) {
    area_row <- data.frame(
      variable = "area",
      etiqueta = "Área Urbana - Rural",
      tabla    = "persona",
      tipo     = "categorica",
      stringsAsFactors = FALSE
    )
    area_row$valores_codigos <- list(
      data.frame(codigo = c("1", "2"),
                 etiqueta = c("Urbana", "Rural"),
                 stringsAsFactors = FALSE)
    )
    area_row <- area_row[, names(cb)]
    cb <- rbind(cb, area_row)
    rownames(cb) <- NULL
  }
  cb
}

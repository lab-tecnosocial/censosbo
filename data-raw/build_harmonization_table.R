## Genera variable_longitudinal_map.rda: mapeo de variables armonizadas
## entre censos de Bolivia (1976, 1992, 2001, 2012, 2024).
## Ejecutar desde la raíz del paquete: source("data-raw/build_harmonization_table.R")

variable_longitudinal_map <- data.frame(
  variable       = character(),
  etiqueta       = character(),
  descripcion    = character(),
  v1976          = character(),
  v1992          = character(),
  v2001          = character(),
  v2012          = character(),
  v2024          = character(),
  notas          = character(),
  stringsAsFactors = FALSE
)

add_var <- function(variable, etiqueta, descripcion,
                     v1976 = NA, v1992 = NA, v2001 = NA, v2012 = NA, v2024 = NA,
                     notas = "") {
  variable_longitudinal_map <<- rbind(variable_longitudinal_map, data.frame(
    variable, etiqueta, descripcion,
    v1976 = as.character(v1976),
    v1992 = as.character(v1992),
    v2001 = as.character(v2001),
    v2012 = as.character(v2012),
    v2024 = as.character(v2024),
    notas,
    stringsAsFactors = FALSE
  ))
}

# --- Demografía básica ---
add_var("sexo", "Sexo",
        "Sexo del individuo",
        v1976 = "p03", v1992 = "P03", v2001 = "P28", v2012 = "P24", v2024 = "p25_sexo",
        notas = "Valores no uniformes: verificar codebook por año (en 2012: 1=Mujer, 2=Hombre; en 2024: 1=Mujer, 2=Hombre)")

add_var("edad", "Edad en años",
        "Edad del individuo en años cumplidos",
        v1976 = "p04", v1992 = "P04", v2001 = "P29", v2012 = NA, v2024 = "p26_edad",
        notas = "NO disponible en la tabla de persona del censo 2012 (dataset procesado sin esa variable)")

add_var("grupo_edad", "Grupos de edad quinquenales",
        "Grupo de edad en intervalos de 5 años (0-4, 5-9, ..., 80+)",
        v1976 = "edad5", v1992 = "GEDAD", v2001 = NA, v2012 = NA, v2024 = NA,
        notas = "Para 2001 calcular desde P29: floor(P29/5)*5. No disponible en 2012. Para 2024 calcular desde p26_edad")

add_var("parentesco", "Relación con el/la jefe/a del hogar",
        "Parentesco o relación del individuo con el jefe o jefa del hogar",
        v1976 = "p02", v1992 = "P02", v2001 = "P31", v2012 = "P23", v2024 = "p24_parentes",
        notas = "Códigos varían entre censos: consultar codebook_ANIO() por año")

add_var("estado_civil", "Estado conyugal o civil",
        "Situación conyugal del individuo",
        v1976 = "p05", v1992 = "P05", v2001 = "P48", v2012 = "P45", v2024 = "p53_ecivil",
        notas = "Categorías similares entre censos; verificar codebook para equivalencias exactas")

# --- Educación ---
add_var("sabe_leer", "Sabe leer y escribir",
        "Indica si el individuo sabe leer y escribir",
        v1976 = "p10", v1992 = "P10", v2001 = "P36", v2012 = "P35", v2024 = "p40_lee",
        notas = "Variable dicotómica en todos los censos (1=Sí, 2=No en la mayoría)")

add_var("nivel_edu", "Nivel de instrucción",
        "Nivel educativo más alto alcanzado. Para comparación longitudinal se harmoniza a 4 categorías: 0=Sin instrucción, 1=Primaria, 2=Secundaria, 3=Superior",
        v1976 = "p14", v1992 = "P12", v2001 = "P39NIV", v2012 = "P37A_NIVELNUE", v2024 = "nivel_edu",
        notas = "La Ley Avelino Siñani (2010) cambió la nomenclatura en 2012. harmonizar en .harmonize_nivel_edu() aplica 4 categorías comparables")

# --- Actividad económica ---
add_var("pea", "Población Económicamente Activa",
        "Indicador: si el individuo pertenece a la PEA",
        v1976 = "pea", v1992 = "NPEA", v2001 = NA, v2012 = "PEA", v2024 = "fft_19",
        notas = "NO disponible directamente en 2001 (requiere cálculo desde variables de actividad). En 2024: fft_19 codifica PEA")

add_var("pet", "Población en Edad de Trabajar",
        "Indicador: si el individuo está en edad de trabajar",
        v1976 = "pet", v1992 = "NPET", v2001 = NA, v2012 = "PET", v2024 = "ft_19",
        notas = "NO disponible directamente en 2001. Edad mínima puede variar entre censos")

# --- Geografía y área ---
add_var("area", "Área urbana o rural",
        "Área de residencia: 1=Urbano, 2=Rural",
        v1976 = "area", v1992 = "URBRUR", v2001 = NA, v2012 = "URBRUR", v2024 = NA,
        notas = "Para 1992 y 2012 está en la tabla VIVIENDA, no en PERSONA. NO disponible en 2001 ni 2024 (en 2024 está en vivienda). get_longitudinal() la incluye como NA con advertencia")

add_var("departamento", "Departamento",
        "Código de departamento (01-09)",
        v1976 = "dep", v1992 = "idep", v2001 = "idep", v2012 = "idep", v2024 = "idep",
        notas = "En 1976: columna 'dep' (numérica 1-9). En censos REDATAM: 'idep' disponible solo con filtro geográfico aplicado en get_censo()")

usethis::use_data(variable_longitudinal_map, overwrite = TRUE)
message("variable_longitudinal_map guardado en data/variable_longitudinal_map.rda")
message("\nVariables armonizadas (", nrow(variable_longitudinal_map), " total):")
print(variable_longitudinal_map[, c("variable", "etiqueta", "v1976", "v1992", "v2001", "v2012", "v2024")])

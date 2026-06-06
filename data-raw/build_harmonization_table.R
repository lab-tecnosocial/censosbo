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
        "Sexo del individuo. Harmonizado a 1=Mujer, 2=Hombre para todos los censos",
        v1976 = "p03", v1992 = "P03", v2001 = "P28", v2012 = "P24", v2024 = "p25_sexo",
        notas = "1976/1992/2001: codificación original 1=Hombre, 2=Mujer (invertida). 2012/2024: 1=Mujer, 2=Hombre. get_longitudinal() harmoniza todo a 1=Mujer, 2=Hombre.")

add_var("edad", "Edad en años",
        "Edad del individuo en años cumplidos",
        v1976 = "p04", v1992 = "P04", v2001 = "P29", v2012 = "P25", v2024 = "p26_edad",
        notas = "2001: P29 re-exportado con .dicx corregido (bug fieldsize exportaba 3 bits en vez de 7). 2012: P25 re-exportado desde .dicx (el .dic binario no la exportaba).")

add_var("grupo_edad", "Grupos de edad quinquenales",
        "Grupo de edad en intervalos de 5 años (0-4, 5-9, ..., 80+)",
        v1976 = "edad5", v1992 = "GEDAD", v2001 = "P29", v2012 = "P25", v2024 = NA,
        notas = "Para 2001, 2012 y 2024 se calcula automáticamente desde la edad individual.")

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
        "Indica si el individuo sabe leer y escribir. Harmonizado a 1=Sí, 2=No",
        v1976 = "p10", v1992 = "P10", v2001 = "P36", v2012 = "P35", v2024 = "p40_lee",
        notas = "1992 (P10): códigos 7=Sí, 8=No (distinto al resto). get_longitudinal() harmoniza a 1=Sí, 2=No.")

add_var("nivel_edu", "Nivel de instrucción",
        "Nivel educativo más alto alcanzado. Para comparación longitudinal se harmoniza a 4 categorías: 0=Sin instrucción, 1=Primaria, 2=Secundaria, 3=Superior",
        v1976 = "nivela", v1992 = "P12", v2001 = "P39NIV", v2012 = "P37A_NIVELNUE", v2024 = "nivel_edu",
        notas = "1976: 'nivela' es var. derivada (1=Ninguno..5=Técnico). 1992: P12 solo cubre quienes asistieron; Ninguno se obtiene combinando con P11 en get_longitudinal(). 2001: P39NIV con códigos reales 11=Ninguno,12=Preescolar,13=Básico,14=Intermedio,15=Medio,16=Primaria,17=Secundaria,18=Licenciatura,19=Técnico,20=Normal,21-23=Otros. 2012: P37A_NIVELNUE usa códigos no secuenciales (1,2,3,9,10,11-18,99). La Ley Avelino Siñani (2010) cambió la nomenclatura en 2012.")

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
        "Área de residencia: 1=Urbana, 2=Rural. Columna directa en todas las tablas de persona.",
        v1976 = "area", v1992 = "area", v2001 = "area", v2012 = "area", v2024 = "area",
        notas = "Columna 'area' presente en todos los parquets de persona. 1976: fuente SPSS directa. 1992/2012: derivada de URBRUR de vivienda (pre-unida). 2001: derivada de TURUR de vivienda (pre-unida). 2024: derivada de urbrur de vivienda (pre-unida). Siempre 1=Urbana, 2=Rural, sin NAs.")

add_var("departamento", "Departamento",
        "Código de departamento (01-09)",
        v1976 = "dep", v1992 = "idep", v2001 = "idep", v2012 = "idep", v2024 = "idep",
        notas = "En 1976: columna 'dep' (numérica 1-9). En censos REDATAM: 'idep' se calcula desde REDCODEN via join con munic.parquet; get_longitudinal() lo fuerza automáticamente.")

usethis::use_data(variable_longitudinal_map, overwrite = TRUE)
message("variable_longitudinal_map guardado en data/variable_longitudinal_map.rda")
message("\nVariables armonizadas (", nrow(variable_longitudinal_map), " total):")
print(variable_longitudinal_map[, c("variable", "etiqueta", "v1976", "v1992", "v2001", "v2012", "v2024")])

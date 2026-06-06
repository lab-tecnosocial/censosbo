# Muestra el mapeo de variables comparables entre censos de Bolivia

Retorna la tabla de variables armonizadas que pueden usarse en análisis
longitudinales o comparativos entre los censos de 1976, 1992, 2001, 2012
y el CPV-2024.

## Usage

``` r
variables_armonizadas()
```

## Value

Un data.frame con las variables armonizadas y sus equivalentes en cada
año de censo.

## Examples

``` r
variables_armonizadas()
#>        variable                            etiqueta
#> 1          sexo                                Sexo
#> 2          edad                        Edad en años
#> 3    grupo_edad         Grupos de edad quinquenales
#> 4    parentesco Relación con el/la jefe/a del hogar
#> 5  estado_civil             Estado conyugal o civil
#> 6     sabe_leer                Sabe leer y escribir
#> 7     nivel_edu                Nivel de instrucción
#> 8           pea     Población Económicamente Activa
#> 9           pet       Población en Edad de Trabajar
#> 10         area                 Área urbana o rural
#> 11 departamento                        Departamento
#>                                                                                                                                               descripcion
#> 1                                                                               Sexo del individuo. Harmonizado a 1=Mujer, 2=Hombre para todos los censos
#> 2                                                                                                                    Edad del individuo en años cumplidos
#> 3                                                                                              Grupo de edad en intervalos de 5 años (0-4, 5-9, ..., 80+)
#> 4                                                                                        Parentesco o relación del individuo con el jefe o jefa del hogar
#> 5                                                                                                                        Situación conyugal del individuo
#> 6                                                                                   Indica si el individuo sabe leer y escribir. Harmonizado a 1=Sí, 2=No
#> 7  Nivel educativo más alto alcanzado. Para comparación longitudinal se harmoniza a 4 categorías: 0=Sin instrucción, 1=Primaria, 2=Secundaria, 3=Superior
#> 8                                                                                                           Indicador: si el individuo pertenece a la PEA
#> 9                                                                                                     Indicador: si el individuo está en edad de trabajar
#> 10                                                                                                                  Área de residencia: 1=Urbana, 2=Rural
#> 11                                                                                                                         Código de departamento (01-09)
#>     v1976 v1992  v2001         v2012        v2024
#> 1     p03   P03    P28           P24     p25_sexo
#> 2     p04   P04    P29           P25     p26_edad
#> 3   edad5 GEDAD    P29           P25         <NA>
#> 4     p02   P02    P31           P23 p24_parentes
#> 5     p05   P05    P48           P45   p53_ecivil
#> 6     p10   P10    P36           P35      p40_lee
#> 7  nivela   P12 P39NIV P37A_NIVELNUE    nivel_edu
#> 8     pea  NPEA   <NA>           PEA       fft_19
#> 9     pet  NPET   <NA>           PET        ft_19
#> 10   area  <NA>   <NA>          <NA>         <NA>
#> 11    dep  idep   idep          idep         idep
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                      notas
#> 1                                                                                                                                                                                                                                                                                                                1976/1992/2001: codificación original 1=Hombre, 2=Mujer (invertida). 2012/2024: 1=Mujer, 2=Hombre. get_longitudinal() harmoniza todo a 1=Mujer, 2=Hombre.
#> 2                                                                                                                                                                                                                                                                                                           2001: P29 re-exportado con .dicx corregido (bug fieldsize exportaba 3 bits en vez de 7). 2012: P25 re-exportado desde .dicx (el .dic binario no la exportaba).
#> 3                                                                                                                                                                                                                                                                                                                                                                                              Para 2001, 2012 y 2024 se calcula automáticamente desde la edad individual.
#> 4                                                                                                                                                                                                                                                                                                                                                                                                           Códigos varían entre censos: consultar codebook_ANIO() por año
#> 5                                                                                                                                                                                                                                                                                                                                                                                         Categorías similares entre censos; verificar codebook para equivalencias exactas
#> 6                                                                                                                                                                                                                                                                                                                                                                           1992 (P10): códigos 7=Sí, 8=No (distinto al resto). get_longitudinal() harmoniza a 1=Sí, 2=No.
#> 7  1976: 'nivela' es var. derivada (1=Ninguno..5=Técnico). 1992: P12 solo cubre quienes asistieron; Ninguno se obtiene combinando con P11 en get_longitudinal(). 2001: P39NIV con códigos reales 11=Ninguno,12=Preescolar,13=Básico,14=Intermedio,15=Medio,16=Primaria,17=Secundaria,18=Licenciatura,19=Técnico,20=Normal,21-23=Otros. 2012: P37A_NIVELNUE usa códigos no secuenciales (1,2,3,9,10,11-18,99). La Ley Avelino Siñani (2010) cambió la nomenclatura en 2012.
#> 8                                                                                                                                                                                                                                                                                                                                                         NO disponible directamente en 2001 (requiere cálculo desde variables de actividad). En 2024: fft_19 codifica PEA
#> 9                                                                                                                                                                                                                                                                                                                                                                                                NO disponible directamente en 2001. Edad mínima puede variar entre censos
#> 10                                                                                                                                                                                                                                                          1976: columna 'area' en tabla poblacion (1=Urbana, 2=Rural). 1992/2001/2012: join automático con vivienda; URBRUR/TURUR usan 1=Urbana, 2=Rural. 2024: en tabla vivienda, no disponible via get_longitudinal().
#> 11                                                                                                                                                                                                                                                                                                    En 1976: columna 'dep' (numérica 1-9). En censos REDATAM: 'idep' se calcula desde REDCODEN via join con munic.parquet; get_longitudinal() lo fuerza automáticamente.
```

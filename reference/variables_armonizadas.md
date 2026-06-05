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
#> 1                                                                                                                                      Sexo del individuo
#> 2                                                                                                                    Edad del individuo en años cumplidos
#> 3                                                                                              Grupo de edad en intervalos de 5 años (0-4, 5-9, ..., 80+)
#> 4                                                                                        Parentesco o relación del individuo con el jefe o jefa del hogar
#> 5                                                                                                                        Situación conyugal del individuo
#> 6                                                                                                             Indica si el individuo sabe leer y escribir
#> 7  Nivel educativo más alto alcanzado. Para comparación longitudinal se harmoniza a 4 categorías: 0=Sin instrucción, 1=Primaria, 2=Secundaria, 3=Superior
#> 8                                                                                                           Indicador: si el individuo pertenece a la PEA
#> 9                                                                                                     Indicador: si el individuo está en edad de trabajar
#> 10                                                                                                                  Área de residencia: 1=Urbano, 2=Rural
#> 11                                                                                                                         Código de departamento (01-09)
#>    v1976  v1992  v2001         v2012        v2024
#> 1    p03    P03    P28           P24     p25_sexo
#> 2    p04    P04    P29          <NA>     p26_edad
#> 3  edad5  GEDAD   <NA>          <NA>         <NA>
#> 4    p02    P02    P31           P23 p24_parentes
#> 5    p05    P05    P48           P45   p53_ecivil
#> 6    p10    P10    P36           P35      p40_lee
#> 7    p14    P12 P39NIV P37A_NIVELNUE    nivel_edu
#> 8    pea   NPEA   <NA>           PEA       fft_19
#> 9    pet   NPET   <NA>           PET        ft_19
#> 10  area URBRUR   <NA>        URBRUR         <NA>
#> 11   dep   idep   idep          idep         idep
#>                                                                                                                                                                         notas
#> 1                                                                   Valores no uniformes: verificar codebook por año (en 2012: 1=Mujer, 2=Hombre; en 2024: 1=Mujer, 2=Hombre)
#> 2                                                                                    NO disponible en la tabla de persona del censo 2012 (dataset procesado sin esa variable)
#> 3                                                                      Para 2001 calcular desde P29: floor(P29/5)*5. No disponible en 2012. Para 2024 calcular desde p26_edad
#> 4                                                                                                              Códigos varían entre censos: consultar codebook_ANIO() por año
#> 5                                                                                            Categorías similares entre censos; verificar codebook para equivalencias exactas
#> 6                                                                                                          Variable dicotómica en todos los censos (1=Sí, 2=No en la mayoría)
#> 7                                           La Ley Avelino Siñani (2010) cambió la nomenclatura en 2012. harmonizar en .harmonize_nivel_edu() aplica 4 categorías comparables
#> 8                                                            NO disponible directamente en 2001 (requiere cálculo desde variables de actividad). En 2024: fft_19 codifica PEA
#> 9                                                                                                   NO disponible directamente en 2001. Edad mínima puede variar entre censos
#> 10 Para 1992 y 2012 está en la tabla VIVIENDA, no en PERSONA. NO disponible en 2001 ni 2024 (en 2024 está en vivienda). get_longitudinal() la incluye como NA con advertencia
#> 11                                             En 1976: columna 'dep' (numérica 1-9). En censos REDATAM: 'idep' disponible solo con filtro geográfico aplicado en get_censo()
```

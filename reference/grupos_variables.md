# Grupos temáticos predefinidos de variables armonizadas

Devuelve la lista de grupos temáticos disponibles y las variables que
contiene cada uno, para usar con el parámetro \`grupo\` de
\[get_temporal()\].

## Usage

``` r
grupos_variables()
```

## Value

Una lista nombrada donde cada elemento es un vector de nombres de
variables armonizadas.

## Examples

``` r
grupos_variables()
#> $demografico
#> [1] "sexo"         "edad"         "grupo_edad"   "parentesco"   "estado_civil"
#> 
#> $educacion
#> [1] "sexo"               "edad"               "sabe_leer"         
#> [4] "nivel_edu"          "asistencia_escolar"
#> 
#> $economia
#> [1] "sexo"                "edad"                "pea"                
#> [4] "pet"                 "categoria_ocupacion"
#> 
#> $cultural
#> [1] "sexo"               "edad"               "identidad_indigena"
#> [4] "idioma_materno"    
#> 
#> $migracion
#> [1] "sexo"               "edad"               "migracion_nac_dpto"
#> [4] "migracion_rec_dpto"
#> 
#> $fertilidad
#> [1] "sexo"                 "edad"                 "hijos_nacidos_vivos" 
#> [4] "hijos_sobrevivientes"
#> 
grupos_variables()$educacion
#> [1] "sexo"               "edad"               "sabe_leer"         
#> [4] "nivel_edu"          "asistencia_escolar"
```

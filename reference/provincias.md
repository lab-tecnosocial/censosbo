# Lista las provincias de un departamento

Lista las provincias de un departamento

## Usage

``` r
provincias(departamento)
```

## Arguments

- departamento:

  Código (e.g., \`"07"\`) o nombre (e.g., \`"Santa Cruz"\`) del
  departamento. Acepta vectores.

## Value

Un \[tibble\]\[dplyr::tibble\] con columnas \`idep\`, \`nombre_dep\`,
\`iprov\`, \`nombre_prov\`.

## Examples

``` r
provincias("Santa Cruz")
#> # A tibble: 15 × 4
#>    idep  nombre_dep iprov nombre_prov           
#>    <chr> <chr>      <chr> <chr>                 
#>  1 07    Santa Cruz 01    Andrés Ibáñez         
#>  2 07    Santa Cruz 02    Warnes                
#>  3 07    Santa Cruz 03    Velasco               
#>  4 07    Santa Cruz 04    Ichilo                
#>  5 07    Santa Cruz 05    Chiquitos             
#>  6 07    Santa Cruz 06    Sara                  
#>  7 07    Santa Cruz 07    Cordillera            
#>  8 07    Santa Cruz 08    Valle Grande          
#>  9 07    Santa Cruz 09    Florida               
#> 10 07    Santa Cruz 10    Obispo Santisteban    
#> 11 07    Santa Cruz 11    Ñuflo de Chávez       
#> 12 07    Santa Cruz 12    Ángel Sandoval        
#> 13 07    Santa Cruz 13    Manuel María Caballero
#> 14 07    Santa Cruz 14    Germán Busch          
#> 15 07    Santa Cruz 15    Guarayos              
provincias("02")
#> # A tibble: 20 × 4
#>    idep  nombre_dep iprov nombre_prov              
#>    <chr> <chr>      <chr> <chr>                    
#>  1 02    La Paz     01    Murillo                  
#>  2 02    La Paz     02    Omasuyos                 
#>  3 02    La Paz     03    Pacajes                  
#>  4 02    La Paz     04    Camacho                  
#>  5 02    La Paz     05    Muñecas                  
#>  6 02    La Paz     06    Larecaja                 
#>  7 02    La Paz     07    Franz Tamayo             
#>  8 02    La Paz     08    Ingavi                   
#>  9 02    La Paz     09    Loayza                   
#> 10 02    La Paz     10    Inquisivi                
#> 11 02    La Paz     11    Sur Yungas               
#> 12 02    La Paz     12    Los Andes                
#> 13 02    La Paz     13    Aroma                    
#> 14 02    La Paz     14    Nor Yungas               
#> 15 02    La Paz     15    Abel Iturralde           
#> 16 02    La Paz     16    Bautista Saavedra        
#> 17 02    La Paz     17    Manco Kapac              
#> 18 02    La Paz     18    Gualberto Villarroel     
#> 19 02    La Paz     19    General José Manuel Pando
#> 20 02    La Paz     20    Caranavi                 
```

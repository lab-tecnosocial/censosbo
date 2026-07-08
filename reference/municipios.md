# Lista los municipios de Bolivia

Lista los municipios de Bolivia

## Usage

``` r
municipios(departamento = NULL, provincia = NULL)
```

## Arguments

- departamento:

  Código o nombre del departamento. Opcional.

- provincia:

  Código o nombre de provincia. Opcional.

## Value

Un \[tibble\]\[dplyr::tibble\] con columnas \`idep\`, \`nombre_dep\`,
\`iprov\`, \`nombre_prov\`, \`imun\`, \`nombre_mun\`.

## Examples

``` r
municipios(departamento = "Cochabamba")
#> # A tibble: 48 × 6
#>    idep  nombre_dep iprov nombre_prov  imun  nombre_mun
#>    <chr> <chr>      <chr> <chr>        <chr> <chr>     
#>  1 03    Cochabamba 01    Cercado      01    Cochabamba
#>  2 03    Cochabamba 02    Campero      01    Aiquile   
#>  3 03    Cochabamba 02    Campero      02    Pasorapa  
#>  4 03    Cochabamba 02    Campero      03    Omereque  
#>  5 03    Cochabamba 03    Ayopaya      01    Ayopaya   
#>  6 03    Cochabamba 03    Ayopaya      02    Morochata 
#>  7 03    Cochabamba 03    Ayopaya      03    Cocapata  
#>  8 03    Cochabamba 04    Esteban Arze 01    Tarata    
#>  9 03    Cochabamba 04    Esteban Arze 02    Anzaldo   
#> 10 03    Cochabamba 04    Esteban Arze 03    Arbieto   
#> # ℹ 38 more rows
municipios(departamento = "Cochabamba", provincia = "Cercado")
#> # A tibble: 1 × 6
#>   idep  nombre_dep iprov nombre_prov imun  nombre_mun
#>   <chr> <chr>      <chr> <chr>       <chr> <chr>     
#> 1 03    Cochabamba 01    Cercado     01    Cochabamba
```

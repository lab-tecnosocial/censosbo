# Análisis de condiciones de vivienda

## Introducción

Esta vignette analiza las condiciones habitacionales usando los datos de
viviendas del CPV-2024. La tabla de viviendas se descarga como un único
archivo (~100 MB) que incluye todos los departamentos.

``` r

# Descargar viviendas con variables de habitabilidad
# (se filtra por Oruro después de descargar el archivo completo)
viviendas <- get_viviendas_2024(
  departamento = "Oruro",
  variables    = c("urbrur", "v03_pared", "v05_techo", "v06_piso",
                   "v07_aguapro", "v09_energia", "v11_basura",
                   "v14_dormit", "tot_pers")
) |>
  collect() |>
  etiquetar_valores(columnas = c("urbrur", "v03_pared", "v05_techo", "v06_piso",
                                  "v07_aguapro", "v09_energia", "v11_basura"))
#> ✔ Usando caché: vivienda.parquet

nrow(viviendas)
#> [1] 271078
```

## Fuente de agua potable

``` r

agua <- viviendas |>
  filter(!is.na(v07_aguapro), !is.na(urbrur)) |>
  count(urbrur, v07_aguapro) |>
  group_by(urbrur) |>
  mutate(pct = n / sum(n) * 100)

ggplot(agua, aes(x = urbrur, y = pct, fill = v07_aguapro)) +
  geom_col() +
  scale_fill_brewer(palette = "Blues", direction = -1) +
  labs(
    title   = "Fuente de agua potable por área — Oruro, CPV-2024",
    x       = "Área",
    y       = "Porcentaje de viviendas (%)",
    fill    = "Fuente de agua",
    caption = "Fuente: INE Bolivia, CPV-2024"
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom",
        legend.text = element_text(size = 8))
```

![](analisis-vivienda_files/figure-html/agua-1.png)

## Energía eléctrica

``` r

energia <- viviendas |>
  filter(!is.na(v09_energia), !is.na(urbrur)) |>
  count(urbrur, v09_energia) |>
  group_by(urbrur) |>
  mutate(pct = n / sum(n) * 100)

ggplot(energia, aes(x = urbrur, y = pct, fill = v09_energia)) +
  geom_col() +
  scale_fill_brewer(palette = "Oranges", direction = -1) +
  labs(
    title   = "Fuente de energía eléctrica — Oruro, CPV-2024",
    x       = "Área",
    y       = "Porcentaje de viviendas (%)",
    fill    = "Tipo de energía",
    caption = "Fuente: INE Bolivia, CPV-2024"
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom",
        legend.text = element_text(size = 8))
```

![](analisis-vivienda_files/figure-html/energia-1.png)

## Índice de hacinamiento

``` r

hacinamiento <- viviendas |>
  filter(!is.na(tot_pers), !is.na(v14_dormit), v14_dormit > 0, tot_pers > 0,
         !is.na(urbrur)) |>
  mutate(
    ppp = tot_pers / v14_dormit,
    nivel = case_when(
      ppp <= 2 ~ "Sin hacinamiento (≤2 p/dormitorio)",
      ppp <= 3 ~ "Hacinamiento medio (2–3)",
      TRUE     ~ "Hacinamiento severo (>3)"
    )
  ) |>
  count(urbrur, nivel) |>
  group_by(urbrur) |>
  mutate(pct = n / sum(n) * 100)

ggplot(hacinamiento, aes(x = urbrur, y = pct, fill = nivel)) +
  geom_col() +
  scale_fill_manual(values = c(
    "Sin hacinamiento (≤2 p/dormitorio)" = "#003087",
    "Hacinamiento medio (2–3)"           = "#F4C430",
    "Hacinamiento severo (>3)"           = "#d7191c"
  )) +
  labs(
    title   = "Hacinamiento habitacional — Oruro, CPV-2024",
    x       = "Área",
    y       = "Porcentaje de viviendas (%)",
    fill    = NULL,
    caption = "Fuente: INE Bolivia, CPV-2024"
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom")
```

![](analisis-vivienda_files/figure-html/hacinamiento-1.png)

## Material de paredes

``` r

paredes <- viviendas |>
  filter(!is.na(v03_pared)) |>
  count(v03_pared, sort = TRUE) |>
  mutate(pct = n / sum(n) * 100)

ggplot(paredes, aes(x = reorder(v03_pared, pct), y = pct)) +
  geom_col(fill = "#003087") +
  geom_text(aes(label = paste0(round(pct, 1), "%")), hjust = -0.1, size = 3.2) +
  coord_flip() +
  ylim(0, max(paredes$pct) * 1.2) +
  labs(
    title   = "Material predominante de paredes — Oruro, CPV-2024",
    x       = NULL,
    y       = "Porcentaje de viviendas (%)",
    caption = "Fuente: INE Bolivia, CPV-2024"
  ) +
  theme_minimal(base_size = 12)
```

![](analisis-vivienda_files/figure-html/paredes-1.png)

## Join personas–viviendas con DuckDB

``` r

library(DBI)

con <- DBI::dbConnect(duckdb::duckdb(), dbdir = ":memory:")

duckdb::duckdb_register_arrow(
  con, "personas",
  get_personas_2024(departamento = "Oruro",
               variables = c("idep","iprov","imun","i00","p25_sexo","p26_edad","nivel_edu"))
)
#> ℹ Descargando persona_dep04.parquet (~14 MB)...
#> ✔ Descargado persona_dep04.parquet [302ms]
#> 
duckdb::duckdb_register_arrow(
  con, "viviendas",
  get_viviendas_2024(departamento = "Oruro",
                variables = c("idep","iprov","imun","i00","v07_aguapro","urbrur","tot_pers"))
)
#> ✔ Usando caché: vivienda.parquet

# Personas en viviendas sin acceso a red pública de agua, por área
resultado <- DBI::dbGetQuery(con, "
  SELECT
    v.urbrur,
    COUNT(*)            AS personas,
    ROUND(AVG(p.p26_edad), 1) AS edad_promedio
  FROM personas p
  JOIN viviendas v
    ON p.idep = v.idep AND p.iprov = v.iprov
   AND p.imun = v.imun AND p.i00  = v.i00
  WHERE v.v07_aguapro != 1
  GROUP BY v.urbrur
  ORDER BY personas DESC
")

DBI::dbDisconnect(con)

resultado |> etiquetar_valores()
#>   urbrur personas edad_promedio
#> 1  Rural   129099          33.6
#> 2 Urbana    30466          26.8
```

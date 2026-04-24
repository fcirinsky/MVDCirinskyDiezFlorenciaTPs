# ==============================================================================
# Script: metrics_figures.R
# ==============================================================================

library(tidyverse)
library(tidytext)
library(here)
library(ggplot2)

message("Generando métricas y visualizaciones...")

# 1. cargo el texto procesado (lematizado)
#busco el archivo que limpie en el paso anterior
data_path <- here("TP2/output/processed_text.rds")

#si el archivo no aparece, freno el proceso para avisar que salió mal
if (!file.exists(data_path)) stop("No se encuentra el archivo procesado.")

words_df <- readRDS(data_path)

# Punto 2.3.a
# elijo estos 5 conceptos porque son los pilares de la agenda de la OEA (segun mi opinion)
mis_terminos <- c("democracia", "electoral", "misión", "derechos", "seguridad") 

# 3. filtrar y contar frecuencias
#busco mis 5 palabras en toda la base de datos y cuento cuántas veces aparece cada una
frecuencias <- words_df %>%
  filter(lemma %in% mis_terminos) %>%
  count(lemma, sort = TRUE)

# Punto 2.3.b
#hago grafico de barras
grafico <- ggplot(frecuencias, aes(x = reorder(lemma, n), y = n, fill = lemma)) +
  #dibujo las columnas
  geom_col(show.legend = FALSE) +
  #giro el gráfico para que los nombres de las palabras se lean mejor de costado
  coord_flip() + # Para que sea más fácil de leer
 #le pongo los títulos y etiquetas para que quede profesional
   labs(title = "Frecuencia de términos clave en comunicados OEA",
       subtitle = "Enero - Abril 2026",
       x = "Términos",
       y = "Cantidad de apariciones") +
  theme_minimal() 

# fuardo el gráfico en /output
ggsave(filename = here("TP2/output/frecuencia_terminos.png"), 
       plot = grafico, 
       width = 10, height = 6, dpi = 300)

message("¡Gráfico guardado como frecuencia_terminos.png en /output!")

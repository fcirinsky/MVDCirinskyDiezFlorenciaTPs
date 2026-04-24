# ==============================================================================
# Script: metrics_figures.R
# Objetivo: Computar DTM, filtrar 5 términos y generar gráfico (Punto 2.3.a y b)
# ==============================================================================

library(tidyverse)
library(tidytext)
library(here)
library(ggplot2)

message("Generando métricas y visualizaciones...")

# 1. Cargar el texto procesado (lematizado)
data_path <- here("TP2/output/processed_text.rds")
if (!file.exists(data_path)) stop("No se encuentra el archivo procesado.")

words_df <- readRDS(data_path)

# 2. Elegir 5 términos relevantes para la OEA (Punto 2.3.a)
# He elegido estos basados en el contexto institucional, pero podés cambiarlos
mis_terminos <- c("democracia", "electoral", "misión", "derechos", "seguridad") 

# 3. Filtrar y contar frecuencias
# Esto simula la lógica de la DTM condensada
frecuencias <- words_df %>%
  filter(lemma %in% mis_terminos) %>%
  count(lemma, sort = TRUE)

# 4. Generar el gráfico de barras (Punto 2.3.b)
grafico <- ggplot(frecuencias, aes(x = reorder(lemma, n), y = n, fill = lemma)) +
  geom_col(show.legend = FALSE) +
  coord_flip() + # Para que sea más fácil de leer
  labs(title = "Frecuencia de términos clave en comunicados OEA",
       subtitle = "Enero - Abril 2026",
       x = "Términos",
       y = "Cantidad de apariciones") +
  theme_minimal() 

# 5. Guardar el gráfico en /output
ggsave(filename = here("TP2/output/frecuencia_terminos.png"), 
       plot = grafico, 
       width = 10, height = 6, dpi = 300)

message("¡Gráfico guardado como frecuencia_terminos.png en /output!")

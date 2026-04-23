
# ==============================================================================
# Script: processing.R
# Objetivo: Limpiar, lematizar y remover stopwords
# ==============================================================================
install.packages("tidytext")
install.packages("udpipe")

library(tidyverse)
library(tidytext)
library(here)
library(udpipe) # Para lematización profesional

message("Leyendo datos para procesamiento...")

# 1. Cargar datos del scraping
df <- readRDS(here("TP2/data/comunicados_oea.rds"))

# 2. Limpieza de texto (Punto A)
# Sacar signos de puntuación, números y caracteres especiales [cite: 34]
df_clean <- df %>%
  mutate(cuerpo = str_to_lower(cuerpo),
         cuerpo = str_replace_all(cuerpo, "[^[:alpha:]///s]", " "),
         cuerpo = str_squish(cuerpo))

message("Lematizando y filtrando categorías gramaticales...")

# 3. Lematización (Punto B)
# Solo sustantivos, verbos y adjetivos en minúscula [cite: 35, 36]
# Bajamos el modelo de español si no lo tenés
modelo_es <- udpipe_download_model(language = "spanish")
ud_model <- udpipe_load_model(modelo_es$file_model)

procesado <- udpipe_annotate(ud_model, x = df_clean$cuerpo) %>%
  as.data.frame() %>%
  filter(upos %in% c("NOUN", "VERB", "ADJ")) %>% # Sustantivos, Verbos, Adjetivos
  select(doc_id, lemma) %>%
  mutate(lemma = str_to_lower(lemma))

# 4. Remover stopwords (Punto C) [cite: 37]
data("stop_words") # Stopwords generales
stopwords_es <- get_stopwords("es")

final_text <- procesado %>%
  filter(!lemma %in% stopwords_es$word)

# 5. Guardar resultado en /output [cite: 31, 32]
if (!dir.exists(here("TP2/output"))) dir.create(here("TP2/output"))
saveRDS(final_text, here("TP2/output/processed_text.rds"))

message("¡Procesamiento finalizado! Archivo guardado en /output.")
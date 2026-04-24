
# ==============================================================================
# Script: processing.R
# Objetivo: Limpiar, lematizar y remover stopwords
# ==============================================================================
#instalo estos paquetes que no tenia 
#install.packages("tidytext")
#install.packages("udpipe")
#install.packages("stopwords")

library(tidyverse)
library(tidytext)
library(here)
library(udpipe) 

message("Leyendo datos para procesamiento...")

# 1. Cargo datos del scraping
df <- readRDS(here("TP2/data/comunicados_oea.rds"))

#PUNTO A
# Limpieza de texto
# Sacar signos de puntuación, números y caracteres especiales 
df_clean <- df %>%
  mutate(cuerpo = str_to_lower(cuerpo),
         cuerpo = str_replace_all(cuerpo, "[^[:alpha:]///s]", " "),
         cuerpo = str_squish(cuerpo))

message("Lematizando y filtrando categorías gramaticales...")

#PUNTO B
# Lematización
# Solo sustantivos, verbos y adjetivos en minúscula
modelo_es <- udpipe_download_model(language = "spanish")
ud_model <- udpipe_load_model(modelo_es$file_model)

procesado <- udpipe_annotate(ud_model, x = df_clean$cuerpo) %>%
  as.data.frame() %>%
  filter(upos %in% c("NOUN", "VERB", "ADJ")) %>% # sust, verbos, adj
  select(doc_id, lemma) %>%
  mutate(lemma = str_to_lower(lemma))

#PUNTO C
# saco stopwords
data("stop_words") # Stopwords generales
stopwords_es <- get_stopwords("es")

final_text <- procesado %>%
  filter(!lemma %in% stopwords_es$word)

#guardo resultado en /output
if (!dir.exists(here("TP2/output"))) dir.create(here("TP2/output"))
saveRDS(final_text, here("TP2/output/processed_text.rds"))

message("¡Procesamiento finalizado! Archivo guardado en /output.")
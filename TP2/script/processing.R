# ==============================================================================
# Script: processing.R
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

# 1. cargo los datos del script de scraping
df <- readRDS(here("TP2/data/comunicados_oea.rds"))

#PUNTO A --> limpio el texto para que R no se confunda con simbolos
#saco signos de puntuación, números y caracteres especiales 
df_clean <- df %>%
  mutate(cuerpo = str_to_lower(cuerpo), #paso todo a minúsculas (para que "Derechos" y "derechos" sean lo mismo)
         cuerpo = str_replace_all(cuerpo, "[^[:alpha:]///s]", " "), #borro todo lo que no sea una letra (números, signos, símbolos raros)
         cuerpo = str_squish(cuerpo)) #saco los espacios de más que hayan quedado

message("Lematizando y filtrando categorías gramaticales...")


#PUNTO B
# Lematización --> busco la "raiz" de las palabras
#solo sustantivos, verbos y adjetivos en minúscula
modelo_es <- udpipe_download_model(language = "spanish")
ud_model <- udpipe_load_model(modelo_es$file_model)

#aplico la lematización a los comunicados
procesado <- udpipe_annotate(ud_model, x = df_clean$cuerpo) %>%
  as.data.frame() %>%
  #filtro para quedarme solo con las palabras importantes (saco las de relleno)
  filter(upos %in% c("NOUN", "VERB", "ADJ")) %>% # sust, verbos, adj
  #me quedo con la columna del ID del documento y la palabra ya simplificada
  select(doc_id, lemma) %>%
  mutate(lemma = str_to_lower(lemma))

#PUNTO C --> saco stopwords (palabras que no aportan info)
data("stop_words") # Stopwords generales
stopwords_es <- get_stopwords("es")

#filtro mi tabla para borrar todas esas palabras que no me sirven para el análisis
final_text <- procesado %>%
  filter(!lemma %in% stopwords_es$word)

#guardo resultado en /output
#si la carpeta no existe, le pido a R que la cree
if (!dir.exists(here("TP2/output"))) dir.create(here("TP2/output"))
saveRDS(final_text, here("TP2/output/processed_text.rds"))

message("¡Procesamiento finalizado! Archivo guardado en /output.")
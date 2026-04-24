# ==============================================================================
# Script: scraping_oea.R
# Objetivo: Web scraping de comunicados de la OEA (Ene-Abr 2026)
# ==============================================================================

library(rvest)
library(tidyverse)
library(here)
library(xml2)

# 1. Configuración de carpetas 
data_dir <- here("TP2/data")
if (!dir.exists(data_dir)) {
  message("Creando el directorio: ", data_dir)
  dir.create(data_dir, recursive = TRUE)
}

# 2. Parámetros de búsqueda 
anio <- 2026
meses <- 1:4 # Enero a Abril
base_url <- "https://www.oas.org/es/centro_noticias/comunicados_prensa.asp"

# 3. Revisión de robots.txt 
# Basado en la consigna de prestar atención al Crawl-delay
delay_segundos <- 5 

message("Iniciando el proceso de scraping...")

all_comunicados <- list()

for (mes in meses) {
  # Construir URL por mes 
  url_busqueda <- paste0(base_url, "?nMes=", mes, "&nAnio=", anio)
  message("Procesando mes ", mes, " de ", anio, "...")
  
  pagina_indice <- read_html(url_busqueda)
  
  # Guardar el HTML original por registro 
  timestamp <- format(Sys.time(), "%Y%m%d")
  write_xml(pagina_indice, here("TP2/data", paste0("indice_mes_", mes, "_", timestamp, ".html")))
  
  # Extraer links de las noticias usando tus selectores 
  links <- pagina_indice %>% 
    html_nodes(".headlinelink") %>% # Selector que encontraste
    html_attr("href") %>% 
    # Convertir rutas relativas a absolutas si es necesario
    paste0("https://www.oas.org/es/centro_noticias/", .)
  
  # Loop para entrar a cada noticia
  for (link in links) {
    message("  Bajando: ", link)
    
    # Respetar el Crawl-delay 
    Sys.sleep(delay_segundos)
    
    pagina_noticia <- read_html(link)
    
    # Extraer info con tus selectores 
    titulo <- pagina_noticia %>% 
      html_node(".headlinelink") %>% # O el que identifiques como principal dentro
      html_text(trim = TRUE)
    
    cuerpo <- pagina_noticia %>% 
      html_nodes("p") %>% # Selector 'p' que encontraste
      html_text(trim = TRUE) %>% 
      paste(collapse = " ")
    
    id <- basename(link)
    
    all_comunicados[[link]] <- tibble(id = id, titulo = titulo, cuerpo = cuerpo)
  }
}

# 4. Consolidar y guardar 
tabla_final <- bind_rows(all_comunicados)
saveRDS(tabla_final, file = here("TP2/data/comunicados_oea.rds"))

message("¡Proceso de scraping finalizado! Archivo guardado en /data.")
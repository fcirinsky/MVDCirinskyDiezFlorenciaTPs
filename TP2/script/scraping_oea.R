# ==============================================================================
# Script: scraping_oea.R
# ==============================================================================

library(rvest)
library(tidyverse)
library(here)
library(xml2)

# 1. configuración de carpetas 
#uso here para que R siempre encuentre la carpeta del proyecto sin que importe en que compu esté
data_dir <- here("TP2/data")

# si no existe la carpeta "data", le pido a R que la cree para poder guardar los archivos
if (!dir.exists(data_dir)) {
  message("Creando el directorio: ", data_dir)
  dir.create(data_dir, recursive = TRUE)
}

# 2. parámetros de búsqueda 
#defino que año y mes quiero buscar
anio <- 2026
meses <- 1:4 # enero a abril
#y pongo la dirección de la pagina de donde voy a sacar las noticias (OEA)
base_url <- "https://www.oas.org/es/centro_noticias/comunicados_prensa.asp"

# 3. revisión de robots.txt 
# le pongo un delay de descarga de 5 segundos, así no se me satura el servidor
delay_segundos <- 5 

message("Iniciando el proceso de scraping...")

#creo una lista vacía para ir guardando toda la info
all_comunicados <- list()

#recorro mes por mes
for (mes in meses) {
 
   # armo la dirección especifica combinando la base con el mes y el año 
  url_busqueda <- paste0(base_url, "?nMes=", mes, "&nAnio=", anio)
  message("Procesando mes ", mes, " de ", anio, "...")
  
  #veo el contenido de esa página de búsqueda
  pagina_indice <- read_html(url_busqueda)
  
  # guardo una copia del archivo HTML para tener un respaldo de lo que bajé 
  timestamp <- format(Sys.time(), "%Y%m%d")
  write_xml(pagina_indice, here("TP2/data", paste0("indice_mes_", mes, "_", timestamp, ".html")))
  
  #busco todos los links de las noticias que aparecen en la lista del mes 
  links <- pagina_indice %>% 
    html_nodes(".headlinelink") %>% # Selector que encontraste
    html_attr("href") %>% 
    # como los links vienen incompletos, les pego el resto de la dirección web al principio
    paste0("https://www.oas.org/es/centro_noticias/", .)
  
  # loop para entrar a cada noticia
  for (link in links) {
    message("  Bajando: ", link)
    
    #hago que el programa espere los 5 segundos que puse antes
    Sys.sleep(delay_segundos)
    
    pagina_noticia <- read_html(link)
    
    # extraigo el título de la noticia 
    titulo <- pagina_noticia %>% 
      html_node(".headlinelink") %>% # O el que identifiques como principal dentro
      html_text(trim = TRUE)
   
    #extraigo todo el texto de la noticia
    #como el texto está dividido en varios párrafos, uso 'paste' para juntar todo en un solo bloque
    cuerpo <- pagina_noticia %>% 
      html_nodes("p") %>% # Selector 'p' que encontraste
      html_text(trim = TRUE) %>% 
      paste(collapse = " ")
    
    #uso el final de la dirección web como un ID para identificar cada noticia
    id <- basename(link)
    
    #guardo el ID, el título y el cuerpo en una tablita y la voy sumando a mi lista
    all_comunicados[[link]] <- tibble(id = id, titulo = titulo, cuerpo = cuerpo)
  }
}

# 4. consolidar y guardar 
# junto todas las noticias que bajé en una sola tabla
tabla_final <- bind_rows(all_comunicados)
#guardo esa tabla final en un archivo en "/data"
saveRDS(tabla_final, file = here("TP2/data/comunicados_oea.rds"))

message("¡Proceso de scraping finalizado! Archivo guardado en /data.")
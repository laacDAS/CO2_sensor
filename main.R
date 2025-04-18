library(ggplot2)
library(lubridate)

# liimpeza e organização de dados ----------------------------------------
diretorio <- "data/"
dir.create("graficos/", showWarnings = FALSE)

arquivos <- list.files(path = diretorio, pattern = "\\.txt$", full.names = TRUE)
banco_de_dados <- data.frame()

for (arquivo in arquivos) {
  dados <- read.table(
    arquivo,
    header = TRUE,
    sep = ",",
    stringsAsFactors = FALSE
  )
  banco_de_dados <- rbind(banco_de_dados, dados)
}

datas_unicas <- unique(banco_de_dados$Data)

# Gráficos diários separados ---------------------------------------------
for (data_unica in datas_unicas) {
  dados_filtrados <- subset(banco_de_dados, Data == data_unica)
  dados_filtrados$hora <- as.POSIXct(dados_filtrados$hora, format = "%H:%M:%S")

  grafico <- ggplot(dados_filtrados, aes(x = hora, y = CO2)) +
    geom_line() +
    geom_smooth(method = "gam", se = FALSE) +
    labs(
      title = paste("Variação de CO2 em", data_unica),
      x = "Hora do Dia",
      y = "CO2 (ppm)"
    ) +
    theme_minimal() +
    scale_x_datetime(date_labels = "%H:%M", date_breaks = "2 hour") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))

  ggsave(
    filename = paste0(gsub("/", "_", data_unica), ".jpg"),
    plot = grafico,
    path = "graficos/",
    width = 10,
    height = 6,
    units = "in",
    dpi = 300
  )
}

# Gráficos diários sobrepostos -------------------------------------------
banco_de_dados$Data <- as.Date(banco_de_dados$Data, format = "%d/%m/%Y")
banco_de_dados$hora <- as.POSIXct(banco_de_dados$hora, format = "%H:%M:%S")

grafico_geral <- ggplot(
  banco_de_dados,
  aes(x = hora, y = CO2, color = as.factor(Data))
) +
  geom_smooth(method = "gam", se = FALSE) +
  labs(
    title = "Variação de CO2 ao Longo dos Dias",
    x = "Hora do Dia",
    y = "CO2 (ppm)",
    color = "Data"
  ) +
  theme_minimal() +
  scale_x_datetime(date_labels = "%H:%M", date_breaks = "2 hour") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave(
  filename = "variacao_co2_geral.jpg",
  plot = grafico_geral,
  path = "graficos/",
  width = 10,
  height = 6,
  units = "in",
  dpi = 300
)

# Gráfico média diária ---------------------------------------------------
media_diaria <- aggregate(CO2 ~ hora, banco_de_dados, mean)
grafico_media_diaria <- ggplot(media_diaria, aes(x = hora, y = CO2)) +
  geom_smooth(method = "gam", se = FALSE) +
  labs(
    title = "Média Diária de CO2",
    x = "Hora do Dia",
    y = "CO2 (ppm)"
  ) +
  theme_minimal() +
  scale_x_datetime(date_labels = "%H:%M", date_breaks = "2 hour") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave(
  filename = "media_diaria_co2.jpg",
  plot = grafico_media_diaria,
  path = "graficos/",
  width = 10,
  height = 6,
  units = "in",
  dpi = 300
)

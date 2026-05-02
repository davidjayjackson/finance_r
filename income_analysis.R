#' ---
#' title: "Income ETF Analysis"
#' date: "`r Sys.Date()`"
#' ---

#+ setup, echo=FALSE, message=FALSE, warning=FALSE
library(dplyr)
library(ggplot2)
library(RMariaDB)
library(DBI)
library(zoo)

rm(list=ls())

#+ connect, echo=FALSE, message=FALSE, warning=FALSE
con <- dbConnect(
  MariaDB(),
  host     = "localhost",
  user     = "root",
  password = "dJj135790",
  dbname   = "investment"
)

stocks <- dbGetQuery(con, "select * from income where Date >= '2025-04-28'")

#' ## Portfolio Summary
#+ summary, echo=FALSE, message=FALSE, warning=FALSE
tapply(stocks$Close, stocks$Ticker, summary)

plot_etf <- function(data, ticker, title) {
  data <- data |> filter(Ticker == ticker)
  data$roll50  <- rollmean(data$Close, 50,  fill = NA, align = "right")
  data$roll100 <- rollmean(data$Close, 100, fill = NA, align = "right")

  ggplot(data) +
    geom_line(aes(x = Date, y = Close,   colour = "Close")) +
    geom_line(aes(x = Date, y = roll50,  colour = "50-Day MA")) +
    geom_line(aes(x = Date, y = roll100, colour = "100-Day MA")) +
    labs(title = title, x = "Date", y = "Price (USD)", colour = "Series") +
    theme_minimal(base_size = 14) +
    theme(
      plot.title      = element_text(face = "bold", size = 16),
      legend.position = "bottom"
    )
}

save_plot <- function(p, filename) {
  ggsave(filename, plot = p, width = 10, height = 8, dpi = 150)
}

#+ plots, echo=FALSE, message=FALSE, warning=FALSE
p1 <- plot_etf(stocks, "JEPI", "JEPI — Close Price & Rolling Means")
p2 <- plot_etf(stocks, "QYLD", "QYLD — Close Price & Rolling Means")
p3 <- plot_etf(stocks, "SCHD", "SCHD — Close Price & Rolling Means")

save_plot(p1, "jepi_plot.png")
save_plot(p2, "qyld_plot.png")
save_plot(p3, "schd_plot.png")

#' <div style="page-break-before: always;"></div>
#'
#' ## JPMorgan Equity Premium Income ETF — JEPI (40%)
#' Tracks equity income with a covered call overlay. Portfolio allocation: **40%**.
#'
#' ![](jepi_plot.png)
#'
#' <div style="page-break-before: always;"></div>
#'
#' ## Global X NASDAQ 100 Covered Call ETF — QYLD (35%)
#' High-yield covered call strategy on the NASDAQ 100. Portfolio allocation: **35%**.
#'
#' ![](qyld_plot.png)
#'
#' <div style="page-break-before: always;"></div>
#'
#' ## Schwab U.S. Dividend Equity ETF — SCHD (25%)
#' Tracks high-dividend U.S. equities. Portfolio allocation: **25%**.
#'
#' ![](schd_plot.png)

#+ disconnect, echo=FALSE
dbDisconnect(con)

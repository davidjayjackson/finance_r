#' ---
#' title: "Income ETF Analysis"
#' date: "`r Sys.Date()`"
#' ---

#+ setup, echo=FALSE, message=FALSE, warning=FALSE
library(dplyr)
library(ggplot2)
# library(RMariaDB)
library(DBI)
library(zoo)
library(duckdb)
rm(list=ls())

#+ connect, echo=FALSE, message=FALSE, warning=FALSE
# con <- dbConnect(
#   MariaDB(),
#   host     = "localhost",
#   user     = "root",
#   password = "dJj135790",
#   dbname   = "investment"
# )
db <- dbConnect(duckdb(),dbdir="investment.duckdb")

stocks_all <- dbGetQuery(db, "SELECT * FROM income ORDER BY Ticker, Date")

vwap_window <- 20

stocks_all <- stocks_all |>
  arrange(Ticker, Date) |>
  group_by(Ticker) |>
  mutate(
    TP         = (High + Low + Close) / 3,
    VWAP       = rollapply(TP * Volume, vwap_window, sum, fill = NA, align = "right") /
                 rollapply(Volume,      vwap_window, sum, fill = NA, align = "right"),
    VWAP_sd    = rollapply(TP,          vwap_window, sd,  fill = NA, align = "right"),
    VWAP_upper = VWAP + 2 * VWAP_sd,
    VWAP_lower = VWAP - 2 * VWAP_sd
  ) |>
  select(-TP) |>
  ungroup()

dbWriteTable(db, "income", stocks_all, overwrite = TRUE)

stocks <- stocks_all |> filter(Date >= as.Date("2025-04-28"))

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

plot_vwap <- function(data, ticker, title) {
  data <- data |> filter(Ticker == ticker, !is.na(VWAP))

  ggplot(data, aes(x = Date)) +
    geom_line(aes(y = Close,      colour = "Close"),  linewidth = 0.8) +
    geom_line(aes(y = VWAP,       colour = "VWAP"),   linewidth = 1.0) +
    geom_line(aes(y = VWAP_upper, colour = "+2 SD"),  linewidth = 0.6, linetype = "dashed") +
    geom_line(aes(y = VWAP_lower, colour = "-2 SD"),  linewidth = 0.6, linetype = "dashed") +
    scale_colour_manual(
      values = c("Close" = "black", "VWAP" = "steelblue", "+2 SD" = "firebrick", "-2 SD" = "forestgreen")
    ) +
    labs(title = title, x = "Date", y = "Price (USD)", colour = "Series") +
    theme_minimal(base_size = 14) +
    theme(
      plot.title      = element_text(face = "bold", size = 16),
      legend.position = "bottom"
    )
}

#+ plots, echo=FALSE, message=FALSE, warning=FALSE
p1 <- plot_etf(stocks, "JEPI", "JEPI — Close Price & Rolling Means")
p2 <- plot_etf(stocks, "QYLD", "QYLD — Close Price & Rolling Means")
p3 <- plot_etf(stocks, "SCHD", "SCHD — Close Price & Rolling Means")

save_plot(p1, "jepi_plot.png")
save_plot(p2, "qyld_plot.png")
save_plot(p3, "schd_plot.png")

p4 <- plot_vwap(stocks, "JEPI", "JEPI — VWAP (20-Day) & ±2 SD Bands")
p5 <- plot_vwap(stocks, "QYLD", "QYLD — VWAP (20-Day) & ±2 SD Bands")
p6 <- plot_vwap(stocks, "SCHD", "SCHD — VWAP (20-Day) & ±2 SD Bands")

save_plot(p4, "jepi_vwap.png")
save_plot(p5, "qyld_vwap.png")
save_plot(p6, "schd_vwap.png")

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

#' <div style="page-break-before: always;"></div>
#'
#' ## JEPI — VWAP & ±2 Standard Deviation Bands
#' 20-day rolling VWAP based on Typical Price × Volume. Bands show ±2 SD of Typical Price.
#'
#' ![](jepi_vwap.png)
#'
#' <div style="page-break-before: always;"></div>
#'
#' ## QYLD — VWAP & ±2 Standard Deviation Bands
#' 20-day rolling VWAP based on Typical Price × Volume. Bands show ±2 SD of Typical Price.
#'
#' ![](qyld_vwap.png)
#'
#' <div style="page-break-before: always;"></div>
#'
#' ## SCHD — VWAP & ±2 Standard Deviation Bands
#' 20-day rolling VWAP based on Typical Price × Volume. Bands show ±2 SD of Typical Price.
#'
#' ![](schd_vwap.png)

#+ disconnect, echo=FALSE
dbDisconnect(db)

library(quantmod) 
library(dplyr) 
library(ggplot2) 
# library(RMariaDB)
library(DBI)
library(lubridate)
library(duckdb)

rm(list=ls())
# 
# con <- dbConnect(
#   MariaDB(),
#   host     = "localhost",
#   user     = "root",
#   password = "dJj135790",
#   dbname   = "investment"
# )
# Duckdb Connec
db <- dbConnect(duckdb(),dbdir="investment.duckdb")

tickers <- c("JEPI", "QYLD", "SCHD")
start_date <- Sys.Date() %m-% years(5)  # exactly 5 years back

df_list <- lapply(tickers, function(ticker) {
  xts_data <- getSymbols(ticker,          # one ticker at a time
                         auto.assign = FALSE, 
                         from = start_date, 
                         to = Sys.Date())
  
  df <- data.frame(Date = index(xts_data), coredata(xts_data))
  colnames(df) <- c("Date", "Open", "High", "Low", "Close", "Volume", "Adjusted")
  df$Ticker <- ticker
  df
})

all_df <- do.call(rbind, df_list) |> select(Date,Ticker,Open:Adjusted)


dbWriteTable(db,"income",all_df,overwrite=TRUE)
dbListTables(db)
library(quantmod)
library(dplyr)
library(ggplot2)
library(lubridate)

symbols          <- c("JEPI", "QYLD", "SCHD")
total_investment <- 300000
alloc_pct        <- c(JEPI = 40, QYLD = 35, SCHD = 25)

# Latest adjusted close price per ticker
prices <- sapply(symbols, function(s) {
  x <- getSymbols(s, auto.assign = FALSE, from = Sys.Date() - 5, to = Sys.Date())
  as.numeric(last(Ad(x)))
})

# Trailing 12-month dividends per share
divs <- sapply(symbols, function(s) {
  d <- getDividends(s, from = Sys.Date() %m-% months(12), to = Sys.Date())
  sum(as.numeric(d), na.rm = TRUE)
})

summary_tbl <- tibble(
  symbol         = symbols,
  percent        = alloc_pct[symbols],
  price          = prices[symbols],
  annual_div     = divs[symbols]
) %>%
  mutate(
    weight         = percent / 100,
    invested       = total_investment * weight,
    shares         = invested / price,
    annual_income  = shares * annual_div,
    monthly_income = annual_income / 12,
    yield          = annual_div / price
  )

save_bar <- function(p, file) ggsave(file, plot = p, width = 8, height = 5, dpi = 150)

save_bar(
  ggplot(summary_tbl) + geom_col(aes(x = symbol, y = percent)) +
    labs(title = "Portfolio Allocation (%)", x = "ETF", y = "Percent") + theme_minimal(),
  "income_percent.png"
)
save_bar(
  ggplot(summary_tbl) + geom_col(aes(x = symbol, y = invested)) +
    labs(title = "Dollars Invested ($300K)", x = "ETF", y = "USD") + theme_minimal(),
  "income_invested.png"
)
save_bar(
  ggplot(summary_tbl) + geom_col(aes(x = symbol, y = annual_income)) +
    labs(title = "Estimated Annual Income", x = "ETF", y = "USD") + theme_minimal(),
  "income_annual.png"
)
save_bar(
  ggplot(summary_tbl) + geom_col(aes(x = symbol, y = monthly_income)) +
    labs(title = "Estimated Monthly Income", x = "ETF", y = "USD") + theme_minimal(),
  "income_monthly.png"
)

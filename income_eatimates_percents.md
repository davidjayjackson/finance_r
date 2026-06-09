---
title: "Income Estimates"
format: html
editor: visual
toc: true
---


```
## Error in `library()`:
## ! there is no package called 'tidyverse'
```

```
## Error in `library()`:
## ! there is no package called 'tidyquant'
```

```
## Error in `tibble()`:
## ! could not find function "tibble"
```

```
## Error:
## ! object 'alloc_input' not found
```

```
## Error in `alloc_input %>% mutate(weight = percent / 100)`:
## ! could not find function "%>%"
```

```
## Error in `tq_get(symbols, get = "stock.prices") %>% group_by(symbol) %>% slice_max(date,
##     n = 1, with_ties = FALSE) %>% ungroup() %>% select(symbol, price = adjusted)`:
## ! could not find function "%>%"
```


``` r
# -----------------------------
# 4) Get dividend history
#    Use the last 12 months to estimate annual dividends/share
# -----------------------------
div_tbl <- tq_get(symbols, get = "dividends") %>%
  mutate(date = as.Date(date))
```

```
## Error in `tq_get(symbols, get = "dividends") %>% mutate(date = as.Date(date))`:
## ! could not find function "%>%"
```

``` r
last_date <- max(div_tbl$date, na.rm = TRUE)
```

```
## Error:
## ! object 'div_tbl' not found
```

``` r
annual_div_tbl <- div_tbl %>%
  filter(!is.na(value)) %>%
  filter(date > last_date %m-% months(12)) %>%
  group_by(symbol) %>%
  summarise(
    annual_dividend_per_share = sum(value, na.rm = TRUE),
    .groups = "drop"
  )
```

```
## Error in `div_tbl %>% filter(!is.na(value)) %>% filter(date > last_date %m-% months(12)) %>%
##     group_by(symbol) %>% summarise(annual_dividend_per_share = sum(value, na.rm = TRUE),
##   .groups = "drop")`:
## ! could not find function "%>%"
```


``` r
# -----------------------------
# 5) Combine allocation, price, and dividend data
# -----------------------------
income_tbl <- alloc_tbl %>%
  left_join(prices_tbl, by = "symbol") %>%
  left_join(annual_div_tbl, by = "symbol") %>%
  mutate(
    dollars_invested = total_investment * weight,
    shares_estimated = dollars_invested / price,
    annual_income = shares_estimated * annual_dividend_per_share,
    monthly_income = annual_income / 12,
    dividend_yield = annual_dividend_per_share / price
  ) %>%
  arrange(desc(monthly_income))
```

```
## Error in `alloc_tbl %>% left_join(prices_tbl, by = "symbol") %>% left_join(annual_div_tbl,
##     by = "symbol") %>% mutate(dollars_invested = total_investment * weight,
##   shares_estimated = dollars_invested / price, annual_income = shares_estimated *
##     annual_dividend_per_share, monthly_income = annual_income / 12,
##   dividend_yield = annual_dividend_per_share / price) %>% arrange(desc(
##     monthly_income))`:
## ! could not find function "%>%"
```


``` r
# -----------------------------
# 6) View stock-by-stock estimates
# -----------------------------
income_tbl %>%
  transmute(
    symbol,
    percent,
    price = round(price, 2),
    annual_dividend_per_share = round(annual_dividend_per_share, 2),
    dividend_yield = scales::percent(dividend_yield, accuracy = 0.01),
    dollars_invested = round(dollars_invested, 2),
    shares_estimated = round(shares_estimated, 2),
    annual_income = round(annual_income, 2),
    monthly_income = round(monthly_income, 2)
  )
```

```
## Error in `income_tbl %>% transmute(symbol, percent, price = round(price, 2),
##   annual_dividend_per_share = round(annual_dividend_per_share, 2),
##   dividend_yield = scales::percent(dividend_yield, accuracy = 0.01),
##   dollars_invested = round(dollars_invested, 2), shares_estimated = round(
##     shares_estimated, 2), annual_income = round(annual_income, 2),
##   monthly_income = round(monthly_income, 2))`:
## ! could not find function "%>%"
```

``` r
# -----------------------------
# 7) Total estimated monthly income
# -----------------------------
income_tbl %>%
  summarise(
    total_annual_income = sum(annual_income, na.rm = TRUE),
    total_monthly_income = sum(monthly_income, na.rm = TRUE)
  )
```

```
## Error in `income_tbl %>% summarise(total_annual_income = sum(annual_income, na.rm = TRUE),
##   total_monthly_income = sum(monthly_income, na.rm = TRUE))`:
## ! could not find function "%>%"
```


``` r
summary_tbl <- income_tbl %>%
  transmute(
    symbol,
    percent,
    invested = dollars_invested,
    yield = dividend_yield,
    annual_income,
    monthly_income
  ) %>%
  mutate(
    invested = round(invested, 0),
    yield = scales::percent(yield, accuracy = 0.01),
    annual_income = round(annual_income, 2),
    monthly_income = round(monthly_income, 2)
  )
```

```
## Error in `income_tbl %>% transmute(symbol, percent, invested = dollars_invested, yield = dividend_yield,
##     annual_income, monthly_income) %>% mutate(invested = round(invested, 0),
##   yield = scales::percent(yield, accuracy = 0.01), annual_income = round(
##     annual_income, 2), monthly_income = round(monthly_income, 2))`:
## ! could not find function "%>%"
```

``` r
print(summary_tbl)
```

```
## Error:
## ! object 'summary_tbl' not found
```


``` r
ggplot(summary_tbl) + geom_col(aes(x=symbol,y=percent))
```

```
## Error in `ggplot()`:
## ! could not find function "ggplot"
```

``` r
ggplot(summary_tbl) + geom_col(aes(x=symbol,y=invested))
```

```
## Error in `ggplot()`:
## ! could not find function "ggplot"
```


``` r
ggplot(summary_tbl) + geom_col(aes(x=symbol,y=annual_income))
```

```
## Error in `ggplot()`:
## ! could not find function "ggplot"
```



``` r
ggplot(summary_tbl) + geom_col(aes(x=symbol,y=monthly_income))
```

```
## Error in `ggplot()`:
## ! could not find function "ggplot"
```

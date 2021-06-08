library(fallRunDSM)
library(tidyverse)

grandtab_raw <- read_csv("data-raw/known-adults-2019.csv",
                         col_names = c("watershed", "order", "1998", "1999",
                                       "2000", "2001", "2002", "2003", "2004",
                                       "2005", "2006", "2007", "2008", "2009",
                                       "2010", "2011", "2012", "2013", "2014",
                                       "2015", "2016", "2017"), skip = 1)

grandtab_imputed <- grandtab_raw %>%
  gather(year, count, -watershed, -order) %>%
  group_by(watershed) %>%
  mutate(
    count = as.numeric(count),
    mean = mean(count, na.rm = TRUE),
    count2 = case_when(
      is.nan(mean) ~ 40,
      is.na(count) ~ mean,
      TRUE ~ count
    )) %>%
  ungroup() %>%
  select(watershed, count = count2, year, order) %>%
  spread(year, count) %>%
  arrange(order) %>%
  select(-watershed, -order) %>%
  as.matrix()

rownames(grandtab_imputed) <- watershed_attributes$watershed
usethis::use_data(grandtab_imputed, overwrite = TRUE)


grandtab_observed <- grandtab_raw %>%
  gather(year, count, -watershed, -order) %>%
  mutate(count = as.numeric(count)) %>%
  filter(count > 100 | is.na(count)) %>%
  spread(year, count) %>%
  arrange(order) %>%
  select(-watershed, -order) %>%
  as.matrix()

rownames(grandtab_observed) <- watershed_attributes$watershed
usethis::use_data(grandtab_observed, overwrite = TRUE)

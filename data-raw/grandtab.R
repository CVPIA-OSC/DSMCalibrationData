library(fallRunDSM)
library(tidyverse)

surv_intercept_idx = c(1, 6, 10, 12, 16, 21, 24, 18, 19, 20, 23, 25, 26, 27, 28, 29, 30, 31)

watersheds <- watershed_attributes[surv_intercept_idx,]$watershed

grandtab_raw <- read_csv("data-raw/Grandtab_Modified.csv")

grandtab_raw %>% distinct(minorbasin)

# remotes::install_github('flowwest/waterYearType')
library(waterYearType)
library(tidyverse)

target_sac <- water_year_indices %>%
  filter(location == 'Sacramento Valley', between(WY, 1997, 2017)) %>%
  select(WY, Index)

options_sac <- water_year_indices %>%
  filter(location == 'Sacramento Valley', between(WY, 1980, 2000)) %>%
  pull(Index)

names(options_sac) <- 1980:2000

target_sj <- water_year_indices %>%
  filter(location == 'San Joaquin Valley', between(WY, 1997, 2017)) %>%
  select(WY, Index)

options_sj <- water_year_indices %>%
  filter(location == 'San Joaquin Valley', between(WY, 1980, 2000)) %>%
  pull(Index)

names(options_sj) <- 1980:2000

synth_year_mapping <- map_chr(seq(target_sj$Index),
                              ~names(
                                which.min(
                                  abs(target_sj$Index[.] - options_sj) +
                                    abs(target_sac$Index[.] - options_sac))
                              )
)

calibration_proxy_year <- data.frame(year = 1997:2017, calibration_year = synth_year_mapping,
                                     sac_actual = target_sac$Index,
                                     sac_synth = options_sac[synth_year_mapping],
                                     sj_actual = target_sj$Index,
                                     sj_synth = options_sj[synth_year_mapping])

cor(calibration_proxy_year$sj_actual, calibration_proxy_year$sj_synth)
cor(calibration_proxy_year$sac_actual, calibration_proxy_year$sac_synth)

calibration_year_spawn_index_V2 <- setNames(calibration_proxy_year$calibration_year, 1997:2017)
calibration_year_index_V2 <- calibration_year_spawn_index[-1]

usethis::use_data(calibration_year_index_V2, overwrite = TRUE)
usethis::use_data(calibration_year_spawn_index_V2, overwrite = TRUE)

calibration_year_index_2019 <- c("1998" = "1998", "1999" = "1997", "2000" = "1993", "2001" = "1981", "2002" = "1989",
           "2003" = "1993", "2004" = "1993", "2005" = "1993", "2006" = "1998", "2007" = "1994",
           "2008" = "1988", "2009" = "1994", "2010" = "1985", "2011" = "1997", "2012" = "1985",
           "2013" = "1994", "2014" = "1992", "2015" = "1992", "2016" = "1989", "2017" = "1998")

calibration_year_spawn_index_2019 <- c("1997" = "1997", calibration_year_index_2019)

usethis::use_data(calibration_year_index_2019, overwrite = TRUE)
usethis::use_data(calibration_year_spawn_index_2019, overwrite = TRUE)

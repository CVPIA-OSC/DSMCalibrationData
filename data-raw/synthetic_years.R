# remotes::install_github('flowwest/waterYearType')
library(waterYearType)
library(tidyverse)

target_sac <- water_year_indices %>%
  filter(location == 'Sacramento Valley', between(WY, 1998, 2018)) %>%
  select(WY, Index)

options_sac <- water_year_indices %>%
  filter(location == 'Sacramento Valley', between(WY, 1979, 2000)) %>%
  pull(Index)

names(options_sac) <- 1979:2000

target_sj <- water_year_indices %>%
  filter(location == 'San Joaquin Valley', between(WY, 1998, 2018)) %>%
  select(WY, Index)

options_sj <- water_year_indices %>%
  filter(location == 'San Joaquin Valley', between(WY, 1979, 2000)) %>%
  pull(Index)

names(options_sj) <- 1979:2000

synth_year_mapping <- map_chr(seq(target_sj$Index),
                      ~names(
                        which.min(
                          abs(target_sj$Index[.] - options_sj) +
                            abs(target_sac$Index[.] - options_sac))
                        )
                    )

calibration_proxy_year <- data.frame(year = 1998:2018, calibration_year = synth_year_mapping,
                   sac_actual = target_sac$Index,
                   sac_synth = options_sac[synth_year_mapping],
                   sj_actual = target_sj$Index,
                   sj_synth = options_sj[synth_year_mapping])

cor(calibration_proxy_year$sj_actual, calibration_proxy_year$sj_synth)
cor(calibration_proxy_year$sac_actual, calibration_proxy_year$sac_synth)


calibration_year_index <- setNames(calibration_proxy_year$calibration_year, 1998:2018)
usethis::use_data(calibration_year_index, overwrite = TRUE)


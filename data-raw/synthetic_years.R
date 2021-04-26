# remotes::install_github('flowwest/waterYearType')
library(waterYearType)
library(tidyverse)

target_sac <- water_year_indices %>%
  filter(location == 'Sacramento Valley', between(WY, 1998, 2017)) %>%
  select(WY, Index)

options_sac <- water_year_indices %>%
  filter(location == 'Sacramento Valley', between(WY, 1980,1999)) %>%
  pull(Index)

names(options_sac) <- 1980:1999

target_sj <- water_year_indices %>%
  filter(location == 'San Joaquin Valley', between(WY, 1998, 2017)) %>%
  select(WY, Index)

options_sj <- water_year_indices %>%
  filter(location == 'San Joaquin Valley', between(WY, 1980,1999)) %>%
  pull(Index)

names(options_sj) <- 1980:1999

fw_combo <- map_chr(seq(target_sj$Index),
                      ~names(
                        which.min(
                          abs(target_sj$Index[.] - options_sj) +
                            abs(target_sac$Index[.] - options_sac))
                        )
                    )

cbind(fw_combo, adams, same = fw_combo == adams)

data <- data_frame(years = 1998:2017, adams, fw_combo,
                   sac_actual = target_sac$Index, sac_adams = options_sac[adams],
                   sac_fw = options_sac[fw_combo],
                   sj_actual = target_sj$Index, sj_adams = options_sj[adams],
                   sj_fw = options_sj[fw_combo])
View(data)

data %>%
  select(-adams:-fw_combo) %>%
  gather(measure, index, -years) %>%
  ggplot(aes(years, index, color = measure)) +
  geom_line() +
  theme(text = element_text(size = 18))

cor(data$sj_actual, data$sj_adams)
cor(data$sj_actual, data$sj_fw)
cor(data$sac_actual, data$sac_adams)
cor(data$sac_actual, data$sac_fw)

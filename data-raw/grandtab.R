library(fallRunDSM)
library(tidyverse)

watershed_order <- tibble(
  watershed = DSMscenario::watershed_labels,
  order = 1:31
)

# SacPas data
grandtab_raw <- read_csv("data-raw/Grandtab_Modified.csv")
unique(grandtab_raw$run)

# cleaned up location names
watershed_lookups <- c(
  "Mainstem - Downstream of RBDD" = "Upper Sacramento River",
  "Mainstem - Upstream of RBDD" = "Upper Sacramento River",
  "Mainstem" = "Upper Sacramento River",
  "Antelope Creek" = "Antelope Creek",
  "Battle Creek" = "Battle Creek",
  "Battle Creek - Downstream of CNFH" = "Battle Creek",
  "Battle Creek - Upstream of CNFH" = "Battle Creek",
  "Bear Creek" = "Bear Creek",
  "Big Chico" = "Big Chico Creek",
  "Butte Creek" = "Butte Creek",
  "Clear Creek" = "Clear Creek",
  "Cottonwood Creek" = "Cottonwood Creek",
  "Cow Creek" = "Cow Creek",
  "Deer Creek" = "Deer Creek",
  "Mill Creek" = "Mill Creek",
  "Paynes Creek" = "Paynes Creek",
  "Thomes Creek" = "Thomes Creek",
  "Bear River" = "Bear River",
  "Feather River" = "Feather River",
  "Yuba River" = "Yuba River",
  "American River" = "American River",
  "Calaveras River" = "Calaveras River",
  "Cosumnes River" = "Cosumnes River",
  "Mokelumne River" = "Mokelumne River",
  "Merced River" = "Merced River",
  "Stanislaus River" = "Stanislaus River",
  "Tuolumne River" = "Tuolumne River"
)

# Filter grandtab data ----
grandtab <- grandtab_raw %>%
  mutate(location2 = watershed_lookups[location]) %>%
  filter(!is.na(location2), endyear >= 1998, origin == "In-River") %>%
  group_by(run, watershed = location2, year = endyear) %>%
  summarise(count = sum(count, na.rm = TRUE)) %>%
  ungroup() |>
  filter(!(watershed == "Yuba River" & run %in% c("Fall", "Spring") &
             year %in% c(2004:2015, 2018, 2019, 2021))) |>
  mutate(method = "grandtab") |>
  glimpse()

# wrangle Yuba to match grandtab format ----
yuba_data <- read_csv("data-raw/yuba_escapement_values.csv") %>%
  rename(Spring = spring_run_escapement,
         Fall = fall_run_escapement) |>
  pivot_longer(cols = Spring:Fall, names_to = 'run', values_to = 'count') |>
  mutate(watershed = "Yuba River",
         method = "vaki") |>  glimpse()

grandtab_with_yuba_updates <- bind_rows(grandtab, yuba_data) |>
  filter(!is.na(year),  year < 2018) |> glimpse()

# Imputed Grandtab ----
# Fall
fall_spawn <- DSMhabitat::fr_spawn[['biop_2008_2009']][, 10, 1] != 0
fall_prop_feather_yuba <- 1 - mean(c(0.076777295, 0.056932196, 0.081441457))

# keep method lookups in a seperate dataframe to allow for spread/gather to work in the next part
calc_method <- grandtab_with_yuba_updates |> filter(run == "Fall") |> select(watershed, year, method)

grandtab_imputed_fall <- grandtab_with_yuba_updates %>%
  filter(run == "Fall") %>%
  select(-run, -method) %>%
  right_join(watershed_order) %>%
  spread(year, count) %>%
  select(-`<NA>`) %>%
  gather(year, count, -watershed, -order) |>
  group_by(watershed, order) %>%
  mutate(
    mean = round(mean(count[count > 0], na.rm = TRUE)),
    count2 = case_when(
      !fall_spawn[watershed] ~ 0,
      fall_spawn[watershed] & is.nan(mean) ~ 40,
      fall_spawn[watershed] & count == 0 ~ mean,
      fall_spawn[watershed] & is.na(count) ~ mean,
      TRUE ~ count
    )
  ) %>%
  ungroup() %>%
  transmute(watershed, count = count2, year = as.numeric(year), order) %>%
  left_join(calc_method, by=c("watershed"="watershed", "year"="year")) |> # bring methods back when needed
  mutate(count = case_when(watershed == "Feather River" ~ round(count * fall_prop_feather_yuba),
                           watershed == "Yuba River" & method == "grandtab" ~ round(count * fall_prop_feather_yuba),
                           T ~ count)) %>%
  select(-method) %>%
  spread(year, count) %>%
  arrange(order) %>%
  select(-watershed, -order) %>%
  as.matrix()

rownames(grandtab_imputed_fall) <- watershed_order$watershed

# Winter
winter_spawn <- DSMhabitat::wr_spawn[['biop_2008_2009']][ ,10, 1] != 0
upsac_wr <- grandtab %>%
  filter(run == "Winter", watershed == "Upper Sacramento River") %>%
  select(-run)

bat_wr <- upsac_wr %>%
  mutate(watershed = "Battle Creek",
         count = round((600/mean(count))* count))

grandtab_imputed_winter <- bind_rows(upsac_wr, bat_wr) %>%
  select(-method) %>%
  right_join(watershed_order) %>%
  spread(year, count) %>%
  select(-`<NA>`) %>%
  arrange(order) %>%
  select(-watershed, -order) %>%
  as.matrix()

grandtab_imputed_winter[which(is.na(grandtab_imputed_winter))] <- 0

rownames(grandtab_imputed_winter) <- watershed_order$watershed

# Spring
# TODO what to do about tiny mean values?
spring_spawn <- DSMhabitat::sr_spawn[['biop_2008_2009']][,10,1] != 0
spring_prop_feather_yuba <- mean(c(0.076777295, 0.056932196, 0.081441457))

# keep method lookups in a seperate dataframe to allow for spread/gather to work in the next part
calc_method_sp <- grandtab_with_yuba_updates |> filter(run == "Spring") |> select(watershed, year, method)

grandtab_imputed_spring <- grandtab_with_yuba_updates %>%
  filter(run == "Spring") %>%
  select(-run, -method) %>%
  right_join(watershed_order) %>%
  spread(year, count) %>%
  select(-`<NA>`) %>%
  gather(year, count, -watershed, -order) %>%
  group_by(watershed, order) %>%
  mutate(
    mean = round(mean(count[count > 0], na.rm = TRUE)),
    count2 = case_when(
      !spring_spawn[watershed] ~ 0,
      spring_spawn[watershed] & is.nan(mean) ~ 40,
      spring_spawn[watershed] & count == 0 ~ mean,
      spring_spawn[watershed] & is.na(count) ~ mean,
      TRUE ~ count
    )
  ) %>%
  ungroup() %>%
  transmute(watershed, count = count2, year = as.numeric(year), order) %>%
  left_join(calc_method_sp, by = c("watershed" = "watershed", "year" = "year")) %>% # bring methods back when needed
  select(-method) %>%
  spread(year, count) %>%
  arrange(order) %>%
  select(-watershed, -order) %>%
  as.matrix()

rownames(grandtab_imputed_spring) <- watershed_order$watershed

grandtab_imputed_spring["Feather River", ] <- round(grandtab_imputed_fall["Feather River", ]/ fall_prop_feather_yuba * spring_prop_feather_yuba)
grandtab_imputed_spring["Yuba River", 1:6] <- round(grandtab_imputed_fall["Yuba River",  1:6]/ fall_prop_feather_yuba * spring_prop_feather_yuba) # use grantab with prop spring scaling for years that there is no vaki
grandtab_imputed_spring["Yuba River", 19:20] <- round(grandtab_imputed_fall["Yuba River", 19:20]/ fall_prop_feather_yuba * spring_prop_feather_yuba) # use grantab with prop spring scaling for years that there is no vaki

# Late-Fall
late_fall_spawn <- DSMhabitat::lfr_spawn[['biop_2008_2009']][,10,1] != 0

# keep method lookups in a seperate dataframe to allow for spread/gather to work in the next part
calc_method_lf <- grandtab_with_yuba_updates |> filter(run == "Late-Fall") |> select(watershed, year, method)

grandtab_imputed_late_fall <- grandtab %>%
  filter(run == "Late-Fall") %>%
  select(-run, -method) %>%
  right_join(watershed_order) %>%
  spread(year, count) %>%
  select(-`<NA>`) %>%
  gather(year, count, -watershed, -order) %>%
  group_by(watershed, order) %>%
  mutate(
    mean = round(mean(count[count > 0], na.rm = TRUE)),
    count2 = case_when(
      !late_fall_spawn[watershed] ~ 0,
      late_fall_spawn[watershed] & is.nan(mean) ~ 40,
      late_fall_spawn[watershed] & count == 0 ~ mean,
      late_fall_spawn[watershed] & is.na(count) ~ mean,
      TRUE ~ count
    )
  ) %>%
  ungroup() %>%
  transmute(watershed, count = count2, year = as.numeric(year), order) %>%
  left_join(calc_method_sp, by = c("watershed" = "watershed", "year" = "year")) %>% # bring methods back when needed
  select(-method) %>%
  spread(year, count) %>%
  arrange(order) %>%
  select(-watershed, -order) %>%
  as.matrix()

rownames(grandtab_imputed_late_fall) <- watershed_order$watershed

grandtab_imputed <- list(fall = grandtab_imputed_fall,
                         late_fall = grandtab_imputed_late_fall,
                         winter = grandtab_imputed_winter,
                         spring = grandtab_imputed_spring)

usethis::use_data(grandtab_imputed, overwrite = TRUE)

# Grandtab Observed -----

# Fall
grandtab_observed_fall <- grandtab_with_yuba_updates %>%
  filter(run == "Fall") %>%
  select(-run) %>%
  filter(count > 100) %>%
  right_join(watershed_order) %>%
  mutate(count = case_when(watershed == "Feather River" ~ round(count * fall_prop_feather_yuba),
                           watershed == "Yuba River" & method == "grandtab" ~ round(count * fall_prop_feather_yuba),
                           T ~ count)) %>%
  select(-method) %>%
  spread(year, count) %>%
  select(-`<NA>`) %>%
  arrange(order) %>%
  select(-watershed, -order) %>%
  as.matrix()

rownames(grandtab_observed_fall) <- watershed_order$watershed

# Winter
grandtab_observed_winter <- grandtab_imputed_winter

# Spring
grandtab_observed_spring <- grandtab_with_yuba_updates %>%
  filter(run == "Spring") %>%
  select(-run, -method) %>%
  right_join(watershed_order) %>%
  spread(year, count) %>%
  select(-`<NA>`) %>%
  arrange(order) %>%
  select(-watershed, -order) %>%
  as.matrix()

rownames(grandtab_observed_spring) <- watershed_order$watershed

grandtab_observed_spring["Feather River", ] <- round(grandtab_observed_fall["Feather River", ]/ fall_prop_feather_yuba * spring_prop_feather_yuba)
grandtab_observed_spring["Yuba River", ] <- round(grandtab_observed_fall["Yuba River", ]/ fall_prop_feather_yuba * spring_prop_feather_yuba)
grandtab_observed_spring["Yuba River", 1:6] <- round(grandtab_observed_fall["Yuba River",  1:6]/ fall_prop_feather_yuba * spring_prop_feather_yuba) # use grantab with prop spring scaling for years that there is no vaki
grandtab_observed_spring["Yuba River", 19:20] <- round(grandtab_observed_fall["Yuba River", 19:20]/ fall_prop_feather_yuba * spring_prop_feather_yuba) # use grantab with prop spring scaling for years that there is no vaki


# Late-Fall
grandtab_observed_late_fall <- grandtab_with_yuba_updates %>%
  filter(run == "Late-Fall") %>%
  select(-run, -method) %>%
  filter(count > 100) %>%
  right_join(watershed_order) %>%
  spread(year, count) %>%
  select(-`<NA>`) %>%
  arrange(order) %>%
  select(-watershed, -order) %>%
  as.matrix()

rownames(grandtab_observed_late_fall) <- watershed_order$watershed

grandtab_observed <- list(fall = grandtab_observed_fall,
                          late_fall = grandtab_observed_late_fall,
                          winter = grandtab_observed_winter,
                          spring = grandtab_observed_spring)
usethis::use_data(grandtab_observed, overwrite = TRUE)

# check species presence ---
# should_be_missing <- DSMscenario::watershed_labels[
#   !as.logical(DSMhabitat::watershed_species_present[1:31, ]$fr *
#                 DSMhabitat::watershed_species_present[1:31,]$spawn)]
# missing <- DSMscenario::watershed_labels[is.nan(rowMeans(grandtab_observed_fall, na.rm = T))]
# all(should_be_missing %in% missing)
# missing <- DSMscenario::watershed_labels[is.nan(rowMeans(grandtab_imputed_fall, na.rm = T))]
# all(should_be_missing %in% missing)
#
# should_be_missing <- DSMscenario::watershed_labels[
#   !as.logical(DSMhabitat::watershed_species_present[1:31, ]$lfr *
#                 DSMhabitat::watershed_species_present[1:31,]$spawn)]
# missing <- DSMscenario::watershed_labels[is.nan(rowMeans(grandtab_observed_late_fall, na.rm = T))]
# all(should_be_missing %in% missing)
# missing <- DSMscenario::watershed_labels[is.nan(rowMeans(grandtab_imputed_late_fall, na.rm = T))]
# all(should_be_missing %in% missing)
#
# should_be_missing <- DSMscenario::watershed_labels[
#   !as.logical(DSMhabitat::watershed_species_present[1:31, ]$sr *
#                 DSMhabitat::watershed_species_present[1:31,]$spawn)]
# missing <- DSMscenario::watershed_labels[is.nan(rowMeans(grandtab_observed_spring, na.rm = T))]
# all(should_be_missing %in% missing)
# missing <- DSMscenario::watershed_labels[is.nan(rowMeans(grandtab_imputed_spring, na.rm = T))]
# all(should_be_missing %in% missing)
#
# should_be_missing <- DSMscenario::watershed_labels[
#   !as.logical(DSMhabitat::watershed_species_present[1:31, ]$wr *
#                 DSMhabitat::watershed_species_present[1:31,]$spawn)]
# missing <- DSMscenario::watershed_labels[is.nan(rowMeans(grandtab_observed_winter, na.rm = T))]
# all(should_be_missing %in% missing)
# missing <- DSMscenario::watershed_labels[is.nan(rowMeans(grandtab_imputed_winter, na.rm = T))]
# all(should_be_missing %in% missing)

# Adult Seeds -----
# Jim used "Battle Creek - Downstream of CNFH" for "Battle Creek"
mean_escapement_2013_2017 <- grandtab_with_yuba_updates %>% #update to use vaki data
  filter(between(year, 2013, 2017)) %>%
  pivot_wider(names_from = run, values_from = count) |>
  mutate(`Adjusted Fall` = ifelse(watershed == "Feather River", Fall * fall_prop_feather_yuba, Fall), #update to add SR to Feather (currently all in Fall)
         Spring = ifelse(watershed == "Feather River", Fall * spring_prop_feather_yuba, Spring),
         Fall = `Adjusted Fall`) |>
  select(-`Adjusted Fall`) |>
  pivot_longer(4:7, names_to = "run", values_to = "count") |>
  group_by(watershed, run) %>%
  summarise(mean = round(mean(count, na.rm = TRUE))) %>%
  spread(run, mean) %>%
  right_join(watershed_order) %>%
  arrange(order) %>%
  select(-order) %>%
  ungroup()

usethis::use_data(mean_escapement_2013_2017, overwrite = TRUE)

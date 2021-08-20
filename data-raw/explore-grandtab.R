library(fallRunDSM)
library(tidyverse)

watershed_order <- tibble(
  watershed = DSMscenario::watershed_labels,
  order = 1:31
)

# SacPas data
grandtab_raw <- read_csv("data-raw/Grandtab_Modified.csv")
unique(grandtab_raw$run)
# Explore Locations -----
unique(grandtab_raw$location)
# location "Butte Creek" for spring run uses carcus count when available then snorkel
butte <- c(
  "Butte Creek - Carcass" = "Butte Creek",
  "Butte Creek - Snorkel" = "Butte Creek",
  "Butte Creek" = "Butte Creek")

grandtab_raw %>%
  mutate(ll = butte[location]) %>%
  filter(!is.na(ll), startyear >= 1998) %>%
  select(startyear, location, count, run) %>%
  spread(startyear, count) %>%  View

# Battle Creek
# remove "Hatchery Transfers to Battle Creek - CNFH" = "Battle Creek" from battle creek sum
# remove " Battle Creek - CNFH "
battle <- c("Battle Creek" = "Battle Creek", "Battle Creek - CNFH" = "Battle Creek",
            "Battle Creek - Downstream of CNFH" = "Battle Creek",
            "Battle Creek - Upstream of CNFH" = "Battle Creek",
            "Hatchery Transfers to Battle Creek - CNFH" = "Battle Creek")

grandtab_raw %>%
  mutate(ll = battle[location]) %>%
  filter(!is.na(ll), startyear >= 1998) %>%
  select(startyear, location, count, run) %>%
  spread(startyear, count) %>%  View

grandtab_raw %>%
  filter(location == "Mokelumne River") %>% View

grandtab_raw %>%
  filter(location %in% names(battle), between(endyear, 2013, 2017)) %>%
  group_by(location, origin) %>%
  summarise(n())
summarise(mean=mean(count, na.rm=T))

# sacramento
# remove "Passing RBDD", "Downstream of RBDD", "Passing RBDD", "Upstream of RBDD"
grandtab_raw %>%
  filter(location %in% c("Mainstem - Downstream of RBDD",
                         "Mainstem - Upstream of RBDD",
                         "Mainstem",
                         "Passing RBDD",
                         "Downstream of RBDD",
                         "Upstream of RBDD"),
         startyear >= 1998, run == "Late-Fall") %>%
  select(startyear, minorbasin, location, count, run) %>%
  spread(startyear, count)


grandtab_raw %>%
  filter(location %in% c("Mainstem - Downstream of RBDD",
                         "Mainstem - Upstream of RBDD",
                         "Mainstem",
                         "Passing RBDD",
                         "Downstream of RBDD",
                         "Upstream of RBDD"),
         between(endyear, 2013, 2017)) %>%
  group_by(location, origin) %>%
  summarise(n())

grandtab_raw %>%
  filter(origin == "Redd Distribution")

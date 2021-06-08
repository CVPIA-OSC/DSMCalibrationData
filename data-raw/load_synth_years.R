# create the data to be cached ----
# fall run
fall_run_calibration <- set_synth_years(species = "fr")
usethis::use_data(fall_run_calibration, overwrite = TRUE)

# spring
spring_run_calibration <- set_synth_years(species = "sr")
usethis::use_data(spring_run_calibration, overwrite = TRUE)

# winter
winter_run_calibration <- set_synth_years(species = "wr")
usethis::use_data(winter_run_calibration, overwrite = TRUE)









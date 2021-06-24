remotes::install_github("CVPIA-OSC/DSMflow@main")
remotes::install_github("CVPIA-OSC/DSMtemperature@main")
remotes::install_github("CVPIA-OSC/DSMhabitat@main")
remotes::install_github("CVPIA-OSC/fallRunDSM@main")
remotes::install_github("CVPIA-OSC/winterRunDSM@main")
remotes::install_github("CVPIA-OSC/latefallRunDSM@main")
remotes::install_github("CVPIA-OSC/springRunDSM@main")

# create the data to be cached ----
# fall run
fall_run_calibration_params <- set_synth_years(species = "fr")
usethis::use_data(fall_run_calibration_params, overwrite = TRUE)

# spring
spring_run_calibration_params <- set_synth_years(species = "sr")
usethis::use_data(spring_run_calibration_params, overwrite = TRUE)

# winter
winter_run_calibration_params <- set_synth_years(species = "wr")
usethis::use_data(winter_run_calibration_params, overwrite = TRUE)

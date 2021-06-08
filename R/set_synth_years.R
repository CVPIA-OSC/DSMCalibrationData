set_synth_years <- function(species = c("fr", "wr", "sr", "st")) {

  species <- match.arg(species)

  inputs <- switch(species,
                   "fr" = fallRunDSM::load_baseline_data(),
                   "wr" = winterRunDSM::load_baseline_data(),
                   "sr" = springRunDSM::load_baseline_data())

  year_index <- DSMCalibrationData::calibration_year_index

  inputs$freeport_flows <- inputs$freeport_flows[ , years]
  inputs$vernalis_flows <- inputs$vernalis_flows[ , years]
  inputs$stockton_flows <- inputs$stockton_flows[ , years]
  inputs$CVP_exports <- inputs$CVP_exports[years, ]
  inputs$SWP_exports <- inputs$SWP_exports[years, ]
  inputs$proportion_diverted <- inputs$proportion_diverted[ , , years]
  inputs$total_diverted <- inputs$proportion_diverted[ , , years]
  inputs$delta_proportion_diverted <- inputs$delta_proportion_diverted[ , years, ]
  inputs$delta_total_diverted <- inputs$delta_total_diverted[ , years, ]
  inputs$prop_pulse_flows <- inputs$prop_pulse_flows[ , years]
  inputs$prop_flow_natal <- inputs$prop_flow_natal[ , years] # extra year
  inputs$upper_sacramento_flows <- inputs$upper_sacramento_flows[ , years]
  inputs$delta_inflow <- inputs$delta_inflow[ , years, ]
  inputs$proportion_flow_bypass <- inputs$proportion_flow_bypass[ , years, ]
  inputs$gates_overtopped <- inputs$gates_overtopped[ , years, ]
  inputs$vernalis_temps <- inputs$vernalis_temps[ , years] # extra year
  inputs$prisoners_point_temps <- inputs$prisoners_point_temps[ , years] # extra year
  inputs$degree_days <- inputs$degree_days[ , , years]
  inputs$avg_temp <- inputs$avg_temp[ , , years] # extra year
  inputs$avg_temp_delta <- inputs$avg_temp_delta[ , years, ] # extra year
  inputs$spawning_habitat <- inputs$spawning_habitat[ , , years] # extra year
  inputs$inchannel_habitat_fry <- inputs$inchannel_habitat_fry[ , , years]
  inputs$inchannel_habitat_juvenile <- inputs$inchannel_habitat_juvenile[ , , years]
  inputs$floodplain_habitat <- inputs$floodplain_habitat[ , , years]
  inputs$weeks_flooded <- inputs$weeks_flooded[ , , years]
  inputs$delta_habitat <- inputs$delta_habitat[ , years, ]
  inputs$sutter_habitat <- inputs$sutter_habitat[ , years]
  inputs$yolo_habitat <- inputs$yolo_habitat[ , years]

  return(inputs)
}

purrr::pwalk()
print(paste(deparse(substitute(inputs[1])), '-', dim(inputs[1])))


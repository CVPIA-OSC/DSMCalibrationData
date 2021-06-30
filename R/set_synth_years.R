#' Set Synthetic Year Series
#' @description Generates model params for running the life cycle models in calibration mode
#' @details This function modifies the baseline model params for a run using
#' the synthetic year series. More details about the synthetic year series can be found
#' here: \code{\link{calibration_year_index}}.
#'
#' Results of running \code{set_synth_years} for each run are cached and accessible via
#' \code{\link{fall_run_calibration}}, \code{\link{winter_run_calibration}},and
#' \code{\link{spring_run_calibration}}
#' @param species either "fr", "lfr", "wr", "sr" for fall run, late fall run, winter run, or spring run respectively
#' @examples
#' \dontrun{
#' params <- set_synth_years("fr")
#' fallRunDSM::fall_run_model(mode = "calibrate", seeds = seeds, ..params = params)
#' }
#' @export
set_synth_years <- function(species = c("fr", "lfr", "wr", "sr", "st")) {

  species <- match.arg(species)

  params <- switch(species,
                   "fr" = fallRunDSM::params,
                   "lfr" = latefallRunDSM::params,
                   "wr" = winterRunDSM::params,
                   "sr" = springRunDSM::params,
                   "st" = steelheadDSM::params)

  spawn_years <- DSMCalibrationData::calibration_year_spawn_index
  years <- DSMCalibrationData::calibration_year_index

  params$freeport_flows <- params$freeport_flows[ , years]
  params$vernalis_flows <- params$vernalis_flows[ , years]
  params$stockton_flows <- params$stockton_flows[ , years]
  params$CVP_exports <- params$CVP_exports[ , years]
  params$SWP_exports <- params$SWP_exports[ , years]
  params$proportion_diverted <- params$proportion_diverted[ , , years]
  params$total_diverted <- params$proportion_diverted[ , , years]
  params$delta_proportion_diverted <- params$delta_proportion_diverted[ , years, ]
  params$delta_total_diverted <- params$delta_total_diverted[ , years, ]
  params$prop_flow_natal <- params$prop_flow_natal[ , spawn_years]
  params$upper_sacramento_flows <- params$upper_sacramento_flows[ , years]
  params$delta_inflow <- params$delta_inflow[ , years, ]
  params$proportion_flow_bypass <- params$proportion_flow_bypass[ , years, ]
  params$gates_overtopped <- params$gates_overtopped[ , years, ]
  params$vernalis_temps <- params$vernalis_temps[ , years]
  params$prisoners_point_temps <- params$prisoners_point_temps[ , years]
  params$degree_days <- params$degree_days[ , , spawn_years]
  params$avg_temp <- params$avg_temp[ , , years]
  params$avg_temp_delta <- params$avg_temp_delta[ , years, ]
  params$spawning_habitat <- params$spawning_habitat[ , , spawn_years]
  params$inchannel_habitat_fry <- params$inchannel_habitat_fry[ , , years]
  params$inchannel_habitat_juvenile <- params$inchannel_habitat_juvenile[ , , years]
  params$floodplain_habitat <- params$floodplain_habitat[ , , years]
  params$weeks_flooded <- params$weeks_flooded[ , , years]
  params$delta_habitat <- params$delta_habitat[ , years, ]
  params$sutter_habitat <- params$sutter_habitat[ , years]
  params$yolo_habitat <- params$yolo_habitat[ , years]

  return(params)
}


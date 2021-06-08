#' @title Calibration Data
#' @description Cached data used for calibration of DSM life cycle models
#' generated with \code{\link{set_synth_years}}
#' @name calibration_data
NULL

#' @rdname calibration_data
#' @format NULL
"fall_run_calibration"

#' @rdname calibration_data
#' @format NULL
"spring_run_calibration"

#' @rdname calibration_data
#' @format NULL
"winter_run_calibration"

#' @title Synthetic Years Index
#' @description We chose proxy years for the calibration time period of 1998-2017
#' by selecting the year from the 1980-1999 model inputs that most closely matched the
#' \href{https://cdec.water.ca.gov/reportapp/javareports?name=WSIHIST}{DWR water year index}
#' in both the San Joaquin and Sacramento Basins of the targeted calibration year.
"calibration_year_index"

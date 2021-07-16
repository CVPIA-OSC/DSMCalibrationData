#' @title Calibration Data
#' @description Cached data used for calibration of DSM life cycle models
#' generated with \code{\link{set_synth_years}}
#' @name calibration_data
NULL

#' @rdname calibration_data
#' @format NULL
"fall_run_calibration_params"


# #' @rdname calibration_data
# #' @format NULL
# "late_fall_run_calibration_params"
#
# #' @rdname calibration_data
# #' @format NULL
# "spring_run_calibration_params"
#
# #' @rdname calibration_data
# #' @format NULL
# "winter_run_calibration_params"


#' @title Synthetic Years Index
#' @description We chose proxy years for the calibration time period of 1998-2017
#' by selecting the year from the 1980-1999 model inputs that most closely matched the
#' \href{https://cdec.water.ca.gov/reportapp/javareports?name=WSIHIST}{DWR water year index}
#' in both the San Joaquin and Sacramento Basins of the targeted calibration year.
"calibration_year_index"

#' @title Grandtab
#' @description GrandTab data is a compilation of sources estimating the late-fall,
#' winter, spring, and fall-run Chinook salmon populations for streams surveyed.
#' Estimates are provided by the California Department of Fish and Wildlife,
#' the US Fish and Wildlife Service, the California Department of Water Resources,
#' the East Bay Municipal Utilities District, the US Bureau of Reclamation,
#' the Lower Yuba River Management Team, and the Fisheries Foundation of California.
#' For more information see \href{https://wildlife.ca.gov/Conservation/Fishes/Chinook-Salmon/Anadromous-Assessment}{CDFW Anadromous Assessment}
#' @name grandtab
NULL

#' @rdname grandtab
#' @format NULL
#' @section Observed:
#' This data will be used in the fitness function to measure the difference
#' between model predictions and observed escapement. Missing values are NA and we
#' made all records less than 100 NA to account for a lack of confidence for counts
#' less than 100.
"grandtab_observed"

#' @rdname grandtab
#' @format NULL
#' @section Imputed:
#'  This data will be used to calculate the number of juveniles during
#' the 20 year simulation. The GrandTab data is incomplete for many watersheds
#' during the 20 year period of calibration. For watersheds with no GrandTab data,
#' we used 40 as the default escapement value. For watersheds with incomplete data,
#' we used the mean escapement value.
"grandtab_imputed"

#' @title Mean Escapement 2013-2017
#' @description Mean Grandtab in-river escapement values for CVPIA SIT watersheds (2013-2017)
#' @details see \link{grandtab} for more information on Grandtab
"mean_escapement_2013_2017"

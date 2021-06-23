# DSMCalibrationData

Calibration data for CVPIA's Structure Decision Making chinook life cycle models.

Contains the following calibration datasets:

* `calibration_year_index` the set of proxy years used to represent model inputs for 1997-2017 selected from the 1979-2000 simulation inputs.
* `fall_run_calibration`, `spring_run_calibration`, `winter_run_calibration` cached model inputs for calibrating model for 1997-2017.
* `grandtab_imputed` used as seeding values for calibration.
* `grandtab_observed` used for comparison to predicted values in optimization process.

and one function: 

* `set_synth_years` generates model inputs for running the life cycle models in calibration mode

See the `data-raw/` directory to see the process for creating the datasets listed above.


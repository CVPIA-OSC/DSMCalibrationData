synth_n_12_20 <- function(n, input_array, model_wy = calibration_year_index) {
  output <- array(NA, dim = c(n, 12, 20))
  synth_year = 1
  for (year in model_wy) {
    output[ , , synth_year] = input_array[, , year]
    synth_year = synth_year + 1
  }
  return(output)
}
synth_12_20_n <- function(n, input_array, model_wy = calibration_year_index) {
  output = array(NA, dim = c(12, 20, n))
  synth_year = 1
  for (year in model_wy) {
    output[ , synth_year, ] = input_array[, year, ]
    synth_year = synth_year + 1
  }
  return(output)
}
# for gate top, 1979-1999, need to use 1997 as 1979 for new 1998-2017 period
synth_12_21_n <- function(n, input_array, model_wy = c(18, calibration_year_index)) {
  output = array(NA, dim = c(12, 21, n))
  synth_year = 1
  for (year in model_wy) {
    output[ , synth_year, ] = input_array[, year, ]
    synth_year = synth_year + 1
  }
  return(output)
}

synth_12_n <- function(n, input_array, model_wy = calibration_year_index) {
  output = array(NA, dim = c(12, n))
  synth_year = 1
  for (year in model_wy) {
    output[ , synth_year] = input_array[, year]
    synth_year = synth_year + 1
  }
  return(output)
}

# fall run
library(fallRunDSM)

set_synth_years <- function(species) {
  run <- fallRunDSM::load_baseline_data()

  migratory_temperature_proportion_over_20 <- migratory_temperature_proportion_over_20
  proportion_diverted <- synth_n_12_20(31, run$proportion_diverted)
  total_diverted <- synth_n_12_20(31, run$total_diverted)
  delta_proportion_diverted <- synth_12_20_n(2, run$delta_proportion_diverted)
  delta_total_diverted <- synth_12_20_n(2, run$delta_total_diverted)
  avg_temp <- synth_n_12_20(31, run$avg_temp)
  avg_temp_delta <- synth_12_20_n(2, run$avg_temp_delta)
  delta_inflow <- synth_12_20_n(2, run$delta_inflow)
  delta_habitat <- synth_12_20_n(2, run$delta_habitat)
  proportion_flow_bypass <- synth_12_20_n(6, run$proportion_flow_bypass)
  # IChab.bypass <- synth_n_12_20(6, run$habitat)
  sutter_habitat <- synth_12_n(20, run$sutter_habitat)
  yolo_habitat <- synth_12_n(20, run$yolo_habitat)
  # floodp.bypass <- synth_n_12_20(6, run$sutter) #https://github.com/CVPIA-OSC/DSMhabitat/issues/7
  # gate.top <- synth_12_21_n(2, run) # https://github.com/CVPIA-OSC/fallRunDSM/issues/4
  weeks_flooded <- synth_n_12_20(31, run$weeks_flooded)
  degree_days <- synth_n_12_20(31, run$degree_days)
  # meanQ <- synth_n_12_20(31, run$flow) # TODO confirm the usage of this is not needed

  prop_flow_natal <- run$prop_flow_natal[,as.character(calibration_proxy_year$calibration_year)]

  upper_sacramento_flows <- run$upper_sacramento_flows[,as.character(calibration_proxy_year$calibration_year)]

  freeport_flows <- run$freeport_flows[,as.character(calibration_proxy_year$calibration_year)]

  cc_gates_prop_days_closed <- run$cc_gates_prop_days_closed
  cc_gates_days_closed <- run$cc_gates_days_closed
  mean_egg_temp_effect <- run$mean_egg_temp_effect
  # Dlt.inp <- run$Dlt.inp # TODO confirm that these are cached into each of the model packages
                          # not affected by synth years so its ok to use the cached versions
  prop_pulse_flows <- run$prop_pulse_flows

  # TODO confirm that these are cached into each of the model packages
  # not affected by synth years so its ok to use the cached versions
  # medQ <- run$medQ
  # inps <- run$inps

  spawning_habitat <- synth_n_12_20(31, run$spawning_habitat)
  inchannel_habitat_fry <- synth_n_12_20(31, run$inchannel_habitat_fry)
  inchannel_habitat_juvenile <- synth_n_12_20(31, run$inchannel_habitat_juvenile)
  floodplain_habitat <- synth_n_12_20(31, run$floodplain_habitat)

  all_inputs <- list(p.tempMC20 = p.tempMC20,
                     p.diver = p.diver,
                     t.diver = t.diver,
                     dlt.divers = dlt.divers,
                     dlt.divers.tot = dlt.divers.tot,
                     juv.tmp = juv.tmp,
                     juv.tmp.dlt = juv.tmp.dlt,
                     Dlt.inf = Dlt.inf,
                     DLThab = DLThab,
                     prop.Q.bypasses = prop.Q.bypasses,
                     IChab.bypass = IChab.bypass,
                     floodp.bypass = floodp.bypass,
                     fp.weeks = fp.weeks,
                     gate.top = gate.top,
                     DegDay = DegDay,
                     retQ = retQ,
                     upSacQ = upSacQ,
                     freeportQ = freeportQ,
                     dlt.gates = dlt.gates,
                     egg.tmp.eff = egg.tmp.eff,
                     Dlt.inp = Dlt.inp,
                     prop.pulse = prop.pulse,
                     medQ = medQ,
                     inps = inps,
                     IChab.spawn = IChab.spawn,
                     IChab.fry = IChab.fry,
                     IChab.juv = IChab.juv,
                     floodP = floodP,
                     aveT20 = aveT20,
                     aveT20D = aveT20D,
                     maxT24 = maxT24,
                     maxT29 = maxT29,
                     meanQ = meanQ)

  switch(species,
         'spring' = {
           all_inputs$SR.pools <- run$SR.pools
           all_inputs$has.SR <- run$has.SR
         },
         'steelhead' = {
           all_inputs$ST.pools <- run$ST.pools
           all_inputs$IChab.adult <- run$IChab.adult
         })

  return(all_inputs)

}

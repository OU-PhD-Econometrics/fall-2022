version 17.0
clear all
set more off
capture log close

log using "sensitivity_examples.log", replace

/*
THIS DO-FILE GOES THROUGH DIFFERENT EXAMPLES OF SENSITIVITY TOOLS
IT IS REQUIRED TO FIRST INSTALL THREE PACKAGES:

1. Krauth (2016) 
net install rcr, from("http://www.sfu.ca/~bkrauth/code")

2. Oster (2019) 
ssc install psacalc

3. Diegert, Masten & Poirier (2022)
ssc install regsensitivity
*/


* load the data
use bfg2020, clear

* create dummies
qui tab statea, gen(statea_d)

* define local macros
local y avgrep2000to2016
local d tye_tfe890_500kNI_100_l6
local x1 log_area_2010 lat lon temp_mean rain_mean elev_mean d_coa d_riv d_lak ave_gyi
local x0 statea_d*
local x `x1' `x0'
local SE cluster(km_grid_cel_code)

* OLS: "short" model
reg `y' `d', `SE'

* OLS: "medium" model
reg `y' `d' `x', `SE'

* Krauth
//rcr `y' `d' `x', lambda(0 0.1) cluster(km_grid_cel_code)

* Oster
qui reg `y' `d' `x', `SE'
psacalc beta `d', delta(0) // returns "medium" OLS result
psacalc beta `d'           // returns an estimate of coeff. of interest ("beta") when ratio of sel. on obs. ÷ sel. on unobs. ("delta") is equal to 1
psacalc delta `d', beta(0) rmax(0.7) // reports ratio of sel. on obs. ÷ sel. on unobs. ("delta") such that coeff. of interest ("beta") is equal to 0

* Diegert et al.
regsensitivity `y' `d' `x', compare(`x1') // Breakdown point = 80.4%, meaning that the OLS coefficient becomes 0 if treatment is 80% as correlated with unobservables as it is with observables
regsensitivity bounds `y' `d' `x', compare(`x1') // only reports the bounds

# Change log for Malaria
To see additional details of the metadata objects mentioned below, refer to the metadata reference documentation of the version in question.

## Aggregate

### Version 1.1.0
* Updated data set `VEM58nY22sO` ("Malaria Elimination"):
	* Added data elements `SXGjaEobp6V` ("GEN - All-cause death"), `cE8SDxizo5s` ("MAL - Suspected malaria cases") and `kRasaq1REFp` ("MAL - Total malaria cases (confirmed + presumed)")
	* Renamed section `RBu2r5nMyBI` to "Malaria cases and deaths"
* Added package `MAL-HIST` ("Malaria historical data"), with data set `F7OVox4TtLP` ("[old records only] Malaria cases") and 6 new data elements. This data set is not intended for prospective data collection, but to allow storing historical data on cases that is not disaggregated by type of confirmation/malaria test. The package is intended to be used as an addition to the complete Malaria elimination or burden reduction packages, and therefore does not include the categories and other metadata that is already included in those complete packages.
* Updated data element `LhcXjWs6lm7`:
	* Code changed to "MAL_CONF_MEAN+2"
	* Name changed to "MAL - Malaria confirmed MEAN+2 STD (threshold)"
	* Formname changed to "MAL - Malaria confirmed MEAN+2 STD (threshold)"
* Updated data element `UH47dKFqTRK`:
	* Code changed to "MAL_LLIN_DISTR_PW"
	* Name changed to "MAL - Long lasting insecticide treated nets distributed to pregnant women"
	* Shortname chnaged to "LLINs distributed to pregnant women"
	* Formname changed to "Number of LLINs distributed to pregnant women"
	* Description changed to "Number of long-lasting insecticidal nets (LLINs) distributed to pregnant women"
* Removed data element `n0tgQ4PjnnT` ("MAL - ANC 1st visit (malaria)"), using instead the equivalent `qqc4NnWVFL9` ("RMNCAH - ANC 1st visit") from the RMNCAH metadata configuration. `qqc4NnWVFL9` is not part of any of the included malaria data sets.
* Updated indicator `blS3OjRXn0c` ("MAL - Percentage of pregnant women attending ANC1"), using data element `qqc4NnWVFL9` instead of `n0tgQ4PjnnT` in the numerator.
* Corrected form names of data elements `AFoWbafBOac` and `NywGy6uMS5r`.
* Included the main RMNCAH data element group (`zXmBu7vpmSw`) and indicator group (`uDy8xg2ofrw`), where relevant data elements/indicators from the RMNCAH metadata configuration are included.
* Added data element `MJFRkoiH4KQ` ("MAL - Long lasting insecticide treated nets distributed to infants")
* Assigned data element `MJFRkoiH4KQ` to data set `qNtxTrp56wV` ("Malaria Annual Data")
* Updated indicator `tIWGvDkU6lb`, name changed to "MAL - Malaria confirmed MEAN+2 STD (threshold)"
* Updated indicator `N8S7Vnntced`
	* Name changed to "MAL - Proportion of foci (active, residual non-active) with zero local cases"
	* Description changed to "Proportion of foci (active, residual non-active) with zero local cases"
* Added indicators:
	* `t7lgbT05u3k` ("MAL - ACTs availability (% of health facility with stock)")
	* `Yf0KTxLcRPE` ("MAL - LLINs availability (% of health facility with stock)")
	* `vK4qNvAtZsG` ("MAL - Percentage of infants received an ITN")
	* `blS3OjRXn0c` ("MAL - Percentage of pregnant women attending ANC1")
	* `VoN285Q7FQG` ("MAL - Percentage of pregnant women received an ITN")
	* `PHKTIO5iFgA` ("MAL - Percentage of pregnant women received IPT1")
	* `lRBSFNlbk3D` ("MAL - Percentage of pregnant women received IPT3")
	* `eGISFgA3Cah` ("MAL - RDTs availability (% of health facility with stock)")
	* `acDxsQjnEof` ("MAL - Malaria test positivity rate (Micr/RDT) (%)")
* Updated predictor `qUSU2OjnKKM`:
	* Name changed to "Malaria confirmed MEAN+2 STD"
	* Generator formula changed to use mean instead of median
* Updated legend `phSksJ6YPO4`
* Added dashboard `VUUrmGS7x42` ("Malaria Maps"), with the following new charts:
	* `XFGdbwY5OA9` ("MAL: Rate of completeness of reporting by health facilities (OPD)")
	* `R2aoozdWrnW` ("MAL: Percentage of suspected cases tested")
	* `uNj85CCHumE` ("MAL: Incidence of confirmed malaria cases")
	* `ZEBh5DFbW73` ("MAL: Malaria test positivity rate")
* Added dashboard `Ly3jbrmhRpB` ("Malaria Trends and Coverage"), with the following new charts:
	* `yJNAGE2iN7e` ("MAL - Trend in coverages: ANC1, ITNs to pregnant women and infants")
	* `odF8xIAXyzh` ("MAL - Trend in coverages: ANC1, IPTp1 and IPTp3")
	* `iSZUMq4XZyd` ("MAL - Trend in MAL - Percentage of estimated pregnancies benefiting from ANC visit and receipt of an ITN")
	* `Xx6WI5IfnoQ` ("MAL - Trend in MAL - Percentage of estimated pregnancies benefiting from ANC visit and receipt of 1,2 and 3 doses of IPTp")
* Updated layout of existing dashboards, changing order and position of dashboard items to work with the new dashboard app
* Fixed validation rule `Kejj3gJ2GD0` ("Positive (Micr) = Sum of species (Pf, Pv, Mixed, Other species)")
* Fixed indicators `xZPfJVUrSsm` and `x2piMpdUU68`, indicator type should be Percentage

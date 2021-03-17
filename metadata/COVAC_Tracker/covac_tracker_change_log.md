# Change logs

If you have installed one of the work in progress packages before the official release, these are the main changes between each iteration:

## Change log for Version 0.1

1. Indicators “AEFI by product”: Modified filter
2. Visualisation “COVAC-AEFI by type of event”: added Bell’s Palsy, Lymphadenopathy, Neurological/Muscular
3. Added explanation for dropout visualisations
4. Added SMS alerts
5. Modified Program rules to fit android requirements
6. Fixed several typos
7. Changed batch number to “render as barcode” on android
8. Modified programme rules for assigning values to underlying diseases from being active in the whole programme to only being active in the vaccination stage

## Change log for version 0.2

1. Added User groups:
COVID Immunization Metadata Admin
COVID Immunization Data Capture
COVID Immunization Data analysis
2. Removed AEFI Stage
3. Removed AEFI Indicators
4. Removed AEFI Program Indicators
5. Added DE “AEFIS present” in the vaccination stage

## Change Log for version 0.3

1. Added Manufacturers
2. Added summy manufacturers option set
3. Added Total doses required for this vaccine
4. Added programme rule which hides manufacturer names depending on vaccine product
5. Added programme rule which assigns number of total doses required
6. Changed “Dose given on” to “Dose given on (Vaccination date)”
7. Changed Unique Identifier attribute to EPI’s unique identifier in order to match AEFI

## Change Log for version 0.4

1. Changed DE “Vaccine type” to “Vaccine given” and changed placeholders option names (i.e. COVAC1) to names of products and  manufacturers (ie “mRNA-1273/Moderna”)
2. Changed DE “Vaccine Name” to vaccine Manufacturer and added a list
3. Added Gamaleya and Sinopharm & respective products (See table below)
4. Added program rule to auto populate manufacturer DE based on vaccine name
5. Added program rule to hide vaccine name options for Astrazeneca
6. Added program rule to auto populate “This is the last dose” DE when a patient is given a second dose. (this assumes that all current products have two doses in their vaccine schedule)
7. Modified the expression in program rule which does not assign a new date for next dose after last dose is completed.
8. Changed AEFI notification from “Please ensure to register this adverse effect in the AEFI stage” to “Please conduct an AEFI investigation following the official procedures for AEFI investigations”
9. Changed placeholder codes

|Vaccine Name|Vaccine Optioncode (old)|Vaccine Option Code (Current)|Manufacturer name|Option Code|Age Recommendation|Dose Interval|Number of doses|
|--- |--- |--- |--- |--- |--- |--- |--- |
|AZD1222 / AstraZeneca|COVAC1|astrazeneca|AstraZeneca|astrazeneca|18|10 days (8-12*)|2|
|AZD1222 / AstraZeneca|COVAC1|astrazeneca|SKBio Astra Zeneca|skbioastrazeneca|18|10 (8-12*)|2|
|BNT162b2 / COMIRNATY Tozinameran (INN) / BioNTech/Pfizer|COVAC2|biontechpfizer|Comirnaty, Tozinameran|biontechpfizer|16|21|2|
|mRNA-1273 / Moderna|COVAC3|moderna|mRNA-1273|moderna|18|28|2|
|Gamaleya|COVAC4|gamaleya|Sputnik V|gamaleya|18|21|2|
|SARS-CoV-2 Vaccine (VeroCell), Inactivated / Sinopharm|COVAC5|sinopharm|Coronavac, BBIBP-CorV|sinopharm|18|21 days (21-28)*|2|

## Change log for version 0.5

1. Changed COVAX to COVAC
2. Changed order of Custom working lists
3. Added a prefix “COVAC” to objects which could give import issues with instances that have existing packages (Sex, Yes/No/Unknown/, Urban/Rural)

## Change log for version 1.1

1. Modified program rule “  If previous vaccine is same as current vaccine, hide explanation field”
2. Added program rule “Hide Suggested date for next dose if second dose and vaccine product has no more doses”
3. Modified expression in Program rule “If patient has had underlying diseases, transfer that value to following stage” and added action to assign value to current PR variable.
4. Modified expressions in Program rules “If client has a history of XXX assign value to current event”

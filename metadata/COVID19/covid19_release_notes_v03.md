# Package Release Notes v0.3

## Overview

We have made several updates to the existing package to align with new COVID-19 [surveillance guidelines released by the WHO on March 20, 2020](https://www.who.int/emergencies/diseases/novel-coronavirus-2019/technical-guidance/surveillance-and-case-definitions) and introduced new components to the overall package of support. Please review the notes here and contact us on the COVID-19 discussion board in the [community of practice](https://community.dhis2.org/c/implementation/covid-19/) with any questions.

**All metadata packages and documentation can be downloaded from [dhis2.org.covid-19](https://www.dhis2.org/covid-19).**

Packages are currently translated into French, Spanish, Portuguese and Russian, with additional languages in the pipeline (Arabic, Lao, Burmese). We can support metadata package translations in our global translation platform and invite the community to contribute if your country is interested in translating the package for a new language. [Check out our Community of Practice announcement](https://community.dhis2.org/t/the-new-dhis2-translation-platform-is-now-available/37755)and get started as a contributing translator here [by joining the DHIS2 translation platform](https://docs.dhis2.org/en/implement/understanding-dhis2-implementation/localization-of-dhis2.html). Please contact us at translate@dhis2.org.

The new release includes:

1. COVID-19 Case-based Surveillance Tracker program (v0.3.3)
2. COVID-19 Contact Registration & Follow-Up program (v0.3.2)
3. COVID-19 Surveillance Event program (v0.3.2)
4. COVID-19 Aggregate Surveillance Reporting (v0.3.2)
5. **NEW** Points of Entry Screening Tracker program (v0.3.1)

## COVID-19 Case-Based Surveillance Program (Tracker)

1. Metadata codes updated to align with the [WHO case-based reporting data dictionary](https://www.who.int/docs/default-source/coronaviruse/2020-02-27-data-dictionary-en.xlsx)
2. Program indicators updated to reflect new WHO case definitions for probable cases (reference the updated case definitions in the interim surveillance guidelines updated March 20, 2020 [WHO interim surveillance guidelines updated March 20, 2020](https://apps.who.int/iris/bitstream/handle/10665/331506/WHO-2019-nCoV-SurveillanceGuidance-2020.6-eng.pdf))
3. Age legends have been updated to meet new WHO guidance for weekly reporting
4. relationshipType added to metadata package
5. Minor fixes to the metadata to enable easier installation of the package (i.e. indicatorType UID matches indicator type included in aggregate package)

## COVID-19 Contact Registration & Follow-up Program (Tracker)

1. A new program stage has been added to enable repeatable ‘follow-up’ of a case contact. This was added to reflect workflows implemented in Uganda and Togo where contacts may be monitored repeatedly over the course of 14 days to determine if there are symptoms. The ***program*** is based on WHO guidelines which can be found [here](https://www.who.int/internal-publications-detail/considerations-in-the-investigation-of-cases-and-clusters-of-covid-19), as well as information obtained via the [OpenWHO](https://openwho.org/courses/introduction-to-ncov) website.
2. Age legends have been updated to meet new WHO guidance for weekly reporting
3. relationshipType added to metadata package
4. Minor fixes to the metadata to enable easier installation of the package

### COVID-19 Event Reporting Program

1. Program rules updated to prevent error when submitting the form in row view (see [Jira issue 8519](https://jira.dhis2.org/browse/DHIS2-8519))
2. Program indicators updated to reflect new WHO case definitions
3. Age legends have been updated to meet new WHO guidance for weekly reporting
4. Minor fixes to the metadata to enable easier installation of the package

### COVID-19 Aggregate Surveillance Reporting

The following updates were made to reflect new guidance in [WHO guidelines updated March 20, 2020](https://apps.who.int/iris/bitstream/handle/10665/331506/WHO-2019-nCoV-SurveillanceGuidance-2020.6-eng.pdf), including updated global aggregate reporting to WHO (weekly & daily)

1. Age categories updated according to new age groups
2. New indicators added for proportion of males among confirmed cases and proportion of males among confirmed deaths
3. New weekly dataset to capture classification of transmission at sub-national level one (i.e. provincial -- can be assigned to any sub-national level as appropriate in country) per updated WHO weekly reporting guidelines
4. Minor fixes to the metadata to enable easier installation of the package

### **NEW** Points of Entry Tracker Program

The Points of Entry tracker program use case was designed to support the registration of travellers entering a country with a history of travel to, or residence in, a country/area/territory reporting local transmission of COVID-19 who may need to be followed up to ensure no symptoms develop. It is based on the design implemented by HISP Sri Lanka to support the Sri Lanka Ministry of Health with minor changes to make the program more generic to global use and to align with the other tracker programs in the COVID-19 package. The package supports interventions at Points of Entry detailed in the WHO [technical guidance for the management of ill persons at points of entry](https://www.who.int/emergencies/diseases/novel-coronavirus-2019/technical-guidance/points-of-entry-and-mass-gatherings).

Please read more about the POE program in the [system design document](covid-19-poe-tracker-design.md).

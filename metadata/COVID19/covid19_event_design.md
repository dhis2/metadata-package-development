# COVID-19 Surveillance Event Program System Design

Last updated 19/03/2020

Package version: 0.3.2

DHIS2 Version compatibility 2.33.2

Demo: [https://covid.dhis2.org](https://covid.dhis2.org/demo)

## Purpose

The COVID-19 Surveillance Event Program System Design document provides an overview of the design principles and guidance used to develop the digital data package for aggregate COVID-19 surveillance. This document is intended for use by DHIS2 implementers at country and regional level to be able to support implementation and localisation of the package. The COVID-19 metadata package can be adapted to local needs and national guidelines. In particular, local work flows and national guidelines should be considered in the localization and adoption of the programs included in this package.

## Background

The COVID-19 digital data package was developed in response to an expressed need from countries to rapidly adapt a solution for managing COVID-19 data. UiO has developed COVID-19 surveillance packages for three types of data models (tracker, event-based aggregate) to enable countries to select the model that is most appropriate for their context given the burden of disease and available resources. These models and their relative benefits/limitations are summarized below:

|Type of Surveillance Package|Case-based Surveillance (Tracker)|Surveillance (Event)|Surveillance (Aggregate)|
|--|--|--|--|
|_Description_|Enrolls a case and tracks over time through laboratory confirmation & case outcome|Captures critical case details in line-listing format|Enables daily or weekly reporting of key aggregate data points|
|_Pros_|Highly granular data and multiple time dimensions for analysis, can support decentralized workflow, all events linked to the case|More granular than aggregate and can capture key time dimensions (i.e. report date vs onset of symptoms); reduced burden of data entry compared to tracker and little complexity|Low complexity, easy to implement, most manageable when cases numbers are high|
|_Cons_|Burden of data entry may be overwhelming when number of cases reach threshold; complexity of implementation|Does not support case-follow up or other decentralized workflows|Less granularity for detailed analysis (i.e. analysis only based on case reporting date, limited disaggregation)

**This document covers only the design of the surveillance event program package**; separate system design documents are available for DHIS2 Tracker and aggregate packages.

WHO is “urging all countries to prepare for the potential arrival of COVID-19 by readying emergency response systems; increasing capacity to detect and care for patients; ensuring hospitals have the space, supplies and necessary personnel; and developing life-saving medical interventions.”

The objectives of COVID-19 surveillance are:

1. to monitor trends of the disease where human to human transmission occurs;
2. rapidly detect new cases in countries where the virus is not circulating;
3. provide epidemiological information to conduct risk assessments at the national, regional and global level; and
4. provide epidemiological information to guide preparedness and response measures.

The system design builds upon existing disease surveillance principles and information system requirements that have been developed collaboratively between the WHO and UiO since 2017. The COVID-19 package was developed with the intent to align to [WHO technical guidance on nCoV-19 surveillance and case definitions](https://www.who.int/emergencies/diseases/novel-coronavirus-2019/technical-guidance/surveillance-and-case-definitions), last updated March 20, 2020. Note that this design may not necessarily reflect the latest available interim global guidance developed by WHO as updates may be released rapidly. National guidelines and policies may vary and it is recommended to adapt this package to local context.

## System Design Summary

This package is designed as a DHIS2 [Event Program](https://docs.dhis2.org/en/use/user-guides/dhis-core-version-master/configuring-the-system/programs.html#about_event_program). **The Event Program is not designed to capture all data variables contained in the [WHO case reporting template](https://www.who.int/docs/default-source/coronaviruse/2020-02-27-data-dictionary-en.xlsx)**. To capture a complete set of WHO case reporting variables, please refer to the DHIS2 COVID-19 Case-based Surveillance Tracker. Rather, the event program is a simplified program that captures a subset of minimum critical data points to facilitate high data quality when the number of caseloads or burden of reporting exceeds capacity for successfully completing the full line-list for suspected COVID-19 cases. For implementers who wish to capture the complete WHO line-listing, please refer to the COVID-19 Case-based Surveillance Tracker Package.

The COVID-19 Surveillance Event Program data package includes:

1. Event program and data elements case reporting
2. Core indicators
3. Dashboard

### Use Case: Simplified line-listing of COVID-19 cases

As cases increase rapidly, some countries may struggle with case-based reporting as the burden becomes too high. The event package is designed to capture the most critical data points in a line-list and analytical capacities for surveillance and response. The event package is designed as a standalone program. However, countries may use the event package in combination with other packages (i.e. event reports and daily aggregate reporting); or, they may shift from tracker to event to aggregate as caseloads and reporting burden increases. **_Countries should plan carefully how they intend to implement these packages in combination, including reporting flows, transitioning from one data model to another, and how to maintain historical data for analysis if transitioning between data models.   _**

The design of the event-based line-listing program assumes that [WHO case definitions](https://apps.who.int/iris/bitstream/handle/10665/331506/WHO-2019-nCoV-SurveillanceGuidance-2020.6-eng.pdf) are followed in the use case; countries should follow national case definitions for classifying cases as suspected, probably or confirmed.

#### Intended users

* Health facility users: capture and report key data on COVID-19 cases and deaths presenting at the health facility
* National and local health authorities: monitor and analyse disease surveillance data through dashboards and analytics tools to conduct risk assessments and plan response measures; generate reports for regional and global reporting

#### Workflow

Unlike the tracker program, there are limitations to decentralization of the data reporting workflow in an Event program. The most significant limitation is that the Case Outcome (recovery or death) is often not known until days or weeks after the case is reported. The current program design allows for the following workflow options:

1. Event is created when a suspected case is reported. All known data is entered, but the event is not completed. A user can select an ‘Active Event’ from a working list based on User filters and criteria. When missing data becomes available (i.e. the case outcome), the user can enter the remaining data fields and complete the event. Cases can be identified in the event list by the Case ID data element. See the image below as an example which can be accessed within the Capture App:
![Capture App](resources/images/EVENT_image1.png "Capture App")

2. Event is created. All case related data is entered retrospectively, including the Outcome. Event is completed. _The limitation is this approach is timeliness of the data reporting, as new suspected cases might not be captured until their outcome which is often too late for decision making._

### Program Structure

The program is called ‘COVID-19 Cases (events)’

|Section|Description|
|--|--|
|Date of report|Event Date<br>_Countries may re-name the event date to apply to their protocols._|
|Section 1<br>**Basic Information**|Records basic demographic data.<br>_Countries may add data elements as desired._<br>- **Patient ID**<br>Can be used to filter events in working lists, eg. Active events<br>- **Sex**<br>- **Age**|
|Section 2<br>Case Details|Records information about the case including symptoms, severity, testing, etc.<br>- **Symptoms**<br>Options: Yes / No<br>Specifies whether a case has any symptoms at time of notification <br><br> - **Date of symptoms onset**<br>Only appears if symptoms are present;<br>Date of symptoms onset, if available, will replace “Date of Report” in data analytics and reporting. <br><br> - **Case Severity (at time of notification)**<br>Options: Mild / Moderate / Severe / Critical<br>- **Laboratory tested?**<br>Options: Yes / No/ Unknown<br>Specifies whether a case has been laboratory tested for COVID-19 <br><br> - **Test Result**<br>Only appears if the case was laboratory tested<br>Options: Inconclusive / Positive / Negative / Unknown<br>The program is designed to capture only the final test result. Results for each individual test (if available) and the total number of tests performed are not captured.<br>- **Case Classification**<br>Options: Suspected case / Probable case / Laboratory confirmed case<br>Automatically assigned values<br>The values are assigned by Program rules in accordance with WHO case definitions<br>This feature can be useful in filtering active cases in the working lists.|
|Section 3<br>**Exposures**|- **Has the case traveled in the 14 days prior to symptoms onset?**<br>Options: Yes / No / Unknown<br>Specifies travel history of the case. <br><br> - **Likely Infection Source**<br>Options: Imported case* / Local Transmission / Exposure unknown<br>* Imported case option appears only if the case traveled in the 14 days prior to symptoms onset <br><br> - **Specify local source**<br>Only appears if Likely Infection Source is Local Transmission<br>Options: Community (workplace, public transport, etc.) / Household / Healthcare Facility / Close Contact with Other Infected Individual / Exposure Unknown <br><br> - **Case Type**<br>Options: New index case / Linked to existing cluster / Unknown<br>Specifies whether the case is connected to an existing cluster or is a new index case|
|Section 4<br>**Treatment**|- **Hospitalised**<br>Options: Yes / No<br><br>- **Did the case receive care in an intensive care unit (ICU)?**<br>Only appears if the case is hospitalised<br>Options: Yes / No|
|Section 5<br>**Contacts**|- **Total number of contacts followed for this case**<br>Records number of contacts|
|Section 6<br>**Outcome**|- **Health outcome**<br>Options: Recovered / Death|
|Section 7<br>**Assigned Date of onset of symptoms**|- **Calculated onset date (for Indicators)**<br>This section is used only to calculate indicators based on report date vs. date of onset of symptoms]<br>This automatically assigned date is used in program indicators. Initially, it is the report date. If the date of onset of symptoms is available, the date is replaced by the date of onset of symptoms.|
|**Status**|**This is a generic field included in all Event Program**<br>**Complete event**<br>Option: Yes<br>The event should only be marked as ‘complete’ if all data entry has been completed. If the user is waiting to complete certain fields (such as case outcome), the event should be left not complete.<br>Events that are not marked as ‘Complete’ are maintained as active and can be more easily searched by the user in a working list|
|Section 9<br>**Comments**|- **Comments**<br>Optional comments and remarks. Note that these comments will not display in the analytics and can only be accessed through the Capture app used to enter line-listed data.|

### User Groups

The following user groups are included in the metadata package:

1. COVID19 admin -- intended for system admins to have metadata edit rights
2. COVID19 data capture -- intended for data entry staff to have access to capture data
3. COVID19 access -- intended for users such as analytics users who should be able to view the data, but not edit metadata. 

Currently, only users assigned to the COVID19 data capture group will have access to capture data in the program.  Please refer to the installation guidance for more instructions.

### Program Rules

The following program rules have been configured for the program:

|Program Rule Name|Program Rule Description|
|--|--|
|Assign Empty Value to Class Classification|Automation: Assign Empty Value to Class Classification|
|Assign Event Date|Automation: Assign Event date if to onset date if no Onset date is available|
|Assign 'Laboratory Confirmed Case' to Case Classification|Automation: Assign 'Laboratory Confirmed Case' to Case Classification|
|Assign Onset Date|Automation: Assign Symptoms Onset Date if available|
|Assign 'Probable Case' to Case Classification|Automation: Assign 'Probable Case' to Case Classification|
|Assign 'Suspected Case' to Case Classification|Automation: Assign Suspected Case' to Case Classification|
|Hide Case Classification Field|Hide Case Classification Field until Lab Test question is answered|
|Hide ICU field|Hide ICU field unless Hospitalised|
|Hide 'Imported Case'|Hide 'Imported Case' if not traveled|
|Hide Onset of Symptoms Date|Hide Onset of Symptoms Date if no symptoms|
|Hide Outcome Options|Hide irrelevant Outcome Options|
|Hide 'Specify Local Infection Source'|Hide 'Specify Local Infection Source' unless Local Transmission is selected|
|Hide Test Result Field|Hide Test Result Field until Lab Test question is answered with yes|
|Hide Test Result Options|Hide Irrelevant Test Result Options|
|Hide Unknown Options|Hide Irrelevant Unknown Options|

You can read more about program rules here:

[https://docs.dhis2.org/master/en/user/html/configure_program_rule.html](https://docs.dhis2.org/en/use/user-guides/dhis-core-version-master/configuring-the-system/programs.html#configure_program_rule)

### Indicators and Program Indicators

From the data captured in the COVID-19 line-listing program, we can calculate the following indicators, including those recommended by the WHO for daily and weekly reporting, present them in a dashboard. All COVID-19 program indicators based on the event program are assigned to the Program Indicator Group ‘COVID-19 Events.’

|||
|--|--|
|COVID-19 - Cases admitted in intensive care unit (ICU)|COVID-19 Cases admitted in intensive care unit (ICU)|
|COVID-19 - Cases exposed through healthcare facility|Cases where infection is suspected to have occurred in a health care setting|
|COVID-19 - Cases infected by community transmission|Cases where infection is suspected to have occurred through community spread|
|COVID-19 - Cases infected by household transmission|Cases where infection is suspected to have occurred within the household|
|COVID-19 - Cases infected by local transmission|Cases where infection is suspected to have occurred locally, not in another country|
|COVID-19 - Cases infected through other contact with other infected individual|Cases where infection is suspected to have occurred through other close contact with an infected individual (excluding those listed: household, known cluster, HCF)|
|COVID-19 - Cases linked to known cluster|Cases where infection is suspected to have occurred by linkage to a known cluster of cases|
|COVID-19 - Cases with unknown exposure|Cases where source of infection or exposure is unknown|
|COVID-19 - Deaths|COVID-19 related deaths (deaths recorded among all suspected cases)|
|
COVID-19 - Confirmed Hospitalised Cases|Number of confirmed cases that were admitted into hospital|
|COVID-19 - Imported Cases|Cases where likely source of infection is recorded as another country or imported from another country.|
|COVID-19 - Laboratory confirmed cases|Suspected cases that were confirmed through laboratory testing (multiple lab tests may be conducted; this indicator assumes that the last test result is "Positive"); displayed by report date|
|COVID-19 - Laboratory confirmed cases - by onset of symptoms|Suspected cases that were confirmed through laboratory testing (multiple lab tests may be conducted; this indicator assumes that the last test result is "Positive"); displayed by date of onset of symptoms|
|COVID-19 - Laboratory tested cases|Number of suspected cases that received a laboratory test (includes inconclusive lab testing results)|
|COVID-19 - Probable cases|Suspected cases with inconclusive laboratory results or not tested for any reason, by reported date|
|COVID-19 - Probable cases - by onset of symptoms|Suspected cases with inconclusive laboratory results or not tested for any reason, by date of onset of symptoms|
|COVID-19 - Recovered cases|Number of cases that are recovered (By date of onset of symptoms)|
|COVID-19 - Suspected cases|Total number of cases suspected with COVID-19, by report date|
|COVID-19 - Suspected cases - by onset of symptoms|Total number of cases suspected with COVID-19, by date of onset of symptoms|
|COVID-19 - Suspected cases not tested|Total number of suspected cases without a lab result|
|COVID-19 Event - case fatality rate|COVID-19 related deaths (deaths recorded among all suspected cases)|
|COVID-19 Deaths by sex and age group|Male, 0-4, 5-14, 15-24, 25-34, 35-44, 45-54, 55-64, 65-74, 75-84, 85+<br>Female, 0-4, 5-14, 15-24, 25-34, 35-44, 45-54, 55-64, 65-74, 75-84, 85+|
|COVID-19 Confirmed cases by sex and age group|Male, 0-4, 5-14, 15-24, 25-34, 35-44, 45-54, 55-64, 65-74, 75-84, 85+<br>Female, 0-4, 5-14, 15-24, 25-34, 35-44, 45-54, 55-64, 65-74, 75-84, 85+|
|COVID-19 Suspected cases by sex and age group|Male, 0-4, 5-14, 15-24, 25-34, 35-44, 45-54, 55-64, 65-74, 75-84, 85+<br>Female, 0-4, 5-14, 15-24, 25-34, 35-44, 45-54, 55-64, 65-74, 75-84, 85+|

## References

* [COVID-19 Surveillance, Response & Vaccine Delivery Toolkit](https://dhis2.org/covid-19)
* WHO Technical guidance on COVID-19 surveillance and case definitions (last updated 20 March 2020)
[https://www.who.int/emergencies/diseases/novel-coronavirus-2019/technical-guidance/surveillance-and-case-definitions](https://www.who.int/emergencies/diseases/novel-coronavirus-2019/technical-guidance/surveillance-and-case-definitions)
* WHO Data Dictionary for COVID-19 Case Reporting Form
[https://www.who.int/docs/default-source/coronaviruse/2020-02-27-data-dictionary-en.xlsx](https://www.who.int/docs/default-source/coronaviruse/2020-02-27-data-dictionary-en.xlsx)
* WHO Laboratory testing for 2019 novel coronavirus (2019-nCoV) in suspected human cases (last updated 2 March 2020) [https://www.who.int/publications-detail/laboratory-testing-for-2019-novel-coronavirus-in-suspected-human-cases-20200117](https://www.who.int/publications-detail/laboratory-testing-for-2019-novel-coronavirus-in-suspected-human-cases-20200117)
* WHO Considerations in the investigation of cases and clusters of COVID-19 (last updated 13 March 2020) [https://www.who.int/internal-publications-detail/considerations-in-the-investigation-of-cases-and-clusters-of-covid-19](https://www.who.int/internal-publications-detail/considerations-in-the-investigation-of-cases-and-clusters-of-covid-19)
* WHO Coronavirus situation reports
[https://www.who.int/emergencies/diseases/novel-coronavirus-2019/situation-reports](https://www.who.int/emergencies/diseases/novel-coronavirus-2019/situation-reports)

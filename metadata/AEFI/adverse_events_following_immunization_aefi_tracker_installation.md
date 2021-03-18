# AEFI Tracker Installation Guide

## Overview

The AEFI tracker package was developed using DHIS2.33.2. This was done in order to support some of the latest features in DHIS2. In order to use the package, it is recommended that you install it into a DHIS2 instance using DHIS2 2.33.2 or above. If you will be setting this up on a new instance, please refer to the [DHIS2 installation guide](https://docs.dhis2.org/master/en/dhis2_system_administration_guide/installation.html).

## Installation

Installation of the module consists of several steps:

1. [Preparing](#preparing-the-metadata-file) the metadata file with DHIS2 metadata.
2. [Importing](#importing-metadata) the metadata file into DHIS2.
3. [Configuring](#additional-configuration) the imported metadata.
4. [Adapting](#adapting-the-tracker-program) the program after being imported

It is recommended to first read through each section before starting the installation and configuration process in DHIS2. Sections that are not applicable have been identified, depending on if you are importing into a new instance of DHIS2 or a DHIS2 instance with metadata already present. The procedure outlined in this document should be tested in a test/staging environment before either being repeated or transferred to a production instance of DHIS2.

## Requirements

In order to install the module, an administrator user account on DHIS2 is required. The procedure outlined in this document should be tested in a test/staging environment before being performed on a production instance of DHIS2.

Great care should be taken to ensure that the server itself and the DHIS2 application is well secured, to restrict access to the data being collected. Details on securing a DHIS2 system is outside the scope of this document, and we refer to the [DHIS2 documentation](http://dhis2.org/documentation).

## Preparing the metadata file

**NOTE**: If you are installing the package on a new instance of DHIS2, you can skip the “Preparing the metadata file” section and move immediately to the section on “[Importing a metadata file into DHIS2](#importing-metadata).”

While not always necessary, it can often be advantageous to make certain modifications to the metadata file before importing it into DHIS2.

### Default data dimension

In early versions of DHIS2, the UID of the default data dimension was auto-generated. Thus, while all DHIS2 instances have a default category option, data element category, category combination and category option combination, the UIDs of these defaults can be different. Later versions of DHIS2 have hardcoded UIDs for the default dimension, and these UIDs are used in the configuration packages.

To avoid conflicts when importing the metadata, it is advisable to search and replace the entire .json file for all occurrences of these default objects, replacing UIDs of the .json file with the UIDs of the database in which the file will be imported. Table 1 shows the UIDs which should be replaced, as well as the API endpoints to identify the existing UIDs

|Object|UID|API endpoint|
|--|--|--|
|Category|GLevLNI9wkl|../api/categories.json?filter=name:eq:default|
|Category option|xYerKDKCefk|../api/categoryOptions.json?filter=name:eq:default|
|Category combination|bjDvmb4bfuf|../api/categoryCombos.json?filter=name:eq:default|
|Category option combination|HllvX50cXC0|../api/categoryOptionCombos.json?filter=name:eq:default|

For example, if importing a configuration package into <https://play.dhis2.org/demo>, the UID of the default category option combination could be identified through <https://play.dhis2.org/demo/api/categoryOptionCombos.json?filter=name:eq:default> as bRowv6yZOF2.

You could then search and replace all occurrences of HllvX50cXC0 with bRowv6yZOF2 in the .json file, as that is the ID of default in the system you are importing into. ***Note that this search and replace operation must be done with a plain text editor***, not a word processor like Microsoft Word.

### Indicator types

Indicator type is another type of object that can create import conflict because certain names are used in different DHIS2 databases (.e.g "Percentage"). Since Indicator types are defined simply by their factor and whether or not they are simple numbers without a denominator, they are unambiguous and can be replaced through a search and replace of the UIDs. This avoids potential import conflicts, and avoids creating duplicate indicator types. Table 2 shows the UIDs which could be replaced, as well as the API endpoints to identify the existing UIDs

|Object|UID|API endpoint|
|--|--|--|
|Numerator only (number)|CqNPn5KzksS|../api/indicatorTypes.json?filter=number:eq:true&filter=factor:eq:1|

#### Tracked Entity Type

Like indicator types, you may have already existing tracked entity types in your DHIS2 database. The references to the tracked entity type should be changed to reflect what is in your system so you do not create duplicates. Table 3 shows the UIDs which could be replaced, as well as the API endpoints to identify the existing UIDs

|Object|UID|API endpoint|
|--|--|--|
|Person|MCPQUTHX1Ze|../api/trackedEntityTypes.json?filter=name:eq:Person|

#### Event report organisation Unit

In the AEFI metadata package there are event reports tied to the root level unit of the organisation unit tree. The reference to the organisation unit needs to be replaced with the UID of the root unit of the organisation unit tree in your system. Table 4 shows the UID which need to be replaced, as well as the api endpoint to identify the existing organisation unit UID

|Object|UID|API  endpoint|
|--|--|--|
|Organisation unit|GD7TowwI46c|../api/organisationUnits.json?level=1|

## Importing metadata

The .json metadata file is imported through the [Import/Export](https://docs.dhis2.org/master/en/user/html/import_export.html) app of DHIS2. It is advisable to use the "dry run" feature to identify issues before attempting to do an actual import of the metadata. If "dry run" reports any issues or conflicts, see the [import conflicts](https://who.dhis2.org/documentation/installation_guide_complete.html#handling-import-conflicts) section below. If the "dry run"/"validate" import works without error, attempt to import the metadata. If the import succeeds without any errors, you can proceed to [configure](https://who.dhis2.org/documentation/installation_guide_complete.html#configuration) the module. In some cases, import conflicts or issues are not shown during the "dry run", but appear when the actual import is attempted. In this case, the import summary will list any errors that need to be resolved.

### Handling import conflicts

***NOTE***: If you are importing into a new DHIS2 instance, you will not have to worry about import conflicts, as there is nothing in the database you are importing to to conflict with. Follow the instructions to import the metadata then please proceed to the “[Additional configuration](#additional-configuration)” section.

There are a number of different conflicts that may occur, though the most common is that there are metadata objects in the configuration package with a name, shortname and/or code that already exists in the target database. There are a couple of alternative solutions to these problems, with different advantages and disadvantages. Which one is more appropriate will depend, for example, on the type of object for which a conflict occurs.

#### Alternative 1

Rename the existing object in your DHIS2 database for which there is a conflict. The advantage of this approach is that there is no need to modify the .json file, as changes are instead done through the user interface of DHIS2. This is likely to be less error prone. It also means that the configuration package is left as is, which can be an advantage for example when training material and documentation based on the configuration package will be used.

#### Alternative 2

Rename the object for which there is a conflict in the .json file. The advantage of this approach is that the existing DHIS2 metadata is left as-is. This can be a factor when there is training material or documentation such as SOPs of data dictionaries linked to the object in question, and it does not involve any risk of confusing users by modifying the metadata they are familiar with.

Note that for both alternative 1 and 2, the modification can be as simple as adding a small pre/post-fix to the name, to minimise the risk of confusion.

#### Alternative 3

A third and more complicated approach is to modify the .json file to re-use existing metadata. For example, in cases where an option set already exists for a certain concept (e.g. "sex"), that option set could be removed from the .json file and all references to its UID replaced with the corresponding option set already in the database. The big advantage of this (which is not limited to the cases where there is a direct import conflict) is to avoid creating duplicate metadata in the database. There are some key considerations to make when performing this type of modification:

* it requires expert knowledge of the detailed metadata structure of DHIS2
* the approach does not work for all types of objects. In particular, certain types of objects have dependencies which are complicated to solve in this way, for example related to disaggregations.
* future updates to the configuration package will be complicated.

## Additional configuration

Once all metadata has been successfully imported, there are a few steps that need to be taken before the module is functional.

### Sharing

First, you will have to use the *Sharing* functionality of DHIS2 to configure which users (user groups) should see the metadata and data associated with the programme as well as who can register/enter data into the program. By default, sharing has been configured for the following:

* Tracked entity type
* Program
* Program stages
* Dashboards

There are six user groups that come with the package, the last three are recipients of program stage notifications:

* AEFI access
* AEFI admin
* AEFI data capture
* AEFI district
* AEFI national
* AEFI first-level decision making

By default the following is assigned to these user groups

|Object|User Group|||
|--|--|--|--|
||_AEFI access_|_AEFI admin_|_AEFI data capture_|
|_*Tracked entity type*_|Metadata : can view <br> Data: can view|Metadata : can edit and view <br> Data: can view|Metadata : can view <br> Data: can capture and view|
|_*Program*_|Metadata : can view <br> Data: can view|Metadata : can edit and view <br> Data: can view|Metadata : can view <br> Data: can capture and view|
|_*Program Stages*_|Metadata : can view <br> Data: can view|Metadata : can edit and view <br> Data: can view|Metadata : can view <br> Data: can capture and view|
|_*Dashboards*_|Metadata : can view|Metadata : can edit and view|Metadata : none|

You will want to assign your users to the appropriate user group based on their role within the system. You may want to enable sharing for other objects in the package depending on your set up. Refer to the [DHIS2 Documentation](https://docs.dhis2.org/master/en/dhis2_user_manual_en/about-sharing-of-objects.html) for more information on configuring sharing.

### User Roles

Users will need user roles in order to engage with the various applications within DHIS2. The following minimum roles are recommended:

1. Tracker data analysis : Can see event analytics and access dashboards, event reports, event visualizer, data visualizer, pivot tables, reports and maps.
2. Tracker data capture : Can add data values, update tracked entities, search tracked entities across org units and access tracker capture

Refer to the [DHIS2 Documentation](http://dhis2.org/documentation) for more information on configuring user roles.

### Organisation Units

You must assign the program to organisation units within your own hierarchy in order to be able to see the program in tracker capture.

### Duplicated metadata

**NOTE**: This section only applies if you are importing into a DHIS2 database in which there is already meta-data present. If you are working with a new DHIS2 instance, please skip this section and go to [Adapting the tracker program](#adapting-the-tracker-program).”

Even when metadata has been successfully imported without any import conflicts, there can be duplicates in the metadata - data elements, tracked entity attributes or option sets that already exist. As was noted in the section above on resolving conflict, an important issue to keep in mind is that decisions on making changes to the metadata in DHIS2 also needs to take into account other documents and resources that are in different ways associated with both the existing metadata, and the metadata that has been imported through the configuration package. Resolving duplicates is thus not only a matter of "cleaning up the database", but also making sure that this is done without, for example, breaking potential integrating with other systems, the possibility to use training material, breaking SOPs etc. This will very much be context-dependent.

One important thing to keep in mind is that DHIS2 has tools that can hide some of the complexities of potential duplications in metadata. For example, where duplicate option sets exist, they can be hidden for groups of users through [sharing](https://docs.dhis2.org/master/en/user/html/sharing.html).

## Adapting the tracker program

Once the programme has been imported, you might want to make certain modifications to the programme. Examples of local adaptations that *could* be made include:

* Adding additional variables to the form.
* Adapting data element/option names according to national conventions.
* Adding translations to variables and/or the data entry form.
* Modifying program indicators based on local case definitions

However, it is strongly recommended to take great caution if you decide to change or remove any of the included form/metadata. There is a danger that modifications could break functionality, for example program rules and program indicators.

## Line Listing

Due to technical issues, two essential line lists are not included in the generic package. The implementers are required to configure these line lists following the steps below

### AEFI Line listing (Event Report)

![Line listing](resources/images/AEFI_Tracker_design_17.png)

* **note:** the screenshot above does not represent the full line list

1. Go to **DHIS 2 Event Reports app**
2. Select Table style **Line list**
3. Select Output style **Event**
4. In **Data** section, select program **Adverse events folloing immunization (AEFI)**
5. Select Stage **AEFI**
6. Use the table below and add the **Data elements / Program Attributes** in the suggested order.
7. In **Periods** section, select **This Year**
8. In **Organisation units** section, select **User org unit**
9. CLick **Favourites** button and **Save**.
10. Add **Name** - AEFI LINE LISTING - this year
11. CLick **Favourites** button and **Save**.
12. Click **Share**. Restrict external and public access and share the event report with applicable user groups: **AEFI access (can view)** and **AEFI admin (can edit and view)**
13. Go to **AEFI Dashboard** and add the event report to the dashboard.

| Field/column # | Variable name | Source Stage | Object Type |  |
|-|---|---|---|-|
| 1 | Number |  |  |  |
| 2 | DOR (date of report - report compilation date) |  |  |  |
| 3 | DON (Date of Notification - date patient notified the event to the health system) |  |  |  |
| 4 | Incident date |  |  |  |
| 5 | Organisation unit |  |  |  |
| 6 | AEFI - Reporter of case | AEFI Stage | Data element | uZ9c4fKXuNS |
| 7 | AEFI - Reporter’s address | AEFI Stage | Data element | Q20pEixZxCs |
| 8 | AEFI Case ID |  | Program attribute | h5FuguPFF2j |
| 9 | Given name |  | Program attribute | TfdH5KvFmMy |
| 10 | Family name |  | Program attribute | aW66s2QSosT |
| 11 | Date of birth |  | Program attribute | BiTsLcJQ95V |
| 12 | Sex |  | Program attribute | CklPZdOd6H1 |
| 13 | AEFI - AEFI start date | AEFI Stage | Data element | vNGUuAZA2C2 |
| 14 | AEFI_Serious adverse event following immunization | AEFI Stage | Data element | kQCVFWE2MPb |
| 15 | AEFI - AEFI outcome | AEFI Stage | Data element | yRrSDiR5v1M |
| 16 | AEFI - Vaccination 1 date | AEFI Stage | Data element | dOkuCjpD978 |
| 17 | AEFI - Vaccine 1 name | AEFI Stage | Data element | uSVcZzSM3zg |
| 18 | AEFI - batch/lot number (Vaccine 1) | AEFI Stage | Data element | LNqkAlvGplL |
| 19 | AEFI - Diluent batch/lot number 1 | AEFI Stage | Data element | FQM2ksIQix8 |
| 20 | AEFI - Vaccination 2 date | AEFI Stage | Data element | VrzEutEnzSJ |
| 21 | AEFI - Vaccine 2 name | AEFI Stage | Data element | g9PjywVj2fs |
| 22 | AEFI - batch/lot number (Vaccine 2) | AEFI Stage | Data element | b1rSwGRcY5W |
| 23 | AEFI - Diluent batch/lot number 2 | AEFI Stage |  Data element | ufWU3WStZgG |
| 24 | AEFI - Vaccination 3 date | AEFI Stage |  Data element | f4WCAVwjHz0 |
| 25 | AEFI - Vaccine 3 name | AEFI Stage | Data element | OU5klvkk3SM |
| 26 | AEFI - batch/lot number (Vaccine 3) | AEFI Stage | Data element | YBnFoNouH6f |
| 27 | AEFI - Diluent batch/lot number 3 | AEFI Stage | Data element | MLP8fi1X7UX |
| 28 | AEFI - Abdominal pain | AEFI Stage | Data element | T6tsxbKzikz |
| 29 | AEFI - Abscess | AEFI Stage | Data element | wce39JmsjIK |
| 30 | AEFI - Anaphylaxis | AEFI Stage | Data element | MkIgCrCTFyE |
| 31 | AEFI - Bell's Palsy | AEFI Stage | Data element | BKxtyqhIDkB |
| 32 | AEFI - Chills | AEFI Stage | Data element | TPSvWhUfib3 |
| 33 | AEFI - Congenital anomaly | AEFI Stage | Data element | lSBsxcQU0kO |
| 34 | AEFI - Cough | AEFI Stage | Data element | ZdFB8xUhOUM |
| 35 | AEFI - Diarrhoea | AEFI Stage | Data element | NAiZTRCHRWL |
| 36 | AEFI - Dizziness | AEFI Stage | Data element | XluNAFG1wj6 |
| 37 | AEFI - Drowsiness | AEFI Stage | Data element | rjjRNU5yDhT |
| 38 | AEFI - Encephalopathy | AEFI Stage | Data element | pdpAEuUS1W9 |
| 39 | AEFI - Fainting | AEFI Stage | Data element | OhHYABXmGGe |
| 40 | AEFI - Fatigue | AEFI Stage | Data element | owRcSysyioE |
| 41 | AEFI - Fever | AEFI Stage | Data element | rzhHSqK3lQq |
| 42 | AEFI - Headache | AEFI Stage | Data element | HY6NIt2FX4A |
| 43 | AEFI - Injection site soreness | AEFI Stage | Data element | P4oSprWWqrn |
| 44 | AEFI - Injection site tenderness | AEFI Stage | Data element | KqlCtmOWt4G |
| 45 | AEFI - Irritability | AEFI Stage | Data element | PWOzcN7UCfW |
| 46 | AEFI - Itching | AEFI Stage | Data element | FC54HsGMErl |
| 47 | AEFI - Joint pain | AEFI Stage | Data element | vCfZD893IVe |
| 48 | AEFI - Loss of apetite | AEFI Stage | Data element | QFMRugi3fm6 |
| 49 | AEFI - Lymphadenopathy | AEFI Stage | Data element | dDWYBYUNpaQ |
| 50 | AEFI - Lymph node enlargement | AEFI Stage | Data element | GEkI9NzxTmM |
| 51 | AEFI - Mild fever | AEFI Stage | Data element | nKLO8ZNdR0B |
| 52 | AEFI - Muscle pain | AEFI Stage | Data element | pzOF4lGIyTU |
| 53 | AEFI - Nasal congestion | AEFI Stage | Data element | wWDenTQ5xBR |
| 54 | AEFI - Nausea | AEFI Stage | Data element | KOt0J61mF61 |
| 55 | AEFI - Specify other (Adverse event) | AEFI Stage | Data element | iTm5wvq16iq |
| 56 | AEFI - Specify other (Severe event) | AEFI Stage | Data element | AfrWB2ofm7l |
| 57 | AEFI - Persistent crying | AEFI Stage | Data element | GTyK3p976de |
| 58 | AEFI - Poor breast feeding | AEFI Stage | Data element | sX1SvRadOmn |
| 59 | AEFI - Seizure type | AEFI Stage | Data element | Zz4KYO4AsSY |
| 60 | AEFI - Seizures | AEFI Stage | Data element | wCGZpudXuYx |
| 61 | AEFI - Sepsis | AEFI Stage | Data element | tUmgO1Ugv6U |
| 62 | AEFI - Severe local reaction | AEFI Stage | Data element | UNmEidE6M9K |
| 63 | AEFI - Severe local reaction > 3 days | AEFI Stage | Data element | We87rvcvd8J |
| 64 | AEFI - Severe local reaction beyond nearest joint | AEFI Stage | Data element | f8hjxmHOtAB |
| 65 | AEFI - Skin rash | AEFI Stage | Data element | xgqzqv0p2Us |
| 66 | AEFI - Sore throat | AEFI Stage | Data element | seXW1hERwOo |
| 67 | AEFI - Tiredness | AEFI Stage | Data element | JaZ9yf1dDy3 |
| 68 | AEFI - Thrombocytopenia | AEFI Stage | Data element | GGLLaieVChK |
| 69 | AEFI - Toxic shock syndrome | AEFI Stage | Data element | Apq4JaueuWR |
| 70 | AEFI - Vomiting | AEFI Stage | Data element | cMEIyp0rMo1 |
| 71 | AEFI - Death | AEFI Stage | Data element | DOA6ZFMro84 |
| 72 | AEFI - Hospitalization | AEFI Stage | Data element | Il1lTfknLdd |
| 73 | AEFI - Life threatening | AEFI Stage | Data element | lATDYNmTLKD |
| 74 | AEFI - Persistent or significant disability | AEFI Stage | Data element | lsO8n8ZmLAB |

### AEFI national level summary (Event Report)

![AEFI National Linelist](resources/images/AEFI_Tracker_design_22.png)


* **note:** the screenshot above does not represent the full linelist

1. Go to **DHIS 2 Event Reports app**
2. Select Table style **Line list**
3. Select Output style **Enrollment**
4. In **Data** section, select program **Adverse events folloing immunization (AEFI)**
5. Select applicable Stage. See the table below
6. Use the table below and add the **Data elements / Program Attributes** in the suggested order.
7. In **Periods** section, select **Last 12 months**
8. In **Organisation units** section, select **User org unit**
9. Click **Favourites** button and **Save**.
10. Add **Name** - AEFI national level summary (this year)
11. Click **Favourites** button and **Save**.
12. Click **Share**. Restrict external and public access and share the event report with applicable user groups: **AEFI access (can view)** and **AEFI admin (can edit and view)**
13. Go to **AEFI Dashboard** and add the event report to the dashboard.

| Field/column # | Variable name | Source Stage | Object type | UID |
|-|---|---|---|-|
| 1 | Number |  |  |  |
| 2 | DON (Date of Notification - date patient notified the event to the health system) |  |  |  |
| 3 | Incident date |  |  |  |  |
| 4 | Organisation unit |  |  |  |
| 5 | AEFI Case ID |  | Program attribute | h5FuguPFF2j |
| 6 | AEFI - Date when seen for approval at national level | National level stage | Data element | cWMUoQEuvtR |
| 7 | AEFI - Date of final classification | National level stage | Data element | wDijUvPYVne |
| 8 | AEFI - Valid Diagnosis | National level stage | Data element | IZoGGNUkNl0 |
| 9 | AEFI - Vaccine 1 name |  AEFI Stage | Data element | uSVcZzSM3zg |
| 10 | AEFI - Vaccination 1 date | AEFI Stage | Data element | dOkuCjpD978 |
| 11 | AEFI - Vaccine 2 name | AEFI Stage | Data element | g9PjywVj2fs |
| 12 | AEFI - Vaccination 2 date | AEFI Stage | Data element | VrzEutEnzSJ |
| 13 | AEFI - Vaccine 3 name | AEFI Stage | Data element | OU5klvkk3SM |
| 14 | AEFI - Vaccination 3 date | AEFI Stage | Data element | f4WCAVwjHz0 |
| 15 | AEFI - Vaccine 4 name | AEFI Stage | Data element | menOXwIFZh5 |
| 16 | AEFI - Vaccination 4 date | AEFI Stage | Data element | H3TKHMFIN6V |
| 17 | AEFI - Final causality assessment classification | National level stage | Data element | DpgoIsq65SW |
| 18 | AEFI - Final causality assessment sub-classification | National level stage | Data element | D42M2tdJo7R |

#### Visualizations

Visualizations associated with the AEFI stage are detailed in the overview of the AEFI facility level line list. There are two key visualizations associated with causality assessment classification and sub-classification.

# Budgeting & planning guidance for COVID-19 vaccine delivery

## Introduction to budgeting guide for COVID-19 vaccine delivery

The following budget guide accompanies an Excel budgeting tool and implementation resources available at [dhis2.org/covid-vaccine-delivery](https://dhis2.org/covid-vaccine-delivery). 

Integration with existing DHIS2-based systems will achieve sustainability and cost efficiency by:

- Reducing barriers to entry and training required

- Re-using existing technology and infrastructure

- Leveraging MOH core HMIS team capacity for customization of the software/toolkit

- Working through existing immunization program processes

- Reinforcing & strengthening overall data management & use for immunization program; combining data use trainings

While the costs in this budget guidance are based on implementation experiences with DHIS2, these budget categories are largely generic and we would anticipate they apply to any electronic information management system solution. Countries that already use DHIS2 as an HMIS and/or for their EPI program will have a number of key building blocks already in place to accelerate implementation of the information system to support their national COVID-19 vaccine plan.

**Country operational budgets are impacted most by the number of users, number of devices, and connectivity required to run their system.** Therefore, these numbers must be updated in the budgeting spreadsheet. We have provided an example based on a moderate implementation assumption of 1000 users.

- Average costs for server infrastructure & maintenance, trainings, internet connectivity
- Costs will vary depending on the total number of end users and national cost norms such as per diem rates and types of trainings delivered (in-person, remote/virtual). Where countries implement more than one module, trainings may be combined depending on the user to achieve further cost efficiencies.
- Additional cost for server upgrades and admin support are budgeted for modules that include individual-level data capture at scale (e.g. electronic immunization registry)
- Human resources: costs for MOH, immunization program and health worker salaries are not included in this budgeting guide. The budgeting tool assumes an HIS unit within the MOH has been trained to provide support for national DHIS2 support with budget for additional training of trainers and support provided by technical experts. In addition, immunization program staff should receive training on the modules.  
- The modules within the toolkit can be implemented in a modular way. Any of the following components may be delivered as part of the toolkit and will have varying budgetary implications based on complexity and scale. Individual level data modules (IER, AEFI) using the DHIS2 tracker model typically (but not always) involve many users, large amounts of data, additional training, more devices and additional server capacity.

### DHIS2 COVID-19 Vaccine Toolkit: Overview of Modules

#### Core package: COVID-19  Vaccine Reporting, Analytics & Dashboard Package (aggregate) for vaccination & logistics data**

- This package is recommended to all countries with DHIS2 or that wish to use DHIS2 for their core analysis in the HMIS
- This package supports data collection that will meet the aggregate reporting listed in the WHO Monitoring Guidance
- Simplest and lowest cost to install, requires the least training and anticipated this modules will be installed in the existing HMIS instance of DHIS2 (though country implementation may vary)
- The package can be used in countries where paper-based or hybrid systems are in place; or in countries where individual level data is captured electronically by DHIS2 tracker or other tools.

#### COVID-19 Vaccine  Immunization eRegistry (EIR) (tracker - large scale)

- Anticipated scale of EIRs will require more resources for server management, end user training, design & customization
- Countries where DHIS2 Tracker is  already used will generally have existing in-country capacity; countries that are new to DHIS2 tracker may requirement more training and TA support
- Introduction of individual level data systems includes increased budgeting for design and user acceptance testing to ensure frontline worker workflows are accommodated
- Additional server upgrade costs are budgeted to account for the scale of data collection

#### Logistics tracking (tracker  - medium scale)

- More complex solution for logistics than the aggregate vaccine site logistics data included in core  package
- Server upgrades and in-country  tracker capacity should be considered

#### Adverse events following  immunization (tracker - medium scale)

- Individual level data collection at smaller scale
- Generally assumes a smaller number of users than electronic immunization registry, but should be adjusted depending on country implementation

#### Custom apps, Interoperability solutions for logistics systems and vaccine certificates

- Generally requires strong core  DHIS2 team in-country or HISP support for development of the custom app or  interoperability layer
- Cost can range from low to very  expensive depending on the complexity of the solution, the frequency of  requirements change, and the maturity of the non-DHIS2 system/tool included  in the interoperability layer

## Budgeting Guidance by Category

### Infrastructure (server, devices & connectivity)

DHIS2 is a web-based platform with a natively integrated mobile application (DHIS2 Capture App) to facilitate offline data capture. The existing infrastructure in country should be re-used wherever possible, but will depend on what types of vaccination sites will be mobilized. In addition, if data entry users for COVID-19 vaccine delivery are already equipped with mobile devices for other health related tasks, they may be able to use these devices for COVID-19 vaccine reporting.
*Budgeting for infrastructure*

- Devices: mobile or desktops, depending on type of data collection

- Connectivity: wifi or 3G (mobile data collection)

- Budget highly dependent on the number of vaccination sites, the level where electronic reporting is expected to happen (e.g. at vaccination site, at district), and the number of users

### Governance & coordination

Solid governance and coordination mechanisms are crucial to support an HMIS that is coherent across programs, up to date and well maintained. Countries that already use DHIS2 generally have mechanisms in place such as routine meetings to convene a DHIS2 governing body in-country, and guidance from can help to facilitate this process as well as sharing best practices from other countries.

*Budgeting implications for COVID-19 Vaccine Delivery:*

- N/A or minimal: governance mechanisms should be activated to engage stakeholders in the use of DHIS2 and the national system for COVID-19 vaccine data requirements

### Server infrastructure and admin

Countries have various server infrastructure arrangements, from maintaining their own hardware within the MOH to contracting through a national service provider to using a cloud-hosting service. UiO recommends cloud-hosting for individual level data collection systems to provide an elastic approach to scale up the system and the hardware requirements,, but it is not always compliant with local data storage policies.

*Budgeting implications for Covid-19 Vaccine Delivery:*

1. Core aggregate package: For integrating basic aggregated reporting into the existing HMIS, minimal additional funding is anticipated.
2. Adverse events module: modest funding for server support and optimization; scale not anticipated to create substantial new server specs
3. Immunization     eRegistries: scaling individual level data collection and storage will require additional server capacity. Estimated budget: $10,000 to support     server upgrade and support for scaling individual level data system,

### DHIS2 national core team training

Most countries that use DHIS2 already have a national core team of experts within the MOH to provide support. In addition, countries that use DHIS2 for their immunization program information likely have capacity within the national program for data management and analysis within DHIS2. The following training activities are proposed to support the national team quickly install, customize and operationalize the COVID-19 vaccine modules within their existing systems:

1. Training of trainers (ToT) provided by HISP groups for package installation,     customization and end user training; recommend to budget one ToT per module adopted
2. Costs may include secondments/workshops with per diems, technical assistance, as well as DHIS2 academy sponsorships.

### Configuration: Package Installation, Customization & Localization

The following provides a guide for package installation and customization costs per type of package. We recommend that all DHIS2 countries intending to use DHIS2 for monitoring COVID-19 vaccine roll-out adopt the standard core aggregate package into their HMIS to ensure data analysis standards can be met regardless of whether paper reporting or electronic individual level systems or hybrid systems are used. Where individual level data are captured electronically, these can be pushed to the Core package to support data analysis in the HMIS and triangulation with COVID-19 surveillance data and routine EPI program data.

#### Core Aggregate COVID-19 Vaccine Package (reporting, analytics & dashboards)

The aggregate module can be installed into the HMIS, and customized as needed for local context. This process has been carried out in 30+ countries for other types of WHO packages and typically takes a few days collaborating between the national immunization program and the HIS unit.

- One installation workshop

#### Individual level packages (vaccine registry, AEFI, logistics tracking)

Based on the DHIS2 tracker data model, individual level data systems generally require more time for user acceptance testing, customization and adaptation to local workflows. Remote guidance and TA onsite can help in this process.

- One installation & customization workshop per module

- One user acceptance testing cycle per module (to ensure the configuration is designed to optimize to the local workflow; this can be done rapidly but is recommended to do at least one UAT before scaling deployment)

#### Electronic health certificate custom app

Custom applications can be developed when core DHIS2 functionality is not available. This can be the case for the development of digital health certificate apps that have been in use in some countries for COVID-19 negative testing certificates and can be re-purposed for COVID-19 vaccine certificates. A custom web or Android app developed can be less or more expensive depending on the requirements. Budgeting for maintenance of the application over time is important.

#### Interoperability solutions for logistics systems and vaccine certificates

Interoperability solutions are highly variable depending on the complexity and the robustness of the non-DHIS2 tool or system. The cost of implementing an interoperability solution is largely TA-related (from the DHIS2 side) and requires engagement in data variable mapping processes as well as facilitating the use of APIs. In general:

- Data exchange and interoperability between individual level data is more complex and more costly; this is further complicated operationally by the availability of inter connectivity. If data collection is intended to happen offline, it will be very difficult for the systems to sync frequently and may result in duplicate enrollments of individuals, for example.

- Data exchange: sending aggregated individual level data from one system to another is less complex. DHIS2 supports the ADX standard for aggregate data exchange.

- Frequency of requirements changing: interoperability solutions are more costly when the requirements are constantly changing, which is often the reality in emergency situations. Determining minimum requirements for data exchange and interoperability can mitigate these costs while ensuring the most critical data for analysis can be collated in an electronic system.

### End User Training

In countries where DHIS2 aggregate or tracker is already used for data collection, the training needs can be substantially reduced. End user training costs are largely driven by:

- Number of users

- Amount of time for training (aggregate: simple; individual level data collection: more complex)

- Existing familiarity with the system

- Per diems and travel required vs. remote/virtual training

 We recommend delivering one end user training for data collection users; and one end user training for data use and analysis.

### DHIS2 ‘start up’ countries

For countries that are new to DHIS2, we recommend that some additional budget be allocated for:
- Training of a core team (3-4 workshops with HISP expert TA to get started)
- Setting up server and cost of running the server for one year (estimated at ~$14,000)
- Budget for additional time for end user and data use training as users in country are less familiar with the platform
- Assessment of connectivity and availability of devices at the intended level of electronic data collection to inform additional resources needed

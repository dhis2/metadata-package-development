# Change log for COVID19 aggregate surveillance package
To see additional details of the metadata objects mentioned below, refer to the metadata reference documentation of this version.

## Aggregate

### Version 2.0
* The changes leading to this version were based on the revised [WHO Global surveillance of COVID-19 Weekly Aggregate Report ](https://www.who.int/publications/i/item/aggregated-weekly-reporting-form)
* The major were made on the age disaggregations with 5 year age bands used for <20 years and 60+ years spanning upto 80+years.
* Unknown age and Unknown sex were also introduced in the disaggregations to cater data that cannot be categorized with the options provided.
* Data elements for cases and deaths among health workers (Confirmed + Probable), tests with PCR assay, deaths amongst probable cases and health workers were introduced in this version.
* Data elements for logistics and cases by transmission classifications were removed.
* Considering these changes, all the core metadata objects; data elements, indicators, dashboard and its items, dataSets, indicator groups and data elements groups were newly created.
* This version now has only one dataSet designed for weekly reporting unlike in the previous version that had 2 dataSets reported weekly and daily basis.
* All the core metadata objects have been coded in support for international standard for aggregate data exchange (ADX).
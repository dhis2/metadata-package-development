## Jenkinsfiles (_Jenkins pipeline scripts_)

### [Exporter](exporter.Jenkinsfile)
Exports metadata packages from a DHIS2 instance and tests them, based on a couple of input parameters (package code/type, dhis2 version and more). Can be started manually or scheduled in parallel by the [triggerer](##Triggerer) pipeline.

### [Triggerer](triggerer.Jenkinsfile)
Triggers the [exporter](##Exporter) pipeline in parallel, based on the enabled packages in the Metadata index spreadsheet (via the [metadata-index-parser](https://github.com/dhis2/dhis2-utils/tree/master/tools/dhis2-metadata-index-parser)) and a list of DHIS2 versions to export from.


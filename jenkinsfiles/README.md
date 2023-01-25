## Jenkinsfiles

### [Export](export.Jenkinsfile)
* Exports metadata packages from a DHIS2 instance and tests them, based on a couple of input parameters (package code/type, dhis2 version and [more](exporter.Jenkinsfile#L8-L17)).
* Can export and test a package (based on the provided input parameters) or only test an already exported package by uploading it via the `package_metadata_file` parameter.
* Can be started manually or scheduled in parallel by the [trigger](##Trigger) pipeline.
* If a package is exported from an instance running a "dev snapshot", instead of a stable version - it will only be tested, but not pushed to GitHub.

### [Trigger](trigger.Jenkinsfile)
* Triggers the [export](##Export) pipeline in parallel, based on the enabled packages in the Metadata index spreadsheet (via the [metadata-index-parser](https://github.com/dhis2/dhis2-utils/tree/master/tools/dhis2-metadata-index-parser)) and a list of DHIS2 versions to export from.
* Can be started manually or by a [cron schedule](https://www.jenkins.io/doc/book/pipeline/syntax/#triggers).

### develop

### commit

### export

### trigger

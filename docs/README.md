# DHIS2 Metadata Package Development Guide

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
- [Developing Metadata Packages](#developing-metadata-packages)
- [Committing Metadata Package Changes](#committing-metadata-package-changes)
- [Exporting Metadata Packages](#exporting-metadata-packages)
- [Releasing Metadata Packages](#releasing-metadata-packages)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

---

## Getting Started

### Prerequisites

Before you begin, ensure you have the following:

- Access to [Jenkins](???)
- Access to the [Metadata Packages Index spreadsheet](https://docs.google.com/spreadsheets/d/1IIQL2IkGJqiIWLr6Bgg7p9fE78AwQYhHBNGoV-spGOM)
- Familiarity with ... (links to metadata package development resources?)

---

## Developing Metadata Packages

To create a DHIS2 instance for developing Metadata packages, you can use the [pkg-develop Jenkins pipeline](https://ci.dhis2.org/job/test-pkg-develop).

Development instances are created via [the Instance Manager](https://im.dhis2.org) and are using our [DHIS2 Docker images](https://hub.docker.com/u/dhis2).

### Develop pipeline
![develop-pipeline-parameters.png](images/develop-pipeline-parameters.png)

#### Parameters:

* `DATABASE` - selects the packages database to start the DHIS2 instance with:
  * `dev` - the aggregate packages database
  * `tracker_dev` - the tracker packages database
  * `pkgmaster` - the Package Master database (`dev` and `tracker_dev` merged together)
  * `empty` - an empty database
* `INSTANCE_NAME` - this is only a part of the full final instance name, so it's easier to distinguish between instances and their purpose
* `DHIS2_IMAGE_REPOSITORY` - the DockerHub image repository
  * `core` - https://hub.docker.com/r/dhis2/core (only stable releases and release candidates)
  * `core-dev` - https://hub.docker.com/r/dhis2/core-dev (development releases)
* `DHIS2_VERSION` - the DHIS2 verison to use; note that it has to be a valid `tag` from one of the DockerHub repositories above
* `TTL` - the Time To Live of the instance, in case it's only temporary and the user would like to get it cleand up automatically; by default "development" instances will exist until manually deleted

---

## Committing Metadata Package Changes

Commiting (or saving) Metadata Package changes can be done via the [pkg-commit Jenkins pipeline](https://ci.dhis2.org/job/test-pkg-commit).

- commiting (saving) packages to `pkgmaster`
- maintenance tasks  via the commit pipeline (with pausing and testing)

### Commit pipeline


https://ci.dhis2.org/job/test-pkg-commit - Creates a “staging” instance and does all the rest of the work (testing, exporting all metadata, creating a diff, etc).

* Being able to use either:
  * an uploaded package
  * a package exported from a dev instance
  * no package at all, just to start a staging instance for maintenance, for example
* Pausing before and after importing into the staging instance (with a notification in Slack).
* Testing the imported package (either manually uploaded or exported from a dev instance) in an empty DHIS2 instance, as well as testing the whole staging instance afterwards.
* Exporting all the metadata from the staging instance, creating a diff with the previous version of it via the metadatapackagediff tool (the .xlsx diff file can be found as an archived artifact in the build, for example see here) and pushing the newly exported version to this GitHub repo - https://github.com/dhis2-metadata/ALL_METADATA. (the name is just a placeholder, unless you like it :smile:)


In the screenshot below, you can see the three main variations of the builds:
* #92 - No dev instance specified and no package file uploaded
* #93 - No dev instance specified and package file uploaded
* #94 - Dev instance specified and no package file uploaded

![commit pipeline variations](images/commit-pipeline-variations.png)

Note that if you both specify a dev instance and upload a package, the dev instance export will take precedence.

...

Here’s how it’s supposed to work:

“Standard” workflow
1. Create a dev instance with the pkg-develop pipeline with INSTANCE_NAME set to “foobar”, for example; currently the “database seed” is a not very up-to-date dev database, i.e. aggregate packages only; this instance will be used to export the given package that is being developed.
2. Wait for the pkg-develop pipeline build to complete and create the instance
3. Create a staging instance with the pkg-commit pipeline and set DEV_INSTANCE_NAME to the final instance name of the dev instance created in the previous step - in case you used “foobar” for INSTANCE_NAME, the final name will be pkg-dev-foobar-<build number>; this instance will be used to test the exported package from the dev instance, import it and test the whole instance (or actually database).
4. Wait for the pkg-commit pipeline build to complete; note that there are 2 “pause” stages (before and after importing the package into the staging instance) that allow for manual interventions to the staging instance; these pause stages will have to be “resumed” manually through the UI. Finally all the metadata is exported and pushed to GitHub if the dashboard and PR checks pass.
5. The Package master database is replaced with the new version (that includes the newly imported package).


“Manually upload a package” workflow
1. Upload a package file to the pkg-commit pipeline; don’t input dev instance name or package code.
2. Wait for the pkg-commit pipeline build to complete; note that this is almost the same as the “Standard” workflow, but instead of using a dev instance to export the package from - the user uploads the package manually. The package still goes through the same tests and validations.
3. The Package master database is replaced with the new version (that includes the newly imported package).


“Create a staging instance for maintenance” workflow
1. Only input STAGING_INSTANCE_NAME; don’t upload package file or input dev instance name and package code.
2. Wait for the pkg-commit pipeline build to complete; note that this workflow could be used to apply changes only to the Package master database (i.e. tracker + aggregate database) or some other maintenance task.
3. The Package master database is replaced with the new version (that includes the changes done by the user).


There’s a bit more information and examples about the pipelines in here.

---

## Exporting Metadata Packages

### Exporter pipeline

Export package by name (from the packages index spreadsheet)
![exporter pipeline parameters](images/exporter-pipeline-parameters.png)

The main parameter is `PACKAGE_NAME`, which is populated by the [packages spreadsheet](https://docs.google.com/spreadsheets/d/1IIQL2IkGJqiIWLr6Bgg7p9fE78AwQYhHBNGoV-spGOM), and based on what a user selects - the rest of the required parameters for exporting a package are also taken from that spreadsheet.

There are still a couple of optional parameters in there that can change the behaviour.

* `REFRESH_PACKAGES` checkbox can be used to, as expected, refresh the list of packages in the `PACKAGE_NAME` parameter dropdown. This is helpful because the `PACKAGE_NAME` parameter list is parsed upon triggering a build, hence if any changes were made to the spreadsheet they won’t be automatically picked up without triggering a build first. So if a user ends up in a situation where the dropdown list is not in sync with the spreadsheet - triggering a build with that checkbox checked will refresh the list and abort the build afterwards.
* `INSTANCE_URL` can be used to extract a package from a different Instance from the one specified in the packages spreadsheet. Currently the “default” instance for most packages is either https://metadata.dev.dhis2.org/tracker_dev or https://metadata.dev.dhis2.org/dev (with some exceptions), so if for some reason you’d like to export a package from a different one - that parameter would allow you to do so.
* `DHIS2_VERSION` can be used to change the version you’d like to export a package from. This defaults to the 2.38, which is the currently the “base” version for developing packages. Note that using a different version would also change the instance that the package is exported from. Currently the “default” instances for exporting from a higher versions are on the https://who-dev.dhis2.org server. If you’d like to export a package from a different instance for a higher version of DHIS2, you can specify the `INSTANCE_URL` parameter and leave `DHIS2_VERSION` empty.

### triggering export of multiple packages via index spreadsheet and triggerer pipeline

you can check the Ready for Export on any number of packages, but note that the DHIS2 versions to export from column controls which versions of DHIS2 will the package be exported   from. You can change versions in the DHIS2 versions to export from column and do and change only to version 2.38 for the packages you want to export and then revert back the changes.
Also note that the pipeline will reset all the checkboxes in the Ready for Export on each build.

---

## Releasing Metadata Packages

- creating package releases/tags
- uploading packages to s3
- publishing packages and the packages download page (based on downloads-index)

...

And here are two step by step guides for adding the “Publish” workflow to a repository we want to publish from, as well as how to create new Releases/Tags.

The “Publish” GitHub workflow needs to be added to every “feature” branch (2.36, 2.37 … ) of every package repository that we want to release.

### How to add the Publish workflow to a given branch:
1. Copy the publish.yaml file contents from the TB_AGG repo, branch 2.36 (this is just the “first” place I’ve added the Publish workflow in order to test it, but given that the file contents are the same regardless of the branch and repo - it can be taken from anywhere it already exists)
2. Go to a feature branch of the desired repository (for example - ENTO_IRS repo, branch 2.36)
3. Click “Add file” > “Create new file”
4. Name the new file “.github/workflows/publish.yaml” (this will create the .github and the workflow parent dirs of the publish.yaml file)
5. Paste the contents of the publish.yaml file that were copied in step 1 as is, no changes needed
6. Commit the new file
7. Repeat for all of the “feature” branches within the desired repository

_To trigger the “Publish” GitHub workflow (which uploads the packages to S3), we need to create a new GitHub Release and Tag._

### How to create new Release and Tag:
1. Go to the desired repository
2. Click on “Releases” to the right
3. Click on “Draft new release” (or “Create new release”, if there are no previous releases)
4. Click on “Choose a tag” and create a new tag like D2.36/X.X.X
5. Click on “Target: master” and select the desired feature branch, based on the tag name (for example, 2.36)
6. Add a “Release title” (should be the same as the Tag name, like D2.36/X.X.X)
7. “Describe this release”, if necessary
8. Click “Publish release” to create the new release and tag and trigger the “Publish” workflow
9. Go to “Actions” tab of the repository, in order to see the progress of the triggered “Publish” workflow

---

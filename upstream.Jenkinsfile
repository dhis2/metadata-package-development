def generateStagesMap(versions, packages, instanceBaseName) {
    def map = [:]

    versions.each { version ->
        packages.each { item ->
            map["${item[0..5]} for ${version}"] = {
                stage("Export package") {
                    build job: 'test-metadata', propagate: false, parameters: [
                        // TODO: parameters should be changed
                        // each package in the list should have type, prefix code and DHIS2 version?
                        string(name: 'DHIS2_version', value: "$version"),
                        string(name: 'Package_name', value: "$item"),
                        string(name: 'Package_type', value: "EVT"),
                        string(name: 'Instance_name', value: "$instanceBaseName")
                    ]
                }
            }
        }
    }

    return map
}

pipeline {
    agent {
        label 'ec2-jdk8-large'
    }

    options {
        ansiColor('xterm')
    }

    parameters {
        string(name: 'packages', defaultValue: 'RMS0 - CRVS_RMS - Rapid Mortality Surveillance')
        string(name: 'DHIS2Versions', defaultValue: '2.37')
    }

    environment {
        TRACKER_DEV_SNAPSHOT = "s3://dhis2-database-development/who-metadata/development/tracker_dev.sql.gz"
        TRACKER_DEV_DB_MANAGER_COPY = "s3://test-db-manager-bucket/whoami/tracker-dev-2.35.11/tracker-dev-2.35.11.sql.gz"
        INSTANCE_HOST = "https://api.im.prod.test.c.dhis2.org"
        HTTP = "https --verify=no --check-status"
    }

    stages {
        stage ('Run Downstream') {
            steps {
                script {
                    packagesList = "${params.packages}".split(',')

                    parallel generateStagesMap(versionsList, packagesList, instanceName)
                }
            }
        }
    }
}

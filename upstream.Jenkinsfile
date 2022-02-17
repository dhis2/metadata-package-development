def generateStagesMap(versions, packages) {
    def map = [:]

    versions.each { version ->
        packages.each { item ->
            map["${item[-6..-1]} for ${version}"] = {
                stage("Export ${item[-6..-1]} for ${version}") {
                    build job: 'test-metadata', propagate: false, parameters: [
                        string(name: 'DHIS2_version', value: "$version"),
                        string(name: 'Package_name', value: "$item"),
                        string(name: 'Package_type', value: "EVT")
                    ]
                }
            }
        }
    }

    return map
}

pipeline {
    agent {
        label 'master'
    }

    options {
        ansiColor('xterm')
    }

    parameters {
        string(name: 'packages', defaultValue: 'CRVS - RMS - Rapid Mortality Surveillance - RMS000')
        string(name: 'DHIS2Versions', defaultValue: '2.36')
    }

    stages {
        stage ('Create DHIS2 instances') {
            steps {
                script {
                    versionsList = "${params.DHIS2Versions}".split(',')

                    versionsList.each { version ->
                        echo "Creating DHIS2 $version instance ..."
                    }
                }
            }
        }

        stage ('Run Downstream') {
            steps {
                script {
                    packagesList = "${params.packages}".split(',')

                    parallel generateStagesMap(versionsList, packagesList)
                }
            }
        }

        stage ('Delete DHIS2 instances') {
            steps {
                script {
                    versionsList.each { version ->
                        echo "Deleting DHIS2 $version instance ..."
                    }
                }
            }
        }
    }
}

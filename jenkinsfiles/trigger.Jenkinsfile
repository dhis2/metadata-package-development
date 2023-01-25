// Generates a map of stages to trigger the metadata-exporter pipeline.
def generateStagesMap(packages) {
    def map = [:]

    packages.each { pkg ->
        pkg["DHIS2 versions to export from"].split(',').each { version ->
            map["${pkg['DHIS2 code for packaging']} (type: ${pkg['Script parameter']}) for ${version}"] = {
                stage("Export package") {
                    build job: 'metadata-exporter', propagate: false, parameters: [
                        string(name: 'DHIS2_version', value: "$version"),
                        string(name: 'Instance_url', value: "${pkg['Source instance']}"),
                        string(name: 'Package_code', value: "${pkg['DHIS2 code for packaging']}"),
                        string(name: 'Package_type', value: "${pkg['Script parameter']}"),
                        string(name: 'Package_description', value: "${pkg['Component name']}"),
                    ]
                }
            }
        }
    }

    return map
}

pipeline {
    agent {
        label 'ec2-jdk8-medium'
    }

    triggers {
        cron('H 18 * * 1-5')
    }

    options {
        ansiColor('xterm')
    }

    stages {
        stage('Get Enabled Packages') {
            environment {
                GC_SERVICE_ACCOUNT_FILE = credentials('metadata-index-parser-service-account')
                GOOGLE_SPREADSHEET_ID = '1IIQL2IkGJqiIWLr6Bgg7p9fE78AwQYhHBNGoV-spGOM'
            }

            steps {
                script {
                    dir('dhis2-utils') {
                        git url: 'https://github.com/dhis2/dhis2-utils'

                        dir('tools/dhis2-metadata-index-parser') {
                            sh 'pip3 install -r requirements.txt'

                            INPUT_JSON = sh(returnStdout: true, script: 'python3 parse-index.py').trim()

                            packagesList = readJSON text: "$INPUT_JSON"
                        }
                    }
                }
            }
        }

        stage ('Run Exporter') {
            steps {
                script {
                    parallel generateStagesMap(packagesList)
                }
            }
        }
    }
}

// Generates a map of stages to trigger the metadata-exporter pipeline.
def generateStagesMap(packages) {
    def map = [:]

    packages.each { pkg ->
        pkg['Supported DHIS2 Versions'].split(',').each { version ->
            map["${pkg['Package Code']} (type: ${pkg['Package Type']}) for ${version}"] = {
                stage("Export package") {
                    // TODO update before merge
                    build job: 'test-metadata-exporter-v2', propagate: false, parameters: [
                        string(name: 'DHIS2_VERSION', value: "$version"),
                        string(name: 'INSTANCE_URL', value: "${pkg['Source Instance']}"),
                        string(name: 'PACKAGE_NAME', value: "${pkg['Component Name']}"),
//                        string(name: 'Package_type', value: "${pkg['Script parameter']}"),
//                        string(name: 'Package_description', value: "${pkg['Component Name']}"),
//                        string(name: 'Package_health_area_name', value: "${pkg['Health area']}"),
//                        string(name: 'Package_health_area_code', value: "${pkg['Health area prefix']}"),
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
                GOOGLE_SERVICE_ACCOUNT = credentials('metadata-index-parser-service-account')
                GOOGLE_SPREADSHEET_ID = '1IIQL2IkGJqiIWLr6Bgg7p9fE78AwQYhHBNGoV-spGOM'
            }

            steps {
                script {
                    dir('dhis2-utils') {
                        git url: 'https://github.com/dhis2/dhis2-utils', branch: 'use-argparse-insead-of-envvars'

                        dir('tools/dhis2-metadata-index-parser') {
                            sh 'pip3 install -r requirements.txt'

                            INPUT_JSON = sh(
                                returnStdout: true,
                                script: 'python3 parse-index.py --service-account-file $GOOGLE_SERVICE_ACCOUNT --spreadsheet-id $GOOGLE_SPREADSHEET_ID'
                            ).trim()

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

    post {
        failure {
            script {
                slackSend(
                    color: '#00ffff',
                    channel: '@U01RSD1LPB3',
                    message: slack.buildUrl() + " failed."
                )
            }
        }
    }
}

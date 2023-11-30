// Generates a map of stages to trigger the metadata-exporter pipeline.
def generateStagesMap(packages) {
    def map = [:]

    packages.each { pkg ->
        pkg['Supported DHIS2 Versions'].split(',').each { version ->
            map["${pkg['Package Code']} (type: ${pkg['Package Type']}) for ${version}"] = {
                stage("Export package") {
                    build job: 'metadata-exporter', propagate: false, parameters: [
                        string(name: 'DHIS2_VERSION', value: "$version"),
                        string(name: 'INSTANCE_URL', value: "${pkg['Source Instance']}"),
                        string(name: 'PACKAGE_NAME', value: "${pkg['Component Name']}"),
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
        cron('H 1 * * 1-5')
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
                        git url: 'https://github.com/dhis2/dhis2-utils'

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

// Generates a map of stages to trigger the metadata-exporter pipeline.
def generateStagesMap(versions, packages) {
    def map = [:]

    versions.each { version ->
        packages.each { item ->
            map["${item['DHIS2 code for packaging']} (type: ${item['Script parameter']}) for ${version}"] = {
                stage("Export package") {
                    build job: 'test-metadata-exporter', propagate: false, parameters: [
                        string(name: 'DHIS2_version', value: "$version"),
                        string(name: 'Package_code', value: "${item['DHIS2 code for packaging']}"),
                        string(name: 'Package_type', value: "${item['Script parameter']}"),
                        string(name: 'Package_description', value: "${item['Component name']}"),
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

    options {
        ansiColor('xterm')
    }

    parameters {
        string(name: 'DHIS2Versions', defaultValue: '2.36,2.37,2.38', description: 'Comma-separated list of DHIS2 versions to extract packages from.')
    }

    stages {
        stage('Get Packages Index') {
            environment {
                GC_SERVICE_ACCOUNT_FILE = credentials('metadata-index-parser-service-account')
                GOOGLE_SPREADSHEET_ID = '1IIQL2IkGJqiIWLr6Bgg7p9fE78AwQYhHBNGoV-spGOM'
            }

            steps {
                script {
                    dir('dhis2-utils') {
                        git branch: 'DEVOPS-167', url: 'https://github.com/dhis2/dhis2-utils'

                        dir('tools/dhis2-metadata-index-parser') {
                            sh 'pip3 install -r requirements.txt'
                            INPUT_JSON = sh(returnStdout: true, script: 'python3 parse-index.py').trim()

                            packagesList = readJSON text: "$INPUT_JSON"

                            packagesList.each { item ->
                                echo item['DHIS2 code for packaging']
                                echo item['Script parameter']
                            }
                        }
                    }
                }
            }
        }

        stage ('Run Downstream') {
            steps {
                script {
                    versionsList = "${params.DHIS2Versions}".split(',')

                    parallel generateStagesMap(versionsList, packagesList)
                }
            }
        }
    }
}
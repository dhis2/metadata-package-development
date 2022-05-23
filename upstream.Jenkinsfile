def generateStagesMap(versions, packages, instanceBaseName) {
    def map = [:]

    // index.each { item -> ... $item['code']
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
        stage('Get Packages Index') {
            environment {
                GC_SERVICE_ACCOUNT = credentials('metadata-index-parser-service-account')
                GOOGLE_SPREADSHEET_ID = '1IIQL2IkGJqiIWLr6Bgg7p9fE78AwQYhHBNGoV-spGOM'
            }

            steps {
                script {
                    dir('dhis2-utils') {
                        git branch: 'DEVOPS-167', url: 'https://github.com/dhis2/dhis2-utils'

                        dir('tools/dhis2-metadata-index-parser') {
                            sh 'pip3 install -r requirements.txt'
                            INPUT_JSON = sh(returnStdout: true, script: 'python3 parse-index.py').trim()

                            index = readJSON text: "$INPUT_JSON"
                            index.each { item ->
                                echo item['DHIS2 code for packaging']
                                echo item['Source instance DHIS2.36']
                                echo item['Script parameter']
                            }
                        }
                    }
                }
            }
        }

//        stage ('Run Downstream') {
//            steps {
//                script {
//                    packagesList = "${params.packages}".split(',')
//
//                    // use index array
//                    parallel generateStagesMap(versionsList, packagesList, instanceName)
//                }
//            }
//        }
    }
}

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
        label 'ec2-jdk8-large'
    }

    options {
        ansiColor('xterm')
    }

    parameters {
        string(name: 'packages', defaultValue: 'CRVS - RMS - Rapid Mortality Surveillance - RMS000')
        string(name: 'DHIS2Versions', defaultValue: '2.37')
    }

    environment {
        TRACKER_DEV_SNAPSHOT = "s3://dhis2-database-development/who-metadata/development/tracker_dev.sql.gz"
        TRACKER_DEV_DB_MANAGER_COPY = "s3://test-db-manager-bucket/whoami/tracker-dev-2.35.11/tracker-dev-2.35.11.sql.gz"
        IM_USER_CREDENTIALS = credentials('test-im-user-credentials')
        USER_EMAIL = '$IM_USER_CREDENTIALS_USR'
        PASSWORD = '$IM_USER_CREDENTIALS_PSW'
        INSTANCE_HOST = "https://api.im.prod.test.c.dhis2.org"
        HTTP = "https --verify=no --check-status"
    }

    stages {
        stage ('Create DHIS2 instances') {
            steps {
                script {
                    echo "Copy latest DB snapshot to database manager ..."
                    sh "aws s3 cp $TRACKER_DEV_SNAPSHOT $TRACKER_DEV_DB_MANAGER_COPY"

                    sh "pip3 install httpie"

                    versionsList = "${params.DHIS2Versions}".split(',')

                    versionsList.each { version ->
                        echo "Creating DHIS2 $version instance ..."
                        // curl dhis2-create and dhis2-deploy scripts?
                        sh 'curl "https://raw.githubusercontent.com/dhis2-sre/im-manager/master/scripts/login.sh" -O'
                        sh 'chmod +x login.sh'
                        sh 'eval \$(./login.sh)'

                        sh 'curl "https://raw.githubusercontent.com/dhis2-sre/im-manager/master/scripts/dhis2-create.sh" -O'
                        sh 'chmod +x dhis2-create.sh'
                        sh './dhis2-create.sh pipeline-instance-1 whoami'
                    }
                }
            }
        }

//         stage ('Run Downstream') {
//             steps {
//                 script {
//                     packagesList = "${params.packages}".split(',')
//
//                     parallel generateStagesMap(versionsList, packagesList)
//                 }
//             }
//         }

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

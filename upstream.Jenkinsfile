def generateStagesMap(versions, packages, instanceBaseName) {
    def map = [:]

    versions.each { version ->
        packages.each { item ->
            map["${item[-6..-1]} for ${version}"] = {
                stage("Export ${item[-6..-1]} for ${version}") {
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
        stage ('Create DHIS2 instances') {
            steps {
                script {
                    echo "Copy latest DB snapshot to database manager ..."

                    sh "aws s3 cp --no-progress $TRACKER_DEV_SNAPSHOT $TRACKER_DEV_DB_MANAGER_COPY"

                    // TODO: install httpie in the agent AMI (pip and apt have different versions)
                    sh "pip3 install httpie"

                    versionsList = "${params.DHIS2Versions}".split(',')

                    withCredentials([usernamePassword(credentialsId: 'test-im-user-credentials', passwordVariable: 'PASSWORD', usernameVariable: 'USER_EMAIL')]) {
                        versionsList.each { version ->
                            echo "Creating DHIS2 $version instance ..."

                            randomInt = new Random().nextInt(9999)
                            instanceName = "instance-$randomInt"

                            readinessDelay = 300
                            sh "./scripts/create-dhis2-instance.sh $instanceName whoami $version $readinessDelay"
                        }
                    }

                    sleep(readinessDelay*2)
                }
            }
        }

        stage ('Run Downstream') {
            steps {
                script {
                    packagesList = "${params.packages}".split(',')

                    parallel generateStagesMap(versionsList, packagesList, instanceName)
                }
            }
        }

        stage ('Delete DHIS2 instances') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'test-im-user-credentials', passwordVariable: 'PASSWORD', usernameVariable: 'USER_EMAIL')]) {
                        versionsList.each { version ->
                            echo "Deleting DHIS2 $version instance ..."

                            sh "./scripts/destroy-dhis2-instance.sh $instanceName whoami $version"
                        }
                    }
                }
            }
        }
    }
}

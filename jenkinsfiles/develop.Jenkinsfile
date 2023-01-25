@Library('pipeline-library') _

pipeline {
    agent {
        label 'ec2-jdk11-large'
    }

    parameters {
        choice(name: 'DATABASE', choices: ['dev', 'tracker_dev', 'pkgmaster', 'empty'], description: 'Packages development database from https://metadata.dev.dhis2.org, pkgmaster or an empty one.')
        string(name: 'INSTANCE_NAME', defaultValue: 'foobar', description: 'Full instance name will be: "pkg-dev-<INSTANCE_NAME>-<BUILD_NUMBER>".')
        string(name: 'DHIS2_VERSION', defaultValue: '2.38.4', description: 'DHIS2 version for the instance.')
        string(name: 'TTL', defaultValue: '', description: 'Time to live for the instance in minutes.')
    }

    options {
        ansiColor('xterm')
    }

    environment {
        IMAGE_TAG = "${params.DHIS2_VERSION}"
        IMAGE_REPOSITORY = 'core'
        IM_ENVIRONMENT = 'prod.test.c.dhis2.org'
        IM_HOST = "https://api.im.$IM_ENVIRONMENT"
        INSTANCE_GROUP_NAME = 'meta-packages'
        INSTANCE_NAME_FULL = "pkg-dev-${params.INSTANCE_NAME.replaceAll("\\P{Alnum}", "").toLowerCase()}-$BUILD_NUMBER"
        INSTANCE_HOST = "https://${INSTANCE_GROUP_NAME}.im.$IM_ENVIRONMENT"
        INSTANCE_URL = "$INSTANCE_HOST/$INSTANCE_NAME_FULL"
        INSTANCE_TTL = "${params.TTL != '' ? params.TTL.toInteger() * 60 : ''}"
        DATABASE_NAME = "${params.DATABASE}.sql.gz"
        HTTP = 'https --check-status'
        PKG_CREDENTIALS = credentials('packages-instance-credentials')
    }

    stages {
        stage('Create dev instance') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'pkg-im-bot', passwordVariable: 'PASSWORD', usernameVariable: 'USER_EMAIL')]) {
                        dir('im-manager') {
                            gitHelper.sparseCheckout('https://github.com/dhis2-sre/im-manager', 'master', '/scripts')

                            // TODO upload database every time or s3 replication rule?
                            dir('scripts/databases') {
                                env.DATABASE_ID = sh(
                                    returnStdout: true,
                                    script: "./list.sh | jq -r '.[] | select(.name == \"$INSTANCE_GROUP_NAME\") .databases[] | select(.name == \"$DATABASE_NAME\") .id'"
                                ).trim()
                                sh '[ -n "$DATABASE_ID" ]'

                                echo "DATABASE_ID is $DATABASE_ID"
                            }

                            dir('scripts/instances') {
                                echo 'Creating DHIS2 instance ...'

                                sh "./deploy-dhis2.sh ${env.INSTANCE_GROUP_NAME} ${env.INSTANCE_NAME_FULL}"

                                timeout(15) {
                                    waitFor.statusOk("$INSTANCE_URL")
                                }

                                if (params.DATABASE != 'empty') {
                                    NOTIFIER_ENDPOINT = dhis2.generateAnalytics("$INSTANCE_URL", '$PKG_CREDENTIALS')
                                    timeout(15) {
                                        waitFor.analyticsCompleted("${INSTANCE_URL}${NOTIFIER_ENDPOINT}", '$PKG_CREDENTIALS')
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

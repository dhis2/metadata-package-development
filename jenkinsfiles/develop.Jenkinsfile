@Library('pipeline-library') _

pipeline {
    agent {
        label 'ec2-jdk11-large'
    }

    parameters {
        booleanParam(name: 'SEED_DATABASE', defaultValue: true, description: '')
        string(name: 'INSTANCE_NAME', defaultValue: 'foobar', description: '')
    }

    options {
        ansiColor('xterm')
    }

    environment {
        IMAGE_TAG = '2.37.9'
        IMAGE_REPOSITORY = 'core'
        IM_ENVIRONMENT = 'prod.test.c.dhis2.org'
        IM_HOST = "https://api.im.$IM_ENVIRONMENT"
        INSTANCE_GROUP_NAME = 'meta-packages'
        INSTANCE_NAME_FULL = "pkg-dev-${params.INSTANCE_NAME.replaceAll("\\P{Alnum}", "").toLowerCase()}-$BUILD_NUMBER"
        INSTANCE_HOST = "https://${INSTANCE_GROUP_NAME}.im.$IM_ENVIRONMENT"
        INSTANCE_URL = "$INSTANCE_HOST/$INSTANCE_NAME_FULL"
        DATABASE_NAME = "${params.SEED_DATABASE ? 'packages-dev.sql.gz' : 'dhis2-db-empty.sql.gz'}"
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

                            dir('scripts/databases') {
                                env.DATABASE_ID = sh(
                                    returnStdout: true,
                                    script: "./list.sh | jq -r '.[] | select(.Name == \"$INSTANCE_GROUP_NAME\") .Databases[] | select(.Name == \"$DATABASE_NAME\") .ID'"
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

                                if (params.SEED_DATABASE) {
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

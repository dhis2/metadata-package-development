@Library('pipeline-library') _

pipeline {
    agent {
        label 'ec2-jdk11-large'
    }

    parameters {
        stashedFile(name: 'PACKAGE_FILE_UPLOAD', description: '[OPTIONAL] Custom metadata package file.')
        string(name: 'STAGING_INSTANCE_NAME', defaultValue: 'foobar', description: '[REQUIRED] Name of the staging instance.')
        string(name: 'DEV_INSTANCE_NAME', defaultValue: '', description: '[OPTIONAL] Name of the dev instance to export from.')
        string(name: 'PACKAGE_CODE', defaultValue: '', description: '[OPTIONAL] Package code to extract with.')
        choice(name: 'PACKAGE_TYPE', choices: ['AGG', 'TRK'], description: '[OPTIONAL] Type of the package to export.')
        string(name: 'PACKAGE_DESC', defaultValue: '', description: '[OPTIONAL] Description of the package.')
    }

    options {
        ansiColor('xterm')
        disableConcurrentBuilds() // Need in order to sequentially “merge” new packages into the current master database.
    }

    environment {
        IMAGE_TAG = '2.37.9'
        IMAGE_REPOSITORY = 'core'
        IM_ENVIRONMENT = 'prod.test.c.dhis2.org'
        IM_HOST = "https://api.im.$IM_ENVIRONMENT"
        INSTANCE_GROUP_NAME = 'meta-packages'
        INSTANCE_NAME_FULL = "pkg-staging-${params.STAGING_INSTANCE_NAME.replaceAll("\\P{Alnum}", "").toLowerCase()}-$BUILD_NUMBER"
        INSTANCE_HOST = "https://${INSTANCE_GROUP_NAME}.im.$IM_ENVIRONMENT"
        INSTANCE_URL = "$INSTANCE_HOST/$INSTANCE_NAME_FULL"
        HTTP = 'https --check-status'
        PKG_IM_CREDENTIALS_ID = 'pkg-im-bot'
        PKG_CREDENTIALS = credentials('packages-instance-credentials')
        PKG_MASTER_DB_NAME = 'packages-dev.sql.gz'
        PACKAGE_FILE = 'PACKAGE_FILE_UPLOAD'
        PACKAGE_DIFF_FILE = 'package-diff-file'
        ALL_METADATA_FILE = 'all-metadata.json'
        DHIS2_LOCAL_PORT = 8080
    }

    stages {
        stage('Clone git repos') {
            steps {
                script {
                    dir('dhis2-utils') {
                        git url: 'https://github.com/dhis2/dhis2-utils'
                    }

                    dir('dhis2-metadata-checkers') {
                        git branch: 'main', url: 'https://github.com/solid-lines/dhis2-metadata-checkers'
                    }

                    dir('im-manager') {
                        gitHelper.sparseCheckout('https://github.com/dhis2-sre/im-manager', 'master', '/scripts')
                    }

                    dir('ALL_METADATA') {
                        git credentialsId: 'github-token-as-password', url: 'https://github.com/dhis2-metadata/ALL_METADATA'
                    }
                }
            }
        }

        stage('Create staging instance') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: "$PKG_IM_CREDENTIALS_ID", passwordVariable: 'PASSWORD', usernameVariable: 'USER_EMAIL')]) {
                        dir('im-manager/scripts/databases') {
                            env.DATABASE_ID = sh(
                                returnStdout: true,
                                script: "./list.sh | jq -r '.[] | select(.Name == \"$INSTANCE_GROUP_NAME\") .Databases[] | select(.Name == \"$PKG_MASTER_DB_NAME\") .ID'"
                            ).trim()

                            sh '[ -n "$DATABASE_ID" ]'
                            echo "DATABASE_ID is $DATABASE_ID"
                        }

                        dir('im-manager/scripts/instances') {
                            echo 'Creating DHIS2 instance ...'

                            sh "./deploy-dhis2.sh $INSTANCE_GROUP_NAME $INSTANCE_NAME_FULL"

                            timeout(15) {
                                waitFor.statusOk("$INSTANCE_URL")
                            }

                            NOTIFIER_ENDPOINT = dhis2.generateAnalytics("$INSTANCE_URL", '$PKG_CREDENTIALS')
                            timeout(15) {
                                waitFor.analyticsCompleted("${INSTANCE_URL}${NOTIFIER_ENDPOINT}", '$PKG_CREDENTIALS')
                            }
                        }
                    }
                }
            }
        }

        stage('Export package from dev instance') {
            when {
                expression {
                    try {
                        unstash "$PACKAGE_FILE" // Need to unstash the file, otherwise it's always null.
                    } catch (e) {
                        echo e.toString()
                    }

                    return params.DEV_INSTANCE_NAME != ''
                }
            }

            steps {
                script {
                    echo "Exporting package from ${params.DEV_INSTANCE_NAME} ..."

                    sh 'echo {\\"dhis\\": {\\"username\\": \\"${PKG_CREDENTIALS_USR}\\", \\"password\\": \\"${PKG_CREDENTIALS_PSW}\\"}} > auth.json'

                    PACKAGE_FILE = sh(
                        returnStdout: true,
                        script: """#!/bin/bash
                            set -euxo pipefail
                            ./scripts/export-package.sh "${params.PACKAGE_CODE}" "${params.PACKAGE_TYPE}" "${params.PACKAGE_DESC}" "${env.INSTANCE_HOST}/${params.DEV_INSTANCE_NAME}" | tail -1
                        """
                    ).trim()

                    PACKAGE_NAME = sh(returnStdout: true, script: "cat $PACKAGE_FILE | jq -r '.package .name'").trim()
                }
            }
        }

        stage('Test package in empty instance') {
            when {
                anyOf {
                    expression { params.DEV_INSTANCE_NAME != '' }

                    expression { readFile("$PACKAGE_FILE").size() != 0 }
                }

            }

            stages {
                stage('Validate metadata') {
                    steps {
                        script {
                            catchError(catchInterruptions: false, message: 'Validation errors found!', stageResult: 'FAILURE') {
                                sh("python3 -u dhis2-utils/tools/dhis2-metadata-package-validator/metadata_package_validator.py -f $WORKSPACE/$PACKAGE_FILE")
                            }
                        }
                    }
                }

                stage('Test import') {
                    steps {
                        script {
                            withDockerRegistry([credentialsId: "docker-hub-credentials", url: ""]) {
                                d2.startCluster("$IMAGE_TAG", "$DHIS2_LOCAL_PORT")
                            }

                            sleep(5)

                            dir('test') {
                                sh "$WORKSPACE/scripts/replace-ou-placeholders.sh $WORKSPACE/$PACKAGE_FILE > ./package.json"
                                sh "$WORKSPACE/scripts/run-import-tests.sh $DHIS2_LOCAL_PORT"
                            }
                        }
                    }

                    post {
                        always {
                            script {
                                sh "d2 cluster compose $IMAGE_TAG logs core > logs_empty_instance.txt"
                                archiveArtifacts artifacts: 'logs_empty_instance.txt'
                            }
                        }
                    }
                }

                stage('Run checks') {
                    parallel {
                        stage('Check dashboards') {
                            steps {
                                sh './scripts/make-dashboards-public.sh'
                                sh './scripts/check-dashboards.sh http://localhost:$DHIS2_LOCAL_PORT'
                            }
                        }

                        stage('Check PR expressions') {
                            steps {
                                sh './scripts/check-expressions.sh http://localhost:$DHIS2_LOCAL_PORT'
                            }
                        }
                    }
                }
            }
        }

        stage ('Notify before import') {
            when {
                anyOf {
                    expression { params.DEV_INSTANCE_NAME != '' }

                    expression { readFile("$PACKAGE_FILE").size() != 0 }
                }

            }

            steps {
                script {
                    slackSend(
                        color: '#00ffff',
                        channel: '@U01RSD1LPB3',
                        message: slack.buildUrl() + "\nPausing for review before importing package."
                    )
                }
            }
        }

        stage('Pause before import') {
            when {
                anyOf {
                    expression { params.DEV_INSTANCE_NAME != '' }

                    expression { readFile("$PACKAGE_FILE").size() != 0 }
                }

            }

            input {
                message "Continue?"
                ok "Yes"
                parameters {
                    string(name: 'EXAMPLE_PARAMETER', defaultValue: 'test', description: 'Example description.')
                    booleanParam(name: 'DELETE_DEV_INSTANCE', defaultValue: false, description: 'Should the dev instance be deleted?')
                }
            }

            steps {
                script {
                    echo "The value of the EXAMPLE_PARAMETER is ${env.EXAMPLE_PARAMETER}"
                    // Parameters from the input block are available as env variables only for the current stage,
                    // so they have to be reassigned to a new environment variable for the next stages.
                    env.DELETE_DEV_INSTANCE_ENV = env.DELETE_DEV_INSTANCE
                }
            }
        }

        stage('Import package into staging instance') {
            when {
                anyOf {
                    expression { params.DEV_INSTANCE_NAME != '' }

                    expression { readFile("$PACKAGE_FILE").size() != 0 }
                }

            }

            steps {
                echo "Importing package into ${params.STAGING_INSTANCE_NAME} ..."
                sh "$WORKSPACE/scripts/replace-ou-placeholders.sh $PACKAGE_FILE > updated-$PACKAGE_FILE"
                sh "$HTTP --auth \$PKG_CREDENTIALS POST $INSTANCE_URL/api/metadata < updated-$PACKAGE_FILE"
            }
        }

        stage ('Notify after import') {
            steps {
                script {
                    slackSend(
                        color: '#00ffff',
                        channel: '@U01RSD1LPB3',
                        message: slack.buildUrl() + "\nPausing for review after importing package."
                    )
                }
            }
        }

        stage('Pause after import') {
            input {
                message "Continue?"
                ok "Yes"
                parameters {
                    string(name: 'EXAMPLE_PARAMETER', defaultValue: 'test', description: 'Example description.')
                    booleanParam(name: 'DELETE_DEV_INSTANCE', defaultValue: false, description: 'Should the dev instance be deleted?')
                }
            }

            steps {
                script {
                    echo "The value of the EXAMPLE_PARAMETER is ${env.EXAMPLE_PARAMETER}"
                    // Parameters from the input block are available as env variables only for the current stage,
                    // so they have to be reassigned to a new environment variable for the next stages.
                    env.DELETE_DEV_INSTANCE_ENV = env.DELETE_DEV_INSTANCE
                }
            }
        }

        stage('Test packages in staging instance') {
            stages {
                stage('Export all metadata') {
                    steps {
                        echo "Export metadata from ${params.STAGING_INSTANCE_NAME} ..."
                        sh "$HTTP --auth \$PKG_CREDENTIALS GET $INSTANCE_URL/api/metadata > $ALL_METADATA_FILE"
                    }
                }

                stage('Validate metadata') {
                    steps {
                        script {
                            catchError(catchInterruptions: false, message: 'Validation errors found!', stageResult: 'FAILURE') {
                                sh("python3 -u dhis2-utils/tools/dhis2-metadata-package-validator/metadata_package_validator.py -f $WORKSPACE/$ALL_METADATA_FILE")
                            }
                        }
                    }
                }

                stage('Run checks') {
                    parallel {
                        stage('Check dashboards') {
                            steps {
                                catchError(catchInterruptions: false, message: 'Dashboard errors found!', stageResult: 'FAILURE') {
                                    sh 'USER_NAME="$PKG_CREDENTIALS_USR" USER_PASSWORD="$PKG_CREDENTIALS_PSW" ./scripts/check-dashboards.sh $INSTANCE_URL'
                                }
                            }
                        }

                        stage('Check PR expressions') {
                            steps {
                                catchError(catchInterruptions: false, message: 'PR expression errors found!', stageResult: 'FAILURE') {
                                    sh 'USER_NAME="$PKG_CREDENTIALS_USR" USER_PASSWORD="$PKG_CREDENTIALS_PSW" ./scripts/check-expressions.sh $INSTANCE_URL'
                                }
                            }
                        }
                    }
                }
            }
        }

        stage('Create diff') {
            steps {
                dir('dhis2-utils/tools/dhis2-metadatapackagediff') {
                    sh 'pip3 install -r requirements.txt'

                    sh "python3 metadata_package_diff.py $WORKSPACE/ALL_METADATA/$ALL_METADATA_FILE $WORKSPACE/$ALL_METADATA_FILE $WORKSPACE/$PACKAGE_DIFF_FILE"
                }
            }

            post {
                always {
                    archiveArtifacts artifacts: "${PACKAGE_DIFF_FILE}.xlsx"
                }
            }
        }

        stage('Push metadata to GitHub') {
            environment {
                GITHUB_CREDS = credentials('github-token-as-password')
                GITHUB_EMAIL = 'apps@dhis2.org'
                REPOSITORY_NAME = 'ALL_METADATA'
            }

            steps {
                script {
                    sh 'git config --global user.email $GITHUB_EMAIL'
                    sh 'git config --global user.name $GITHUB_CREDS_USR'

                    dir("$REPOSITORY_NAME") {
                        sh 'cp $WORKSPACE/$ALL_METADATA_FILE .'
                        sh 'git add .'
                        sh 'git diff-index --quiet HEAD || git commit -m "chore: Upload all metadata"'
                        sh 'git push https://$GITHUB_CREDS_PSW@github.com/dhis2-metadata/$REPOSITORY_NAME'
                    }
                }
            }
        }

        stage('Dump staging db') {
            steps {
                echo "Dumping staging db ..."
                script {
                    withCredentials([usernamePassword(credentialsId: "$PKG_IM_CREDENTIALS_ID", passwordVariable: 'PASSWORD', usernameVariable: 'USER_EMAIL')]) {
                        dir('im-manager/scripts/databases') {
                            env.NEW_DATABASE_ID = sh(
                                returnStdout: true,
                                script: "./saveAs.sh $INSTANCE_GROUP_NAME $INSTANCE_NAME_FULL ${INSTANCE_NAME_FULL}-dump.pgc custom | jq -r '.ID'"
                            ).trim()

                            timeout(15) {
                                waitUntil(initialRecurrencePeriod: 5000, quiet: true) {
                                    dbUrl = sh(returnStdout: true, script: "./findById.sh $NEW_DATABASE_ID | jq -r '.Url'").trim()

                                    return (dbUrl != '')
                                }
                            }
                        }
                    }
                }
            }
        }

        stage('Replace PKG master db') {
            steps {
                echo "Replacing PKG master db ..."
                withCredentials([usernamePassword(credentialsId: "$PKG_IM_CREDENTIALS_ID", passwordVariable: 'PASSWORD', usernameVariable: 'USER_EMAIL')]) {
                    dir('im-manager/scripts/databases') {
                        sh "./update.sh $DATABASE_ID old-$PKG_MASTER_DB_NAME"
                        sh "./update.sh $NEW_DATABASE_ID $PKG_MASTER_DB_NAME"
                        sh "./delete.sh $DATABASE_ID"
                    }
                }
            }

            post {
                success {
                    script {
                        withCredentials([usernamePassword(credentialsId: "$PKG_IM_CREDENTIALS_ID", passwordVariable: 'PASSWORD', usernameVariable: 'USER_EMAIL')]) {
                            dir('im-manager/scripts/instances') {
                                env.INSTANCES_TO_DELETE = env.INSTANCE_NAME_FULL
                                if (env.DELETE_DEV_INSTANCE_ENV.toBoolean()) {
                                    env.INSTANCES_TO_DELETE = "${env.INSTANCE_NAME_FULL} ${params.DEV_INSTANCE_NAME}"
                                }

                                sh "./destroy.sh $INSTANCE_GROUP_NAME $INSTANCES_TO_DELETE"
                            }
                        }
                    }
                }
            }
        }
    }
}

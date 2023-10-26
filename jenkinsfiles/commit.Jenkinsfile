@Library('pipeline-library') _

node('ec2-jdk8-large-spot') {
    dir('dhis2-utils') {
        git url: 'https://github.com/dhis2/dhis2-utils', branch: 'use-argparse-insead-of-envvars'

        dir('tools/dhis2-metadata-index-parser') {
            sh 'pip3 install -r requirements.txt'

            withCredentials([file(credentialsId: 'metadata-index-parser-service-account', variable: 'GOOGLE_SERVICE_ACCOUNT')]) {
                env.SPREADSHEET_ID = '1IIQL2IkGJqiIWLr6Bgg7p9fE78AwQYhHBNGoV-spGOM'

                env.PACKAGES_INDEX_JSON = sh(
                    returnStdout: true,
                    script: 'python3 parse-index.py --service-account-file $GOOGLE_SERVICE_ACCOUNT --spreadsheet-id $SPREADSHEET_ID --no-only-ready --no-uncheck-readiness'
                ).trim()

                PARAMETER_VALUES = sh(returnStdout:true, script: 'echo $PACKAGES_INDEX_JSON | jq -r \'.[] | .["Component name"]\'').trim()
            }
        }
    }
}

pipeline {
    agent {
        label 'ec2-jdk11-large'
    }

    parameters {
        booleanParam(name: 'REFRESH_PACKAGES', defaultValue: false, description: '[OPTIONAL] Refresh the list of PACKAGE_NAMEs and abort the build.')
        string(name: 'STAGING_INSTANCE_NAME', defaultValue: 'foobar', description: '[REQUIRED] Full staging instance name will be: "pkg-staging-<STAGING_INSTANCE_NAME>-<BUILD_NUMBER>".')
        choice(name: 'DATABASE', choices: ['pkgmaster', 'dev', 'tracker_dev'], description: '[REQUIRED] Master packages database or development database from https://metadata.dev.dhis2.org.')
        booleanParam(name: 'REPLACE_DATABASE', defaultValue: true, description: '[OPTIONAL] Replace database if all validations and tests pass.')
        choice(name: 'DHIS2_IMAGE_REPOSITORY', choices: ['core', 'core-dev'], description: 'DHIS2 Docker image repository.')
        string(name: 'DHIS2_VERSION', defaultValue: '2.38.4', description: '[OPTIONAL] DHIS2 version for the instance.')
        string(name: 'DEV_INSTANCE_NAME', defaultValue: '', description: '[OPTIONAL] Name of the dev instance to export from.\nOnly needed if you want to export a package specified with PACKAGE_NAME')
        choice(name: 'PACKAGE_NAME', choices: PARAMETER_VALUES, description: '[REQUIRED] Select a package to extract by name.')
        stashedFile(name: 'PACKAGE_FILE_UPLOAD', description: '[OPTIONAL] Provide a custom metadata package file instead of exporting it.\nIf a file is uploaded, the "DEV_INSTANCE_NAME" and "PACKAGE_NAME" are obsolete.')
    }

    options {
        ansiColor('xterm')
        disableConcurrentBuilds() // Needed in order to sequentially “merge” new packages into the current master database.
    }

    environment {
        IMAGE_TAG = "${params.DHIS2_VERSION}"
        IMAGE_REPOSITORY = "${params.DHIS2_IMAGE_REPOSITORY}"
        IM_REPO_URL = 'https://github.com/dhis2-sre/im-manager'
        IM_ENVIRONMENT = 'im.dhis2.org'
        IM_HOST = "https://api.$IM_ENVIRONMENT"
        INSTANCE_GROUP_NAME = 'meta-packages'
        INSTANCE_NAME_FULL = "pkg-staging-${params.STAGING_INSTANCE_NAME.replaceAll("\\P{Alnum}", "").toLowerCase()}-$BUILD_NUMBER"
        INSTANCE_HOST = "https://${INSTANCE_GROUP_NAME}.$IM_ENVIRONMENT"
        INSTANCE_URL = "$INSTANCE_HOST/$INSTANCE_NAME_FULL"
        HTTP = 'https --check-status'
        PKG_IM_CREDENTIALS_ID = 'pkg-im-bot'
        PKG_CREDENTIALS = credentials('packages-instance-credentials')
        PKG_MASTER_DB_NAME = 'packages-dev.sql.gz'
        DATABASE_NAME = "${params.DATABASE == 'pkgmaster' ? params.DATABASE + '.pgc' : params.DATABASE + '.sql.gz'}"
        PACKAGE_FILE = 'PACKAGE_FILE_UPLOAD'
        PACKAGE_DIFF_FILE = 'package-diff-file'
        ALL_METADATA_FILE = 'all-metadata.json'
        DHIS2_LOCAL_PORT = 8080
    }

    stages {
        stage('Clone git repos') {
            steps {
                script {
                    // Immediately abort pipeline if REFRESH_PACKAGES is enabled.
                    if (params.REFRESH_PACKAGES.toBoolean()) {
                        error('This build is only for refreshing the PACKAGE_NAME parameter. Pipeline will be aborted now.')
                    }

                    dir('dhis2-utils') {
                        git url: 'https://github.com/dhis2/dhis2-utils'
                    }

                    dir('dhis2-metadata-checkers') {
                        git url: 'https://github.com/solid-lines/dhis2-metadata-checkers', branch: 'main'
                    }

                    dir('ALL_METADATA') {
                        git url: 'https://github.com/dhis2-metadata/ALL_METADATA', credentialsId: 'github-token-as-password'
                    }

                    dir('im-manager') {
                        gitHelper.sparseCheckout(IM_REPO_URL, "${gitHelper.getLatestTag(IM_REPO_URL)}", '/scripts')
                    }
                }
            }
        }

        stage('Create staging instance') {
            steps {
                script {
                    // Get package details based on the selected PACKAGE_NAME parameter value.
                    env.SELECTED_PACKAGE = sh(returnStdout: true, script: 'echo "$PACKAGES_INDEX_JSON" | jq --arg name "$PACKAGE_NAME" -r \'.[] | select(."Component name" == $name)\'').trim()
                    env.PACKAGE_CODE = sh(returnStdout: true, script: 'echo "$SELECTED_PACKAGE" | jq -r \'."Extraction code"\'').trim()
                    env.PACKAGE_TYPE = sh(returnStdout: true, script: 'echo "$SELECTED_PACKAGE" | jq -r \'."Script parameter"\'').trim()
                    env.PACKAGE_SOURCE_INSTANCE = sh(returnStdout: true, script: 'echo "$SELECTED_PACKAGE" | jq -r \'."Source instance"\'').trim()
                    env.PACKAGE_HEALTH_AREA_NAME = sh(returnStdout: true, script: 'echo "$SELECTED_PACKAGE" | jq -r \'."Health area"\'').trim()
                    env.PACKAGE_HEALTH_AREA_CODE = sh(returnStdout: true, script: 'echo "$SELECTED_PACKAGE" | jq -r \'."Health area prefix"\'').trim()

                    withCredentials([usernamePassword(credentialsId: "$PKG_IM_CREDENTIALS_ID", passwordVariable: 'PASSWORD', usernameVariable: 'USER_EMAIL')]) {
                        dir('im-manager/scripts/databases') {
                            env.DATABASE_ID = sh(
                                returnStdout: true,
                                script: "./list.sh | jq -r '.[] | select(.name == \"$INSTANCE_GROUP_NAME\") .databases[] | select(.name == \"$DATABASE_NAME\") .id'"
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
                        script: '''#!/bin/bash
                            set -euxo pipefail
                            ./scripts/export-package.sh "$PACKAGE_CODE" "$PACKAGE_TYPE" "$PACKAGE_NAME" "$PACKAGE_HEALTH_AREA_NAME" "$PACKAGE_HEALTH_AREA_CODE" "$INSTANCE_HOST/$DEV_INSTANCE_NAME" | tail -1
                        '''
                    ).trim()

                    // TODO obsolete?
                    PACKAGE_FILE_NAME = sh(returnStdout: true, script: "cat $PACKAGE_FILE | jq -r '.package .name'").trim()
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
//                                DHIS2_CHANNEL = "${params.DHIS2_IMAGE_REPOSITORY == 'core' ? 'stable' : 'dev'}"
//                                d2.startCluster("$IMAGE_TAG", "$DHIS2_LOCAL_PORT", "$DHIS2_CHANNEL")
                                dir('hack') {
                                    dir('docker') {
                                        sh 'curl "https://raw.githubusercontent.com/dhis2/dhis2-core/master/docker/dhis.conf" -O'
                                    }

                                    env.DHIS2_HOME = '/opt/dhis2'
                                    env.DHIS2_IMAGE = "dhis2/${params.DHIS2_IMAGE_REPOSITORY}:${IMAGE_TAG}"

                                    sh 'docker-compose up -d'

                                    sleep(10)

                                    timeout(5) {
                                        waitFor.statusOk("http://localhost:${DHIS2_LOCAL_PORT}")
                                    }
                                }
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
//                                sh "d2 cluster compose $IMAGE_TAG logs core > logs_empty_instance.txt"
                                dir('hack') {
                                    sh "docker-compose logs core > logs_empty_instance.txt"
                                    archiveArtifacts artifacts: 'logs_empty_instance.txt'
                                }
                            }
                        }
                    }
                }

                stage('Run checks') {
                    parallel {
                        stage('Check dashboards') {
                            steps {
                                catchError(catchInterruptions: false, message: 'Dashboard errors found!', stageResult: 'FAILURE') {
                                    sh './scripts/make-dashboards-public.sh'
                                    sh './scripts/check-dashboards.sh http://localhost:$DHIS2_LOCAL_PORT'
                                }
                            }
                        }

                        stage('Check PR expressions') {
                            steps {
                                catchError(catchInterruptions: false, message: 'PR expressions errors found!', stageResult: 'FAILURE') {
                                    sh './scripts/check-expressions.sh http://localhost:$DHIS2_LOCAL_PORT'
                                }
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
                        channel: 'pkg-notifications',
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
                        channel: 'pkg-notifications',
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

        stage('Save DB') {
            when {
                expression { params.REPLACE_DATABASE }
            }

            steps {
                echo "Saving ${params.DATABASE} DB ..."
                script {
                    withCredentials([usernamePassword(credentialsId: "$PKG_IM_CREDENTIALS_ID", passwordVariable: 'PASSWORD', usernameVariable: 'USER_EMAIL')]) {
                        dir('im-manager/scripts/databases') {
                            sh "./save.sh $INSTANCE_GROUP_NAME $INSTANCE_NAME_FULL"

                            timeout(15) {
                                waitUntil(initialRecurrencePeriod: 5000, quiet: true) {
                                    // TODO change this once we have a better way of knowing the status of a "save"
                                    lock = sh(returnStdout: true, script: "./findById.sh $DATABASE_ID | jq -r '.lock'").trim()

                                    return (lock == 'null')
                                }
                            }
                        }
                    }
                }
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

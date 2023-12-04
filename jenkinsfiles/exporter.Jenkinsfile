@Library('pipeline-library') _

node('ec2-jdk8-large-spot') {
    dir('dhis2-utils') {
        git url: 'https://github.com/dhis2/dhis2-utils'

        dir('tools/dhis2-metadata-index-parser') {
            sh 'pip3 install -r requirements.txt'

            withCredentials([file(credentialsId: 'metadata-index-parser-service-account', variable: 'GOOGLE_SERVICE_ACCOUNT')]) {
                env.SPREADSHEET_ID = '1IIQL2IkGJqiIWLr6Bgg7p9fE78AwQYhHBNGoV-spGOM'

                env.PACKAGES_INDEX_JSON = sh(
                    returnStdout: true,
                    script: 'python3 parse-index.py --service-account-file $GOOGLE_SERVICE_ACCOUNT --spreadsheet-id $SPREADSHEET_ID --no-only-ready --no-uncheck-readiness'
                ).trim()

                PARAMETER_VALUES = sh(returnStdout:true, script: 'echo $PACKAGES_INDEX_JSON | jq -r \'.[] | .["Component Name"]\'').trim()
            }
        }
    }
}

pipeline {
    agent {
        label 'ec2-jdk8-large-spot'
    }

    parameters {
        booleanParam(name: 'REFRESH_PACKAGES', defaultValue: false, description: '[OPTIONAL] Refresh the list of PACKAGE_NAMEs and abort the build.')
        choice(name: 'PACKAGE_NAME', choices: PARAMETER_VALUES, description: '[REQUIRED] Select a package to extract by name.')
        string(name: 'INSTANCE_URL', defaultValue: '', description: '[OPTIONAL] Instance URL to export package from.')
        string(name: 'DHIS2_VERSION', defaultValue: '2.38', description: '[OPTIONAL] DHIS2 version to extract the package from. (only major.minor version like 2.38, not 2.38.1, etc)')
        stashedFile(name: 'PACKAGE_FILE_UPLOAD', description: '[OPTIONAL] Upload a package file directly, instead of exporting it.\n If a file is uploaded, all the previous parameters are obsolete.')
        booleanParam(name: 'RUN_CHECKS', defaultValue: true, description: '[OPTIONAL] Choose whether to run the PR expressions and Dashboard checks.')
        booleanParam(name: 'PUSH_PACKAGE', defaultValue: true, description: '[OPTIONAL] Push the package to its GitHub repository, if the build succeeds.')
        string(name: 'COMMIT_MESSAGE', defaultValue: '', description: '[OPTIONAL] Custom commit message when pushing package to GitHub.')
    }

    options {
        ansiColor('xterm')
    }

    environment {
        UTILS_GIT_URL = 'https://github.com/dhis2/dhis2-utils'
        METADATA_CHECKERS_GIT_URL = 'https://github.com/solid-lines/dhis2-metadata-checkers'
        PACKAGE_FILE = 'PACKAGE_FILE_UPLOAD'
        DHIS2_PORT = 8080
        PACKAGE_IS_EXPORTED = false
        PACKAGE_EXPORT_SUCCEEDED = false
        PACKAGE_DHIS2_CREDENTIALS = credentials('packages-instance-credentials')
    }

    stages {
        stage('Export package') {
            when {
                expression {
                    try {
                        // Unless the file is unstashed, it's null.
                        unstash "${PACKAGE_FILE}"
                    } catch (e) {
                        echo e.toString()
                        return true;
                    }

                    // If file wasn't uploaded, its size will be 0.
                    return (fileExists("${PACKAGE_FILE}")) && readFile("${PACKAGE_FILE}").size() == 0
                }
            }

            steps {
                script {
                    if (params.REFRESH_PACKAGES.toBoolean()) {
                        error('This build is only for refreshing the PACKAGE_NAME parameter. Pipeline will be aborted now.')
                    }

                    // Get package details based on the selected PACKAGE_NAME parameter value.
                    env.SELECTED_PACKAGE = sh(returnStdout: true, script: 'echo "$PACKAGES_INDEX_JSON" | jq --arg name "$PACKAGE_NAME" -r \'.[] | select(."Component Name" == $name)\'').trim()
                    env.PACKAGE_CODE = sh(returnStdout: true, script: 'echo "$SELECTED_PACKAGE" | jq -r \'."Package Code"\'').trim()
                    env.PACKAGE_TYPE = sh(returnStdout: true, script: 'echo "$SELECTED_PACKAGE" | jq -r \'."Package Type"\'').trim()
                    env.PACKAGE_SOURCE_INSTANCE = sh(returnStdout: true, script: 'echo "$SELECTED_PACKAGE" | jq -r \'."Source Instance"\'').trim()
                    env.PACKAGE_HEALTH_AREA_NAME = sh(returnStdout: true, script: 'echo "$SELECTED_PACKAGE" | jq -r \'."Health Area"\'').trim()
                    env.PACKAGE_HEALTH_AREA_CODE = sh(returnStdout: true, script: 'echo "$SELECTED_PACKAGE" | jq -r \'."Health Area Code"\'').trim()
                    env.INSTANCE_URL = "${params.INSTANCE_URL != '' ? params.INSTANCE_URL : env.PACKAGE_SOURCE_INSTANCE}"

                    dir('dhis2-utils') {
                        git url: "$UTILS_GIT_URL"
                    }

                    PACKAGE_IS_EXPORTED = true

                    sh 'echo {\\"dhis\\": {\\"baseurl\\": \\"\\", \\"username\\": \\"${PACKAGE_DHIS2_CREDENTIALS_USR}\\", \\"password\\": \\"${PACKAGE_DHIS2_CREDENTIALS_PSW}\\"}} > auth.json'

                    PACKAGE_FILE = sh(
                        returnStdout: true,
                        script: '''#!/bin/bash
                            set -euxo pipefail
                            ./scripts/export-package.sh "$PACKAGE_CODE" "$PACKAGE_TYPE" "$PACKAGE_NAME" "$PACKAGE_HEALTH_AREA_NAME" "$PACKAGE_HEALTH_AREA_CODE" "$INSTANCE_URL" | tail -1
                        '''
                    ).trim()

                    PACKAGE_EXPORT_SUCCEEDED = true
                }
            }

            post {
                success {
                    script {
                        archiveArtifacts artifacts: "$PACKAGE_FILE"
                    }
                }
            }
        }

        stage('Extract package info') {
            steps {
                script {
                    if (PACKAGE_IS_EXPORTED.toBoolean()) {
                        sh "cp $WORKSPACE/$PACKAGE_FILE ./test/package_orig.json"
                    } else {
                        unstash "$PACKAGE_FILE"
                        sh "cp $PACKAGE_FILE ./test/package_orig.json"
                    }

                    DHIS2_VERSION_IN_PACKAGE = sh(returnStdout: true, script: "cat $PACKAGE_FILE | jq -r \".package .DHIS2Version\"").trim()

                    // The following DHIS2 versions contain an extraneous "SNAPSHOT" substring, even though they're stable versions.
                    // This check makes sure the substring is removed, so they're not incorrectly considered as dev versions.
                    if (DHIS2_VERSION_IN_PACKAGE in ['2.39.0.1-SNAPSHOT', '2.38.2.1-SNAPSHOT', '2.37.8.1-SNAPSHOT', '2.36.12.1-SNAPSHOT']) {
                        DHIS2_VERSION_IN_PACKAGE = DHIS2_VERSION_IN_PACKAGE.replace('-SNAPSHOT', '')
                    }

                    PACKAGE_NAME = sh(returnStdout: true, script: "cat $PACKAGE_FILE | jq -r \".package .name\"").trim()

                    currentBuild.description = "$PACKAGE_NAME"
                }
            }
        }

        stage('Validate metadata') {
            steps {
                script {
                    // In case the 'Export package' stage was skipped, the utils repo needs to be cloned again
                    if (!fileExists('dhis2-utils')) {
                        dir('dhis2-utils') {
                            git url: "$UTILS_GIT_URL"
                        }
                    }

                    catchError(catchInterruptions: false, message: 'Validation errors found!', stageResult: 'FAILURE') {
                        sh("python3 -u dhis2-utils/tools/dhis2-metadata-package-validator/metadata_package_validator.py -f $WORKSPACE/$PACKAGE_FILE")
                    }
                }
            }
        }

        stage('Test import in empty instance') {
            environment {
                DEFAULT_DHIS2_CREDENTIALS = credentials('dhis2-default')
            }

            steps {
                script {
                    env.DHIS2_CHANNEL = 'stable'

                    if (DHIS2_VERSION_IN_PACKAGE.length() <= 4 || DHIS2_VERSION_IN_PACKAGE.contains('SNAPSHOT')) {
                        echo 'DHIS2 version is from dev channel.'
                        env.DHIS2_CHANNEL = 'dev'
                        DHIS2_VERSION_IN_PACKAGE = DHIS2_VERSION_IN_PACKAGE[0..3]
                        PUSH_PACKAGE = false
                    }

                    withDockerRegistry([credentialsId: 'docker-hub-credentials', url: '']) {
                        d2.startCluster("$DHIS2_VERSION_IN_PACKAGE", "$DHIS2_PORT", "$DHIS2_CHANNEL")
                    }

                    sleep(5)

                    dir('test') {
                        sh "$WORKSPACE/scripts/run-import-tests.sh ./package_orig.json $DHIS2_PORT"
                    }

                    NOTIFIER_ENDPOINT = dhis2.generateAnalytics("http://localhost:$DHIS2_PORT", '$DEFAULT_DHIS2_CREDENTIALS')
                    timeout(5) {
                        waitFor.analyticsCompleted("http://localhost:${DHIS2_PORT}${NOTIFIER_ENDPOINT}", '$DEFAULT_DHIS2_CREDENTIALS')
                    }
                }
            }

            post {
                always {
                    script {
                        sh "d2 cluster compose $DHIS2_VERSION_IN_PACKAGE logs core > logs_empty_instance.txt"
                        archiveArtifacts artifacts: 'logs_empty_instance.txt'
                    }
                }
            }
        }

        stage('Run checks') {
            when {
                expression { params.RUN_CHECKS.toBoolean() }
            }

            parallel {
                stage('Check PR expressions') {
                    steps {
                        dir('dhis2-metadata-checkers') {
                            git branch: 'main', url: "$METADATA_CHECKERS_GIT_URL"
                        }

                        sh "./scripts/check-expressions.sh $DHIS2_PORT"
                    }
                }
            }
        }

        stage('Push to GitHub') {
            when {
                expression { PUSH_PACKAGE.toBoolean() }
            }

            environment {
                GITHUB_CREDS = credentials('github-token-as-password')
                GITHUB_EMAIL = 'apps@dhis2.org'
            }

            steps {
                script {
                    sh "./scripts/push-package.sh $PACKAGE_FILE"
                }
            }
        }
    }

    post {
        failure {
            script {
                if (!params.REFRESH_PACKAGES.toBoolean()) {
                    if (!params.DHIS2_VERSION) {
                        DHIS2_VERSION = 'not provided'
                    }

                    if (!PACKAGE_EXPORT_SUCCEEDED.toBoolean()) {
                        message = "The $PACKAGE_CODE (package type: $PACKAGE_TYPE, DHIS2 version: $DHIS2_VERSION) package export failed in ${slack.buildUrl()}"
                    } else {
                        message = "The $PACKAGE_NAME (DHIS2 version: $DHIS2_VERSION_IN_PACKAGE) package tests failed in ${slack.buildUrl()}"
                    }

                    slackSend(
                        color: '#ff0000',
                        channel: 'pkg-notifications',
                        message: message
                    )
                }
            }
        }
    }
}

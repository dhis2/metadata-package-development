@Library('pipeline-library') _

pipeline {
    agent {
        label 'ec2-jdk8-large-spot'
    }

    parameters {
        stashedFile 'package_metadata_file'
        string(name: 'Package_code', defaultValue: '', description: '[REQUIRED] Package code to extract with.')
        string(name: 'Package_type', defaultValue: '', description: '[REQUIRED] Type of the package to export.')
        string(name: 'Package_description', defaultValue: '', description: '[REQUIRED] Description of the package.')
        string(name: 'Instance_url', defaultValue: 'https://metadata.dev.dhis2.org/dev', description: '[REQUIRED] Instance URL to export package from.')
        string(name: 'DHIS2_version', defaultValue: '2.36', description: '[OPTIONAL] DHIS2 version to extract the package from. (only major.minor version like 2.36, not 2.36.1)')
        booleanParam(name: 'Push_package', defaultValue: true, description: '[OPTIONAL] Push the package to its GitHub repository, if the build succeeds.')
        string(name: 'Commit_message', defaultValue: '', description: '[OPTIONAL] Custom commit message when pushing package to GitHub.')
    }

    options {
        ansiColor('xterm')
    }

    environment {
        UTILS_GIT_URL = "https://github.com/dhis2/dhis2-utils"
        METADATA_CHECKERS_GIT_URL = "https://github.com/solid-lines/dhis2-metadata-checkers"
        PACKAGE_FILE = "package_metadata_file"
        PACKAGE_CODE = "${params.Package_code}"
        PACKAGE_TYPE = "${params.Package_type}"
        PACKAGE_DESCRIPTION = "${params.Package_description}"
        DHIS2_VERSION_INPUT = "${params.DHIS2_version}"
        INSTANCE_URL = "${params.Instance_url}"
        PUSH_PACKAGE = "${params.Push_package}"
        DHIS2_PORT = 8080
        PACKAGE_IS_EXPORTED = false
        PACKAGE_EXPORT_SUCCEEDED = false
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

            environment {
                USER_CREDENTIALS = credentials('packages-instance-credentials')
            }

            steps {
                script {
                    if (params.Package_code == null || params.Package_code == '') {
                        error('Package code is not set.')
                    }

                    if (params.Package_type == null || params.Package_type == '') {
                        error('Package type is not set.')
                    }

                    if (params.Package_description == null || params.Package_description == '') {
                        error('Package description is not set.')
                    }

                    dir('dhis2-utils') {
                        git url: "$UTILS_GIT_URL"
                    }

                    PACKAGE_IS_EXPORTED = true

                    sh 'echo {\\"dhis\\": {\\"baseurl\\": \\"\\", \\"username\\": \\"${USER_CREDENTIALS_USR}\\", \\"password\\": \\"${USER_CREDENTIALS_PSW}\\"}} > auth.json'

                    PACKAGE_FILE = sh(
                        returnStdout: true,
                        script: """#!/bin/bash
                            set -euxo pipefail
                            ./scripts/export-package.sh "$PACKAGE_CODE" "$PACKAGE_TYPE" "$PACKAGE_DESCRIPTION" "$INSTANCE_URL" | tail -1
                        """
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
            steps {
                script {
                    env.DHIS2_DOCKER_REPO = 'core'
                    env.DHIS2_HOME = '/DHIS2_home'

                    if (DHIS2_VERSION_IN_PACKAGE.length() <= 4 || DHIS2_VERSION_IN_PACKAGE.contains('SNAPSHOT')) {
                        echo "DHIS2 version is from dev channel."
                        env.DHIS2_DOCKER_REPO = 'core-dev'
                        DHIS2_VERSION_IN_PACKAGE = DHIS2_VERSION_IN_PACKAGE[0..3]
                        PUSH_PACKAGE = false
                    }

                    JIB_IMAGE_VERSIONS = ['2.39.0', '2.38.2', '2.37.9']

                    if (JIB_IMAGE_VERSIONS.any { DHIS2_VERSION_IN_PACKAGE.contains(it) } || DHIS2_DOCKER_REPO == 'core-dev') {
                        env.DHIS2_HOME = '/opt/dhis2'
                    }

                    withDockerRegistry([credentialsId: "docker-hub-credentials", url: ""]) {
                        dir('hack') {
                            dir('docker') {
                                sh 'curl "https://raw.githubusercontent.com/dhis2/dhis2-core/master/docker/dhis.conf" -O'
                            }

                            env.DHIS2_IMAGE = "dhis2/${DHIS2_DOCKER_REPO}:${DHIS2_VERSION_IN_PACKAGE}"

                            sh 'docker-compose up -d'

                            sleep(10) // Needed for safety, as the curl cmd below might fail with "Error (7): couldn't connect to host"

                            waitUntil {
                                response_code = sh(returnStdout: true, script: "curl -ksL -X GET -w %{http_code} -o /dev/null http://localhost:${DHIS2_PORT}")

                                return (response_code.toInteger() == 200)
                            }
                        }
                    }

                    sleep(5)

                    dir('test') {
                        sh "$WORKSPACE/scripts/run-import-tests.sh ./package_orig.json $DHIS2_PORT"
                    }
                }
            }

            post {
                always {
                    script {
                        dir('hack') {
                            sh 'docker-compose logs web > logs_empty_instance.txt'
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
                        sh "./scripts/check-dashboards.sh $DHIS2_PORT"
                    }
                }

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
                if (!env.DHIS2_VERSION_INPUT) {
                    DHIS2_VERSION_INPUT = "not provided"
                }

                if (!PACKAGE_EXPORT_SUCCEEDED.toBoolean()) {
                    message = "The $PACKAGE_CODE (package type: $PACKAGE_TYPE, DHIS2 version: $DHIS2_VERSION_INPUT) package export failed in ${slack.buildUrl()}"
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

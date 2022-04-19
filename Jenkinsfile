@Library('pipeline-library') _

pipeline {
    agent {
        label 'ec2-jdk8-large'
    }

    parameters {
        stashedFile 'package_metadata_file'
    }

    options {
        ansiColor('xterm')
    }

    environment {
        UTILS_GIT_URL = "https://github.com/dhis2/dhis2-utils"
        METADATA_CHECKERS_GIT_URL = "https://github.com/solid-lines/dhis2-metadata-checkers"
        DHIS2_BRANCH_VERSION = "master"
        PORT = 9090
        INPUT_FILE_NAME = "package_metadata_file"
        DHIS2_VERSION = "${params.DHIS2_version}"
        PACKAGE_NAME = "${params.Package_name}"
        PACKAGE_VERSION = "${params.Package_version}"
        PACKAGE_TYPE = "${params.Package_type}"
        DESCRIPTION = "${params.Description}"
        INSTANCE_URL = "${params.Instance_url}"
        PACKAGE_IS_EXPORTED = false
    }

    stages {
        stage('Export package') {
            when {
                expression {
                    echo "package_metadata_file: ${INPUT_FILE_NAME}"
                    echo "package_metadata_file: ${params.package_metadata_file}"
                    try {
                        // unless the file is unstashed, it's null.
                        unstash "${INPUT_FILE_NAME}"
                    } catch (e) {
                        echo e.toString()
                        return true;
                    }
                    // if file wasn't uploaded, its size will be 0
                    return (fileExists("${INPUT_FILE_NAME}")) && readFile("${INPUT_FILE_NAME}").size() == 0
                }
            }

            environment {
                USER_CREDENTIALS = credentials('packages-instance-credentials')
            }

            steps {
                script {
                    dir('dhis2-utils') {
                        git url: "$UTILS_GIT_URL"
                    }

                    PACKAGE_IS_EXPORTED = true

                    sh 'echo {\\"dhis\\": {\\"baseurl\\": \\"\\", \\"username\\": \\"${USER_CREDENTIALS_USR}\\", \\"password\\": \\"${USER_CREDENTIALS_PSW}\\"}} > auth.json'

                    sh "./scripts/export-package.sh \"$PACKAGE_NAME\" \"$PACKAGE_TYPE\""

                    EXPORTED_PACKAGE = sh(returnStdout: true, script: "ls -t *.json | head -n 1").trim()
                }
            }

            post {
                always {
                    script {
                        archiveArtifacts artifacts: "$EXPORTED_PACKAGE"
                    }
                }
            }
        }

        stage('Extract package info') {
            steps {
                script {
                    if (PACKAGE_IS_EXPORTED.toBoolean()) {
                        sh "cp $WORKSPACE/$EXPORTED_PACKAGE ./test/package_orig.json"
                    } else {
                        unstash "$INPUT_FILE_NAME"
                        sh "cp $INPUT_FILE_NAME ./test/package_orig.json"
                    }

                    DHIS2_BRANCH_VERSION = sh(returnStdout: true, script: "cat $EXPORTED_PACKAGE | jq -r \".package .DHIS2Version\"").trim()

                    currentBuild.description = sh(returnStdout: true, script: "cat $EXPORTED_PACKAGE | jq -r \".package .name\"").trim()
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

                    catchError {
                        sh("python3 -u dhis2-utils/tools/dhis2-metadata-package-validator/metadata_package_validator.py -f $WORKSPACE/$EXPORTED_PACKAGE")
                    }
                }
            }
        }

        stage('Test import in empty instance') {
            steps {
                script {
                    withDockerRegistry([credentialsId: "docker-hub-credentials", url: ""]) {
                        d2.startCluster("$DHIS2_BRANCH_VERSION", "$PORT")
                    }

                    sleep(5)

                    dir('test') {
                        sh "$WORKSPACE/scripts/run-import-tests.sh ./package_orig.json $PORT"
                    }
                }
            }

            post {
                always {
                    script {
                        sh "d2 cluster compose $DHIS2_BRANCH_VERSION logs core > logs_empty_instance.txt"
                        archiveArtifacts artifacts: "logs_empty_instance.txt"
                    }
                }
            }
        }

        stage('Run checks') {
            parallel {
                stage('Check dashboards') {
                    steps {
                        sh "./scripts/check-dashboards.sh $PORT"
                    }
                }

                stage('Check PR expressions') {
                    steps {
                        dir('dhis2-metadata-checkers') {
                            git branch: 'main', url: "$METADATA_CHECKERS_GIT_URL"
                        }

                        sh "./scripts/check-expressions.sh $PORT"
                    }
                }
            }
        }

        stage('Push to GitHub') {
            when {
                expression { params.Push_package }
            }

            environment {
                GITHUB_CREDS = credentials('github-token-as-password')
                GITHUB_EMAIL = 'apps@dhis2.org'
            }

            steps {
                script {
                    sh "./scripts/push-package.sh $EXPORTED_PACKAGE"
                }
            }
        }
    }

    post {
        failure {
            script {
                IMPLEMENTERS = [
                    RMS000: 'U01RSD1LPB3'
                ]

                slackSend(
                    color: "#ff0000",
                    channel: "@${IMPLEMENTERS.get(PACKAGE_NAME[-6..-1])}",
                    message: "The $EXPORTED_PACKAGE package is failing validation/checks in <${BUILD_URL}|${JOB_NAME} (#${BUILD_NUMBER})>"
                )
            }
        }
    }
}

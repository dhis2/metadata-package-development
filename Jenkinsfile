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
        PACKAGE_FILE = "package_metadata_file"
        DHIS2_VERSION = "${params.DHIS2_version}"
        CHANNEL = "stable"
        PACKAGE_NAME = "${params.Package_name}"
        PACKAGE_VERSION = "${params.Package_version}"
        PACKAGE_TYPE = "${params.Package_type}"
        DESCRIPTION = "${params.Custom_description}"
        INSTANCE_URL = "${params.Instance_url}"
        PACKAGE_IS_EXPORTED = false
    }

    stages {
        stage('Export package') {
            when {
                expression {
                    try {
                        // unless the file is unstashed, it's null.
                        unstash "${PACKAGE_FILE}"
                    } catch (e) {
                        echo e.toString()
                        return true;
                    }
                    // if file wasn't uploaded, its size will be 0
                    return (fileExists("${PACKAGE_FILE}")) && readFile("${PACKAGE_FILE}").size() == 0
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

                    PACKAGE_FILE = sh(returnStdout: true, script: "ls -t *.json | head -n 1").trim()
                }
            }

            post {
                always {
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

                    DHIS2_BRANCH_VERSION = sh(returnStdout: true, script: "cat $PACKAGE_FILE | jq -r \".package .DHIS2Version\"").trim()

                    currentBuild.description = sh(returnStdout: true, script: "cat $PACKAGE_FILE | jq -r \".package .name\"").trim()
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
                        sh("python3 -u dhis2-utils/tools/dhis2-metadata-package-validator/metadata_package_validator.py -f $WORKSPACE/$PACKAGE_FILE")
                    }
                }
            }
        }

        stage('Test import in empty instance') {
            steps {
                script {
                    if (DHIS2_BRANCH_VERSION.length() <= 4) {
                        echo "DHIS2 version is from dev channel."
                        CHANNEL = "dev"
                    }

                    withDockerRegistry([credentialsId: "docker-hub-credentials", url: ""]) {
                        d2.startCluster("$DHIS2_BRANCH_VERSION", "$PORT", "$CHANNEL")
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
                    sh "./scripts/push-package.sh $PACKAGE_FILE"
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
                    channel: "@${IMPLEMENTERS.get(PACKAGE_NAME[0..5])}",
                    message: "The $PACKAGE_FILE package is failing validation/checks in <${BUILD_URL}|${JOB_NAME} (#${BUILD_NUMBER})>"
                )
            }
        }
    }
}

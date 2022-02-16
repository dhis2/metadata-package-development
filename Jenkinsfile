@Library('pipeline-library@DEVOPS-125') _

pipeline {
    agent {
        label 'ec2-jdk8'
    }

    parameters {
        stashedFile 'package_metadata_file'
    }

    options {
        ansiColor('xterm')
        // This is required if you want to clean before build
        skipDefaultCheckout(true)
    }

    environment {
        UTILS_GIT_URL = "https://github.com/dhis2/dhis2-utils"
        METADATA_DEV_GIT_URL = "https://github.com/dhis2/metadata-package-development"
        METADATA_CHECKERS_GIT_URL = "https://github.com/solid-lines/dhis2-metadata-checkers"
        DHIS2_BRANCH_VERSION = "master"
        OUS_METADATA = "test/ous_metadata.json"
        TEST_METADATA = "test_metadata.json"
        PORT = 9090
        INPUT_FILE_NAME = "package_metadata_file"
        DHIS2_VERSION = "${params.DHIS2_version}"
        PACKAGE_NAME = "${params.Package_name}"
        PACKAGE_VERSION = "${params.Package_version}"
        PACKAGE_TYPE = "${params.Package_type}"
        DESCRIPTION = "${params.Description}"
        PACKAGE_IS_GENERATED = false
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

                    PACKAGE_IS_GENERATED = true

                    sh 'pip3 install -r dhis2-utils/tools/dhis2-package-exporter/requirements.txt'
                    sh 'echo { \\"dhis\\": { \\"baseurl\\": \\"\\", \\"username\\": \\"${USER_CREDENTIALS_USR}\\", \\"password\\": \\"${USER_CREDENTIALS_PSW}\\" } } > auth.json'


                    EXPORTED_PACKAGE = metadataPackage.export("$PACKAGE_NAME", "$PACKAGE_TYPE")

                    DHIS2_BRANCH_VERSION = metadataPackage.getInfo("$WORKSPACE/$EXPORTED_PACKAGE")
                }
            }

            post {
                always {
                    script {
                        // TODO: is that needed with pushing to GitHub?
                        archiveArtifacts artifacts: "$EXPORTED_PACKAGE"
                    }
                }
            }
        }

        stage('Validate metadata') {
            steps {
                script {
                    //This call is done also here just in case the previous stage is skipped
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

                    dir('metadata-dev') {
                        git branch: "DEVOPS-104", url: "$METADATA_DEV_GIT_URL"

                        dir('test') {
                            metadataPackage.runImportTests("$WORKSPACE/$EXPORTED_PACKAGE", "$PORT")
                        }
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

//         stage('Run checks') {
//             parallel {
//                 stage('Check dashboards') {
//                     steps {
//                         dir('dhis2-utils/tools/dhis2-dashboardchecker') {
//                             script {
//                                 metadataPackage.checkDashboards("$PORT")
//                             }
//                         }
//                     }
//                 }
//
//                 stage('Check PR expressions') {
//                     steps {
//                         dir('metadata-checkers') {
//                             git branch: 'main', url: "$METADATA_CHECKERS_GIT_URL"
//
//                             script {
//                                 metadataPackage.checkExpressions("$PORT")
//                             }
//                         }
//                     }
//                 }
//             }
//         }

        stage('Push to GitHub') {
            when {
                expression { params.Push_package }
            }

            environment {
                GITHUB_CREDS = credentials('github-token-as-password')
                GITHUB_EMAIL = 'apps@dhis2.org'
                PACKAGE_FILE = "$EXPORTED_PACKAGE"
            }

            steps {
                script {
                    // the prefix is the last 6 characters of the package name parameter
                    PACKAGE_PREFIX = PACKAGE_NAME[-6..-1]
                    sh "$WORKSPACE/metadata-dev/scripts/push-package.sh $PACKAGE_PREFIX $DHIS2_VERSION"
                }
            }
        }

        //stage('Remove d2 cache again') {
        //    steps {
        //        sh 'sudo -S rm -rf /ebs1/home/jenkins/.cache/d2'
        //    }
        //}

        //stage("Test SL instance") {
        //    steps {
        //        script {
        //            if ("${DHIS2_BRANCH_VERSION}".contains('-')) {
        //                CLEAN_DHIS2_VERSION = DHIS2_BRANCH_VERSION.replaceAll("[^0-9.]", "")
        //                echo "CLEAN_DHIS2_VERSION: ${CLEAN_DHIS2_VERSION}"
        //                SEED_FILE = "https://databases.dhis2.org/sierra-leone/"+CLEAN_DHIS2_VERSION+"/dhis2-db-sierra-leone.sql.gz"
        //                echo "SEED_FILE: ${SEED_FILE}"
        //                sh "wget ${SEED_FILE}"
        //                d2.startClusterAndSeedWithFile( "${DHIS2_BRANCH_VERSION}", "$PORT", "$CHANNEL", "dhis2-db-sierra-leone.sql.gz")
        //            }
        //            else {
        //                d2.startClusterAndSeed( "${DHIS2_BRANCH_VERSION}", "$PORT", "$CHANNEL")
        //            }
        //
        //            dir('test') {
        //                sh "cat package_orig.json | sed 's/<OU_LEVEL_DISTRICT_UID>/wjP19dkFeIk/g' | sed 's/<OU_ROOT_UID>/ImspTQPwCqd/g'| sed 's/NI0QRzJvQ0k/iESIqZ0R0R0/g' | sed 's/sB1IHYu2xQT/TfdH5KvFmMy/g' | sed 's/fctSQp5nAYl/Agywv2JGwuq/g' | sed 's/oindugucx72/CklPZdOd6H1/g' | sed 's/WDUwjiW2rGH/hiQ3QFheQ3O/g' | sed 's/MCPQUTHX1Ze/nEenWmSyUEp/g' | sed 's/FKKrOBBFgs1/AZK4rjJCss5/g' | sed 's/Ii4IxCLWEFn/UrUdMteQzlT/g' | sed 's/Fm6cUmmiY3d/qrur9Dvnyt5/g' | sed 's/UoL9vGPT0qF/u3TE34T4KH0/g' | sed 's/HAZ7VQ730yn/flGbXLXCrEo/g' | sed 's/phxAY4PQdsT/KrCahWFMYYz/g' | sed 's/ap4DkRRjUWi/oBWhZmavxQY/g'  | sed 's/I4tpTPGwr5V/dEFhuheLj1A/g'  | sed 's/hEhl7FOtnR7/HrKHCQUSYZh/g' | sed 's/BiTsLcJQ95V/iESIqZ0R0R0/g' | sed 's/ciCR6BBvIT4/Agywv2JGwuq/g' > package.json"
        //                sh "URL=http://localhost:${PORT} AUTH=system:System123 ./run-tests.sh"
        //            }
        //        }
        //    }
        //
        //    post {
        //        always {
        //            script {
        //                sh(
        //                    returnStdout: false,
        //                    script: "d2 cluster compose $DHIS2_BRANCH_VERSION logs core > logs_sl.txt"
        //                )
        //                archiveArtifacts artifacts: "logs_sl.txt"
        //                d2.stopCluster("${DHIS2_BRANCH_VERSION}")
        //            }
        //        }
        //    }
        //}
    }

    post {
        always {
            script {
                IMPLEMENTERS = [
                    RMS000: 'U01RSD1LPB3'
                ]

                slackSend(
                    color: "#ff0000",
                    channel: "@${IMPLEMENTERS.get(PACKAGE_PREFIX)}",
                    message: "The $PACKAGE_PREFIX package is failing validation/checks in <${BUILD_URL}|${JOB_NAME} (#${BUILD_NUMBER})>"
                )
            }
        }
    }

    //post {
    //    always {
    //        script {
    //            echo "POST_ALWAYS"
    //            def logContent = Jenkins.getInstance().getItemByFullName(env.JOB_NAME).getBuildByNumber(Integer.parseInt(env.BUILD_NUMBER)).logFile.text
    //            // copy the log in the job's own workspace
    //            writeFile file: "buildlog.txt", text: logContent
    //            archiveArtifacts artifacts: "buildlog.txt"
    //
    //            def logList = Jenkins.getInstance().getItemByFullName(env.JOB_NAME).getBuildByNumber(Integer.parseInt(env.BUILD_NUMBER)).logFile.readLines()
    //            def errorList = logList.findAll {it.contains("ERROR") || it.contains("WARNING")}
    //
    //            writeFile file: "error_log.txt", text: errorList.join("\n")
    //            archiveArtifacts artifacts: "error_log.txt"
    //        }
    //    }
    //}
}

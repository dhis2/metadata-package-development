@Library('pipeline-library') _
pipeline {
    agent {
        label 'ec2-jdk8'
    }
    parameters {
        stashedFile 'package_metadata_file'
    }
    options {
        ansiColor('xterm')
        disableConcurrentBuilds()
        // This is required if you want to clean before build
        skipDefaultCheckout(true)
    }
    //tools {
    //    nodejs "node"
    //}
    environment {
        GIT_URL = "https://github.com/dhis2/metadata-package-development"
        DHIS2_BRANCH_VERSION = "master"
        OUS_METADATA = "test/ous_metadata.json"
        TEST_METADATA = "test_metadata.json"
        CHANNEL = ""
        PORT = ""
        INPUT_FILE_NAME = "package_metadata_file"
        DHIS2_VERSION = "${params.DHIS2_version}"
        PACKAGE_NAME = "${params.Package_name}"
        PACKAGE_VERSION = "${params.Package_version}"
        PACKAGE_TYPE = "${params.Package_type}"
        DESCRIPTION = "${params.Description}"
        PACKAGE_IS_GENERATED = false
    }
    stages {
      stage('Generate package') {
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
                    git url: 'https://github.com/dhis2/dhis2-utils.git'
                }

                PACKAGE_IS_GENERATED = true

                components = "${PACKAGE_NAME}".split(' - ')
                HEALTH_AREA = components[0]
                INTERVENTION = components[1]
                if(params.Description == "") {
                   DESCRIPTION = components[2]
                }
                PACKAGE_PREFIX = components[3]

                echo "TYPE: ${PACKAGE_TYPE}"
                echo "HEALTH_AREA: ${HEALTH_AREA}"
                echo "INTERVENTION: ${INTERVENTION}"
                echo "PACKAGE_PREFIX: ${PACKAGE_PREFIX}"
                //echo "PROGRAM_OR_DATASET_UID: ${PROGRAM_OR_DATASET_UID}"
                echo "DESCRIPTION: ${DESCRIPTION}"

                if (PACKAGE_TYPE.equals("TKR") || PACKAGE_TYPE.equals("EVT")){
                    switch(params.DHIS2_version) {
                        //case "2.33": INSTANCE="https://metadata.dev.dhis2.org/old_tracker_dev"; break;
                        //case "2.34": INSTANCE="https://metadata.dev.dhis2.org/tracker_dev"; break;
                        case "2.35": INSTANCE="https://metadata.dev.dhis2.org/tracker_dev"; break;
                        case "2.36": INSTANCE="https://who-dev.dhis2.org/tracker_dev236"; break;
                        case "2.37": INSTANCE="https://who-dev.dhis2.org/tracker_dev237"; break;
                    }
                } else { // AGG or DHS
                    switch(params.DHIS2_version) {
                        //case "2.33": INSTANCE="https://metadata.dev.dhis2.org/dev"; break;
                        //case "2.34": INSTANCE="https://who-dev.dhis2.org/dev234"; break;
                        case "2.35": INSTANCE="https://metadata.dev.dhis2.org/dev"; break;
                        case "2.36": INSTANCE="https://who-dev.dhis2.org/dev236"; break;
                        case "2.37": INSTANCE="https://who-dev.dhis2.org/dev237"; break;
                    }
                }
                sh 'pip3 install -r dhis2-utils/tools/dhis2-package-exporter/requirements.txt'
                sh 'echo { \\"dhis\\": { \\"baseurl\\": \\"\\", \\"username\\": \\"${USER_CREDENTIALS_USR}\\", \\"password\\": \\"${USER_CREDENTIALS_PSW}\\" } } > auth.json'
                echo "Generating a package..."
                sh("python3 -u dhis2-utils/tools/dhis2-package-exporter/package_exporter.py ${PACKAGE_TYPE} ${HEALTH_AREA} ${INTERVENTION} -v=${PACKAGE_VERSION} -desc=\"${DESCRIPTION}\" -i=${INSTANCE} -pf=${PACKAGE_PREFIX}")
                sh 'pwd'
                sh 'ls -la'
                INPUT_FILE_NAME = sh(
                    returnStdout: true,
                    script: "ls -t1 ${HEALTH_AREA}*${INTERVENTION}*${DHIS2_version}*.json | head -n 1"
                ).trim()

                echo "Generated file: ${INPUT_FILE_NAME}"
            }
        }
        post {
          always {
              script {
                  archiveArtifacts artifacts: "${INPUT_FILE_NAME}"
              }
          }
        }
      }
      stage("Extract package info") {
        steps {
          dir('metadata-dev') {
            git url: 'https://github.com/dhis2/metadata-package-development'
            //unarchive mapping: ["${INPUT_FILE_NAME}": "${INPUT_FILE_NAME}"]

            script {
              if (PACKAGE_IS_GENERATED.toBoolean()) {
                sh "cp $WORKSPACE/$INPUT_FILE_NAME ./test/package_orig.json"
              } else {
                unstash "$INPUT_FILE_NAME"
                sh "cp $INPUT_FILE_NAME ./test/package_orig.json"
              }
              //if (readFile("${INPUT_FILE_NAME}").size() == 0) {
              //    error("Build failed because package file is empty")
              //}

//               sh "cp ${INPUT_FILE_NAME} ./test/package_orig.json"

              // example of expected value: VE_TRACKER_V1.0.0_DHIS2.33.8-en
              PACKAGE_VERSION = sh(
                  returnStdout: true,
                  script: "cat $WORKSPACE/$INPUT_FILE_NAME | awk ' BEGIN { package_found = 0; } { if(package_found == 1 && index(\$1, \"name\") != 0) { gsub(/[\",]/,\"\"); print \$2; exit(0); }  if(index(\$1, \"package\") != 0) { package_found = 1; } }'"
              ).trim()

              // example of expected value: 2.33.8
              DHIS2_BRANCH_VERSION = sh(
                  returnStdout: true,
                  script: "grep DHIS2Version $WORKSPACE/$INPUT_FILE_NAME | awk -F '\"' '{print \$4;}' ").trim().toLowerCase()

              echo "Package version: ${PACKAGE_VERSION}"
              currentBuild.description = "${PACKAGE_VERSION}"
              echo "DHIS2 version: ${DHIS2_BRANCH_VERSION}"

              def length = sh(
                  returnStdout: true,
                  script: "echo -n ${DHIS2_BRANCH_VERSION} | wc -c "
              ).trim()


              if ("${length}".toInteger() > 4) {
                  echo "DHIS2 version is a patch version."
                  CHANNEL = ""
              }
            }
          }
        }
      }

      stage('Metadata validation') {
        steps {
            //This call is done also here just in case the previous stage is skipped
            dir('dhis2-utils') {
                git url: 'https://github.com/dhis2/dhis2-utils.git'
            }
            sh("python3 -u dhis2-utils/tools/dhis2-metadata-package-validator/metadata_package_validator.py -f $WORKSPACE/$INPUT_FILE_NAME")
        }
      }
      stage("Test empty instance") {
        steps {
          script {
              //PORT = "${findFreePort()}"
              PORT = 9090
              withDockerRegistry([credentialsId: "docker-hub-credentials", url: ""]) {
                  d2.startCluster( "${DHIS2_BRANCH_VERSION}", "$PORT", "$CHANNEL")
              }
              sleep(10)
              dir("$WORKSPACE/metadata-dev/test") {
                  sh "cat package_orig.json | sed 's/<OU_LEVEL_DISTRICT_UID>/qpXLDdXT3po/g' | sed 's/<OU_LEVEL_FACILITY_UID>/vFr4zVw6Avn/g' | sed 's/<OU_ROOT_UID>/GD7TowwI46c/g' > package.json"
                  sh "./api-test.sh -f tests.json -url http://localhost:${PORT} -auth admin:district test ou_import "
                  sh "URL=http://localhost:${PORT} AUTH=admin:district ./run-tests.sh"
              }
            }
        }

        post {
          always {
            script {
                sh(
                  returnStdout: false,
                  script: "d2 cluster compose $DHIS2_BRANCH_VERSION logs core > logs_empty.txt"
                )
                archiveArtifacts artifacts: "logs_empty.txt"
//                 d2.stopCluster("${DHIS2_BRANCH_VERSION}")
            }
          }
        }
      }
      /*
      stage('Remove d2 cache again') {
        steps {
            sh 'sudo -S rm -rf /ebs1/home/jenkins/.cache/d2'
        }
      }
      stage("Test SL instance") {
        steps {
          script {
              if ("${DHIS2_BRANCH_VERSION}".contains('-')) {
                CLEAN_DHIS2_VERSION = DHIS2_BRANCH_VERSION.replaceAll("[^0-9.]", "")
                echo "CLEAN_DHIS2_VERSION: ${CLEAN_DHIS2_VERSION}"
                SEED_FILE = "https://databases.dhis2.org/sierra-leone/"+CLEAN_DHIS2_VERSION+"/dhis2-db-sierra-leone.sql.gz"
                echo "SEED_FILE: ${SEED_FILE}"
                sh "wget ${SEED_FILE}"
                d2.startClusterAndSeedWithFile( "${DHIS2_BRANCH_VERSION}", "$PORT", "$CHANNEL", "dhis2-db-sierra-leone.sql.gz")
              } else {
                d2.startClusterAndSeed( "${DHIS2_BRANCH_VERSION}", "$PORT", "$CHANNEL")
              }
              dir('test') {
                sh "cat package_orig.json | sed 's/<OU_LEVEL_DISTRICT_UID>/wjP19dkFeIk/g' | sed 's/<OU_ROOT_UID>/ImspTQPwCqd/g'| sed 's/NI0QRzJvQ0k/iESIqZ0R0R0/g' | sed 's/sB1IHYu2xQT/TfdH5KvFmMy/g' | sed 's/fctSQp5nAYl/Agywv2JGwuq/g' | sed 's/oindugucx72/CklPZdOd6H1/g' | sed 's/WDUwjiW2rGH/hiQ3QFheQ3O/g' | sed 's/MCPQUTHX1Ze/nEenWmSyUEp/g' | sed 's/FKKrOBBFgs1/AZK4rjJCss5/g' | sed 's/Ii4IxCLWEFn/UrUdMteQzlT/g' | sed 's/Fm6cUmmiY3d/qrur9Dvnyt5/g' | sed 's/UoL9vGPT0qF/u3TE34T4KH0/g' | sed 's/HAZ7VQ730yn/flGbXLXCrEo/g' | sed 's/phxAY4PQdsT/KrCahWFMYYz/g' | sed 's/ap4DkRRjUWi/oBWhZmavxQY/g'  | sed 's/I4tpTPGwr5V/dEFhuheLj1A/g'  | sed 's/hEhl7FOtnR7/HrKHCQUSYZh/g' | sed 's/BiTsLcJQ95V/iESIqZ0R0R0/g' | sed 's/ciCR6BBvIT4/Agywv2JGwuq/g' > package.json"
                sh "URL=http://localhost:${PORT} AUTH=system:System123 ./run-tests.sh"
              }
          }
        }
        post {
          always {
              script {
                  sh(
                    returnStdout: false,
                    script: "d2 cluster compose $DHIS2_BRANCH_VERSION logs core > logs_sl.txt"
                  )
                  archiveArtifacts artifacts: "logs_sl.txt"
                  d2.stopCluster("${DHIS2_BRANCH_VERSION}")
              }
          }
        }
      }// stage
      */
   } // stages
    /*
    post {
      always {
        script {
          echo "POST_ALWAYS"
          def logContent = Jenkins.getInstance().getItemByFullName(env.JOB_NAME).getBuildByNumber(Integer.parseInt(env.BUILD_NUMBER)).logFile.text
          // copy the log in the job's own workspace
          writeFile file: "buildlog.txt", text: logContent
          archiveArtifacts artifacts: "buildlog.txt"

          def logList = Jenkins.getInstance().getItemByFullName(env.JOB_NAME).getBuildByNumber(Integer.parseInt(env.BUILD_NUMBER)).logFile.readLines()
          def errorList = logList.findAll {it.contains("ERROR") || it.contains("WARNING")}

          writeFile file: "error_log.txt", text: errorList.join("\n")
          archiveArtifacts artifacts: "error_log.txt"
        } // script
      } // always
    } // post
    */
}

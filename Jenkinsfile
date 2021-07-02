@Library('pipeline-library') _
pipeline {
    agent any
    parameters {
        stashedFile 'package_metadata_file'
    }
    options {
        ansiColor('xterm')
        disableConcurrentBuilds()
    }
    tools {
        nodejs "node"
    }
    environment {
        GIT_URL = "https://github.com/dhis2/metadata-package-development"
        DHIS2_VERSION = "master"
        OUS_METADATA = "test/ous_metadata.json"
        TEST_METADATA = "test_metadata.json"
        CHANNEL = "dev"
        PORT = ""
        INPUT_FILE_NAME = "package_metadata_file"
    }
    stages {
      stage("Extract package info") {
        steps {
          git url: "${GIT_URL}"

          script {
            unstash "${INPUT_FILE_NAME}"
            if (!fileExists("${INPUT_FILE_NAME}")) {
                error("Build failed because package file is empty")
            }

            sh "cp $INPUT_FILE_NAME ./test/package_orig.json"
            
            withFileParameter("${INPUT_FILE_NAME}") {
                // example of expected value: VE_TRACKER_V1.0.0_DHIS2.33.8-en
                PACKAGE_VERSION = sh(
                    returnStdout: true,
                    script: "cat ${INPUT_FILE_NAME} | awk ' BEGIN { package_found = 0; } { if(package_found == 1 && index(\$1, \"name\") != 0) { gsub(/[\",]/,\"\"); print \$2; exit(0); }  if(index(\$1, \"package\") != 0) { package_found = 1; } }'"
                ).trim()

                // example of expected value: 2.33.8
                DHIS2_VERSION = sh(
                    returnStdout: true,
                    script: "grep DHIS2Version ${INPUT_FILE_NAME} | awk -F '\"' '{print \$4;}' ").trim()

                echo "Package version: ${PACKAGE_VERSION}"
                currentBuild.description = "${PACKAGE_VERSION}"
                echo "DHIS2 version: ${DHIS2_VERSION}"
               
            }
            
            def length = sh(
                returnStdout: true,
                script: "echo -n ${DHIS2_VERSION} | wc -c "
            ).trim()
                
             
            if ( "${length}" > 4) {
                echo "it's a patch"
                CHANNEL = ""
            }
          }
        }
      }

      stage('metadata validation') {
        steps {
            dir('dhis2-utils') {
                git url: 'https://github.com/dhis2/dhis2-utils.git'
            }

            sh('python3 -u dhis2-utils/tools/dhis2-metadata-package-validator/metadata_package_validator.py -f ${INPUT_FILE_NAME}')
        }
      }
        
      stage("Test empty instance") {
        steps {
          script {
              PORT = "${findFreePort()}"
              d2.startCluster( "${DHIS2_VERSION}", "$PORT", "$CHANNEL")
              // Tomcat is ready before the dhis2 user is created. That's the reason behind this sleep.
              sleep(10)
              dir('test') {
                  sh "cat package_orig.json | sed 's/<OU_LEVEL_DISTRICT_UID>/qpXLDdXT3po/g' | sed 's/<OU_ROOT_UID>/GD7TowwI46c/g' > package.json"
                  sh "./api-test.sh -f tests.json -url http://localhost:${PORT} -auth admin:district test ou_import "
                  //sh(
                  //    returnStdout: true, 
                  //    script: "curl -iv -u admin:district -H \"Content-Type: application/json\" -H \"Expect:\" --data @ous_metadata.json http://localhost:${PORT}/api/metadata?mergeMode=REPLACE&strategy=CREATE_AND_UPDATE"
                  //)

                  //def response = ["curl", "-iv", "--trace-ascii", "--http1.1", "-u", "admin:district", "-k", "-X", "POST", "-H", "Content-Type: application/json", "--data", "@ous_metadata.json", "http://localhost:${PORT}/api/metadata?mergeMode=REPLACE&strategy=CREATE_AND_UPDATE"].execute()
                  //echo "${response}"
                  sh "URL=http://localhost:${PORT} AUTH=admin:district ./run-tests.sh"
              }
          }
        }

        post {
          always {
            script {
                sh(
                  returnStdout: false,
                  script: "d2 cluster compose $DHIS2_VERSION logs core > logs_empty.txt"
                )
                archiveArtifacts artifacts: "logs_empty.txt"
                d2.stopCluster("${DHIS2_VERSION}")
            }
          }
        }
      }

      stage("Test SL instance") {
        steps {
          script {
              d2.startClusterAndSeed( "${DHIS2_VERSION}", "$PORT", "$CHANNEL")
              dir('test') {
                sh "cat package_orig.json | sed 's/<OU_LEVEL_DISTRICT_UID>/wjP19dkFeIk/g' | sed 's/<OU_ROOT_UID>/ImspTQPwCqd/g'| sed 's/NI0QRzJvQ0k/iESIqZ0R0R0/g' | sed 's/sB1IHYu2xQT/TfdH5KvFmMy/g' | sed 's/fctSQp5nAYl/Agywv2JGwuq/g' | sed 's/oindugucx72/CklPZdOd6H1/g' | sed 's/WDUwjiW2rGH/hiQ3QFheQ3O/g' | sed 's/MCPQUTHX1Ze/nEenWmSyUEp/g' | sed 's/FKKrOBBFgs1/AZK4rjJCss5/g' | sed 's/Ii4IxCLWEFn/UrUdMteQzlT/g' > package.json"
                sh "URL=http://localhost:${PORT} AUTH=system:System123 ./run-tests.sh"
              }
          }
        }
        post {
          always {
              script {
                  sh(
                    returnStdout: false,
                    script: "d2 cluster compose $DHIS2_VERSION logs core > logs_sl.txt"
                  )
                  archiveArtifacts artifacts: "logs_sl.txt"
                  d2.stopCluster("${DHIS2_VERSION}")
              }
          }
        }
      }
  }
    post {
        always {
            // Clean the workspace
            cleanWs()
        }
    }
}

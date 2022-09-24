@Library('slack') _

pipeline {
  agent any

//environment variables definition

  environment {
    deploymentName = "devsecops"
    containerName = "devsecops-container"
    serviceName = "devsecops-svc"
    imageName = "jakubmajer/numeric-app:${GIT_COMMIT}"
    applicationURL = "http://devsecops.francecentral.cloudapp.azure.com"
    applicationURI = "/increment/99"
  }

  stages {
      //building application
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' //so that they can be downloaded later
            }
        }   
      //unit tests
      stage('Unit test') {
            steps {
              sh "mvn test"
            }
        }
      //mutation tests
      stage('Mutation Tests PIT') {
        steps {
          sh "mvn org.pitest:pitest-maven:mutationCoverage"
        }
      }
      //sonarqube static analysis
      stage('Sonarqube Static Code Analysis') {
        steps {
          withSonarQubeEnv('SonarQube') {
          withCredentials([string(credentialsId: 'sq', variable: 'SQKEY'), string(credentialsId: 'SQPROJECT', variable: 'SQPROJECT'), string(credentialsId: 'SQHOST', variable: 'SQHOST')]) {
              sh "printenv"
              sh "mvn clean verify sonar:sonar \
                -Dsonar.projectKey=$SQPROJECT \
                -Dsonar.host.url=$SQHOST \
                -Dsonar.login=$SQKEY"
        }
        }
        timeout(time: 2, unit: 'MINUTES') {
          script {
            waitForQualityGate abortPipeline: true
          }
        }
      }   
      }
      //maven dependency scan, trivy base image scan, docker OPA conftest
      stage('Vulnerability Scan - Docker') {
        steps {
          parallel (
            "Dependency Scan": {
              sh "mvn dependency-check:check"
            },
            "Aquasec Trivy Scan": {
              sh "bash trivy-scan.sh"
            },
            "OPA Conftest": {
              sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-docker-security.rego Dockerfile'
            }
          )
        }
      }
      //docker build and image push
      stage('Docker Build and Push') {
        steps {
          withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
            sh 'printenv'
            sh 'docker build -t jakubmajer/numeric-app:""$GIT_COMMIT""  .'
            sh 'docker push jakubmajer/numeric-app:""$GIT_COMMIT""'
          }
        }
      }
      //trivy scan - application image
      stage('Aquasec Trivy scan - application docker image') {
        steps {
          sh "bash trivy-k8s-scan.sh"
        }
      }
      //yaml deployment scan with conftest OPA and kubesec
      stage("k8s files security scans") {
        steps {
          parallel(
            "OPA Scan": {
              sh "sed -i 's|{{image}}|jakubmajer/numeric-app:${GIT_COMMIT}|g' k8s_deployment_service.yaml"
              sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-k8s-security.rego k8s_deployment_service.yaml'
            },
            "Kubesec Scan": {
              sh "bash kubesec-scan.sh"
            }
          )
        }
      }
      //deployment to k8s cluster
      stage('Kubernetes deployment dev') {
        steps {
          withKubeConfig([credentialsId: 'kubeconfig']) {
            sh "bash k8s-deployment.sh"
          }
        }
      }
      //script to check if deployment was succesfull
      stage('k8s deployment check') {
        steps {
          withKubeConfig([credentialsId: 'kubeconfig']) {
            sh "bash k8s-deployment-rollout-status.sh"
          }
        }
      }
      //OWASP ZAP - DAST Test
      stage('OWASP ZAP DAST Test') {
        steps {
          withKubeConfig([credentialsId: 'kubeconfig']) {
            sh "bash zap.sh"
          }
        }
      }
      //doesn't work for now
      // stage('Aquasec kubench test') {
      //   steps {
      //     sh "bash kube-bench"
      //   }
      // }

      stage('Approve prod deployment') {
        steps {
          timeout(time: 2, unit: 'DAYS') {
            input 'Approve prod deployment'
          }
        }
      }

     //deployment to k8s cluster prod namespace
      stage('Kubernetes deployment prod') {
        steps {
          withKubeConfig([credentialsId: 'kubeconfig']) {
            sh "bash k8s-deployment-prod.sh"
          }
        }
      }

    }
      post {
        always {
              sendNotification currentBuild.result
              publishHTML([allowMissing: false, alwaysLinkToLastBuild: true, keepAll: true, reportDir: 'owasp-zap-report', reportFiles: 'zap_report.html', reportName: 'OWASP ZAP HTML Report', reportTitles: 'OWASP ZAP HTML Report', useWrapperFileDirectly: true])
              junit 'target/surefire-reports/*.xml'
              jacoco execPattern: 'target/jacoco.exec'
              pitmutation mutationStatsFile: 'target/pit-reports/**/mutations.xml'
              dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
        }
      }
}

pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' //so that they can be downloaded later
            }
        }   
      stage('Unit test') {
            steps {
              sh "mvn test"
            }
        }
      stage('Mutation Tests PIT') {
        steps {
          sh "mvn org.pitest:pitest-maven:mutationCoverage"
        }
      }
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

      stage('Vulnerability Scan - Docker') {
        steps {
          parallel {
            "Dependency Scan": {
              sh "mvn dependency-check:check"
            },
            "Trivy Scan": {
              sh "bash trivy-scan.sh"
            }
          }
        }
      }

      stage('Docker Build and Push') {
        steps {
          withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
            sh 'printenv'
            sh 'docker build -t jakubmajer/numeric-app:""$GIT_COMMIT""  .'
            sh 'docker push jakubmajer/numeric-app:""$GIT_COMMIT""'
          }
        }
      }
      stage('Kubernetes deployment dev') {
        steps {
          withKubeConfig([credentialsId: 'kubeconfig']) {
            sh "sed -i 's|{{image}}|jakubmajer/numeric-app:${GIT_COMMIT}|g' k8s_deployment_service.yaml"
            sh "kubectl apply -f k8s_deployment_service.yaml"
          }
        }
      }
    }
      post {
        always {
              junit 'target/surefire-reports/*.xml'
              jacoco execPattern: 'target/jacoco.exec'
              pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
              dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
        }
      }
}

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
         post {
           always {
              junit 'target/surefire-reports/*.xml'
              jacoco execPattern: 'target/jacoco.exec'
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
            sh "sed -i 's/{{image}}/jakubmajer/numeric-app:${GIT_COMMIT}/g' k8s_deployment_service.yaml"
            sh "kubectl apply -f k8s_deployment_service.yaml"
          }
        }
      }
    }
}

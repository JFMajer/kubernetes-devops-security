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
          docker.withRegistry([credentialsId: "docker-hub", url: ""]) {
            sh 'printenv'
            sh 'docker build -t jakubmajer/numeric-app:""$GIT_COMMIT""  .'
            sh 'docker push jakubmajer/numeric-app:""$GIT_COMMIT""'
          }
        }
      }
    }
}

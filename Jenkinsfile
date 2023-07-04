pipeline {
    agent any
    stages {
        stage('Checkout') {
          steps {
            checkout scm
          }
        }
        stage('Environment') {
          steps {
              sh 'git --version'
              echo "Branch: ${env.BRANCH_NAME}"
              sh 'docker -v'
              sh 'printenv'
          }
        }
        stage('Lint code') {
            steps {
                sh 'docker build -t react-lint -f lint.Dockerfile --no-cache .'
            }
        }
        stage('Docker lint'){
          steps {
            sh 'docker run --rm react-lint'
          }
        }
        stage('Clean Docker lint'){
          steps {
            sh 'docker rmi -f react-lint'
          }
        }
        stage('Build Docker test'){
           steps {
              sh 'docker build -t react-test -f test.Dockerfile --no-cache .'
           }
        }
        stage('Docker test'){
          steps {
            sh 'docker run --rm react-test'
          }
        }
        stage('Clean Docker test'){
          steps {
            sh 'docker rmi -f react-test'
          }
        }
        stage('Deploy'){
          steps {
            sh 'docker build -t react-app build.Dockerfile --no-cache .'
            sh 'docker tag react-app localhost:5000/react-app'
            sh 'docker push localhost:5000/react-app'
            sh 'docker rmi -f react-app localhost:5000/react-app'
          }
        }
    }
}
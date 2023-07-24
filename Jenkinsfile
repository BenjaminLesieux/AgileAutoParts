pipeline {
    agent any
    environment {
        discord_wh = credentials('discord_wh')
    }
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
                sh 'docker build -t react-lint -f ./ci_cd/lint.Dockerfile --no-cache .'
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
              sh 'docker build -t react-test -f ./ci_cd/test.Dockerfile --no-cache .'
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
        stage('SonarQube Analysis') {
          steps {
           discordSend description: "Launching SonarQube quality gate", footer: "AgileAutoParts", result: currentBuild.currentResult, title: "Quality Gate", webhookURL: env.discord_wh
            def scannerHome = tool 'SonarQube';
            withSonarQubeEnv(installationName: "SonarQube") {
                sh "${scannerHome}/bin/sonar-scanner"
            }
          }
        }
        stage('Deploy'){
          steps {
            sh 'docker build -t react-app ./ci_cd/build.Dockerfile --no-cache .'
            sh 'docker tag react-app localhost:5000/react-app'
            sh 'docker push localhost:5000/react-app'
            sh 'docker rmi -f react-app localhost:5000/react-app'
          }
        }
    }
    post {
        always {
            echo 'Pipeline run finished'
        }
        success {
           discordSend description: "Pipeline job has been successfully finished ", footer: "AgileAutoParts", result: currentBuild.currentResult, title: "AgileAutoParts_Deploy", webhookURL: env.discord_wh
        }
        failure {
           discordSend description: "Pipeline job has failed ", footer: "AgileAutoParts", result: currentBuild.currentResult, title: "AgileAutoParts_Deploy", webhookURL: env.discord_wh
        }
    }
}
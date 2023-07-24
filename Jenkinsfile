pipeline {
    agent any
    environment {
        discord_wh = credentials('discord_wh')
    }
    stages {
        stage('Checkout & Environment') {
          steps {
            checkout scm
            sh 'git --version'
            echo "Branch: ${env.BRANCH_NAME}"
            sh 'docker -v'
            sh 'printenv'
          }
        }
        stage('Lint code') {
            steps {
                sh 'docker build -t react-lint -f ./ci_cd/lint.Dockerfile --no-cache .'
                sh 'docker run --rm react-lint'
                sh 'docker rmi -f react-lint'
            }
        }
        stage('Test code'){
           steps {
              sh 'docker build -t react-test -f ./ci_cd/test.Dockerfile --no-cache .'
              sh 'docker run --rm react-test'
              sh 'docker rmi -f react-test'
           }
        }
        stage('SonarQube Analysis') {
          environment {
            scannerHome = tool 'sonarqube'
          }
          steps {
            withSonarQubeEnv(installationName: "SonarQube") {
                sh "${scannerHome}/bin/sonar-scanner -Dproject.settings=./sonar-project.properties"
            }
          }
        }
        stage("Quality gate") {
          steps {
            script {
              def qualitygate = waitForQualityGate()
              sleep(10)
              if (qualitygate.status != "OK") {
                waitForQualityGate abortPipeline: true
              }
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
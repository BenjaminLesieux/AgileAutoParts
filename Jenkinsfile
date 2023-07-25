pipeline {
    agent any
    environment {
        discord_wh = credentials('discord_wh')
        dockerhub_usr = credentials('dockerhub_usr')
        dockerhub_pwd = credentials('dockerhub_pwd')
    }
    stages {
//         stage('Checkout & Environment') {
//           steps {
//             checkout scm
//             sh 'git --version'
//             echo "Branch: ${env.BRANCH_NAME}"
//             sh 'docker -v'
//             sh 'printenv'
//           }
//         }
//         stage('Lint code') {
//             steps {
//                 sh 'docker build -t react-lint -f ./ci_cd/lint.Dockerfile --no-cache .'
//                 sh 'docker run --rm react-lint'
//                 sh 'docker rmi -f react-lint'
//             }
//         }
//         stage('Test code'){
//            steps {
//               sh 'docker build -t react-test -f ./ci_cd/test.Dockerfile --no-cache .'
//               sh 'docker run --rm react-test'
//               sh 'docker rmi -f react-test'
//            }
//         }
//         stage('SonarQube Analysis') {
//           environment {
//             scannerHome = tool 'sonarqube'
//             sonar_login = credentials('sonar_login')
//             sonar_password = credentials('sonar_password')
//           }
//           steps {
//             sh 'ls with-jest-app'
//             withSonarQubeEnv(installationName: "SonarQube") {
//                 sh "${scannerHome}/bin/sonar-scanner -Dsonar.host.url=http://sonarqube:9000 -Dsonar.login=${sonar_login} -Dsonar.password=${sonar_password}"
//             }
//           }
//         }
        stage('Deploy'){
          steps {
            sh 'docker login -u ${dockerhub_usr} -p ${dockerhub_pwd}'
            sh 'docker build -t agile_auto_parts -f ./ci_cd/build.Dockerfile --no-cache .'
            sh 'docker tag agile_auto_parts ${dockerhub_usr}/agile_auto_parts:${env.BUILD_NUMBER}'
            sh 'docker push ${dockerhub_usr}/agile_auto_parts:${env.BUILD_NUMBER}'
            sh 'docker rmi -f agile_auto_parts ${dockerhub_usr}/agile_auto_parts:${env.BUILD_NUMBER}'
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
# AgileAutoParts
Devops project for Efrei (2023-2024)

## How to use the pipeline 

### Setup the Jenkins & SonarQube servers 

1. Clone the repository
2. Run the following command to start the Jenkins & SonarQube servers
```bash
docker-compose up -d
```
3. Go to http://localhost:8080/ and login with the following credentials
```
username: admin
password: admin
```
By default, all necessary plugins should be installed. 
To verify if the plugins are installed, go to Manage Jenkins > Manage Plugins > Installed.
If it happens that the plugins are not installed, you can install them manually.
To do so, go to Manage Jenkins > Manage Plugins > Available > Search for the plugin > Install without restart.
The name of the plugins are:
- SonarQube Scanner
- Sonar Quality Gates
- Discord Notification
- Docker Pipeline
- Docker
- Docker Compose
- Docker API

Go to Manage Jenkins > System and scroll down to the SonarQube section.
Do as such: 
- Name: SonarQube
[](https://github.com/BenjaminLesieux/AgileAutoParts/blob/main/pictures/sonarqube_servers.png)
In the same section, make sure your jenkins url is correct.
[](https://github.com/BenjaminLesieux/AgileAutoParts/blob/main/pictures/jenkins_loc.png)

NB: You can change the credentials in the docker-compose.yml file or on the jenkins ui interface
4. Go to http://localhost:9000/ and login with the following credentials
```
username: admin
password: admin
```
Then you'll be asked to change your credentials and you'll be able to access the SonarQube dashboard
We already created a project called "AgileAutoParts" for this POC.
In order to create yours, you first have to:
- Create a new project on SonarQube
  - - Go to Projects > Create new project from GitHub
  - - Select your repository
  - - Follow the instructions
- Generate a token for this project
- Change the project property: "sonar.projectKey" to your project key in the Jenkinsfile (line 37)
- Push the code on the main branch so that the updated Jenkinsfile is used

** Now your servers are ready to use **

### Create a new pipeline

1. Go to http://localhost:8080/ and login with the following credentials
```
username: admin
password: admin
```
2. Add credentials 
- Go to Credentials > System > Global credentials (unrestricted) > Add Credentials
- Add your discord webhook credentials
  - Go to your discord channel > Edit channel > Integrations > Webhooks > New Webhook
- Add your dockerhub credentials
- Add your SonarQube token (you can generate one on the SonarQube dashboard)
  - Go to My Account > Security > Generate Tokens
  - Give it a name and click on generate
  - Copy the token and paste it in the Jenkins credentials
3. Create a new pipeline
- Go to New Item > Pipeline
- Add your github repository url: https://github.com/BenjaminLesieux/AgileAutoParts.git
- Save

Make sure the following properties are set:
**Build Triggers**
[](https://github.com/BenjaminLesieux/AgileAutoParts/blob/main/pictures/build_triggers.png)
**SCM Pipeline Options**
[](https://github.com/BenjaminLesieux/AgileAutoParts/blob/main/pictures/SCM_pipeline.png)

1. Run the pipeline
2. Check the SonarQube dashboard to see the results of the analysis
3. Check your discord channel to see the results of the pipeline

### Detail of the pipeline

The pipeline is divided in 4 stages:
- Linting
- Test
- SonarQube
- Deploy
  - Build
  - Push on DockerHub
- Notify on Discord (if the pipeline failed or succeeded)

### Linting

The linting stage is used to check if the code is well formatted.
It corresponds to the following snippet: 
```groovy
        stage('Lint code') {
            steps {
                sh 'docker build -t react-lint -f ./ci_cd/lint.Dockerfile --no-cache .'
                sh 'docker run --rm react-lint'
                sh 'docker rmi -f react-lint'
            }
        }
```
It uses a Dockerfile to build an image with the necessary dependencies to run the linting.
Then it runs the linting and removes the image.
Here is the Dockerfile:
```dockerfile
# Extending image
FROM node:latest
LABEL authors="team 9"

# Create app directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Versions
RUN npm -v
RUN node -v

RUN npm install -g pnpm

# Install app dependencies
COPY /with-jest-app/package.json /usr/src/app/
COPY /with-jest-app/pnpm-lock.yaml /usr/src/app/

RUN pnpm install --frozen-lockfile

# Bundle app source
COPY /with-jest-app/ /usr/src/app/

# Port to listener
EXPOSE 3000

# Environment variables
ENV NODE_ENV production
ENV PORT 3000
ENV PUBLIC_PATH "/"

CMD ["npm", "run", "lint"]
```
You'll just have to change "with-jest-app" to the directory of your project.

### Test

The test stage is used to run the tests.
It corresponds to the following snippet: 
```groovy
        stage('Test') {
            steps {
                sh 'docker build -t react-test -f ./ci_cd/test.Dockerfile --no-cache .'
                sh 'docker run --rm react-test'
                sh 'docker rmi -f react-test'
            }
        }
```

It uses a Dockerfile to build an image with the necessary dependencies to run the tests.
Then it runs the tests and removes the image.
Here is the Dockerfile:
```dockerfile
# Extending image
FROM node:latest
LABEL authors="team 9"

# Create app directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Versions
RUN npm -v
RUN node -v
RUN npm install -g pnpm

COPY /with-jest-app/package.json /usr/src/app
COPY /with-jest-app/pnpm-lock.yaml /usr/src/app/

RUN pnpm install --frozen-lockfile

COPY /with-jest-app/ /usr/src/app

# Environment variables
ENV NODE_ENV test

# Main command
CMD [ "npm", "test" ]
```

Same thing as before. You'll just have to change "with-jest-app" to the directory of your project.

### SonarQube

The SonarQube stage is used to run the SonarQube analysis.
It corresponds to the following snippet: 
```groovy
        stage('SonarQube Analysis') {
          steps {
            withSonarQubeEnv('SonarQube') {
               sh "${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=BenjaminLesieux_AgileAutoParts_AYmHuTrwUUH-oCO6QK7t -Dsonar.language=ts -Dsonar.webhooks.project=http://jenkins:8080/sonarqube-webhook/ -Dsonar.host.url=http://sonarqube:9000 -Dsonar.web.host=0.0.0.0 -Dsonar.web.port:9000 -Dsonar.login=${sonar_login} -Dsonar.password=${sonar_password}"
            }
          }
        }
        stage("Quality Gate") {
          steps {
            timeout(time: 5, unit: 'MINUTES') {
              waitForQualityGate abortPipeline: true
            }
          }
        }
```

You won't have to change anything exept the project key (line 37) which corresponds to the project key of your SonarQube project.
You can also change the timeout of the quality gate (line 45).

### Deploy

The deploy stage is used to build and push the image on DockerHub.
Here is the snippet:

```groovy
        stage('Deploy'){
          steps {
            sh 'docker login -u ${dockerhub_usr} -p ${dockerhub_pwd}'
            sh 'docker build -t agile_auto_parts -f ./ci_cd/build.Dockerfile --no-cache .'
            sh 'docker tag agile_auto_parts benjaminlesieux/agile_auto_parts:latest'
            sh 'docker push benjaminlesieux/agile_auto_parts:latest'
            sh 'docker rmi -f agile_auto_parts benjaminlesieux/agile_auto_parts:latest'
          }
        }
```

You'll just have to change "agile_auto_parts" to the name of your image and "benjaminlesieux/agile_auto_parts" to your DockerHub username.

Here is the Dockerfile:
```dockerfile
FROM node:18-alpine AS base

FROM base AS deps
RUN apk add --no-cache libc6-compat
RUN npm install -g pnpm
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY /with-jest-app/package.json ./
COPY /with-jest-app/pnpm-lock.yaml ./
RUN pnpm i --frozen-lockfile --production
COPY /with-jest-app/ ./

FROM base AS builder
WORKDIR /usr/src/app
RUN npm install -g pnpm
COPY --from=deps /usr/src/app/node_modules ./node_modules
COPY --from=deps /usr/src/app/ .
RUN pnpm run build

FROM base AS runner
WORKDIR usr/src/app
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs
COPY --from=builder /usr/src/app/public ./public
COPY --from=builder --chown=nextjs:nodejs /usr/src/app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /usr/src/app/.next/static ./.next/static
USER nextjs
EXPOSE 3000
ENV PORT 3000
CMD ["node", "server.js"]
```

You'll just have to change "with-jest-app" to the directory of your project.

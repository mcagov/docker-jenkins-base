pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = '009543623063.dkr.ecr.eu-west-2.amazonaws.com'
        //DOCKER_IMAGE_NAME = "${env.JOB_NAME.split('/')[-2]?.replace('docker-', '')}"
        DOCKER_IMAGE_NAME = "docker-jenkins-base"
        DOCKER_TAG = "${env.BRANCH_NAME == 'master' ? 'latest' : env.BRANCH_NAME}"
        DOCKER_OPTS = '--pull --compress --no-cache=true --force-rm=true --progress=plain '
        DOCKER_BUILDKIT = '1'
        AWS_REGION = 'eu-west-2'
        BRANCH_NAME = 'develop'
        AWS_CREDENTIALS_ID = 'aws-jenkins-service-account-credentials' // ID for AWS credentials in Jenkins
    }

    triggers {
        // run once a week between the hours of 1 and 6 on sunday
        cron('H H(1-6) * * 0')
        upstream(upstreamProjects: 'Docker/docker-jdk/corretto-21')
    }

    options {
        ansiColor('xterm')
        timestamps()
        buildDiscarder(logRotator(numToKeepStr: '5'))
        disableConcurrentBuilds()
    }

    stages {
            stage('Authenticate to ECR') {
                  steps {
                            withCredentials([aws(credentialsId: "${AWS_CREDENTIALS_ID}", accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                                script {
                                     def AWS_PASSWORD = sh(script: "aws ecr get-login-password --region ${AWS_REGION}", returnStdout: true).trim()
                                     sh "echo ${AWS_PASSWORD} | docker login --username AWS --password-stdin 009543623063.dkr.ecr.${AWS_REGION}.amazonaws.com"
                                }
                            }
                        }
                    }

        stage('build') {
            agent {
                    docker {
                        image '009543623063.dkr.ecr.eu-west-2.amazonaws.com/jenkins-docker-ci:latest'
                        alwaysPull true
                        args '-v /var/run/docker.sock:/var/run/docker.sock'
                    }
                }
            steps {
                sh '''
                    docker build ${DOCKER_OPTS} -t "${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${DOCKER_TAG}" \
                    --secret id=CODEARTIFACT_AUTH_TOKEN,env=CODEARTIFACT_AUTH_TOKEN \
                                                    .
                '''
            }
        }

        stage('publish') {
            steps {
                sh '''
                    docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${DOCKER_TAG}
                '''
            }
        }
    }
}

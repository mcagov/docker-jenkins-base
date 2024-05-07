pipeline {
    agent {
        docker {
            image '676563297163.dkr.ecr.eu-west-2.amazonaws.com/jenkins-docker-ci:latest'
            alwaysPull true
            args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    environment {
        DOCKER_REGISTRY = '676563297163.dkr.ecr.eu-west-2.amazonaws.com'
        DOCKER_IMAGE_NAME = "${env.JOB_NAME.split('/')[-2]?.replace('docker-', '')}"
        DOCKER_TAG = "${env.BRANCH_NAME == 'master' ? 'latest' : env.BRANCH_NAME}"
        DOCKER_OPTS = '--pull --compress --no-cache=true --force-rm=true --progress=plain '
        DOCKER_BUILDKIT = '1'
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
        stage('build') {
            steps {
                sh '''
                    docker build ${DOCKER_OPTS} -t "${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${DOCKER_TAG}" .
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

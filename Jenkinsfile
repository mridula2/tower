def branch = env.BRANCH_NAME.replace("-", "").toLowerCase()
def buildNumber = env.BUILD_NUMBER
def json
def tag = branch + "." + buildNumber


pipeline {
    options {
        buildDiscarder(logRotator(numToKeepStr:'10'))
        timestamps()
        ansiColor('xterm')
    }
    agent {
        label 'docker-v18.03'
    }
    stages {
        stage('Clean Workspace') {
            steps {
                deleteDir()
            }
        }
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Init') {
            steps {
                // Read Vault values
                script {
                    json = vaultGetSecrets()
                }

                // Login to DTR
                wrap([$class: 'MaskPasswordsBuildWrapper', varPasswordPairs: [[var: 'password', password: json.password]]]) {
                   sh """
                       docker login --username ${json.username} --password '${json.password}' hub.docker.hpecorp.net
                   """
                }
            }
        }
        stage("Docker Build") {
            steps {
                sh """
                    docker build \
                        --build-arg http_proxy=$HTTP_PROXY \
                        --file playbooks/roles/services/commands/files/dockerhub/Dockerfile \
                        -t hub.docker.hpecorp.net/docker-hub/dockerhub:${tag} .
                """
            }
        }
        stage("Push to DTR") {
            steps {
                script {
                    if (env.BRANCH_NAME == "master") {
                        sh """
                            docker tag hub.docker.hpecorp.net/docker-hub/dockerhub:${tag} hub.docker.hpecorp.net/docker-hub/dockerhub:latest
                            docker push hub.docker.hpecorp.net/docker-hub/dockerhub:latest
                            docker push hub.docker.hpecorp.net/docker-hub/dockerhub:${tag}
                        """
                    } else {
                        sh """
                            docker push hub.docker.hpecorp.net/docker-hub/dockerhub:${tag}
                        """
                    }
                }
            }
        }
    }
    post {
        success {
            logstashPush("SUCCESS")
        }
        failure {
            logstashPush("FAILURE")
        }
        unstable {
            logstashPush("UNSTABLE")
        }
        always {
            deleteDir()
        }
    }
}

pipeline{
    agent any
    tools {
        jdk 'jdk-17'
        maven 'maven-3.8'
    }
    environment {
        IMAGE_NAME = "registry:5000/my-app"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }
    stages{
        stage("build java code"){
            steps{
                checkout([$class: 'GitSCM',
                   branches: [[name: '*/master']],
                   userRemoteConfigs: [[url: 'https://github.com/jabedhasan21/java-hello-world-with-maven']]
                ])

                sh 'mvn clean package'    
            }
        }
        stage('Check Docker') {
            steps {
                script {
                    echo "Docker object class: ${docker.getClass()}"
                    sh 'whoami'
                }
            }
        }
        stage("build docker image"){
            steps {
                script {
                    withEnv([
                        'DOCKER_TLS_VERIFY=',
                        'DOCKER_CERT_PATH=',
                        'DOCKER_HOST=unix:///var/run/docker.sock'
                    ]) {
                        image = docker.build("${IMAGE_NAME}:${IMAGE_TAG}")
                    }
                } 
            }
        }
        
        stage("push docker image"){
            steps {
                script {
                    docker.withRegistry('http://myregistry:5000') {
                        image.push()
                    }
                }
            }
        }
    }
}

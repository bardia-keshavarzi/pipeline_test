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
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/master']],
                    userRemoteConfigs: [[url: 'https://github.com/jabedhasan21/java-hello-world-with-maven']],
                    extensions: [
                        [$class: 'RelativeTargetDirectory', relativeTargetDir: 'app']
                    ]
                ])
                sh 'cd app && mvn clean package'    
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
                              sh '''
                                unset DOCKER_TLS_VERIFY
                                unset DOCKER_CERT_PATH
                                docker build -t registry:5000/my-app:${BUILD_NUMBER} -f Dockerfile app
                              '''
                } 
            }
        }

        stage("push docker image"){
            steps {
                script {
                    docker.withRegistry('http://localhost:5000') {
                        image.push()
                    }
                }
            }
        }
    }
}

pipeline{
    agent any
    tools {
        jdk 'jdk-17'
        maven 'maven-3.8'
    }
    environment {
        IMAGE_NAME = "localhost:5000/my-app"
        IMAGE_TAG = "${BUILD_NUMBER}"
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
                    def Image = docker.build("${IMAGE_NAME}:${BUILD_NUMBER}", "-f Dockerfile ./app")
                    docker.withRegistry('http://localhost:5000') {
                        image.push()
                } 
            }
        }
    }
}

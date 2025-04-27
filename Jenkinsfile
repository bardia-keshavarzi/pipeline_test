pipeline{
    agent any
    tools {
        jdk 'jdk-17'
        maven 'maven-3.8'
    }
    environment {

        PROJECT_NAME = "test-1"
        NEXUS_URL = 'localhost:5000'  
        IMAGE_NAME = "${NEXUS_URL}/myapp"
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
        
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sq1') { 
                    
                    sh 'cd app && mvn sonar:sonar \
                        -Dsonar.projectKey=${PROJECT_NAME} \
                        -Dsonar.projectName=${PROJECT_NAME}' 
                }
                    timeout(time: 15, unit: 'MINUTES') {

                     waitForQualityGate abortPipeline: true
                }
            }
        }
                   
        stage("build docker image"){
            steps {
                script {
                    def builtimage = docker.build("${IMAGE_NAME}:${BUILD_NUMBER}","-f Dockerfile ./app")
                    docker.withRegistry('http://${NEXUS_URL}', 'jenkins-nexus') {
                        builtimage.push()
                    } 
                }
            }
        }
    }
}
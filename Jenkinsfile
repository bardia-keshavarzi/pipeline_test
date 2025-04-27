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
    }
    stages{
        stage("build java code"){
            steps{
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/master']],
                    userRemoteConfigs: [[url: 'https://github.com/bardia-keshavarzi/java-hello-world-with-maven.git']],
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

        stage("push jar artifacts"){
            steps {
               withMaven (mavenSettingsConfig: 'nexus-cred'){
                  sh "cd app && mvn clean deploy"
               } 

            }
        }
                   
        stage("build docker image"){
            steps {
                script {
                    env.BUILT_IMAGE = docker.build("${IMAGE_NAME}:${BUILD_NUMBER}","-f Dockerfile ./app")
                }
            }
        }

 /*     stage("trivy test docker image"){
            steps {
                    sh '''
                        trivy image --no-progress --exit-code 1  --severity CRITICAL  --java-db-repository ghcr.io/aquasecurity/trivy-java-db:1 ${IMAGE_NAME}:${BUILD_NUMBER}
                    '''
            }
        }
*/
        stage("push docker image"){
            steps {
                script {
                    docker.withRegistry("http://${NEXUS_URL}", 'jenkins-nexus') {
                        def builtimage = env.BUILT_IMAGE
                        builtimage.push()
                    } 
                }
            }
        }
    }
}
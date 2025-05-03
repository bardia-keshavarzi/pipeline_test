pipeline{
    agent any
    tools {
        jdk 'jdk-17'
        maven 'maven-3.8'
    }
    parameters {
        booleanParam(name: 'AUTO_DEPLOY', defaultValue: true, description: 'deploy to k8s automatically')
    }
    environment {

        PROJECT_NAME = "test-1"
        NEXUS_URL = '10.153.152.95:5000'  
        IMAGE_NAME = "${NEXUS_URL}/myapp"
        ARGOCD_URL = '192.168.100.238:32100'
        ARGOCD_APP = 'my-app'
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
                    def builtimage = docker.build("${IMAGE_NAME}:${BUILD_NUMBER}","-f Dockerfile ./app")
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
                    def builtimage = docker.image("${IMAGE_NAME}:${BUILD_NUMBER}")
                    docker.withRegistry("http://${NEXUS_URL}", 'jenkins-nexus') {
                        builtimage.push()
                    } 
                }
            }
        }
        stage("update manifests"){
            steps {
                script {
                    if(params.AUTO_DEPLOY){
                        sh "sed -i 's|image:.*|image: ${IMAGE_NAME}:${BUILD_NUMBER}|' manifests/deployment.yaml"
                    }
                }
            }
        }
        stage("push manifests to git") {
            steps {
                script {
                    if(params.AUTO_DEPLOY) {
                        withCredentials([sshUserPrivateKey(
                            credentialsId: 'jenkins-github',
                            keyFileVariable: 'SSH_KEY'
                        )]) {
                            sh '''
                                git config --global user.name "jenkins"
                                git config --global user.email "jenkins@localhost"
                                git config --global core.sshCommand "ssh -i $SSH_KEY -o StrictHostKeyChecking=no"
                                git checkout main
                                git add manifests/deployment.yaml
                                git commit -m "update image to ${IMAGE_NAME}:${BUILD_NUMBER}"
                                git push origin main
                            '''
                        }
                    }
                }
            }
        }
        stage("trigger argo cd"){
            steps {
                script {
                    if(params.AUTO_DEPLOY){
                        withCredentials([usernamePassword(credentialsId: 'argocd-cred', passwordVariable: 'ARGOCD_PASS', usernameVariable: 'ARGOCD_USER')]) {
                        sh '''
                            argocd login $ARGOCD_URL --username $ARGOCD_USER --password $ARGOCD_PASS --insecure
                            argocd app sync $ARGOCD_APP
                            argocd app wait $ARGOCD_APP --health --sync --timeout 500
                            argocd app get $ARGOCD_APP
                        '''
                        }
                    }
                }
            }
        }
    }
}
pipeline {
    agent any
    tools {
        maven 'maven'
    }
    stages {
        stage ("Testing the code") {
            script {
                git branch: 'main', credentialsId: 'GitHub', url: 'https://github.com/vilayilarun/azure-devops.git'
            }
        }
        stage("build the docker image"){
                steps{
                    script {
                        customImage = docker.build("vilayilarun/max:${env.BUILD_ID}")
                    }
                }
            }
        stage("Push the builded docker image ${customImage}"){
            steps{
                script{
                    docker.withRegistry(' ','dockerhub' ){
                        customeImage.push();
                    }
                }
            }
        }
    }
}

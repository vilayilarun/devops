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
                 environment {
                    docker_repo = "vilayilarun/max"
                    script {
                        customImage = docker.build("${env.docker_repo}:${env.BUILD_ID}")
                        customImage.push()
                }
            }                
        }
    }
}
}
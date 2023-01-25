pipeline {
    agent any
    tools {
        maven 'maven'
        terraform 'terraform'
    }
    stages {
        stage ("Testing the code") {
            steps{
                script {
                git branch: 'main', credentialsId: 'GitHub', url: 'https://github.com/vilayilarun/azure-devops.git'
                }

            }
        }
        stage("build the docker image"){
                steps{
                    script {
                        customImage = docker.build("vilayilarun/max:helloworld-python-${env.BUILD_ID}")
                    }
                }
            }
        stage("Push the builded docker image "){
            steps{
                script{
                    docker.withRegistry('','docker-hub' ){
                        customImage.push();
                    }
                }
            }
        }
        stage("Update image tags") {
            steps {
                script {
                    def imageTag = sh(returnStdout: true, script: 'docker images --format "{{.Tag}}" vilayilarun/max').trim()
                    def values = readYaml file: "helloworld-python/values.yaml"
                    values.image.tag = imageTag
                    writeYaml file: 'helloworld-python/values.yaml', data: values, overwrite: true
                    dir('helloworld-python') {
                        // git add: 'helloworld-python/values.yaml', commit: 'Update image tag to ' + imageTag, push: true, pushCredentialsId: 'GitHub'
                        // git branch: 'main', credentialsId: 'GitHub', url: 'https://github.com/vilayilarun/azure-devops.git'
                        sh 'git config --global user.email "jenkins@example.com"'
                        sh 'git config --global user.name "Your Name"'
                        sh 'git add .'
                        sh 'git commit -m "Update from Jenkins"'
                        sh 'git push origin main'                     
                        // checkout([$class: 'GitSCM', branches: [[name: '*/main']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'GitHub', url: 'https://github.com/vilayilarun/azure-devops.git']]])
                    }
                    // for (image in values.images.repository) {
                    //     def tag = imagetag
                    //     sh "docker pull ${image.name}:${tag}"
                    //     sh "docker tag ${image.name}:${tag} ${image.name}:new_tag"
                    //     image.tag = "new_tag"
                    // }
                    // writeYaml file: "./helloworld-python/values.yaml", data: values
                }
            }
        }
        stage('Terraform Init') {
            steps {
                dir("./terrafrom") {
                withCredentials([file(credentialsId: 'aws_credentials', variable: 'AWS_CREDS')]) {
                    sh 'aws configure set aws_access_key_id $(echo ${AWS_CREDS} | jq -r .access_key)'
                    sh 'aws configure set aws_secret_access_key $(echo ${AWS_CREDS} | jq -r .secret_key)'
                }
                sh "${tool 'terraform'} init"
            }
        }
        }
        stage('Terraform Plan') {
            steps {
                dir("./terrafrom") {
                sh "${tool 'terraform'} plan -var-file=production.tfvars -out=tfplan"
            }
        }
        }
        stage('Terraform Apply') {
            steps {
                dir("./terrafrom") {
                sh "${tool 'terraform'} apply -auto-approve tfplan"
                script {
                    def cluster_status = sh(returnStatus: true, script: 'terraform output cluster_status')
                    if (cluster_status == 0) {
                        slackSend (color: 'good', message: 'Cluster creation completed successfully!', channel: '#devops', tokenCredentialId: 'slacktoken')
                    } else {
                        slackSend (color: 'danger', message: 'Cluster creation failed. Check the logs for more details.', channel: '#devops', tokenCredentialId: 'slacktoken')
                    }
                }
            }
        }
        }
        stage('Read tfvars file') {
            steps {
                script {
                    def tfvars = readFile './terraform/production.tfvars'
                    def cluster_name = /cluster_name = "(.*)"/.exec(tfvars)[1]
                    def region_name = /region = "(.*)"/.exec(tfvars)[1]
                }
            }
        }       
        stage('Connect to K8s') {
            steps {
                withCredentials([file(credentialsId: 'aws_credentials', variable: 'AWS_CREDS')]) {
                    sh 'aws configure set aws_access_key_id $(echo ${AWS_CREDS} | jq -r .access_key)'
                    sh 'aws configure set aws_secret_access_key $(echo ${AWS_CREDS} | jq -r .secret_key)'
                }
                sh "aws eks --region ${region_name} update-kubeconfig --name ${cluster_name}"
            }
        }        
    }
    post {
        always {
            slackSend (color: '#FFFF00', message: "Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' completed. Check the logs for more details.", channel: '#devops', tokenCredentialId: 'slacktoken')
        }
    }
}

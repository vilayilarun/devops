pipeline {
    agent any
    environment {
        imageTag = ""
    }
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
                    imageTag = sh(returnStdout: true, script: 'docker images --format "{{.Tag}}" vilayilarun/max').trim()
                    }
                }
            }
        }
        stage("Update image tags") {
            steps { 
                 script {
                    def values = readYaml file: "helloworld-python/values.yaml"
                    def updated = values.replace(/(image:\s*tag:\s*)(\S+)/, '$1' + imageTag)
                    writeYaml file: 'helloworld-python/values.yaml', data: updated, overwrite: true
                    dir('helloworld-python') { 
                    sh 'git add .'
                    sh 'git commit -m "Update build"'
                    git credentialsId: 'GitHub', url: 'https://github.com/vilayilarun/devops.git', branch: 'main', force: true
                    }
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

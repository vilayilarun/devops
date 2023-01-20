pipeline {
    agent any
    tools {
        maven 'maven'
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
        stage('Terraform Init') {
            steps {
                withCredentials([file(credentialsId: 'aws_credentials', variable: 'AWS_CREDS')]) {
                    sh "aws configure set aws_access_key_id $(echo ${AWS_CREDS} | jq -r .access_key)"
                    sh "aws configure set aws_secret_access_key $(echo ${AWS_CREDS} | jq -r .secret_key)"
                }
                sh 'terraform init'
            }
        }
        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -var-file=variables.tfvars -out=tfplan'
            }
        }
        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve tfplan'
                script {
                    def cluster_status = sh(returnStatus: true, script: 'terraform output cluster_status')
                    if (cluster_status == 0) {
                        slackSend (color: 'good', message: 'Cluster creation completed successfully!', channel: '#Jenkins-build', tokenCredentialId: 'slack-token')
                    } else {
                        slackSend (color: 'danger', message: 'Cluster creation failed. Check the logs for more details.', channel: '#Jenkins-build', tokenCredentialId: 'slack-token')
                    }
                }
            }
        }
        stage('Read tfvars file') {
            steps {
                script {
                    def tfvars = readFile './production.tfvars'
                    def cluster_name = /cluster_name = "(.*)"/.exec(tfvars)[1]
                    def region_name = /region = "(.*)"/.exec(tfvars)[1]
                }
            }
        }
        stage('Connect to K8s') {
            steps {
                withCredentials([file(credentialsId: 'aws_credentials', variable: 'AWS_CREDS')]) {
                    sh "aws configure set aws_access_key_id $(echo ${AWS_CREDS} | jq -r .access_key)"
                    sh "aws configure set aws_secret_access_key $(echo ${AWS_CREDS} | jq -r .secret_key)"
                }
                sh "aws eks --region ${region_name} update-kubeconfig --name ${cluster_name}"
            }
        }        
    }
    post {
        always {
            slackSend (color: '#FFFF00', message: "Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' completed. Check the logs for more details.", channel: '#Jenkins-build', tokenCredentialId: 'slack-token')
        }
    }
}

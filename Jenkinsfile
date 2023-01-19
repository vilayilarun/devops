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
                input message: 'Do you want to continue with terraform apply?', ok: 'Yes',
                parameters: [string(defaultValue: 'No', description: '', name: 'confirmation')]
                if (params.confirmation == 'Yes') {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }
        stage('Connect to K8s') {
            steps {
                withCredentials([file(credentialsId: 'aws_credentials', variable: 'AWS_CREDS')]) {
                    sh "aws configure set aws_access_key_id $(echo ${AWS_CREDS} | jq -r .access_key)"
                    sh "aws configure set aws_secret_access_key $(echo ${AWS_CREDS} | jq -r .secret_key)"
                }
                sh 'aws eks --region <region> update-kubeconfig --name <cluster_name>'
            }
        }
        stage('Deploy Docker Image') {
            steps {
                sh 'kubectl apply -f k8s-deployment.yaml'
            }
        }        
    }
}

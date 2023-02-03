pipeline {
    agent any
    environment {
        imageTag = ""
        AWS_ACCESS_KEY_ID = credentials('aws_access_key_id')
        AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key')                 
    }
    tools {
        maven 'maven'
        // terraform 'terraform'
    }
    stages {
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
                    // imageTag = sh(returnStdout: true, script: 'docker images --format "{{.Tag}}" vilayilarun/max | head -n 1').trim()
                    }
                }
            }
        }
        stage("Update image tags") {
            steps { 
                 script {
                    def values = readYaml file: "helloworld-python/values.yaml"
                    values.image.tag = "helloworld-python-${env.BUILD_ID}"
                    writeYaml file: 'helloworld-python/values.yaml', data: values, overwrite: true
                    withCredentials([usernamePassword(credentialsId: 'GitHub', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                        dir('/var/lib/jenkins/workspace/spark/helloworld-python/') {
                            sh "git config --global user.email '${env.GIT_USERNAME}'"
                            sh "git config --global user.name '${env.GIT_USERNAME}'"
                            sh "git remote set-url origin https://${env.GIT_USERNAME}:${env.GIT_PASSWORD}@github.com/vilayilarun/devops.git"
                            sh 'git add values.yaml'
                            sh 'git commit -m "Docker image has been updated on the charts Values.yaml"'
                            sh 'git push origin HEAD:main'
                        }
                    }
                 }
            
            }
        }
        stage('Terraform Init') {
            steps {
                dir("terraform") {
                sh "terraform init"
            }
        }
        }
        stage('Terraform Plan') {           
            steps {
                dir("terraform") {
                sh "terraform plan -var-file=production.tfvars -out=tfplan"
            }
        }
        }
        stage('Terraform Apply') {

            steps {
                dir("terraform") {
                sh "terraform apply -auto-approve tfplan"
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
        stage('Read tfvars file and Dwonload EKS configurations') {
            steps {
                script {
                    def tfvars = readFile('terraform/production.tfvars')
                    def region = tfvars.split("\n").find { it.startsWith('region = ') }.split(' = ')[1].replaceAll('"', '').trim().replaceAll('\r','').replaceAll('\n','')
                    def clusterName = tfvars.split("\n").find { it.startsWith('cluster_name = ') }.split(' = ')[1].replaceAll('"', '').trim().replaceAll('\r','').replaceAll('\n','')
                    sh "aws eks update-kubeconfig --name ${clusterName} --region ${region}"
                }
            }
        }       
        stage('Deploy the Helm Charts to the production') {
            steps {
                sh "helm install sprk helloworld-python"
                script {
                    def cluster_status = sh(returnStatus: true, script: 'echo $?')
                    if (cluster_status == 0) {
                        slackSend (color: 'good', message: 'Deployed the application successfully!', channel: '#devops', tokenCredentialId: 'slacktoken')
                    } else {
                        slackSend (color: 'danger', message: 'Application dployment failed.', channel: '#devops', tokenCredentialId: 'slacktoken')
                    }
                }
            }
        }
        stage('Check the status of the pods') {
            steps {
                script {
                    sh 'helm list'
                    sh 'kubectl get po'
                }
            }
        }        
    }
    post {
        always {
            slackSend (color: '#FFFF00', message: "Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' completed. Check the logs for more details.", channel: '#devops', tokenCredentialId: 'slacktoken')
        }
    }
}

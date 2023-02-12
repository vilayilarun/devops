pipeline {
    // Pipeline Agents
    agent any
    // AWS secrets and access keys are configured as env. The values are proppulated from the Jenkins cred
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
                        //Building the docker image, Image repo and tags can be updated
                        customImage = docker.build("vilayilarun/max:helloworld-python-${env.BUILD_ID}")
                    }
                }
            }
        stage("Push the builded docker image "){
            steps{
                script{
                    // Push the image to the docker-hub, Docker registry can be added to push
                    docker.withRegistry('','docker-hub' ){
                        customImage.push();
                    }
                }
            }
        }
        stage("Update image tags") {
            steps { 
                 script {
                    // Reading the Values.yaml file 
                    def values = readYaml file: "helloworld-python/values.yaml"
                    // Seting the tag value 
                    values.image.tag = "helloworld-python-${env.BUILD_ID}"
                    // Writing back the image tag to the values.yaml
                    writeYaml file: 'helloworld-python/values.yaml', data: values, overwrite: true
                    // Pushing the updated image tag to the Git repo
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
                // Initializing the terrafrom
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
            //    Create registry secrets for the Helm deployment.
        stage('Create registry secrets for the Helm deployment'){
            steps{
                script{
                    withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]){
                        sh 'kubectl delete secret myregistry --ignore-not-found'
                        sh 'kubectl create secret docker-registry myregistry --docker-server=https://index.docker.io/v1/ --docker-username=${DOCKER_USERNAME} --docker-password=${DOCKER_PASSWORD} --docker-email=vilayilarun@gamil.com'
                    }
                }
            }
        }
        stage('Deploy the Helm Charts to the production') {
            steps {

                // sh "helm install sprk helloworld-python"
                script {
                    // Define the chart name and release name
                    chart_name = "spark"
                    release_name = "helloworld-python"
                    // Check if the chart is already deployed
                    def deployed = deployed = sh(returnStdout: true, script: "helm list -q --all").trim().contains(release_name)
                    if (deployed) {
                        sh "helm upgrade ${release_name} ${chart_name}"
                    }
                    // If the chart is not deployed, perform a Helm install
                    else {
                        sh "helm install ${chart_name} ${release_name}"
                    }
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

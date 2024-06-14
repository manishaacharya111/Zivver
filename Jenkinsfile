pipeline {
    agent any
    
    environment {
        region = "ap-south-1"
        //ecrRegistryCredential = 'ecr:ap-south-1:aws-cred'
        registryURI =   "637423474653.dkr.ecr.ap-south-1.amazonaws.com/zivver-repo"
        vprofileRegistry = "https://637423474653.dkr.ecr.ap-south-1.amazonaws.com"
        cluster = "cluster"
        task_def_arn = "arn:aws:ecs:ap-south-1:637423474653:task-definition/tomacat-service"
        AWS_ACCESS_KEY_ID = credentials('aws-cred')
        AWS_SECRET_ACCESS_KEY = credentials('aws-cred')

    }
    stages {
        stage('Build App Image') {
            steps{
                script{
                    dockerImage = docker.build(registryURI + ":$BUILD_NUMBER", "./version-server-html")
                }
            }
        }
        
        // Upload docker image to ECR
        stage('Upload App Image') {
            steps{
                script {
                    // docker.withRegistry(vprofileRegistry, ecrRegistryCredential) 
                    // dockerImage.push ("$BUILD_NUMBER")
                    // dockerImage.push('latest')
                    //ecr login 
                    sh 'aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 637423474653.dkr.ecr.ap-south-1.amazonaws.com'
                    sh 'docker push ${registryURI}:$BUILD_NUMBER'
                    
                }
            }   
        } 
        // Scan Image using Trivy 
        stage('Image Scan') {
            steps{
                script {
                    sh 'trivy image ${registryURI}:$BUILD_NUMBER'                    
                }
            }   
        } 
        //stage('Deploy') {
            steps {
                script {
                // //login 
                // docker.withRegistry(vprofileRegistry, ecrRegistryCredential){
                // }
                // Override image field in taskdef file
                    sh "sed -i 's|{{image}}|${registryURI}:${BUILD_NUMBER}|' taskdef.json"
                    sh "sed -i 's|{{image}}|${registry}:${BUILD_NUMBER}|' taskdef.json"
                // Create a new task definition revision
                    sh "aws ecs register-task-definition --cli-input-json file://taskdef.json --region ${region}"
                // Update service
                    sh "aws ecs update-service --cluster ${cluster} --service service --task-definition ${task_def_arn} --region ${region}"
                }
            }
        } //
    }
} 

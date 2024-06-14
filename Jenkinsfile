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
    }
}

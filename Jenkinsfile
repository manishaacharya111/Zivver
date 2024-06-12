pipeline {
    agent any
    
    environment {
        ecrRegistryCredential = 'ecr:ap-south-1:terraform-new'
        registryURI =   "637423474653.dkr.ecr.ap-south-1.amazonaws.com/zivver-repo"
        vprofileRegistry = "https://637423474653.dkr.ecr.ap-south-1.amazonaws.com"
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
                    docker.withRegistry( vprofileRegistry, ecrRegistryCredential) {
                    dockerImage.push ("$BUILD_NUMBER")
                    dockerImage.push('latest')
                    }
                }
            }   
        } 
    } 
} 

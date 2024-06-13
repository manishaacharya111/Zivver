pipeline {
    agent any
    
    environment {
        region = "ap-south-1"
        ecrRegistryCredential = 'ecr:ap-south-1:aws-cred'
        registryURI =   "637423474653.dkr.ecr.ap-south-1.amazonaws.com/zivver-repo"
        vprofileRegistry = "https://637423474653.dkr.ecr.ap-south-1.amazonaws.com"
        cluster = "cluster"
        task_def_arn = "arn:aws:ecs:ap-south-1:637423474653:task-definition/tomacat-service"

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
                    docker.withRegistry(vprofileRegistry, ecrRegistryCredential) {
                    dockerImage.push ("$BUILD_NUMBER")
                    dockerImage.push('latest')
                    }
                }
            }   
        } 
        stage('Deploy') {
            steps {
                script {
                // Override image field in taskdef file
                    sh "sed -i 's|{{image}}|${registryURI}:${BUILD_NUMBER}|' taskdef.json"
                // Create a new task definition revision
                    sh "aws ecs register-task-definition --cli-input-json file://taskdef.json --region ${region}"
                // Update service
                    sh "aws ecs update-service --cluster ${cluster} --service service --task-definition ${task_def_arn} --region ${region}"
                }
            }
        }
    }
} 

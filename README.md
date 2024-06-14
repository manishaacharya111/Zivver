# Zivver
this is Zivver task
____________________________________________________________________________

This repository contains the implementation of the Zivver task. The task involves setting up a new application in AWS, deploying a containerized tomcat app in AWS ECS, and automating deployments by creating a CI/CD pipeline using Jenkins, Terraform.
# 1. Steps to Set Up Jenkins Server Using Terraform

Reference directory in Repos: **Zivver/Jenkins-Terraform**

**Pre-requisites:**

Ensure you have an AWS account and a IAM user created[have provided the AdministratorAccess] & “aws configure” is done in the local machine to authenticate on behalf of you to use the AWS services.

**Create Terraform Configuration**:

- backend.tf: Defines the Terraform state backend configuration using S3 and DynamoDB for locking.  I have created the S3 bucket and dynamoDB table already and defined here.

- provider.tf: Specifies the AWS provider configuration.

- variable.tf: Declares variables like instance type and AMI ID.

- main.tf: Defines AWS resources including security group, instance, and associated Elastic IP.

- output.tf: Outputs the Jenkins instance's Elastic IP address.

- Create Installation Script (script.sh):
Bash script is incorporated to be executed on the Jenkins instance once the instance is up and running. We have the below installations:
  - System updates
  - Java
  - Jenkins
  - Docker
  - Trivy
  - AWS CLI
  - Terraform

**Deployment Steps**: Clone Terraform configuration and script to your local directory.

- Initialize Terraform: terraform init
- Review the plan and apply: 
- terraform plan
- terraform apply

- Access Jenkins using the provided **Elastic IP address:8080**

In this way Jenkins is ready and we need to do the below-following steps.

- Install the plugins: Eclipse Temurin installer, Docker, AWS ECR

- Configure the Tools & Credentials: Manage Jenkins→ Add the Java, docker tools for installation

  - Manage Jenkins→ Credentials→ AWS credentials→ provide the Access key & Secret Access key → Create

Two Jobs to be created in Jenkins:

- ECS Infrastructure Provision - To provision ECS infrastructure in AWS.
- App Deployment - CI/CD pipeline.

# 2.ECS Infrastructure Provision Using Terraform and automating it using Jenkins.
Reference directory in Repos: **Zivver/ECS-FARGATE-terraform/**

Terraform Configuration:

- Terraform Backend Configuration (backend.tf): Manages Terraform state in an S3 bucket for collaboration and state locking in DynamoDB. I have created the S3 bucket and dynamoDB table already and defined here.

- Provider Configuration (provider.tf): Configures AWS as the Terraform provider.

- Main.tf Configuration: The main.tf contains essential Terraform configurations to set up an ECS cluster, task definition, and service on AWS.

Here we are using ECS with Fargate Launch type ECS cluster named "cluster" with Amazon CloudWatch Container Insights enabled.

ECS task definition named "tomacat-service" specifies the Docker container image to use (zivver-repo:latest from ECR), resource allocation (CPU and memory), networking mode (awsvpc for Fargate), and port mappings (8080).

We have the desired no.of tasks as 2 which means minimum 2 containers will be running always.

- Variables (variables.tf): Defines variables such as AWS region and VPC CIDR block & availability zones.

- Networking (network.tf): Sets up VPC, subnets, security groups, internet gateway, and route tables. Have defined 2 availability zones so that app will be highly available.

- Load Balancer (loadbalancer.tf): Defines AWS Application Load Balancer (ALB), target group, and listener. 
This setup ensures that incoming traffic is properly distributed across your ECS containers or tasks, providing high availability and scalability for your application.

Here, ALB listener (aws_lb_listener.ecs_listener) is configured to route incoming HTTP traffic from port 80 to the target group.

- Auto Scaling and Monitoring (autoscaling.tf): Sets up Auto Scaling policies and CloudWatch alarms based on CPU utilization metrics.

Jenkins CI/CD Pipeline (Jenkinsfile):

- Jenkins Pipeline Configuration (Jenkinsfile): Automates the deployment process using Jenkins declarative pipeline. Jenkins is configured with a pipeline to automate Terraform actions (init, validate, plan, apply or destroy)

This configuration ensures that your ECS-based application can handle varying levels of traffic, maintain high availability, and scale dynamically based on demand, all managed through Terraform's infrastructure as code approach.

**Steps to Provision the ECS infrastructure.**

- With the above configs, create a Jenkins pipeline job pulls code from Zivver/ECS-FARGATE-terraform/

- Creating a Parametrized job & configure the parameters name as ‘action’ and values as ‘apply’,’ destroy’.

- Choose the correct Jenkinsfile.

- To provision the ECS infrastructure, simply run the pipeline. Choose the build parameter as apply.

- This job also can be used to destroy the ECS by choosing build parameter as destroy.

# 3. CI/CD Pipeline to Deploy the application on ECS existing Cluster 

Reference directory in Repos: **Zivver/version-server-html/index.html**

- src: We have the HTML file (index.html) that will be served by your Tomcat container running in ECS Cluster(which we created at first)

- Dockerfile: We have the Dockerfile [version-server-html/Dockerfile] which basically binds the HTML code and create a image out of it.

Now we have the Jenkinsfile[Zivver/Jenkinsfile] to deploy the image on the Cluster.

Below are the steps explained.

Here in the environment section we have used the global environment variables for AWS login. These credentials are fetched securely from Jenkins credentials during the build.

- Build App Image:

Jenkins builds a Docker image based on the Dockerfile (./version-server-html directory).

The image is tagged with the Jenkins build number and pushed to the ECR repository.

- Upload App Image to ECR:

Jenkins logs in to ECR using AWS credentials fetched securely.

The Docker image tagged with the build number is pushed to ECR.

- Image Scan using Trivy:

Trivy scans the Docker image for vulnerabilities before deployment. If there is any vulnerability for any particular version of the dependencies it will help us to avoid security issues. We use this as an extra layer of security. Also, it does scan the Dockerfile layer by layer and helps to find if there is any vulnerability associated with the underlying base image.

- Deploy to ECS:

The taskdef.json file is updated dynamically to replace the placeholder {{image}} with the newly built Docker image URI.

Jenkins registers a new ECS task definition revision with AWS ECS.

AWS ECS service is updated to use the latest task definition, triggering a rolling deployment of the new container instances.

- Configure Webhook: By setting up GitHub webhooks and integrating them with Jenkins pipelines, you establish an automated CI/CD workflow that reacts to changes in your codebase, facilitating faster and more reliable deployments.

**CI/CD Steps**

- Create Jenkins pipeline which uses Jenkinsfile.

- Choose GitHub hook trigger for GITScm polling in job config.

- On each release, the build will be auto-triggered as the webhook is configured. 

- Once the build is triggered it will execute the configured stages mentioned above. 

- Upon successful build, ECS cluster will be updated with the latest image gracefully.

This process will be repeated whenever a new feature is released.

# 4. How to access the application:

Fetch the load balancer dns name and access it in the private browser to check the message in the HTML code.

—------------------------------*******************----------------------------------

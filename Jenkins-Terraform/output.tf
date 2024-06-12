output "jenkins_eip" {
  description = "The Elastic IP address of the Jenkins instance"
  value       = aws_eip.jenkins_eip.public_ip
}
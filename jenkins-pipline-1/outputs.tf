output "jenkins_public_Ip" {
    value = aws_instance.jenkins-pipeline.public_ip
}

output "browser_port" {
    value = var.http_port
}
output "instance_public_ip" {
  description = "Public IP of the EC2 instance running the app"
  value       = aws_instance.app.public_ip
}

output "instance_id" {
  description = "EC2 instance ID (needed for GitHub Actions SSM deploy step)"
  value       = aws_instance.app.id
}

output "ecr_repository_url" {
  description = "ECR repository URL to push Docker images to"
  value       = aws_ecr_repository.app.repository_url
}

output "app_url" {
  description = "URL to access the deployed app"
  value       = "http://${aws_instance.app.public_ip}"
}

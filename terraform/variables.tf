variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name prefix used for all resources"
  type        = string
  default     = "devops-heavy-project"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "AZ for the public subnet"
  type        = string
  default     = "us-east-1a"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to SSH into the instance. Restrict this to your own IP (x.x.x.x/32) in production."
  type        = string
  default     = "0.0.0.0/0"
}

variable "key_pair_name" {
  description = "Existing EC2 key pair name for SSH access (optional if only using SSM)"
  type        = string
  default     = ""
}

variable "app_port" {
  description = "Port the container exposes the app on (mapped to host port 80)"
  type        = number
  default     = 80
}

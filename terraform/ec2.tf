data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

locals {
  user_data = <<-EOF
    #!/bin/bash
    set -e
    dnf update -y
    dnf install -y docker
    systemctl enable docker
    systemctl start docker

    # Login to ECR and pull the latest app image
    aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.app.repository_url}
    docker pull ${aws_ecr_repository.app.repository_url}:latest || true
    docker run -d --name app --restart unless-stopped -p 80:${var.app_port} ${aws_ecr_repository.app.repository_url}:latest || true
  EOF
}

resource "aws_instance" "app" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.app.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  key_name                    = var.key_pair_name != "" ? var.key_pair_name : null
  associate_public_ip_address = true

  user_data = local.user_data

  tags = {
    Name = "${var.project_name}-instance"
  }
}

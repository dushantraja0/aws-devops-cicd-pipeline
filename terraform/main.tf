terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Recommended for real/team usage: remote state in S3 + lock table in DynamoDB.
  # Uncomment and fill in after creating the bucket/table once (chicken-and-egg problem
  # otherwise). Keeping it local by default so the project runs out of the box.
  #
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "devops-heavy-project/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-locks"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region
}

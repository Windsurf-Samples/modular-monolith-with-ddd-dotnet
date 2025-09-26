terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project     = "MyMeetings"
      Environment = var.environment
      ManagedBy   = "terraform"
      Repository  = "modular-monolith-with-ddd-dotnet"
    }
  }
}

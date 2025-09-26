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
      Environment = "dev"
      ManagedBy   = "terraform"
      Repository  = "modular-monolith-with-ddd-dotnet"
    }
  }
}

module "ses" {
  source = "../../modules/ses"
  
  domain_name  = var.domain_name
  project_name = var.project_name
  environment  = "dev"
  from_email   = var.from_email
}

module "lambda_iam" {
  source = "../../modules/lambda"
  
  project_name           = var.project_name
  environment           = "dev"
  ses_domain_identity_arn = module.ses.domain_identity_arn
}

module "eventbridge" {
  source = "../../modules/eventbridge"
  
  project_name = var.project_name
  environment  = "dev"
}

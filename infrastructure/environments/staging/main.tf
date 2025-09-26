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
      Environment = "staging"
      ManagedBy   = "terraform"
      Repository  = "modular-monolith-with-ddd-dotnet"
    }
  }
}

module "ses" {
  source = "../../modules/ses"
  
  domain_name  = var.domain_name
  project_name = var.project_name
  environment  = "staging"
  from_email   = var.from_email
}

module "lambda_iam" {
  source = "../../modules/lambda"
  
  project_name           = var.project_name
  environment           = "staging"
  ses_domain_identity_arn = module.ses.domain_identity_arn
}

module "eventbridge" {
  source = "../../modules/eventbridge"
  
  project_name = var.project_name
  environment  = "staging"
}

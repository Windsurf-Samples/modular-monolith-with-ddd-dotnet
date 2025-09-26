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
      Environment = "prod"
      ManagedBy   = "terraform"
      Repository  = "modular-monolith-with-ddd-dotnet"
    }
  }
}

module "sns" {
  source = "../../modules/sns"
  
  project_name = var.project_name
  environment  = "prod"
}

module "lambda_iam" {
  source = "../../modules/lambda"
  
  project_name = var.project_name
  environment  = "prod"
}

module "eventbridge" {
  source = "../../modules/eventbridge"
  
  project_name                      = var.project_name
  environment                       = "prod"
  user_registration_topic_arn       = module.sns.user_registration_topic_arn
  meeting_group_created_topic_arn   = module.sns.meeting_group_created_topic_arn
  meeting_attendee_added_topic_arn  = module.sns.meeting_attendee_added_topic_arn
  subscription_created_topic_arn    = module.sns.subscription_created_topic_arn
  subscription_renewed_topic_arn    = module.sns.subscription_renewed_topic_arn
}

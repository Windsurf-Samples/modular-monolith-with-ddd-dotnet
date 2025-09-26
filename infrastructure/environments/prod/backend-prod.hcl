bucket         = "mymeetings-terraform-state-prod"
key            = "prod/terraform.tfstate"
region         = "us-east-1"
encrypt        = true
dynamodb_table = "mymeetings-terraform-locks-prod"

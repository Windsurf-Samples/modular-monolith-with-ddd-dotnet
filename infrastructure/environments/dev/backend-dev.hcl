bucket         = "mymeetings-terraform-state-dev"
key            = "dev/terraform.tfstate"
region         = "us-east-1"
encrypt        = true
dynamodb_table = "mymeetings-terraform-locks-dev"

bucket         = "mymeetings-terraform-state-staging"
key            = "staging/terraform.tfstate"
region         = "us-east-1"
encrypt        = true
dynamodb_table = "mymeetings-terraform-locks-staging"

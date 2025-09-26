variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "mymeetings"
}

variable "domain_name" {
  description = "Domain name for SES verification (e.g., example.com)"
  type        = string
}

variable "from_email" {
  description = "Default from email address for SES"
  type        = string
  default     = ""
}

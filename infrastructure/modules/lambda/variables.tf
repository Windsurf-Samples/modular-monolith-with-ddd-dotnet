variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "ses_domain_identity_arn" {
  description = "ARN of the SES domain identity"
  type        = string
  default     = "*"
}

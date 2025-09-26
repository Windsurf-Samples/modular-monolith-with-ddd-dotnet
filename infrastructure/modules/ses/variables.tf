variable "domain_name" {
  description = "Domain name for SES verification"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "from_email" {
  description = "Default from email address"
  type        = string
  default     = ""
}

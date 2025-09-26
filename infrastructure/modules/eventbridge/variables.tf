variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "user_registration_topic_arn" {
  description = "ARN of the user registration confirmation SNS topic"
  type        = string
}

variable "meeting_group_created_topic_arn" {
  description = "ARN of the meeting group created SNS topic"
  type        = string
}

variable "meeting_attendee_added_topic_arn" {
  description = "ARN of the meeting attendee added SNS topic"
  type        = string
}

variable "subscription_created_topic_arn" {
  description = "ARN of the subscription created SNS topic"
  type        = string
}

variable "subscription_renewed_topic_arn" {
  description = "ARN of the subscription renewed SNS topic"
  type        = string
}

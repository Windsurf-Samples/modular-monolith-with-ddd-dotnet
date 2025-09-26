output "sns_topic_arns" {
  description = "ARNs of all SNS topics"
  value = {
    user_registration_confirmation = module.sns.user_registration_topic_arn
    meeting_group_created         = module.sns.meeting_group_created_topic_arn
    meeting_attendee_added        = module.sns.meeting_attendee_added_topic_arn
    subscription_created          = module.sns.subscription_created_topic_arn
    subscription_renewed          = module.sns.subscription_renewed_topic_arn
  }
}

output "lambda_email_role_arn" {
  description = "ARN of the Lambda execution role for SNS publishing functions"
  value       = module.lambda_iam.email_lambda_role_arn
}

output "eventbridge_bus_arn" {
  description = "ARN of the EventBridge custom bus"
  value       = module.eventbridge.event_bus_arn
}

output "eventbridge_email_rule_arn" {
  description = "ARN of the EventBridge rule for email events"
  value       = module.eventbridge.email_rule_arn
}

output "email_queue_url" {
  description = "URL of the SQS queue for email processing"
  value       = module.eventbridge.email_queue_url
}

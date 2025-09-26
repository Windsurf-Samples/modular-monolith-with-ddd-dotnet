output "event_bus_arn" {
  description = "ARN of the EventBridge custom bus"
  value       = aws_cloudwatch_event_bus.main.arn
}

output "event_bus_name" {
  description = "Name of the EventBridge custom bus"
  value       = aws_cloudwatch_event_bus.main.name
}

output "email_rule_arn" {
  description = "ARN of the EventBridge rule for email events"
  value       = aws_cloudwatch_event_rule.email_events.arn
}

output "email_queue_arn" {
  description = "ARN of the SQS queue for email processing"
  value       = aws_sqs_queue.email_queue.arn
}

output "email_queue_url" {
  description = "URL of the SQS queue for email processing"
  value       = aws_sqs_queue.email_queue.url
}

output "email_dlq_arn" {
  description = "ARN of the SQS dead letter queue for email processing"
  value       = aws_sqs_queue.email_dlq.arn
}

output "sns_targets" {
  description = "List of SNS target ARNs configured for EventBridge"
  value = [
    var.user_registration_topic_arn,
    var.meeting_group_created_topic_arn,
    var.meeting_attendee_added_topic_arn,
    var.subscription_created_topic_arn,
    var.subscription_renewed_topic_arn
  ]
}

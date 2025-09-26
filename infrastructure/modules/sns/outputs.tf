output "user_registration_topic_arn" {
  description = "ARN of the user registration confirmation SNS topic"
  value       = aws_sns_topic.user_registration_confirmation.arn
}

output "meeting_group_created_topic_arn" {
  description = "ARN of the meeting group created SNS topic"
  value       = aws_sns_topic.meeting_group_created.arn
}

output "meeting_attendee_added_topic_arn" {
  description = "ARN of the meeting attendee added SNS topic"
  value       = aws_sns_topic.meeting_attendee_added.arn
}

output "subscription_created_topic_arn" {
  description = "ARN of the subscription created SNS topic"
  value       = aws_sns_topic.subscription_created.arn
}

output "subscription_renewed_topic_arn" {
  description = "ARN of the subscription renewed SNS topic"
  value       = aws_sns_topic.subscription_renewed.arn
}

output "sns_dlq_arn" {
  description = "ARN of the SNS dead letter queue"
  value       = aws_sqs_queue.sns_dlq.arn
}

output "email_lambda_role_arn" {
  description = "ARN of the Lambda execution role for SNS publishing functions"
  value       = aws_iam_role.email_lambda_role.arn
}

output "email_lambda_role_name" {
  description = "Name of the Lambda execution role for SNS publishing functions"
  value       = aws_iam_role.email_lambda_role.name
}

output "sns_publish_policy_arn" {
  description = "ARN of the SNS publish policy"
  value       = aws_iam_policy.sns_publish_policy.arn
}

output "email_lambda_role_arn" {
  description = "ARN of the Lambda execution role for email functions"
  value       = aws_iam_role.email_lambda_role.arn
}

output "email_lambda_role_name" {
  description = "Name of the Lambda execution role for email functions"
  value       = aws_iam_role.email_lambda_role.name
}

output "ses_send_policy_arn" {
  description = "ARN of the SES send policy"
  value       = aws_iam_policy.ses_send_policy.arn
}

output "ses_domain_identity_arn" {
  description = "ARN of the SES domain identity"
  value       = module.ses.domain_identity_arn
}

output "ses_domain_identity_verification_token" {
  description = "Verification token for SES domain identity"
  value       = module.ses.domain_identity_verification_token
}

output "ses_dkim_tokens" {
  description = "DKIM tokens for domain verification"
  value       = module.ses.dkim_tokens
}

output "lambda_email_role_arn" {
  description = "ARN of the Lambda execution role for email functions"
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

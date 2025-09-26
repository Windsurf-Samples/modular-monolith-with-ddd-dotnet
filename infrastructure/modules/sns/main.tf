resource "aws_sns_topic" "user_registration_confirmation" {
  name = "${var.project_name}-${var.environment}-user-registration-confirmation"

  tags = {
    Name = "${var.project_name}-${var.environment}-user-registration-confirmation"
  }
}

resource "aws_sns_topic" "meeting_group_created" {
  name = "${var.project_name}-${var.environment}-meeting-group-created"

  tags = {
    Name = "${var.project_name}-${var.environment}-meeting-group-created"
  }
}

resource "aws_sns_topic" "meeting_attendee_added" {
  name = "${var.project_name}-${var.environment}-meeting-attendee-added"

  tags = {
    Name = "${var.project_name}-${var.environment}-meeting-attendee-added"
  }
}

resource "aws_sns_topic" "subscription_created" {
  name = "${var.project_name}-${var.environment}-subscription-created"

  tags = {
    Name = "${var.project_name}-${var.environment}-subscription-created"
  }
}

resource "aws_sns_topic" "subscription_renewed" {
  name = "${var.project_name}-${var.environment}-subscription-renewed"

  tags = {
    Name = "${var.project_name}-${var.environment}-subscription-renewed"
  }
}

resource "aws_sqs_queue" "sns_dlq" {
  name = "${var.project_name}-${var.environment}-sns-dlq"

  message_retention_seconds = 1209600

  tags = {
    Name = "${var.project_name}-${var.environment}-sns-dlq"
  }
}

resource "aws_cloudwatch_log_group" "sns_events" {
  name              = "/aws/sns/${var.project_name}-${var.environment}"
  retention_in_days = 14
}

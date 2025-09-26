resource "aws_cloudwatch_event_bus" "main" {
  name = "${var.project_name}-${var.environment}-events"

  tags = {
    Name = "${var.project_name}-${var.environment}-events"
  }
}

resource "aws_cloudwatch_event_rule" "email_events" {
  name           = "${var.project_name}-${var.environment}-email-events"
  description    = "Rule to capture email-related domain events"
  event_bus_name = aws_cloudwatch_event_bus.main.name

  event_pattern = jsonencode({
    source      = ["mymeetings.domain"]
    detail-type = [
      "UserRegistrationConfirmationRequested",
      "MeetingGroupCreated", 
      "MeetingAttendeeAdded",
      "SubscriptionCreated",
      "SubscriptionRenewed"
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-email-events"
  }
}

resource "aws_sqs_queue" "email_dlq" {
  name = "${var.project_name}-${var.environment}-email-dlq"

  message_retention_seconds = 1209600 # 14 days

  tags = {
    Name = "${var.project_name}-${var.environment}-email-dlq"
  }
}

resource "aws_sqs_queue" "email_queue" {
  name = "${var.project_name}-${var.environment}-email-queue"

  visibility_timeout_seconds = 300
  message_retention_seconds  = 1209600 # 14 days

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.email_dlq.arn
    maxReceiveCount     = 3
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-email-queue"
  }
}

resource "aws_cloudwatch_event_target" "email_queue_target" {
  rule           = aws_cloudwatch_event_rule.email_events.name
  event_bus_name = aws_cloudwatch_event_bus.main.name
  target_id      = "EmailQueueTarget"
  arn            = aws_sqs_queue.email_queue.arn

  sqs_target {
    message_group_id = "email-events"
  }
}

resource "aws_sqs_queue_policy" "email_queue_policy" {
  queue_url = aws_sqs_queue.email_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.email_queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_cloudwatch_event_rule.email_events.arn
          }
        }
      }
    ]
  })
}

resource "aws_ses_domain_identity" "main" {
  domain = var.domain_name
}

resource "aws_ses_domain_dkim" "main" {
  domain = aws_ses_domain_identity.main.domain
}

resource "aws_ses_domain_mail_from" "main" {
  domain           = aws_ses_domain_identity.main.domain
  mail_from_domain = "mail.${var.domain_name}"
}

resource "aws_ses_configuration_set" "main" {
  name = "${var.project_name}-${var.environment}"

  delivery_options {
    tls_policy = "Require"
  }
}

resource "aws_ses_event_destination" "bounce_complaint" {
  name                   = "bounce-complaint-destination"
  configuration_set_name = aws_ses_configuration_set.main.name
  enabled                = true
  matching_types         = ["bounce", "complaint"]

  cloudwatch_destination {
    default_value  = "default"
    dimension_name = "MessageTag"
    value_source   = "messageTag"
  }
}

resource "aws_ses_event_destination" "delivery" {
  name                   = "delivery-destination"
  configuration_set_name = aws_ses_configuration_set.main.name
  enabled                = true
  matching_types         = ["delivery", "send"]

  cloudwatch_destination {
    default_value  = "default"
    dimension_name = "MessageTag"
    value_source   = "messageTag"
  }
}

resource "aws_ses_email_identity" "from_email" {
  count = var.from_email != "" ? 1 : 0
  email = var.from_email
}

resource "aws_cloudwatch_log_group" "ses_events" {
  name              = "/aws/ses/${var.project_name}-${var.environment}"
  retention_in_days = 14
}

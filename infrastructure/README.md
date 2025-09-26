# MyMeetings Infrastructure

This directory contains Terraform infrastructure as code for the MyMeetings application's AWS resources, starting with Amazon SES for email delivery and organized for future serverless migration.

## Directory Structure

```
infrastructure/
├── modules/                    # Reusable Terraform modules
│   ├── ses/                   # Amazon SES configuration
│   ├── lambda/                # Lambda IAM roles and policies
│   ├── eventbridge/           # EventBridge and SQS for event routing
│   └── api-gateway/           # (Future) API Gateway configuration
├── environments/              # Environment-specific configurations
│   ├── dev/                   # Development environment
│   ├── staging/               # Staging environment
│   └── prod/                  # Production environment
├── provider.tf               # AWS provider configuration
├── variables.tf              # Global variables
├── outputs.tf                # Global outputs
└── terraform.tfvars.example  # Example variables file
```

## Prerequisites

1. **AWS CLI configured** with appropriate credentials
2. **Terraform >= 1.0** installed
3. **Domain name** that you control for SES verification
4. **S3 bucket and DynamoDB table** for Terraform state management (see setup below)

## Initial Setup

### 1. Configure AWS Credentials

```bash
aws configure
# or use environment variables, IAM roles, etc.
```

### 2. Create S3 Backend Resources (One-time setup)

Before using Terraform, create the S3 bucket and DynamoDB table for state management:

```bash
# Create S3 bucket for Terraform state
aws s3 mb s3://mymeetings-terraform-state-dev --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket mymeetings-terraform-state-dev \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name mymeetings-terraform-locks-dev \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region us-east-1
```

### 3. Configure Variables

```bash
cd infrastructure/environments/dev
cp ../../terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your actual values
```

### 4. Initialize and Deploy

```bash
# Initialize Terraform with backend configuration
terraform init -backend-config=backend-dev.hcl

# Plan the deployment
terraform plan

# Apply the changes
terraform apply
```

## SES Domain Verification

After deployment, you'll need to verify your domain with SES:

### 1. Get Verification Records

```bash
terraform output ses_domain_identity_verification_token
terraform output ses_dkim_tokens
```

### 2. Add DNS Records

Add these DNS records to your domain:

**Domain Verification (TXT record):**
- Name: `_amazonses.yourdomain.com`
- Value: `<verification_token_from_output>`

**DKIM Records (CNAME records):**
- Name: `<dkim_token_1>._domainkey.yourdomain.com`
- Value: `<dkim_token_1>.dkim.amazonses.com`
- Name: `<dkim_token_2>._domainkey.yourdomain.com`
- Value: `<dkim_token_2>.dkim.amazonses.com`
- Name: `<dkim_token_3>._domainkey.yourdomain.com`
- Value: `<dkim_token_3>.dkim.amazonses.com`

**Mail From Domain (MX record):**
- Name: `mail.yourdomain.com`
- Value: `10 feedback-smtp.us-east-1.amazonses.com`

### 3. Verify Domain Status

```bash
aws ses get-identity-verification-attributes --identities yourdomain.com
```

## Integration with Existing Email Handlers

The infrastructure is designed to integrate with your existing email command handlers:

### Current Email Handlers Ready for Migration:
- `SendUserRegistrationConfirmationEmailCommandHandler`
- `SendMeetingGroupCreatedEmailCommandHandler`
- `SendMeetingAttendeeAddedEmailCommandHandler`
- `SendSubscriptionCreationConfirmationEmailCommandHandler`
- `SendSubscriptionRenewalConfirmationEmailCommandHandler`

### Migration Pattern:

1. **Replace EmailSender Implementation:**
   ```csharp
   // Current: Stores in database
   await sqlConnection.ExecuteScalarAsync("INSERT INTO [app].[Emails]...")

   // New: Send via SES
   await sesClient.SendEmailAsync(new SendEmailRequest
   {
       Source = fromEmail,
       Destination = new Destination { ToAddresses = { message.To } },
       Message = new Message
       {
           Subject = new Content(message.Subject),
           Body = new Body { Html = new Content(message.Content) }
       }
   });
   ```

2. **Event-Driven Architecture:**
   - Domain events → EventBridge → SQS → Lambda → SES
   - Existing Outbox/Inbox patterns publish to EventBridge
   - Lambda functions process events from SQS queue

## Environment Management

### Development
```bash
cd infrastructure/environments/dev
terraform init -backend-config=backend-dev.hcl
terraform plan
terraform apply
```

### Staging
```bash
cd infrastructure/environments/staging
terraform init -backend-config=backend-staging.hcl
terraform plan
terraform apply
```

### Production
```bash
cd infrastructure/environments/prod
terraform init -backend-config=backend-prod.hcl
terraform plan
terraform apply
```

## Monitoring and Troubleshooting

### SES Metrics
- Bounce and complaint rates are monitored via CloudWatch
- Events are logged to CloudWatch Logs

### EventBridge and SQS
- Failed email processing goes to dead letter queue
- Monitor queue depth and processing errors

### Common Issues

1. **Domain not verified:** Check DNS records and wait for propagation
2. **SES sandbox mode:** Request production access in AWS Console
3. **IAM permissions:** Ensure Lambda roles have SES send permissions

## Future Expansion

This infrastructure is organized to support:
- **Lambda Functions:** IAM roles already configured for email handlers
- **API Gateway:** Module structure ready for REST API endpoints
- **EventBridge:** Custom bus configured for domain events
- **Additional Services:** Easy to add modules for DynamoDB, RDS, etc.

## Security Considerations

- All resources are tagged for cost tracking and governance
- IAM roles follow least privilege principle
- SES configuration includes bounce and complaint handling
- State files are encrypted in S3
- DynamoDB table provides state locking

## Cost Optimization

- CloudWatch log retention set to 14 days
- SES is pay-per-use with no minimum fees
- EventBridge and SQS have generous free tiers
- Lambda will be pay-per-execution when added

## Support

For issues with this infrastructure:
1. Check Terraform plan output for configuration errors
2. Verify AWS credentials and permissions
3. Check CloudWatch logs for runtime errors
4. Review AWS service quotas and limits

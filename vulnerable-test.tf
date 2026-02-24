# DELIBERATELY VULNERABLE TERRAFORM CODE FOR TESTING SECURITY AGENT
# DO NOT USE IN PRODUCTION - THIS IS FOR TESTING PURPOSES ONLY

# Vulnerability 1: Hardcoded AWS Credentials
provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAIOSFODNN7EXAMPLE"
  secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
}

# Vulnerability 2: S3 Bucket with Public Access and No Encryption
resource "aws_s3_bucket" "vulnerable_bucket" {
  bucket = "my-vulnerable-public-bucket-12345"
  
  # No encryption configured
  # No versioning
  # No lifecycle policies
}

resource "aws_s3_bucket_public_access_block" "vulnerable_public_access" {
  bucket = aws_s3_bucket.vulnerable_bucket.id

  block_public_acls       = false  # VULNERABLE: Allows public ACLs
  block_public_policy     = false  # VULNERABLE: Allows public policies
  ignore_public_acls      = false  # VULNERABLE: Doesn't ignore public ACLs
  restrict_public_buckets = false  # VULNERABLE: Allows public bucket access
}

# Vulnerability 3: Security Group with Wide Open Access
resource "aws_security_group" "wide_open_sg" {
  name        = "wide-open-security-group"
  description = "Insecure security group for testing"
  
  # VULNERABLE: Allows all inbound traffic from anywhere
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # CRITICAL: Open to the entire internet
    description = "Allow all traffic from anywhere"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # CRITICAL: SSH open to the world
    description = "SSH from anywhere"
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # CRITICAL: RDP open to the world
    description = "RDP from anywhere"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # VULNERABLE: No tags for compliance
}

# Vulnerability 4: RDS Database without Encryption
resource "aws_db_instance" "vulnerable_database" {
  identifier           = "vulnerable-db"
  engine              = "mysql"
  engine_version      = "5.7"
  instance_class      = "db.t3.large"  # COST: Oversized for testing
  allocated_storage   = 100
  username            = "admin"
  password            = "Password123!"  # CRITICAL: Hardcoded password
  
  storage_encrypted   = false  # VULNERABLE: No encryption at rest
  publicly_accessible = true   # CRITICAL: Database accessible from internet
  
  skip_final_snapshot = true   # VULNERABLE: No backup on deletion
  backup_retention_period = 0  # VULNERABLE: No automated backups
  
  # VULNERABLE: No SSL enforcement
  # VULNERABLE: No CloudWatch logs
  # VULNERABLE: Missing required tags
}

# Vulnerability 5: Lambda Function with Overly Permissive IAM Role
resource "aws_iam_role" "lambda_admin_role" {
  name = "lambda-admin-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_admin_policy" {
  name = "lambda-admin-policy"
  role = aws_iam_role.lambda_admin_role.id

  # CRITICAL: Wildcard permissions - Full Admin Access
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "*"  # VULNERABLE: All actions allowed
      Resource = "*"  # VULNERABLE: On all resources
    }]
  })
}

resource "aws_lambda_function" "vulnerable_function" {
  filename      = "function.zip"
  function_name = "vulnerable-lambda"
  role          = aws_iam_role.lambda_admin_role.arn
  handler       = "index.handler"
  runtime       = "python3.9"
  memory_size   = 3008  # COST: Way oversized (max is 10GB, but 3GB is excessive for most)
  timeout       = 900   # COST: Maximum timeout (15 minutes)
  
  environment {
    variables = {
      DB_PASSWORD = "MySecretPassword123"  # VULNERABLE: Hardcoded secret
      API_KEY     = "sk_live_51234567890abcdef"  # VULNERABLE: Hardcoded API key
      AWS_KEY     = "AKIAI44QH8DHBEXAMPLE"  # VULNERABLE: Hardcoded AWS key
    }
  }

  # VULNERABLE: No VPC configuration
  # VULNERABLE: No dead letter queue
  # VULNERABLE: No reserved concurrency (cost risk)
  # VULNERABLE: No X-Ray tracing
}

# Vulnerability 6: EC2 Instance with Issues
resource "aws_instance" "vulnerable_instance" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.2xlarge"  # COST: Oversized instance
  
  vpc_security_group_ids = [aws_security_group.wide_open_sg.id]
  
  # VULNERABLE: No encrypted EBS
  root_block_device {
    encrypted = false  # VULNERABLE: Unencrypted root volume
    volume_size = 500  # COST: Large volume
  }

  # VULNERABLE: No monitoring
  monitoring = false
  
  # VULNERABLE: No IAM instance profile
  # VULNERABLE: No user_data script security
  user_data = <<-EOF
              #!/bin/bash
              export AWS_ACCESS_KEY_ID="AKIAIOSFODNN7EXAMPLE"
              export AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
              EOF

  # VULNERABLE: Missing tags
}

# Vulnerability 7: DynamoDB without Encryption
resource "aws_dynamodb_table" "vulnerable_table" {
  name           = "vulnerable-dynamodb-table"
  billing_mode   = "PROVISIONED"  # COST: Provisioned mode with high capacity
  read_capacity  = 100  # COST: Over-provisioned
  write_capacity = 100  # COST: Over-provisioned
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  # VULNERABLE: No encryption at rest configured (uses AWS owned keys by default)
  # VULNERABLE: No point-in-time recovery
  # VULNERABLE: No auto-scaling
  # VULNERABLE: Missing tags
}

# Vulnerability 8: SQS Queue without Encryption
resource "aws_sqs_queue" "vulnerable_queue" {
  name = "vulnerable-queue"
  
  # VULNERABLE: No encryption
  # VULNERABLE: No DLQ configured
  # VULNERABLE: Default message retention (could be optimized)
  message_retention_seconds = 1209600  # COST: 14 days maximum
}

# Vulnerability 9: API Gateway without Security
resource "aws_api_gateway_rest_api" "vulnerable_api" {
  name        = "vulnerable-api"
  description = "Vulnerable API for testing"
  
  # VULNERABLE: No API key required
  # VULNERABLE: No WAF protection
  # VULNERABLE: No CloudWatch logging
  # VULNERABLE: No throttling
}

# Vulnerability 10: Secrets in plain text
locals {
  database_credentials = {
    username = "admin"
    password = "SuperSecret123!"  # VULNERABLE: Plain text password
    api_key  = "1234567890abcdef"  # VULNERABLE: Plain text API key
  }
  
  aws_credentials = {
    access_key = "AKIAI44QH8DHBEXAMPLE"  # VULNERABLE: Hardcoded AWS key
    secret_key = "je7MtGbClwBF/2Zp9Utk/h3yCo8nvbEXAMPLEKEY"  # VULNERABLE: Hardcoded AWS secret
  }
}

# Vulnerability 11: CloudWatch Log Group without Retention
resource "aws_cloudwatch_log_group" "expensive_logs" {
  name = "/aws/lambda/vulnerable-function"
  
  # COST: No retention policy means logs kept forever
  # retention_in_days = null  # Default is never expire - COST RISK
}

# Vulnerability 12: KMS Key with Overly Permissive Policy
resource "aws_kms_key" "vulnerable_key" {
  description = "Vulnerable KMS key"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "*"  # VULNERABLE: Allows all AWS accounts
        }
        Action   = "kms:*"  # VULNERABLE: All KMS actions
        Resource = "*"
      }
    ]
  })
}

# Missing items that should be present:
# - No terraform backend configuration (state file security)
# - No provider version pinning
# - No required_providers block
# - No resource tagging policy
# - No budget alerts
# - No cost allocation tags

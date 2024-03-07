# Define variables to make the infrastructure configuration more flexible and reusable
variable "aws_region" {
  description = "AWS region for the deployment."
}

variable "ami_id" {
  description = "The AMI ID of the EC2 instance"
}

variable "instance_type" {
  description = "The instance type of the EC2 instance"
}

variable "environment" {
  description = "The deployment environment (e.g., Development, Staging, Production)"
}

variable "project_name" {
  description = "The name of the project for resource tagging"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed for SSH access"
}

variable "kms_key_id" {
  description = "KMS Key ID for EBS volume encryption. Leave blank to use the default AWS managed key."
}

variable "sns_topic_name" {
  description = "The name of the SNS topic for alerts."
  type        = string
}

variable "alert_email_address" {
  description = "The email address to subscribe to the SNS topic."
  type        = string
}

# Configure the AWS provider with the specified region from variable
provider "aws" {
  region = var.aws_region
}

# Create a security group to control access to the EC2 instance
resource "aws_security_group" "app_server_sg" {
  name        = "${var.project_name}-${var.environment}-sg"
  description = "Allow limited traffic to app server"
  
  # Ingress rule to allow SSH access from a specified IP address
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }
  
  # Egress rule to allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Tag the security group with metadata for identification and management
  tags = {
    Name        = "AppServerSG"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu   = "true"
  }
}

# Define an EC2 instance with attached security group and IMDSv2 configuration
resource "aws_instance" "app_server" {
  ami           = var.ami_id          # Use the AMI ID specified in the variable
  instance_type = var.instance_type   # Use the instance type specified in the variable

  vpc_security_group_ids = [aws_security_group.app_server_sg.id]

  # Configure the instance to use IMDSv2 for enhanced security
  metadata_options {
    # Enforce the use of IMDSv2 by setting the HTTP tokens to "required"
    http_tokens = "required"

    # Optionally, you can adjust the hop limit. The default is 1, which is typical for most use cases.
    http_put_response_hop_limit = 1

    # Setting the endpoint to "enabled" ensures that the IMDS is accessible.
    http_endpoint = "enabled"
  }

  # Configuring the root EBS volume
  root_block_device {
    volume_size = 20 # Sets the primary hard drive size to 20 GiB.
    encrypted   = true # Enables EBS encryption for data security.
    # Setting encrypted = true without specifying a kms_key_id will use the default AWS managed key for EBS encryption.
    # Optionally specify a KMS key.
    kms_key_id = var.kms_key_id # Uses the specified KMS key for encryption.
  }

  # Tag the instance with metadata for identification and management
  tags = {
    Name        = "AppServer"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu   = "true"
  }
}

# SNS Topic Resource
resource "aws_sns_topic" "app_server_alerts" {
  name = var.sns_topic_name

  # Tag the SNS topic resource with metadata for identification and management
  tags = {
    Name        = "AppServerSNS"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu   = "true"
  }
}

# SNS Topic Subscription Resource
resource "aws_sns_topic_subscription" "app_server_email_subscription" {
  topic_arn = aws_sns_topic.app_server_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email_address
}

# CPU Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "high_cpu_utilization" {
  alarm_name          = "high-cpu-utilization-${aws_instance.app_server.id}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alarm when CPU exceeds 80%"
  actions_enabled     = "true"
  alarm_actions       = [aws_sns_topic.app_server_alerts.arn]

  dimensions = {
    InstanceId = aws_instance.app_server.id
  }

  # Tag the SNS topic resource with metadata for identification and management
  tags = {
    Name        = "AppServerAlarmCPU"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu   = "true"
  }
}

# Disk Read/Write Ops Alarm
resource "aws_cloudwatch_metric_alarm" "high_disk_usage" {
  alarm_name          = "high-disk-usage-${aws_instance.app_server.id}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "DiskWriteOps"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1000"
  alarm_description   = "Alarm when disk writes exceed 1000 ops"
  actions_enabled     = "true"
  alarm_actions       = [aws_sns_topic.app_server_alerts.arn]
  dimensions = {
    InstanceId = aws_instance.app_server.id
  }

  tags = {
    Name        = "AppServerAlarmDiskOps"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu   = "true"
  }
}

# Network In/Out Bytes Alarm
resource "aws_cloudwatch_metric_alarm" "unusual_network_activity" {
  alarm_name          = "unusual-network-activity-${aws_instance.app_server.id}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "NetworkIn"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Sum"
  threshold           = "10000000"  # 10 MB threshold. Adjust based on expected network traffic
  alarm_description   = "Alarm when network in exceeds 10 MB"
  actions_enabled     = "true"
  alarm_actions       = [aws_sns_topic.app_server_alerts.arn]
  dimensions = {
    InstanceId = aws_instance.app_server.id
  }

  tags = {
    Name        = "AppServerAlarmNetworkActivity"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu   = "true"
  }
}

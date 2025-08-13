data "aws_vpc" "default" {
  default = true
}

data "aws_availability_zones" "available" {
  state = "available"
  # Exclude known unsupported AZs for MSK
  exclude_names = ["us-east-1e"]
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "availability-zone"
    values = data.aws_availability_zones.available.names
  }
}

locals {
  selected_subnets = slice(data.aws_subnets.default.ids, 0, min(3, length(data.aws_subnets.default.ids)))
}

resource "aws_security_group" "msk_sg" {
  name        = "msk_sg"
  description = "Allow Kafka traffic"
  vpc_id      = data.aws_vpc.default.id

  # Kafka SASL_SSL (IAM authentication)
  ingress {
    from_port = 9098
    to_port   = 9098
    protocol  = "tcp"
    self      = true # Allow traffic from instances with the same security group
  }

  # Kafka TLS (if needed for other clients)
  ingress {
    from_port = 9094
    to_port   = 9094
    protocol  = "tcp"
    self      = true
  }

  # Zookeeper (for admin operations)
  ingress {
    from_port = 2181
    to_port   = 2181
    protocol  = "tcp"
    self      = true
  }

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Change this to a more restrictive CIDR block in production
  }

  # EC2 access
  ingress {
    from_port   = 9096
    to_port     = 9096
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Change this to a more restrictive CIDR block in production
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.default.cidr_block]
  }

  tags = {
    Name = "msk-security-group"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "msk_logs" {
  name              = "/aws/msk/loyalty-msk-cluster"
  retention_in_days = 7

  tags = {
    Name        = "msk-log-group"
    Project     = "real-time-loyalty-platform"
  }
}

resource "aws_msk_cluster" "this" {
  cluster_name           = var.cluster_name
  kafka_version          = "3.8.x"
  number_of_broker_nodes = var.number_of_broker_nodes
  broker_node_group_info {
    instance_type   = var.instance_type
    client_subnets  = local.selected_subnets
    security_groups = [aws_security_group.msk_sg.id]

    storage_info {
      ebs_storage_info {
        volume_size = var.broker_volume_size
      }
    }

  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.msk_logs.name
      }
    }
  }

  encryption_info {
    encryption_in_transit {
      client_broker = "TLS"
      in_cluster    = true
    }
  }
  client_authentication {
    sasl {
      scram = true
    }
  }

  tags = {
    Name        = var.cluster_name
    Environment = var.environment
    Project     = "real-time-loyalty-platform"
  }
}

# Create a Customer Managed KMS Key
resource "aws_kms_key" "msk_scram_kms" {
  description         = "KMS key for MSK SCRAM authentication secrets"
  deletion_window_in_days = 7
}

# Create the SCRAM Secret (must start with AmazonMSK_)
resource "aws_secretsmanager_secret" "msk_scram_secret" {
  name       = "AmazonMSK_msk_scram_secret"
  kms_key_id = aws_kms_key.msk_scram_kms.arn
}

# Add the username/password to the secret
resource "aws_secretsmanager_secret_version" "msk_scram_secret_version" {
  secret_id     = aws_secretsmanager_secret.msk_scram_secret.id
  secret_string = jsonencode({
    username = var.msk_scram_username
    password = var.msk_scram_password
  })
}

# Associate the secret with the MSK cluster
resource "aws_msk_scram_secret_association" "msk_scram_association" {
  cluster_arn     = aws_msk_cluster.this.arn
  secret_arn_list = [aws_secretsmanager_secret.msk_scram_secret.arn]
}
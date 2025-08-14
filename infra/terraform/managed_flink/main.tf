data "aws_vpc" "default" {
  default = true
}

# Data block to get MSK cluster bootstrap servers
data "aws_msk_bootstrap_brokers" "msk_brokers" {
  cluster_arn = var.msk_cluster_arn
}

# Data block to get MSK cluster details
data "aws_msk_cluster" "cluster" {
  cluster_name = var.msk_cluster_name
}

# Get subnet details to determine VPC
data "aws_subnet" "msk_subnets" {
  for_each = toset(var.private_subnet_ids)
  id       = each.value
}

# Get the VPC ID from one of the subnets
locals {
  vpc_id = values(data.aws_subnet.msk_subnets)[0].vpc_id
  subnet_ids = data.aws_msk_cluster.cluster.broker_node_group_info[0].client_subnets
  msk_security_group_ids = data.aws_msk_cluster.cluster.broker_node_group_info[0].security_groups
}

# Security group for Flink (add to your main configuration)
resource "aws_security_group" "flink_sg" {
  name_prefix = "${var.application_name}-${var.environment}-sg-"
  vpc_id      = local.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow access to MSK brokers (adjust ports as needed)
  egress {
    from_port       = 9096  # SASL_SSL port
    to_port         = 9096
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.application_name}-${var.environment}-sg"
    Environment = var.environment
  }
}

# IAM role for Flink application
resource "aws_iam_role" "flink_role" {
  name = "${var.application_name}-${var.environment}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "kinesisanalytics.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy for Flink application
resource "aws_iam_role_policy_attachment" "flink_vpc_policy" {
  role       = aws_iam_role.flink_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonKinesisAnalyticsFullAccess"
}


# IAM policy for Flink application
resource "aws_iam_role_policy" "flink_policy" {
  name = "${var.application_name}-${var.environment}-policy"
  role = aws_iam_role.flink_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kafka:DescribeCluster",
          "kafka:GetBootstrapBrokers",
          "kafka:DescribeClusterV2"
        ]
        Resource = var.msk_cluster_arn
      },
      {
        Effect = "Allow"
        Action = [
          "kafka-cluster:Connect",
          "kafka-cluster:AlterCluster",
          "kafka-cluster:DescribeCluster"
        ]
        Resource = var.msk_cluster_arn
      },
      {
        Effect = "Allow"
        Action = [
          "kafka-cluster:*Topic*",
          "kafka-cluster:WriteData",
          "kafka-cluster:ReadData"
        ]
        Resource = "${replace(var.msk_cluster_arn, "cluster/", "topic/")}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "kafka-cluster:AlterGroup",
          "kafka-cluster:DescribeGroup"
        ]
        Resource = "${replace(var.msk_cluster_arn, "cluster/", "group/")}/*"
      },
    ]
  })
}

# CloudWatch log group for Flink application
resource "aws_cloudwatch_log_group" "flink_log_group" {
  name              = "/aws/kinesis-analytics/${var.application_name}-${var.environment}"
  retention_in_days = 7
}

# CloudWatch log stream
resource "aws_cloudwatch_log_stream" "flink_log_stream" {
  name           = "kinesis-analytics-log-stream"
  log_group_name = aws_cloudwatch_log_group.flink_log_group.name
}

# Flink Application
resource "aws_kinesisanalyticsv2_application" "flink_app" {
  name                   = "${var.application_name}-${var.environment}"
  runtime_environment    = "FLINK-1_15"
  service_execution_role = aws_iam_role.flink_role.arn

  application_configuration {
    application_code_configuration {
      code_content_type = "ZIPFILE"
      # code_content {
      #   s3_content_location {
      #     bucket_arn = "arn:aws:s3:::your-flink-code-bucket"
      #     file_key   = "flink-app.jar"
      #   }
      # }
    }

    flink_application_configuration {
      checkpoint_configuration {
        configuration_type = "DEFAULT"
      }

      monitoring_configuration {
        configuration_type = "DEFAULT"
        log_level         = "INFO"
        metrics_level     = "APPLICATION"
      }

      parallelism_configuration {
        configuration_type = "DEFAULT"
        parallelism        = 1
        parallelism_per_kpu = 1
        auto_scaling_enabled = true
      }
    }

    vpc_configuration {
      security_group_ids = [aws_security_group.flink_sg.id]
      subnet_ids        = local.subnet_ids
    }

    environment_properties {
      property_group {
        property_group_id = "kafka.properties"
        property_map = {
          "bootstrap.servers" = data.aws_msk_bootstrap_brokers.msk_brokers.bootstrap_brokers_sasl_scram
          "security.protocol" = "SASL_SSL"
          "sasl.mechanism"    = "SCRAM-SHA-512"
          "sasl.jaas.config"  = "org.apache.kafka.common.security.scram.ScramLoginModule required username=\"${var.kafka_username}\" password=\"${var.kafka_password}\";"
        }
      }
    }
  }

  cloudwatch_logging_options {
    log_stream_arn = aws_cloudwatch_log_stream.flink_log_stream.arn
  }
}
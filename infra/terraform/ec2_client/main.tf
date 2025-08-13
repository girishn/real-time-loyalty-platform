# Get default VPC subnets (or pass as variables)
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Create security group in this module or pass as variable
resource "aws_security_group" "kafka_client_sg" {
  name_prefix = "kafka-client-"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "kafka-client-sg"
  }
}

resource "aws_instance" "kafka_client" {
  ami                         = var.kafka_client_ami
  instance_type               = var.kafka_client_instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.kafka_client_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = true
  key_name                    = aws_key_pair.msk_key.key_name

  user_data = <<-EOF
              #!/bin/bash
              exec > /var/log/user-data.log 2>&1
              set -x
              
              # Update system
              sudo yum update -y
              
              # Install Java
              sudo yum install java-11-amazon-corretto-devel -y
              
              # Set up Kafka
              KAFKA_VERSION=3.8.0
              KAFKA_SCALA_VERSION=2.13
              cd /home/ec2-user
              
              # Download and extract Kafka
              wget https://archive.apache.org/dist/kafka/$${KAFKA_VERSION}/kafka_$${KAFKA_SCALA_VERSION}-$${KAFKA_VERSION}.tgz
              tar -xzf kafka_$${KAFKA_SCALA_VERSION}-$${KAFKA_VERSION}.tgz
              
              # Set up MSK IAM authentication library
              cd kafka_$${KAFKA_SCALA_VERSION}-$${KAFKA_VERSION}/libs
              wget https://github.com/aws/aws-msk-iam-auth/releases/download/v2.3.2/aws-msk-iam-auth-2.3.2-all.jar
              
              # Change ownership to ec2-user
              chown -R ec2-user:ec2-user /home/ec2-user/kafka_$${KAFKA_SCALA_VERSION}-$${KAFKA_VERSION}
              
              echo "Kafka client installation completed"
              EOF

  tags = {
    Name = "kafka-client"
    Environment = var.environment
  }
}

resource "aws_key_pair" "msk_key" {
  key_name   = "msk-key"
  public_key = file("~/.ssh/msk-key.pub")
}

resource "aws_iam_role_policy" "ec2_scram_policy" {
  name = "ec2-scram-policy"
  role = aws_iam_role.ec2_kafka_iam_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = var.msk_scram_secret_arn
      }
    ]
  })
}

resource "aws_iam_role" "ec2_kafka_iam_role" {
  name = "kafka-client-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_kafka_profile"
  role = aws_iam_role.ec2_kafka_iam_role.name
}


# Data sources for dynamic values
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
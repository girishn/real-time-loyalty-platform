resource "aws_iam_role_policy" "ec2_scram_policy" {
  role = aws_iam_role.ec2_kafka_iam_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = aws_secretsmanager_secret.msk_scram_secret.arn
      }
    ]
  })
}

resource "aws_iam_role" "ec2_kafka_iam_role" {
  name = "ec2_kafka_iam_role"
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
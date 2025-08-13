resource "aws_instance" "kafka_client" {
  ami                         = var.kafka_client_ami
  instance_type               = var.kafka_client_instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.msk_sg.id]
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
    Name = "KafkaClientInstance"
    Environment = var.environment
  }
}
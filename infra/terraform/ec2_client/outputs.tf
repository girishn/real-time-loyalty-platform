output "ec2_public_ip" {
  value = aws_instance.kafka_client.public_ip
  description = "Public IP of the Kafka client EC2 instance"
}
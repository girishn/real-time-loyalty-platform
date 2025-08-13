output "msk_cluster_arn" {
  description = "MSK cluster ARN"
  value       = aws_msk_cluster.this.arn
}

output "bootstrap_brokers_tls" {
  description = "MSK cluster bootstrap servers"
  value       = aws_msk_cluster.this.bootstrap_brokers_sasl_scram
}

output "ec2_public_ip" {
  value = aws_instance.kafka_client.public_ip
  description = "Public IP of the Kafka client EC2 instance"
}
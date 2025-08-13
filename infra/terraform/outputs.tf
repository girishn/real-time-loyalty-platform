output "bootstrap_brokers_tls" {
  description = "MSK cluster bootstrap servers"
  value       = module.msk_cluster.bootstrap_brokers_tls
}

output "ec2_public_ip" {
  value = module.ec2_client.ec2_public_ip
  description = "Public IP of the Kafka client EC2 instance"
}
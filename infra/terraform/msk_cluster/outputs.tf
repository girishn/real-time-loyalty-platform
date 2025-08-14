output "msk_cluster_arn" {
  description = "MSK cluster ARN"
  value       = aws_msk_cluster.this.arn
}

output "msk_cluster_name" {
  description = "MSK cluster Name"
  value       = aws_msk_cluster.this.cluster_name
}

output "bootstrap_brokers_tls" {
  description = "MSK cluster bootstrap servers"
  value       = aws_msk_cluster.this.bootstrap_brokers_sasl_scram
}

output "msk_scram_secret_arn" {
  description = "ARN of the secret containing MSK SCRAM credentials"
  value       = aws_secretsmanager_secret.msk_scram_secret.arn
  sensitive   = true
}

output "private_subnet_ids" {
  value = local.selected_subnets
}

output "msk_security_group_id" {
  value = aws_security_group.msk_sg.id
}

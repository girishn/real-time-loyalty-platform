output "msk_cluster_arn" {
  description = "MSK cluster ARN"
  value       = aws_msk_cluster.this.arn
}

output "bootstrap_brokers_tls" {
  description = "MSK cluster bootstrap servers"
  value       = aws_msk_cluster.this.bootstrap_brokers_sasl_scram
}
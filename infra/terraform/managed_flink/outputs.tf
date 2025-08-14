output "flink_application_arn" {
  description = "ARN of the Flink application"
  value       = aws_kinesisanalyticsv2_application.flink_app.arn
}

output "flink_application_name" {
  description = "Name of the Flink application"
  value       = aws_kinesisanalyticsv2_application.flink_app.name
}

output "flink_role_arn" {
  description = "ARN of the Flink execution role"
  value       = aws_iam_role.flink_role.arn
}

output "flink_security_group_id" {
  description = "ID of the Flink security group"
  value       = aws_security_group.flink_sg.id
}

output "msk_bootstrap_servers" {
  description = "Bootstrap servers for the MSK cluster"
  value       = data.aws_msk_bootstrap_brokers.msk_brokers.bootstrap_brokers_sasl_scram
}
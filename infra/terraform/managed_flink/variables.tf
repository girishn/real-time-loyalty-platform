variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "application_name" {
  description = "Name of the Flink application"
  type        = string
  default     = "points-fraud-processor"
}

variable "msk_cluster_arn" {
  description = "ARN of the MSK cluster"
  type        = string
}

variable "msk_cluster_name" {
  description = "Name of the MSK cluster"
  type        = string
}

variable "kafka_username" {
  description = "Kafka SCRAM username"
  type        = string
}

variable "kafka_password" {
  description = "Kafka SCRAM password"
  type        = string
  sensitive   = true
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "msk_security_group_id" {}
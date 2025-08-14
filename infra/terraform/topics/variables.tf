variable "bootstrap_servers" {
  description = "MSK bootstrap server endpoints"
  type        = string
}

variable "kafka_username" {
  description = "Kafka SASL username"
  type        = string
  sensitive   = true
}

variable "kafka_password" {
  description = "Kafka SASL password"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}
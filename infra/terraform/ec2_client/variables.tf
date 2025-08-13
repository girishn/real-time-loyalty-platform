variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
  default     = "dev"
  
}

variable "kafka_client_ami" {
  description = "AMI ID for the Kafka client EC2 instance"
  type        = string
  default     = "ami-0de716d6197524dd9"
}

variable "kafka_client_instance_type" {
  description = "Instance type for the Kafka client EC2 instance"
  type        = string
  default     = "t3.micro"
}

variable "msk_scram_secret_arn" {
  description = "ARN of the MSK SCRAM secret"
  type        = string
}

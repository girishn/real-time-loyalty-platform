variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "msk_scram_username" {
  description = "Username for MSK SCRAM authentication"
  type        = string
  sensitive   = true
}

variable "msk_scram_password" {
  description = "Password for MSK SCRAM authentication"
  type        = string
  sensitive   = true
}

variable "cluster_name" {
  default = "loyalty-msk-cluster"
}

variable "instance_type" {
  default = "kafka.t3.small"
}

variable "number_of_broker_nodes" {
  description = "Number of broker nodes for the MSK cluster"
  type        = number
  default     = 3
}

variable "broker_volume_size" {
  description = "The size in GiB of the EBS volume for each broker node"
  type        = number
  default     = 100
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

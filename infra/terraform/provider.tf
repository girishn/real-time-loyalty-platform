terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    kafka = {
      source = "Mongey/kafka"
      version = "0.13.0"
    }
  }
}
provider "aws" {
  region = var.aws_region
}

provider "kafka" {
  bootstrap_servers = [var.bootstrap_servers]
  sasl_username     = var.kafka_username
  sasl_password     = var.kafka_password
  sasl_mechanism    = "scram-sha512"
  security_protocol = "sasl_ssl"
}
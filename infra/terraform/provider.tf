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
  bootstrap_servers = [module.msk_cluster.bootstrap_brokers_tls]
  sasl_username     = var.msk_scram_username
  sasl_password     = var.msk_scram_password
  sasl_mechanism    = "scram-sha512"
  tls_enabled = true
}
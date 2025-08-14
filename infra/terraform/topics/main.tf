provider "kafka" {
  bootstrap_servers = [var.bootstrap_servers]
  sasl_username     = var.kafka_username
  sasl_password     = var.kafka_password
  sasl_mechanism    = "scram-sha512"
  security_protocol = "sasl_ssl"
}

locals {
  topics_config = yamldecode(file("${path.root}/config/topics-${var.environment}.yaml"))
}

resource "kafka_topic" "topics" {
  for_each = { for topic in local.topics_config.topics : topic.name => topic }
  
  name               = each.value.name
  replication_factor = each.value.replication_factor
  partitions         = each.value.partitions
  
  config = each.value.config
}
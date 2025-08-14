terraform {
  required_providers {
    kafka = {
      source  = "Mongey/kafka"
      version = "~> 0.7"
    }
  }
}

locals {
  topics_config = yamldecode(file("${path.root}/config/topics-${var.environment}.yaml"))
}

resource "kafka_topic" "topics" {
  for_each = { for topic in local.topics_config.topics : topic.name => topic }
  
  name               = each.value.name
  replication_factor = each.value.replication_factor
  partitions         = each.value.partitions
  
  config = lookup(each.value, "config", null) != null ? each.value.config : {}
}
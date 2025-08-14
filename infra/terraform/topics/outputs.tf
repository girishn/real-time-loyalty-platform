output "topic_names" {
  description = "Names of created topics"
  value       = [for topic in kafka_topic.topics : topic.name]
}

output "topics_details" {
  description = "Details of created topics"
  value = {
    for name, topic in kafka_topic.topics : name => {
      name               = topic.name
      partitions         = topic.partitions
      replication_factor = topic.replication_factor
    }
  }
}

output "bootstrap_server" {
  value = confluent_kafka_cluster.standard.bootstrap_endpoint
}

output "kafka_cluster_api_key" {
  value = confluent_api_key.app_kafka_cluster_key.id
}

output "kafka_cluster_api_secret" {
  value = confluent_api_key.app_kafka_cluster_key.secret
  sensitive = true
}

output "schema_registry_api_key" {
  value = confluent_api_key.app_schema_registry_key.id
}

output "schema_registry_api_secret" {
  value = confluent_api_key.app_schema_registry_key.secret
  sensitive = true
}

output "schema_registry_rest_endpoint" {
  value = var.schema_registry_rest_endpoint
}

output "kafka_topics" {
  value = [
    confluent_kafka_topic.carga_sandbox_avro.topic_name,
    confluent_kafka_topic.resultados_carga_sandbox_avro_consumer.topic_name,
    confluent_kafka_topic.resultados_carga_sandbox_avro_producer.topic_name,
    confluent_kafka_topic.carga_sandbox_json.topic_name,
    confluent_kafka_topic.resultados_carga_sandbox_json_consumer.topic_name,
    confluent_kafka_topic.resultados_carga_sandbox_json_producer.topic_name
  ]
}

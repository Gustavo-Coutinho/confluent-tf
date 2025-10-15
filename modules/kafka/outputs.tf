
output "bootstrap_server" {
  value = confluent_kafka_cluster.basic.bootstrap_endpoint
}

output "producer_api_key" {
  value = confluent_api_key.producer_key.id
}

output "producer_api_secret" {
  value = confluent_api_key.producer_key.secret
  sensitive = true
}

output "consumer_api_key" {
  value = confluent_api_key.consumer_key.id
}

output "consumer_api_secret" {
  value = confluent_api_key.consumer_key.secret
  sensitive = true
}


output "bootstrap_server" {
  value = module.kafka_cluster.bootstrap_server
}

output "kafka_cluster_api_key" {
  value = module.kafka_cluster.kafka_cluster_api_key
}

output "kafka_cluster_api_secret" {
  value = module.kafka_cluster.kafka_cluster_api_secret
  sensitive = true
}

output "schema_registry_api_key" {
  value = module.kafka_cluster.schema_registry_api_key
}

output "schema_registry_api_secret" {
  value = module.kafka_cluster.schema_registry_api_secret
  sensitive = true
}

output "schema_registry_rest_endpoint" {
  value = module.kafka_cluster.schema_registry_rest_endpoint
}

# As secrets são ocultas por padrão
# Para visualizar os outputs, temos o comando: terraform output
# terraform output kafka_cluster_api_secret
# terraform output schema_registry_api_secret
# ou, para salvar num arquivo JSON: terraform output -json > outputs.json
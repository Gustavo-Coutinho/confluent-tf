
output "bootstrap_server" {
  value = module.kafka_cluster.bootstrap_server
}

output "producer_api_key" {
  value = module.kafka_cluster.producer_api_key
}

output "producer_api_secret" {
  value = module.kafka_cluster.producer_api_secret
  sensitive = true
}

output "consumer_api_key" {
  value = module.kafka_cluster.consumer_api_key
}

output "consumer_api_secret" {
  value = module.kafka_cluster.consumer_api_secret
  sensitive = true
}

# As secrets são ocultas por padrão
# Para visualizar os outputs, temos o comando: terraform output
# terraform output consumer_api_secret
# terraform output producer_api_secret
# ou, para salvar num arquivo JSON: terraform output -json > outputs.json
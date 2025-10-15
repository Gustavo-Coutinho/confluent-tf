
variable "confluent_cloud_api_key" {
  description = "The Confluent Cloud API key"
  type        = string
}
variable "confluent_cloud_api_secret" {
  description = "The Confluent Cloud API secret"
  type        = string
  sensitive   = true
}
variable "kafka_cluster_name" {
  description = "The name of the Kafka cluster"
  type        = string
  default     = "kafkacluster001"
}

variable "producer_user_name" {
  description = "The name of the producer user"
  type        = string
  default     = "producer"
}

variable "consumer_user_name" {
  description = "The name of the consumer user"
  type        = string
  default     = "consumer"
}
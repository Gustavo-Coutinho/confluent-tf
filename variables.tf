
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

variable "service_account_name" {
  description = "The name of the service account"
  type        = string
  default     = "app-service-account"
}

variable "aws_region" {
  description = "AWS region for Kafka cluster"
  type        = string
  default     = "sa-east-1"
}
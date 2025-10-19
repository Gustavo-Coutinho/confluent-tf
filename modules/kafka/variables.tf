variable "kafka_cluster_name" {
  description = "The name of the Kafka cluster"
  type        = string
}

variable "environment_id" {
  description = "The ID of the environment"
  type        = string
}

variable "service_account_name" {
  description = "The name of the service account"
  type        = string
}

variable "environment_crn" {
  description = "The CRN of the environment"
  type        = string
}

variable "schema_registry_id" {
  description = "The ID of the Schema Registry"
  type        = string
}

variable "schema_registry_rest_endpoint" {
  description = "The REST endpoint of the Schema Registry"
  type        = string
}

variable "aws_region" {
  description = "AWS region for Kafka cluster"
  type        = string
}

variable "confluent_cloud_api_key" {
  description = "The Confluent Cloud API key"
  type        = string
}

variable "confluent_cloud_api_secret" {
  description = "The Confluent Cloud API secret"
  type        = string
  sensitive   = true
}

variable "api_key_owner_id" {
  description = "Optional owner id (principal) to assign to created API keys. If empty the module's service account will be used."
  type        = string
  default     = ""
}

variable "api_key_owner_api_version" {
  description = "Optional api_version for the owner principal. If empty the service account api_version will be used."
  type        = string
  default     = ""
}

variable "api_key_owner_kind" {
  description = "Optional kind for the owner principal. If empty the service account kind will be used."
  type        = string
  default     = ""
}
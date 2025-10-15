variable "kafka_cluster_name" {
  description = "The name of the Kafka cluster"
  type        = string
}

variable "environment_id" {
  description = "The ID of the environment"
  type        = string
}

variable "producer_user_name" {
  description = "The name of the producer user"
  type        = string
}

variable "consumer_user_name" {
  description = "The name of the consumer user"
  type        = string
}

variable "environment_crn" {
  description = "The CRN of the environment"
  type        = string
}

terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "2.48.0"
    }
  }
}

provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

resource "confluent_environment" "carga_sandbox" {
  display_name = "CargaSandbox"
  stream_governance {
    package = "ADVANCED"
  }
}

module "kafka_cluster" {
  source                 = "./modules/kafka"
  kafka_cluster_name     = var.kafka_cluster_name
  environment_id         = confluent_environment.carga_sandbox.id
  producer_user_name     = var.producer_user_name
  consumer_user_name     = var.consumer_user_name
  environment_crn        = confluent_environment.carga_sandbox.resource_name
}

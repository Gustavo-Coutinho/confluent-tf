terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "2.48.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
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

# Sleep to allow Schema Registry to be provisioned
resource "time_sleep" "wait_for_schema_registry" {
  depends_on = [confluent_environment.carga_sandbox]
  create_duration = "30s"
}

data "confluent_schema_registry_cluster" "env_schema_registry" {
  environment {
    id = confluent_environment.carga_sandbox.id
  }
  depends_on = [time_sleep.wait_for_schema_registry]
}

module "kafka_cluster" {
  source                 = "./modules/kafka"
  kafka_cluster_name     = var.kafka_cluster_name
  environment_id         = confluent_environment.carga_sandbox.id
  service_account_name   = var.service_account_name
  environment_crn        = confluent_environment.carga_sandbox.resource_name
  schema_registry_id     = data.confluent_schema_registry_cluster.env_schema_registry.id
  schema_registry_rest_endpoint = data.confluent_schema_registry_cluster.env_schema_registry.rest_endpoint
  aws_region             = var.aws_region
  confluent_cloud_api_key    = var.confluent_cloud_api_key
  confluent_cloud_api_secret = var.confluent_cloud_api_secret
}

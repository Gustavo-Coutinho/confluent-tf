terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "2.48.0"
    }
  }
}

resource "confluent_kafka_cluster" "basic" {
  display_name = var.kafka_cluster_name
  availability = "SINGLE_ZONE"
  cloud        = "AWS"
  region       = "sa-east-1"
  basic {}
  environment {
    id = var.environment_id
  }
}

resource "confluent_service_account" "producer" {
  display_name = var.producer_user_name
  description  = "Service account for producer"
}

resource "confluent_service_account" "consumer" {
  display_name = var.consumer_user_name
  description  = "Service account for consumer"
}

resource "confluent_role_binding" "producer_environment_admin" {
  principal   = "User:${confluent_service_account.producer.id}"
  role_name   = "EnvironmentAdmin"
  crn_pattern = var.environment_crn
}

resource "confluent_role_binding" "consumer_environment_admin" {
  principal   = "User:${confluent_service_account.consumer.id}"
  role_name   = "EnvironmentAdmin"
  crn_pattern = var.environment_crn
}

resource "confluent_api_key" "producer_key" {
  display_name = "producer-key"
  description  = "API Key for producer"
  owner {
    id          = confluent_service_account.producer.id
    api_version = confluent_service_account.producer.api_version
    kind        = confluent_service_account.producer.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.basic.id
    api_version = confluent_kafka_cluster.basic.api_version
    kind        = confluent_kafka_cluster.basic.kind

    environment {
      id = var.environment_id
    }
  }
}

resource "confluent_api_key" "consumer_key" {
  display_name = "consumer-key"
  description  = "API Key for consumer"
  owner {
    id          = confluent_service_account.consumer.id
    api_version = confluent_service_account.consumer.api_version
    kind        = confluent_service_account.consumer.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.basic.id
    api_version = confluent_kafka_cluster.basic.api_version
    kind        = confluent_kafka_cluster.basic.kind

    environment {
      id = var.environment_id
    }
  }
}

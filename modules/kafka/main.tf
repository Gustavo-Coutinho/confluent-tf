terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "2.48.0"
    }
  }
}

resource "confluent_kafka_cluster" "standard" {
  display_name = var.kafka_cluster_name
  availability = "SINGLE_ZONE"
  cloud        = "AWS"
  region       = var.aws_region
  standard {}
  environment {
    id = var.environment_id
  }
}

resource "confluent_service_account" "app" {
  display_name = var.service_account_name
  description  = "Service account for Kafka applications"
}

resource "confluent_role_binding" "app_environment_admin" {
  principal   = "User:${confluent_service_account.app.id}"
  role_name   = "EnvironmentAdmin"
  crn_pattern = var.environment_crn
}

resource "confluent_role_binding" "app_cluster_admin" {
  principal   = "User:${confluent_service_account.app.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.standard.rbac_crn
}

# Kafka Topics
resource "confluent_kafka_topic" "carga_sandbox_avro" {
  depends_on = [confluent_role_binding.app_cluster_admin]

  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  topic_name    = "carga-sandbox-avro"
  partitions_count = 36
  rest_endpoint = confluent_kafka_cluster.standard.rest_endpoint
  config = {
    "max.message.bytes" = "8388608"      # 8 MB
    "retention.ms"      = "1814400000"    # 3 weeks (21 days)
    "retention.bytes"   = "-1"            # No size limit
  }
  credentials {
    key    = confluent_api_key.app_kafka_cluster_key.id
    secret = confluent_api_key.app_kafka_cluster_key.secret
  }
}

resource "confluent_kafka_topic" "resultados_carga_sandbox_avro_consumer" {
  depends_on = [confluent_role_binding.app_cluster_admin]

  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  topic_name    = "resultados-carga-sandbox-avro-consumer"
  partitions_count = 36
  rest_endpoint = confluent_kafka_cluster.standard.rest_endpoint
  config = {
    "max.message.bytes" = "8388608"      # 8 MB
    "retention.ms"      = "1814400000"    # 3 weeks (21 days)
    "retention.bytes"   = "-1"            # No size limit
  }
  credentials {
    key    = confluent_api_key.app_kafka_cluster_key.id
    secret = confluent_api_key.app_kafka_cluster_key.secret
  }
}

resource "confluent_kafka_topic" "resultados_carga_sandbox_avro_producer" {
  depends_on = [confluent_role_binding.app_cluster_admin]

  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  topic_name    = "resultados-carga-sandbox-avro-producer"
  partitions_count = 36
  rest_endpoint = confluent_kafka_cluster.standard.rest_endpoint
  config = {
    "max.message.bytes" = "8388608"      # 8 MB
    "retention.ms"      = "1814400000"    # 3 weeks (21 days)
    "retention.bytes"   = "-1"            # No size limit
  }
  credentials {
    key    = confluent_api_key.app_kafka_cluster_key.id
    secret = confluent_api_key.app_kafka_cluster_key.secret
  }
}

resource "confluent_kafka_topic" "carga_sandbox_json" {
  depends_on = [confluent_role_binding.app_cluster_admin]

  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  topic_name    = "carga-sandbox-json"
  partitions_count = 36
  rest_endpoint = confluent_kafka_cluster.standard.rest_endpoint
  config = {
    "max.message.bytes" = "8388608"      # 8 MB
    "retention.ms"      = "1814400000"    # 3 weeks (21 days)
    "retention.bytes"   = "-1"            # No size limit
  }
  credentials {
    key    = confluent_api_key.app_kafka_cluster_key.id
    secret = confluent_api_key.app_kafka_cluster_key.secret
  }
}

resource "confluent_kafka_topic" "resultados_carga_sandbox_json_consumer" {
  depends_on = [confluent_role_binding.app_cluster_admin]

  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  topic_name    = "resultados-carga-sandbox-json-consumer"
  partitions_count = 36
  rest_endpoint = confluent_kafka_cluster.standard.rest_endpoint
  config = {
    "max.message.bytes" = "8388608"      # 8 MB
    "retention.ms"      = "1814400000"    # 3 weeks (21 days)
    "retention.bytes"   = "-1"            # No size limit
  }
  credentials {
    key    = confluent_api_key.app_kafka_cluster_key.id
    secret = confluent_api_key.app_kafka_cluster_key.secret
  }
}

resource "confluent_kafka_topic" "resultados_carga_sandbox_json_producer" {
  depends_on = [confluent_role_binding.app_cluster_admin]

  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  topic_name    = "resultados-carga-sandbox-json-producer"
  partitions_count = 36
  rest_endpoint = confluent_kafka_cluster.standard.rest_endpoint
  config = {
    "max.message.bytes" = "8388608"      # 8 MB
    "retention.ms"      = "1814400000"    # 3 weeks (21 days)
    "retention.bytes"   = "-1"            # No size limit
  }
  credentials {
    key    = confluent_api_key.app_kafka_cluster_key.id
    secret = confluent_api_key.app_kafka_cluster_key.secret
  }
}

# API Key for Kafka Cluster
resource "confluent_api_key" "app_kafka_cluster_key" {
  display_name = "app-kafka-cluster-key"
  description  = "API Key for Kafka Cluster"
  owner {
    id          = confluent_service_account.app.id
    api_version = confluent_service_account.app.api_version
    kind        = confluent_service_account.app.kind
  }
  managed_resource {
    id          = confluent_kafka_cluster.standard.id
    api_version = confluent_kafka_cluster.standard.api_version
    kind        = confluent_kafka_cluster.standard.kind

    environment {
      id = var.environment_id
    }
  }
}

# API Key for Schema Registry
resource "confluent_api_key" "app_schema_registry_key" {
  display_name = "app-schema-registry-key"
  description  = "API Key for Schema Registry"
  owner {
    id          = confluent_service_account.app.id
    api_version = confluent_service_account.app.api_version
    kind        = confluent_service_account.app.kind
  }
  managed_resource {
    id          = var.schema_registry_id
    api_version = "srcm/v2"
    kind        = "Cluster"

    environment {
      id = var.environment_id
    }
  }
}

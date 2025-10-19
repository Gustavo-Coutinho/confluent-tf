# Projeto Terraform para Confluent Cloud

Este projeto utiliza o Terraform para provisionar recursos na Confluent Cloud de forma automatizada.

## Recursos Criados

O código está configurado para criar os seguintes recursos:

-   **Ambiente Confluent**: Um ambiente chamado `CargaSandbox` com o pacote de Governança de Dados "ADVANCED" habilitado.
-   **Cluster Kafka**: Um cluster Kafka chamado `kafkacluster001`.
    -   **Provedor de Nuvem**: AWS
    -   **Região**: `sa-east-1`
    -   **Tipo de Cluster**: Básico
-   **Contas de Serviço (RBAC)**: Duas contas de serviço (`producer` e `consumer`).
-   **Permissões**: Acesso de `EnvironmentAdmin` para as contas de serviço no ambiente `CargaSandbox`.
-   **Chaves de API**: Chaves de API e segredos para cada conta de serviço, permitindo a conexão com o cluster.

## Estrutura de Diretórios

```
.
├── main.tf                 # Arquivo principal que define o ambiente e chama o módulo
├── modules/                # Módulos Terraform reutilizáveis
│   └── kafka/
│       ├── main.tf         # Lógica do módulo para criar o cluster, contas de serviço e chaves
│       ├── outputs.tf      # Saídas do módulo
│       └── variables.tf    # Variáveis de entrada do módulo
├── outputs.tf              # Saídas do projeto (bootstrap server, chaves, etc.)
├── terraform.tfvars        # Arquivo para armazenar suas credenciais (NÃO FAÇA COMMIT)
└── variables.tf            # Variáveis de entrada do projeto
```

## Pré-requisitos

-   [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) instalado.
-   Uma conta na [Confluent Cloud](https://www.confluent.io/confluent-cloud/).
-   Uma chave de API da Confluent Cloud com permissões de `OrganizationAdmin`.

## Como Usar

1.  **Clone o repositório (se aplicável).**

2.  **Configure suas credenciais:**
    Crie um arquivo chamado `terraform.tfvars` e adicione sua chave e segredo da API da Confluent Cloud:

    ```hcl
    # terraform.tfvars

    confluent_cloud_api_key    = "SUA_CHAVE_DE_API"
    confluent_cloud_api_secret = "SEU_SEGREDO_DE_API"
    ```
    **Atenção:** Este arquivo contém informações sensíveis. Adicione-o ao seu `.gitignore` para evitar o commit acidental de credenciais.

3.  **Inicialize o Terraform:**
    Execute o comando abaixo para baixar os provedores necessários.

    ```sh
    terraform init
    ```

4.  **Planeje e Aplique as Configurações:**
    Execute o `apply` para que o Terraform crie os recursos na Confluent Cloud.

    ```sh
    terraform apply
    ```

    O Terraform mostrará um plano de execução e pedirá sua confirmação antes de fazer qualquer alteração.

## Saídas (Outputs)

Após a execução bem-sucedida, o Terraform exibirá as seguintes saídas:

-   `bootstrap_server`: O endpoint do servidor de bootstrap para se conectar ao cluster Kafka.
-   `producer_api_key`: A chave de API para a conta de serviço do produtor.
-   `consumer_api_key`: A chave de API para a conta de serviço do consumidor.

Os segredos das chaves de API são marcados como sensíveis e não são exibidos diretamente. Para visualizá-los, use o comando `terraform output`:

```sh
# Para ver o segredo do produtor
terraform output producer_api_secret

# Projeto Terraform para Confluent Cloud (atualizado)

Este repositório contém código Terraform que cria um ambiente completo na Confluent Cloud e recursos associados necessários para testes e integração:

- Ambiente Confluent chamado `CargaSandbox` com Stream Governance (pacote ADVANCED).
- Cluster Kafka gerenciado na Confluent Cloud.
- Schema Registry associado ao ambiente (provisionado pelo Stream Governance).
- Um Service Account (conta de serviço) para aplicações.
- Duas chaves de API gerenciadas:
  - API Key + Secret para o Kafka Cluster
  - API Key + Secret para o Schema Registry
- Seis tópicos Kafka criados automaticamente.

## Tópicos criados

O módulo cria os seguintes tópicos (configuração atual: 1 partição, 10 MB max message size, retenção 3 semanas):

- carga-sandbox-avro
- resultados-carga-sandbox-avro-consumer
- resultados-carga-sandbox-avro-producer
- carga-sandbox-json
- resultados-carga-sandbox-json-consumer
- resultados-carga-sandbox-json-producer

> Observação: reduzir o número de partições (por exemplo de 6 para 1) força a recriação dos tópicos e causa perda de dados. Faça backup se necessário.

## Estrutura de arquivos

```
confluent-tf/
├── main.tf                 # Raiz: provider, environment e chamada do módulo kafka
├── variables.tf            # Variáveis do root module (inclui aws_region)
├── terraform.tfvars        # Valores sensíveis e region (NÃO COMMITAR)
├── outputs.tf              # Saídas principais (bootstrap server, api keys, sr endpoint, tópicos)
└── modules/
    └── kafka/
        ├── main.tf         # Cria cluster, service account, role binding, topics e api keys
        ├── variables.tf    # Variáveis do módulo
        └── outputs.tf      # Saídas do módulo
```

## Variáveis importantes

- `confluent_cloud_api_key` e `confluent_cloud_api_secret` — credenciais da Confluent Cloud (Organization-level).
- `kafka_cluster_name` — nome do cluster Kafka (padrão: `kafkacluster001`).
- `service_account_name` — nome da conta de serviço criada (padrão: `app-service-account`).
- `aws_region` — região AWS para o cluster (padrão: `sa-east-1`). Defina no `terraform.tfvars` se quiser alterar.

Exemplo mínimo em `terraform.tfvars`:

```hcl
confluent_cloud_api_key    = "<SUA_API_KEY>"
confluent_cloud_api_secret = "<SEU_API_SECRET>"
aws_region = "sa-east-1"
```

## Como executar

1. Inicialize o Terraform:

```sh
terraform init
```

2. Planeje a execução:

```sh
terraform plan
```

3. Aplique (cria os recursos):

```sh
terraform apply
```

Para aplicar sem confirmação:

```sh
terraform apply -auto-approve
```

## Saídas e como visualizar segredos

Os outputs principais disponíveis após o `apply` (alguns são sensíveis):

- `bootstrap_server` — endpoint do Kafka (SASL_SSL://...)
- `kafka_cluster_api_key` e `kafka_cluster_api_secret` — API key/secret para conectar ao cluster Kafka
- `schema_registry_api_key` e `schema_registry_api_secret` — API key/secret para Schema Registry
- `schema_registry_rest_endpoint` — URL REST do Schema Registry
- `kafka_topics` — lista com os nomes dos tópicos criados

Por segurança, os segredos (API secrets) são marcados como sensíveis e não são impressos automaticamente no `terraform apply`. Para visualizá-los use:

```sh
terraform output kafka_cluster_api_secret
terraform output schema_registry_api_secret
```

Ou para exportar todos os outputs em JSON:

```sh
terraform output -json > outputs.json
```
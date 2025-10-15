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

# Para ver o segredo do consumidor
terraform output consumer_api_secret
```

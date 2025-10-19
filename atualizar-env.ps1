
# atualizar-env.ps1
# Este script atualiza o arquivo .env para a aplicação de teste de carga
# usando os outputs do módulo Terraform 'confluent-tf'.

# Obtém o diretório onde o script está localizado para construir caminhos relativos.
$scriptDir = $PSScriptRoot

# Caminho do arquivo de saída JSON do Terraform.
$tfOutputFile = Join-Path $scriptDir "confluent-tf.json"

# Atualiza os outputs do Terraform para garantir que o JSON esteja sempre atualizado.
Write-Host "Executando 'terraform output -json' para atualizar confluent-tf.json..."
Push-Location $scriptDir
try {
    terraform output -json | Out-File -FilePath $tfOutputFile -Encoding utf8
} finally {
    Pop-Location
}

# Torna o caminho do template .env dinâmico usando UserProfile
$userProfile = [Environment]::GetFolderPath("UserProfile")
$envTemplateFile = Join-Path $userProfile "Downloads\teste-carga-avro-vs-json\.env.template"
$envFile = Join-Path $userProfile "Downloads\teste-carga-avro-vs-json\.env"

# Verifica se o arquivo de saída do Terraform existe.
if (-not (Test-Path $tfOutputFile)) {
    Write-Error "Arquivo de saída do Terraform não encontrado em '$tfOutputFile'. Execute 'terraform output -json > confluent-tf.json' no diretório 'confluent-tf'."
    exit 1
}

# Lê o output do Terraform e converte de JSON.
$tfOutput = Get-Content -Path $tfOutputFile -Raw | ConvertFrom-Json

# Lê o conteúdo do arquivo .env.template como array de strings.
$envLines = Get-Content -Path $envTemplateFile

# Cria um novo array para armazenar as linhas atualizadas.
$newEnvLines = @()

# Itera sobre cada linha e substitui os valores se a chave corresponder.
foreach ($line in $envLines) {
    if ($line -match "^bootstrap_server=") {
        $newEnvLines += "bootstrap_server=" + $tfOutput.bootstrap_server.value
    } elseif ($line -match "^kafka_cluster_api_key=") {
        $newEnvLines += "kafka_cluster_api_key=" + $tfOutput.kafka_cluster_api_key.value
    } elseif ($line -match "^kafka_cluster_api_secret=") {
        $newEnvLines += "kafka_cluster_api_secret=" + $tfOutput.kafka_cluster_api_secret.value
    } elseif ($line -match "^schema_registry_rest_endpoint=") {
        $newEnvLines += "schema_registry_rest_endpoint=" + $tfOutput.schema_registry_rest_endpoint.value
    } elseif ($line -match "^schema_registry_api_key=") {
        $newEnvLines += "schema_registry_api_key=" + $tfOutput.schema_registry_api_key.value
    } elseif ($line -match "^schema_registry_api_secret=") {
        $newEnvLines += "schema_registry_api_secret=" + $tfOutput.schema_registry_api_secret.value
    } else {
        $newEnvLines += $line
    }
}

# Escreve o conteúdo atualizado no novo arquivo .env.
Set-Content -Path $envFile -Value $newEnvLines

Write-Host "Arquivo .env criado com sucesso em '$envFile'"

# --- Etapa de Validação ---
Write-Host "Validando o conteúdo do arquivo .env gerado..."
$envFinalContent = Get-Content -Path $envFile -Raw
Write-Host "--- Conteúdo do arquivo .env ---"
Write-Host $envFinalContent
Write-Host "-------------------------------"

# Verifica se todas as chaves foram preenchidas
$missingKeys = @()
if (($envFinalContent -split "`r?`n" | Where-Object { $_ -match "^kafka_cluster_api_key=" -and $_.EndsWith("=") })) { $missingKeys += "kafka_cluster_api_key" }
if (($envFinalContent -split "`r?`n" | Where-Object { $_ -match "^kafka_cluster_api_secret=" -and $_.EndsWith("=") })) { $missingKeys += "kafka_cluster_api_secret" }
if (($envFinalContent -split "`r?`n" | Where-Object { $_ -match "^schema_registry_api_key=" -and $_.EndsWith("=") })) { $missingKeys += "schema_registry_api_key" }
if (($envFinalContent -split "`r?`n" | Where-Object { $_ -match "^schema_registry_api_secret=" -and $_.EndsWith("=") })) { $missingKeys += "schema_registry_api_secret" }

if ($missingKeys.Count -gt 0) {
    Write-Error "Validação falhou! As seguintes chaves estão vazias no arquivo .env: $($missingKeys -join ', ')"
} else {
    Write-Host "Validação bem-sucedida! Todas as chaves parecem estar preenchidas."
}


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


# Escreve o conteúdo atualizado no novo arquivo .env local.
Set-Content -Path $envFile -Value $newEnvLines

Write-Host "Arquivo .env criado com sucesso em '$envFile'"

# --- Copia o .env para os servidores remotos via scp ---
$sshKey = "$userProfile/.oci/acesso_vm.key"

# Lê os IPs públicos do arquivo oci.json gerado pelo Terraform.
# Preferimos o arquivo no diretório oci-vm, com fallback para o diretório atual do script.
$ociJsonCandidates = @(
    (Join-Path ([Environment]::GetFolderPath("UserProfile")) "Documents\oci-vm\oci.json"),
    (Join-Path $scriptDir "oci.json")
)
$ociJsonFile = $ociJsonCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
$remoteIpValues = @()
if ($ociJsonFile) {
    try {
        $ociJson = Get-Content -Path $ociJsonFile -Raw | ConvertFrom-Json
        if ($null -ne $ociJson.public_ips -and $null -ne $ociJson.public_ips.value) {
            $remoteIpValues = @($ociJson.public_ips.value | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
        }
    } catch {
        Write-Warning "Não foi possível ler '$ociJsonFile'. Usando lista vazia de IPs remotos."
    }
} else {
    Write-Warning "Arquivo 'oci.json' não encontrado em '$($ociJsonCandidates -join ', ')'. Nenhum upload remoto será feito."
}

$remotePaths = @()
foreach ($ip in $remoteIpValues) {
    $remotePaths += @{ host = $ip; path = "/home/ubuntu/teste-carga-avro-vs-json/.env" }
}

if ($remotePaths.Count -eq 0) {
    Write-Warning "Nenhum IP público encontrado no arquivo oci.json. O arquivo .env foi gerado localmente, mas nenhum scp será executado."
}

foreach ($remote in $remotePaths) {
    $remoteHost = $remote.host
    $path = $remote.path
    Write-Host ("Copiando .env para ubuntu@{0}:{1} ..." -f $remoteHost, $path)
    $destino = "ubuntu@${remoteHost}:$path"
    $scpArgs = @("-i", $sshKey, "-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null", $envFile, $destino)
    $scpResult = & scp @scpArgs 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host ".env copiado com sucesso para $remoteHost"
    } else {
        Write-Error ("Falha ao copiar .env para {0}: {1}" -f $remoteHost, $scpResult)
    }
}

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

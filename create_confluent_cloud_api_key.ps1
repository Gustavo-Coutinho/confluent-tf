<#
Creates a Confluent Cloud "cloud resource management" API key using confluent CLI
and writes terraform.tfvars.

Requires: confluent CLI installed and logged in; run 'confluent environment use <env-id>' if needed.
#>

param(
    [string]$Description = "terraform-api-key",
    [string]$TfvarsPath = ".\terraform.tfvars"
)

function Try-ParseJson {
    param([string]$s)
    try { return $s | ConvertFrom-Json -ErrorAction Stop } catch { return $null }
}

Write-Host "Creating Confluent Cloud resource-management API key..."

# Call CLI with proper argument array
$out = & confluent api-key create --resource cloud -o json --description $Description 2>&1
$outStr = $out | Out-String
$json = Try-ParseJson -s $outStr

if (-not $json) {
    Write-Error "CLI did not return JSON. Output:`n$outStr"
    exit 1
}

$newKey    = $json.api_key
$newSecret = $json.api_secret

if (-not $newKey -or -not $newSecret) {
    Write-Error "Failed to extract api_key/api_secret. JSON:`n$outStr"
    exit 1
}

Write-Host "API key created: $newKey"
Write-Host ("Secret preview: {0}..." -f $newSecret.Substring(0, [Math]::Min(6, $newSecret.Length)))

# Write terraform.tfvars
$lines = @()
$lines += "confluent_cloud_api_key = `"$newKey`""
$lines += "confluent_cloud_api_secret = `"$newSecret`""

if (Test-Path $TfvarsPath) {
    Add-Content -Path $TfvarsPath -Value "`n# Added on $(Get-Date -Format o)`n"
    Add-Content -Path $TfvarsPath -Value ($lines -join "`n")
    Write-Host "Appended API key and secret to $TfvarsPath"
} else {
    Set-Content -Path $TfvarsPath -Value ($lines -join "`n")
    Write-Host "Created $TfvarsPath with API key and secret"
}

Write-Host "Done. Do not commit terraform.tfvars to source control."

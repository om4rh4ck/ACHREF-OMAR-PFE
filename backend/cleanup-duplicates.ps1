param()
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$cleanupFile = Join-Path $root "db\cleanup-duplicates.sql"
if (!(Test-Path $cleanupFile)) { throw "File not found: $cleanupFile" }
Write-Host "Suppression des doublons (offres + candidatures)..."
Get-Content -Raw $cleanupFile | docker exec -i vermeg-postgres psql -U vermeg -d vermeg_sirh -v ON_ERROR_STOP=1
Write-Host "Nettoyage termine."

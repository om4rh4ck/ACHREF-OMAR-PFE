param()

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$seedFile = Join-Path $root "db\seed.sql"

if (!(Test-Path $seedFile)) {
  throw "Seed file not found: $seedFile"
}

Write-Host "Applying seed data to PostgreSQL container vermeg-postgres..."
Get-Content -Raw $seedFile | docker exec -i vermeg-postgres psql -U vermeg -d vermeg_sirh -v ON_ERROR_STOP=1
Write-Host "Seed completed."

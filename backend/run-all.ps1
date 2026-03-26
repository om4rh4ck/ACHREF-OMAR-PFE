param(
  [switch]$StartInfra
)

$root = Split-Path -Parent $MyInvocation.MyCommand.Path

# Utiliser mvnw.cmd si Maven n'est pas dans le PATH
$mvnCmd = if (Get-Command mvn -ErrorAction SilentlyContinue) { 'mvn' } else { '.\mvnw.cmd' }
$mavenRepo = Join-Path $env:USERPROFILE '.m2\repository'
$mvnOpts = "-Dmaven.repo.local=$mavenRepo"

if ($StartInfra) {
  Write-Host 'Démarrage de Postgres et Keycloak (Docker)...'
  docker compose -f (Join-Path $root 'docker-compose.yml') up -d
  if ($LASTEXITCODE -ne 0) {
    Write-Host 'Erreur: Docker na pas pu demarrer. Lancez Docker Desktop puis relancez ce script.' -ForegroundColor Red
    exit 1
  }
  Write-Host 'Attente du demarrage de Postgres (15 s)...'
  Start-Sleep -Seconds 15
}

Write-Host "Lancement des microservices avec: $mvnCmd (MAVEN_OPTS=$mvnOpts)"
Start-Process powershell -ArgumentList '-NoExit','-Command',"`$env:MAVEN_OPTS='$mvnOpts'; cd '$root\api-gateway'; & $mvnCmd spring-boot:run"
Start-Process powershell -ArgumentList '-NoExit','-Command',"`$env:MAVEN_OPTS='$mvnOpts'; cd '$root\employee-service'; & $mvnCmd spring-boot:run"
Start-Process powershell -ArgumentList '-NoExit','-Command',"`$env:MAVEN_OPTS='$mvnOpts'; cd '$root\recruitment-service'; & $mvnCmd spring-boot:run"
Start-Process powershell -ArgumentList '-NoExit','-Command',"`$env:MAVEN_OPTS='$mvnOpts'; cd '$root\approval-service'; & $mvnCmd spring-boot:run"

Write-Host '4 fenetres PowerShell ont ete ouvertes (api-gateway 8081, employee 8082, recruitment 8083, approval 8084).'
Write-Host 'Attendez que chaque service affiche "Started ..." avant dutiliser le frontend.'

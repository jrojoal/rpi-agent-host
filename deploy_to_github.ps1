<#
.SYNOPSIS
  Automatitza la creació i pujada del projecte actual a GitHub.
.DESCRIPTION
  Detecta automàticament el nom del directori actual, crea el repo a GitHub i fa push inicial.
.AUTHOR
  Pep Rojo
.VERSION
  1.3 - Novembre 2025
#>

param(
    [string]$Description = "Agent Host Python per interactuar amb una Raspberry Pi via SSH",
    [string]$License = "MIT"
)

# Funcions per mostrar missatges amb color
function Info($msg) { Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Ok($msg)   { Write-Host "[OK]   $msg" -ForegroundColor Green }
function Warn($msg) { Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Err($msg)  { Write-Host "[ERR]  $msg" -ForegroundColor Red }

# Detectar nom del projecte segons el directori actual
$CurrentDir = Split-Path -Leaf (Get-Location)
$ProjectName = $CurrentDir

Info "Projecte detectat: $ProjectName"

# 1️⃣ Comprovar si gh està instal·lat
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Err "El CLI de GitHub (gh) no està instal·lat o no és al PATH."
    Info "Instal·la'l amb: winget install --id GitHub.cli"
    exit 1
}

# 2️⃣ Iniciar repositori Git si cal
if (-not (Test-Path ".git")) {
    Info "Inicialitzant repositori Git..."
    git init | Out-Null
    git add . | Out-Null
    git commit -m "Initial commit - $ProjectName" | Out-Null
} else {
    Info "Repositori Git ja existeix, saltant inicialització."
}

# 3️⃣ Preguntar usuari de GitHub
$GitUser = Read-Host "Introdueix el teu nom d'usuari de GitHub"

# 4️⃣ Crear el repositori remot
Info "Creant repositori remot a GitHub..."
try {
    gh repo create "$GitUser/$ProjectName" --public --description "$Description" --license "$License" --confirm | Out-Null
}
catch {
    Err "Error creant el repositori. Potser ja existeix o tens problemes d'autenticació."
}

# 5️⃣ Configurar remot i fer push inicial
Info "Fent push inicial a GitHub..."
git branch -M main
git remote remove origin -ErrorAction SilentlyContinue | Out-Null
git remote add origin "https://github.com/$GitUser/$ProjectName.git"
git push -u origin main | Out-Null

Ok "Projecte pujat correctament!"
Write-Host "URL del repositori: https://github.com/$GitUser/$ProjectName" -ForegroundColor White

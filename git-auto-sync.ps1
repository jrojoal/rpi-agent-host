<#
Autor: Pep Rojo
Entorn: DevOps / Windows / PowerShell 7+
Fitxer: git-auto-sync.ps1
Descripció:
    Sincronitza automàticament un repositori Git local amb el remot (GitHub o similar).
    Detecta canvis locals, fa commit, pull amb rebase i push automàticament.
#>

param (
    [string]$CommitMessage = "Auto-sync commit by Pep Rojo"
)

function Info($msg)  { Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Ok($msg)    { Write-Host "[OK]   $msg" -ForegroundColor Green }
function Warn($msg)  { Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Err($msg)   { Write-Host "[ERR]  $msg" -ForegroundColor Red }

# Comprova que sigui un repo Git
if (-not (Test-Path ".git")) {
    Err "Aquest directori no és un repositori Git. Inicialitza'l amb 'git init'."
    exit 1
}

# Mostra el nom del projecte
$repoName = Split-Path -Leaf (Get-Location)
Info "Repositori detectat: $repoName"

# Mostra la branca actual
$branch = git rev-parse --abbrev-ref HEAD
Info "Branca actual: $branch"

# Comprova canvis pendents
$changes = git status --porcelain
if ($changes) {
    Info "S'han detectat canvis locals. Afegint i fent commit..."
    git add .
    git commit -m "$CommitMessage"
} else {
    Warn "No hi ha canvis nous per commitejar."
}

# Pull amb rebase per mantenir històric net
Info "Fent 'git pull --rebase'..."
git pull --rebase origin $branch --allow-unrelated-histories

if ($LASTEXITCODE -ne 0) {
    Err "Conflictes durant el rebase. Revisa manualment abans de continuar."
    exit 1
}

# Push final
Info "Fent 'git push' al remot..."
git push origin $branch

if ($LASTEXITCODE -eq 0) {
    Ok "Repositori sincronitzat correctament amb GitHub! 🎉"
} else {
    Err "Error en el push. Comprova la connexió o permisos."
}

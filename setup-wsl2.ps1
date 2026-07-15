# ============================================
# FIT AI COACH - Instalacao WSL2 + Docker
# ============================================
# EXECUTE COMO ADMINISTRADOR (Right-click > Run as Administrator)
# Requer reboot apos execucao
# ============================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  FIT AI COACH - Instalacao WSL2 + Docker" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar se esta rodando como Admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERRO: Execute este script como Administrador!" -ForegroundColor Red
    Write-Host "Clique com botao direito > Run as Administrator" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "[1/5] Habilitando WSL..." -ForegroundColor Yellow
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

Write-Host "[2/5] Habilitando Virtual Machine Platform..." -ForegroundColor Yellow
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

Write-Host "[3/5] Definindo WSL 2 como padrao..." -ForegroundColor Yellow
wsl --set-default-version 2

Write-Host "[4/5] Baixando atualizacao do kernel WSL2..." -ForegroundColor Yellow
Write-Host "  (Abrira o Windows Update automaticamente)" -ForegroundColor Gray
wsl --update

Write-Host "[5/5] Instalando Docker Desktop..." -ForegroundColor Yellow
Write-Host "  Se ja tem Docker Desktop, ignore esta etapa." -ForegroundColor Gray

# Verificar se Docker Desktop ja esta instalado
$dockerPath = "C:\Program Files\Docker\Docker\Docker Desktop.exe"
if (Test-Path $dockerPath) {
    Write-Host "  Docker Desktop ja instalado!" -ForegroundColor Green
} else {
    Write-Host "  Baixe Docker Desktop manualmente:" -ForegroundColor Yellow
    Write-Host "  https://docs.docker.com/desktop/install/windows-install/" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  INSTALACAO CONCLUIDA!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "PROXIMOS PASSOS:" -ForegroundColor Yellow
Write-Host "  1. REINICIE O COMPUTADOR agora" -ForegroundColor White
Write-Host "  2. Abra o Docker Desktop apos o reboot" -ForegroundColor White
Write-Host "  3. Execute: docker-compose up -d" -ForegroundColor White
Write-Host "  4. Acesse: http://localhost:3000/docs" -ForegroundColor White
Write-Host ""
Write-Host "Para testar o WSL2 apos o reboot:" -ForegroundColor Cyan
Write-Host "  wsl --list --verbose" -ForegroundColor White
Write-Host "  wsl --list --online" -ForegroundColor White
Write-Host ""

pause

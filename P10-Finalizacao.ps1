# ==========================================
# P13 - Finalização
# ==========================================

$ErrorActionPreference = 'Stop'

try {
    Clear-Host

    Write-Host ""
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "      Senhor Contábil - Processamento Finalizado" -ForegroundColor Green
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "As etapas foram processadas pelo orquestrador." -ForegroundColor Yellow
    Write-Host "Consulte o resumo no terminal e em:"
    Write-Host "  C:\ProgramData\SenhorContabil\status.log"
    Write-Host ""

    # Limpa temporários utilizados pelos scripts
    Get-ChildItem "$env:TEMP" -Filter "RustDesk*" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    Get-ChildItem "$env:TEMP" -Filter "Ninite*" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

    Write-Host "Arquivos temporários removidos." -ForegroundColor Green
    Write-Host ""

    do {
        $resp = Read-Host "Deseja reiniciar o computador agora? (S/N)"
    } until ($resp -match '^[SsNn]$')

    if ($resp -match '^[Ss]$') {
        Write-Host ""
        Write-Host "Reiniciando em 10 segundos..." -ForegroundColor Yellow
        Start-Sleep -Seconds 10
        Restart-Computer -Force
    }
    else {
        Write-Host ""
        Write-Host "Reinicialização cancelada." -ForegroundColor Yellow
        Write-Host "Lembre-se de reiniciar o computador posteriormente." -ForegroundColor Yellow
    }
}
catch {
    Write-Error $_
}

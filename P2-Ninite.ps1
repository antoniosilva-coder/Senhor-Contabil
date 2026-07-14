Write-Host "== Baixando Ninite =="

$NiniteUrl = "https://raw.githubusercontent.com/antoniosilva-coder/Contabil_Default/main/Ninite-SenhorContabil.exe"
$NiniteExe = Join-Path $env:TEMP "Ninite-SenhorContabil.exe"

Invoke-WebRequest `
    -Uri $NiniteUrl `
    -OutFile $NiniteExe `
    -UseBasicParsing

Write-Host "== Instalando programas =="

Start-Process `
    -FilePath $NiniteExe `
    -Wait

Write-Host "Ninite finalizado."
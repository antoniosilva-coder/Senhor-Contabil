Write-Host "== Baixando Ninite =="

$NiniteUrl = "https://raw.githubusercontent.com/antoniosilva-coder/Contabil_Default/main/Ninite-SenhorContabil.exe"
$NiniteExe = Join-Path $env:TEMP "Ninite-SenhorContabil.exe"

try {
    Invoke-WebRequest `
        -Uri $NiniteUrl `
        -OutFile $NiniteExe `
        -UseBasicParsing `
        -ErrorAction Stop
}
catch {
    throw "Falha ao baixar o Ninite em '$NiniteUrl'. Erro: $($_.Exception.Message)"
}

if (-not (Test-Path $NiniteExe)) {
    throw "O download foi concluído, mas o arquivo não foi encontrado em '$NiniteExe'."
}

Write-Host "== Instalando programas =="

Start-Process `
    -FilePath $NiniteExe `
    -Wait

Write-Host "Ninite finalizado."

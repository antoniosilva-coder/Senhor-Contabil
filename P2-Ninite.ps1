$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Write-Host "== Baixando Ninite =="

$RepoOwner = if ($env:SENHOR_CONTABIL_REPO_OWNER) {
    $env:SENHOR_CONTABIL_REPO_OWNER
}
else {
    "antoniosilva-coder"
}

$RepoName = if ($env:SENHOR_CONTABIL_REPO_NAME) {
    $env:SENHOR_CONTABIL_REPO_NAME
}
else {
    "Senhor-Contabil"
}

$RepositoryRef = if ($env:SENHOR_CONTABIL_REPO_REF) {
    $env:SENHOR_CONTABIL_REPO_REF
}
else {
    "main"
}

$NiniteUrl = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$RepositoryRef/Ninite-SenhorContabil.exe"
$NiniteExe = Join-Path $env:TEMP "Ninite-SenhorContabil.exe"

[Net.ServicePointManager]::SecurityProtocol = (
    [Net.ServicePointManager]::SecurityProtocol -bor
    [Net.SecurityProtocolType]::Tls12
)

try {
    Remove-Item -LiteralPath $NiniteExe -Force -ErrorAction SilentlyContinue

    Invoke-WebRequest `
        -Uri $NiniteUrl `
        -OutFile $NiniteExe `
        -UseBasicParsing `
        -TimeoutSec 180 `
        -ErrorAction Stop
}
catch {
    throw "Falha ao baixar o Ninite em '$NiniteUrl'. Erro: $($_.Exception.Message)"
}

if (-not (Test-Path -LiteralPath $NiniteExe -PathType Leaf)) {
    throw "O download terminou, mas '$NiniteExe' nao foi criado."
}

if ((Get-Item -LiteralPath $NiniteExe).Length -le 0) {
    throw "O instalador do Ninite foi baixado vazio."
}

Unblock-File -LiteralPath $NiniteExe -ErrorAction SilentlyContinue

Write-Host "== Instalando programas =="

$process = Start-Process `
    -FilePath $NiniteExe `
    -PassThru `
    -Wait

if ($process.ExitCode -ne 0) {
    throw "O Ninite retornou o codigo $($process.ExitCode)."
}

Write-Host "Ninite finalizado."

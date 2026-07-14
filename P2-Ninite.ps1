$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Write-Host "== Preparando Ninite =="

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

$WorkDir = "C:\ProgramData\SenhorContabil"
$NiniteDir = Join-Path $WorkDir "ninite"
$NiniteTemp = Join-Path $NiniteDir "temp"
$NiniteExe = Join-Path $NiniteDir "Ninite-SenhorContabil.exe"
$NiniteUrl = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$RepositoryRef/Ninite-SenhorContabil.exe"

New-Item -ItemType Directory -Path $NiniteDir -Force | Out-Null
New-Item -ItemType Directory -Path $NiniteTemp -Force | Out-Null

$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent().Name
$permission = "${currentUser}:(OI)(CI)M"

& "$env:SystemRoot\System32\icacls.exe" `
    $NiniteDir `
    "/grant:r" `
    $permission `
    "/T" `
    "/C" `
    "/Q" | Out-Null

if ($LASTEXITCODE -ne 0) {
    throw "Nao foi possivel preparar as permissoes da pasta '$NiniteDir'."
}

[Net.ServicePointManager]::SecurityProtocol = (
    [Net.ServicePointManager]::SecurityProtocol -bor
    [Net.SecurityProtocolType]::Tls12
)

try {
    Remove-Item -LiteralPath $NiniteExe -Force -ErrorAction SilentlyContinue

    Write-Host "Baixando o Ninite para $NiniteDir..."

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

$originalTemp = $env:TEMP
$originalTmp = $env:TMP

try {
    $env:TEMP = $NiniteTemp
    $env:TMP = $NiniteTemp

    Write-Host "== Instalando programas =="
    Write-Host "Temporarios do Ninite: $NiniteTemp"

    $process = Start-Process `
        -FilePath $NiniteExe `
        -WorkingDirectory $NiniteDir `
        -PassThru `
        -Wait

    if ($process.ExitCode -ne 0) {
        throw "O Ninite retornou o codigo $($process.ExitCode)."
    }
}
finally {
    $env:TEMP = $originalTemp
    $env:TMP = $originalTmp
}

Write-Host "Ninite finalizado."

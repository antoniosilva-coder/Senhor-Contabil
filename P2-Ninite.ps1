#Requires -Version 5.1

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

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

$ExpectedHash = "DE82BA9D11920E7182C94E51027F2187878D8D7BB76FE05CA13A3388FFBBB86E"
$NiniteUrl = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$RepositoryRef/Ninite-SenhorContabil.exe"
$NiniteDir = "C:\ProgramData\SenhorContabil\ninite"
$NiniteExe = Join-Path $NiniteDir "Ninite-SenhorContabil.exe"

[Net.ServicePointManager]::SecurityProtocol = (
    [Net.ServicePointManager]::SecurityProtocol -bor
    [Net.SecurityProtocolType]::Tls12
)

Write-Host "== Preparando pasta do Ninite =="

New-Item -ItemType Directory -Path $NiniteDir -Force | Out-Null

$currentSid = [Security.Principal.WindowsIdentity]::GetCurrent().User.Value

& icacls.exe $NiniteDir /inheritance:e | Out-Null
& icacls.exe $NiniteDir /grant:r `
    "*S-1-5-18:(OI)(CI)F" `
    "*S-1-5-32-544:(OI)(CI)F" `
    "*$($currentSid):(OI)(CI)F" | Out-Null

if ($LASTEXITCODE -ne 0) {
    throw "Nao foi possivel ajustar as permissoes da pasta '$NiniteDir'."
}

Write-Host "== Baixando Ninite =="

$lastError = $null

for ($attempt = 1; $attempt -le 3; $attempt++) {
    try {
        Remove-Item -LiteralPath $NiniteExe -Force -ErrorAction SilentlyContinue

        Invoke-WebRequest `
            -Uri $NiniteUrl `
            -OutFile $NiniteExe `
            -UseBasicParsing `
            -TimeoutSec 180 `
            -ErrorAction Stop

        $lastError = $null
        break
    }
    catch {
        $lastError = $_.Exception
        Remove-Item -LiteralPath $NiniteExe -Force -ErrorAction SilentlyContinue

        if ($attempt -lt 3) {
            Start-Sleep -Seconds 3
        }
    }
}

if ($null -ne $lastError) {
    throw "Falha ao baixar o Ninite em '$NiniteUrl'. Erro: $($lastError.Message)"
}

if (-not (Test-Path -LiteralPath $NiniteExe -PathType Leaf)) {
    throw "O download terminou, mas '$NiniteExe' nao foi criado."
}

if ((Get-Item -LiteralPath $NiniteExe).Length -le 0) {
    throw "O instalador do Ninite foi baixado vazio."
}

$ActualHash = (Get-FileHash -LiteralPath $NiniteExe -Algorithm SHA256).Hash

if ($ActualHash -ne $ExpectedHash) {
    Remove-Item -LiteralPath $NiniteExe -Force -ErrorAction SilentlyContinue
    throw "Hash divergente do Ninite. Esperado: $ExpectedHash | Obtido: $ActualHash"
}

Unblock-File -LiteralPath $NiniteExe -ErrorAction SilentlyContinue

Write-Host "== Instalando programas =="

$process = Start-Process `
    -FilePath $NiniteExe `
    -WorkingDirectory $NiniteDir `
    -PassThru `
    -Wait

if ($process.ExitCode -ne 0) {
    throw "O Ninite retornou o codigo $($process.ExitCode)."
}

Write-Host "Ninite finalizado." -ForegroundColor Green

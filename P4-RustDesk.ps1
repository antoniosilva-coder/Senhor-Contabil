$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

function Get-InstalledRustDesk {
    $uninstallPaths = @(
        "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    foreach ($path in $uninstallPaths) {
        $app = Get-ItemProperty -Path $path -ErrorAction SilentlyContinue |
            Where-Object { $_.DisplayName -like "RustDesk*" } |
            Select-Object -First 1

        if ($null -ne $app) {
            return $app
        }
    }

    return $null
}

try {
    Write-Host "== Verificando RustDesk =="

    $installedApp = Get-InstalledRustDesk
    $runningProcess = Get-Process -Name "rustdesk" -ErrorAction SilentlyContinue |
        Select-Object -First 1

    $installedExe = Join-Path $env:ProgramFiles "RustDesk\rustdesk.exe"

    if (
        ($null -ne $installedApp) -or
        ($null -ne $runningProcess) -or
        (Test-Path -LiteralPath $installedExe -PathType Leaf)
    ) {
        $installedVersion = $installedApp.DisplayVersion

        if ($installedVersion) {
            Write-Host "RustDesk ja esta instalado (versao $installedVersion). Etapa ignorada." -ForegroundColor Green
        }
        else {
            Write-Host "RustDesk ja esta instalado ou em execucao. Etapa ignorada." -ForegroundColor Green
        }

        exit 0
    }

    Write-Host "== Instalando RustDesk =="

    [Net.ServicePointManager]::SecurityProtocol = (
        [Net.ServicePointManager]::SecurityProtocol -bor
        [Net.SecurityProtocolType]::Tls12
    )

    $headers = @{
        "User-Agent" = "SenhorContabil-PowerShell"
        "Accept" = "application/vnd.github+json"
    }

    Write-Host "Consultando a versao mais recente..."

    $release = Invoke-RestMethod `
        -Uri "https://api.github.com/repos/rustdesk/rustdesk/releases/latest" `
        -Headers $headers `
        -TimeoutSec 30 `
        -ErrorAction Stop

    $asset = $release.assets |
        Where-Object { $_.name -match "^rustdesk-.*-x86_64\.msi$" } |
        Select-Object -First 1

    if ($null -eq $asset) {
        throw "O pacote MSI x64 do RustDesk nao foi encontrado na versao mais recente."
    }

    $installerPath = Join-Path $env:TEMP "RustDesk-x64.msi"
    $installLog = "C:\ProgramData\SenhorContabil\RustDesk-install.log"

    Remove-Item -LiteralPath $installerPath -Force -ErrorAction SilentlyContinue

    Write-Host "Baixando $($asset.name)..."

    Invoke-WebRequest `
        -Uri $asset.browser_download_url `
        -OutFile $installerPath `
        -Headers $headers `
        -UseBasicParsing `
        -TimeoutSec 300 `
        -ErrorAction Stop

    if (-not (Test-Path -LiteralPath $installerPath -PathType Leaf)) {
        throw "O download terminou, mas o instalador nao foi criado."
    }

    if ((Get-Item -LiteralPath $installerPath).Length -le 0) {
        throw "O instalador do RustDesk foi baixado vazio."
    }

    Unblock-File -LiteralPath $installerPath -ErrorAction SilentlyContinue

    Write-Host "Instalando RustDesk silenciosamente..."

    $msiArguments = "/i `"$installerPath`" /qn /norestart CREATEDESKTOPSHORTCUTS=`"N`" CREATESTARTMENUSHORTCUTS=`"Y`" INSTALLPRINTER=`"N`" /l*v `"$installLog`""

    $process = Start-Process `
        -FilePath "$env:SystemRoot\System32\msiexec.exe" `
        -ArgumentList $msiArguments `
        -PassThru

    $timeoutSeconds = 300
    $finished = $process.WaitForExit($timeoutSeconds * 1000)

    if (-not $finished) {
        Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
        throw "A instalacao do RustDesk excedeu $timeoutSeconds segundos e foi interrompida. Log: $installLog"
    }

    $process.Refresh()
    $validExitCodes = @(0, 1641, 3010)

    if ($process.ExitCode -notin $validExitCodes) {
        throw "O instalador MSI retornou o codigo $($process.ExitCode). Log: $installLog"
    }

    Write-Host "RustDesk instalado com sucesso." -ForegroundColor Green
}
catch {
    Write-Error $_.Exception.Message
}
finally {
    if ($installerPath) {
        Remove-Item -LiteralPath $installerPath -Force -ErrorAction SilentlyContinue
    }
}

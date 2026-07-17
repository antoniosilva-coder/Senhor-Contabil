$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

try {
    Write-Host "== Aplicando wallpaper Senhor Contabil =="

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

    $wallpaperUrl = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$RepositoryRef/Wallpaper%20Senhor_Contabil.png"
    $wallpaperDir = "C:\ProgramData\SenhorContabil"
    $wallpaperPath = Join-Path $wallpaperDir "Wallpaper-SenhorContabil.png"

    New-Item -ItemType Directory -Path $wallpaperDir -Force | Out-Null
    Remove-Item -LiteralPath $wallpaperPath -Force -ErrorAction SilentlyContinue

    [Net.ServicePointManager]::SecurityProtocol = (
        [Net.ServicePointManager]::SecurityProtocol -bor
        [Net.SecurityProtocolType]::Tls12
    )

    Invoke-WebRequest `
        -Uri $wallpaperUrl `
        -OutFile $wallpaperPath `
        -UseBasicParsing `
        -TimeoutSec 120 `
        -ErrorAction Stop

    if (-not (Test-Path -LiteralPath $wallpaperPath -PathType Leaf)) {
        throw "O wallpaper nao foi criado depois do download."
    }

    if ((Get-Item -LiteralPath $wallpaperPath).Length -le 0) {
        throw "O wallpaper foi baixado vazio."
    }

    Add-Type -TypeDefinition @"
using System.Runtime.InteropServices;

public static class SenhorContabilWallpaper
{
    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    public static extern bool SystemParametersInfo(
        uint action,
        uint parameter,
        string value,
        uint flags
    );
}
"@

    $desktopRegistry = "Registry::HKEY_CURRENT_USER\Control Panel\Desktop"

    Set-ItemProperty `
        -Path $desktopRegistry `
        -Name "Wallpaper" `
        -Value $wallpaperPath `
        -Type String `
        -Force

    Set-ItemProperty `
        -Path $desktopRegistry `
        -Name "WallpaperStyle" `
        -Value "10" `
        -Type String `
        -Force

    Set-ItemProperty `
        -Path $desktopRegistry `
        -Name "TileWallpaper" `
        -Value "0" `
        -Type String `
        -Force

    $SPI_SETDESKWALLPAPER = 20
    $SPIF_UPDATEINIFILE = 1
    $SPIF_SENDWININICHANGE = 2

    $applied = [SenhorContabilWallpaper]::SystemParametersInfo(
        $SPI_SETDESKWALLPAPER,
        0,
        $wallpaperPath,
        ($SPIF_UPDATEINIFILE -bor $SPIF_SENDWININICHANGE)
    )

    if (-not $applied) {
        $errorCode = [Runtime.InteropServices.Marshal]::GetLastWin32Error()
        throw "O Windows nao conseguiu aplicar o wallpaper. Codigo: $errorCode"
    }

    Write-Host "Wallpaper aplicado com sucesso." -ForegroundColor Green
}
catch {
    Write-Error $_.Exception.Message
}

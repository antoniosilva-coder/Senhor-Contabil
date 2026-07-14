$ErrorActionPreference = 'Stop'

try {
    Write-Host "== Instalando RustDesk =="

    # Garante TLS 1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $headers = @{
        'User-Agent' = 'PowerShell'
    }

    Write-Host "Consultando última versão..."

    $release = Invoke-RestMethod `
        -Uri "https://api.github.com/repos/rustdesk/rustdesk/releases/latest" `
        -Headers $headers

    $asset = $release.assets |
        Where-Object {
            $_.name -match '^rustdesk-.*-x86_64\.exe$'
        } |
        Select-Object -First 1

    if (-not $asset) {
        throw "Instalador x64 não encontrado."
    }

    $Destino = Join-Path $env:TEMP "RustDesk.exe"

    Write-Host "Baixando $($asset.name)..."

    Invoke-WebRequest `
        -Uri $asset.browser_download_url `
        -OutFile $Destino `
        -Headers $headers

    Write-Host "Instalando RustDesk..."

    Start-Process `
        -FilePath $Destino `
        -ArgumentList "--silent-install" `
        -Wait

    Remove-Item $Destino -Force

    Write-Host "RustDesk instalado com sucesso."
}
catch {
    Write-Error $_
}
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

    # Remove marca de "arquivo da internet" (Zone.Identifier) - em algumas
    # configurações isso evita que o SmartScreen tente exibir um prompt
    # (que trava o -Wait numa sessão sem desktop interativo).
    Unblock-File -Path $Destino -ErrorAction SilentlyContinue

    # Exclui o instalador do Defender ANTES de rodar. O P7-Defender.ps1 só roda
    # depois do P4 na ordem do P0-Main, então sem isso o Defender pode
    # escanear/segurar o instalador durante a instalação silenciosa.
    try {
        Add-MpPreference -ExclusionPath $Destino -ErrorAction Stop
        Add-MpPreference -ExclusionProcess $Destino -ErrorAction Stop
    }
    catch {
        Write-Host "Aviso: não foi possível adicionar exclusão no Defender ($($_.Exception.Message)). Prosseguindo mesmo assim."
    }

    Write-Host "Instalando RustDesk..."

    # Start-Process com -Wait puro pode travar indefinidamente se o instalador
    # disparar um prompt (UAC/SmartScreen) numa sessão sem desktop interativo.
    # Usamos -PassThru + timeout manual para nunca ficar preso pra sempre.
    $proc = Start-Process `
        -FilePath $Destino `
        -ArgumentList "--silent-install" `
        -PassThru

    $TimeoutSeconds = 120
    $finished = $proc.WaitForExit($TimeoutSeconds * 1000)

    if (-not $finished) {
        Write-Host "RustDesk não terminou em $TimeoutSeconds s - encerrando o processo e seguindo em frente." -ForegroundColor Yellow
        Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
        throw "Instalação do RustDesk excedeu o tempo limite de $TimeoutSeconds s (processo travado, possivelmente aguardando um prompt de UAC/SmartScreen que não pode ser exibido)."
    }

    if ($proc.ExitCode -ne 0) {
        throw "Instalador do RustDesk retornou código de saída $($proc.ExitCode)."
    }

    Remove-Item $Destino -Force -ErrorAction SilentlyContinue

    Write-Host "RustDesk instalado com sucesso."
}
catch {
    Write-Error $_
}

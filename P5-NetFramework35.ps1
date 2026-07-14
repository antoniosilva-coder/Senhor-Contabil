$ErrorActionPreference = 'Stop'

try {
    Write-Host "== Instalando .NET Framework 3.5 =="

    Enable-WindowsOptionalFeature `
        -Online `
        -FeatureName NetFx3 `
        -All `
        -NoRestart

    Write-Host ".NET Framework 3.5 instalado com sucesso."
}
catch {
    Write-Warning ".NET Framework 3.5 não pôde ser instalado automaticamente."
    Write-Warning "Caso necessário, utilize uma mídia do Windows contendo a pasta \sources\sxs."
}
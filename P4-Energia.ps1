Write-Host "== Configurando Plano de Energia =="

# Cria e ativa Ultimate Performance
$out = & "$env:windir\System32\powercfg.exe" /DuplicateScheme "e9a42b02-d5df-448d-aa00-03f14749eb61"

if ($out -match '([a-fA-F0-9-]{36})') {
    $guid = $Matches[1]
    & powercfg /SetActive $guid
}

# Processador em 100%
powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100
powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100

# Nunca desligar HD
powercfg /CHANGE DISK-TIMEOUT-AC 0

# Nunca suspender
powercfg /CHANGE STANDBY-TIMEOUT-AC 0

# Nunca hibernar
powercfg /CHANGE HIBERNATE-TIMEOUT-AC 0

# Desativar suspensão híbrida
powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_SLEEP HYBRIDSLEEP 0

# Desativar USB Selective Suspend
powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_USB USBSELECTIVE 0

# Desativar economia PCI Express
powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_PCIEXPRESS ASPM 0

# Aplicar
powercfg /SETACTIVE SCHEME_CURRENT

Write-Host "Plano de energia configurado."
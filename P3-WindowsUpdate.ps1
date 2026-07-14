Write-Host "== Pausando Windows Update =="

$format = 'yyyy-MM-ddTHH\:mm\:ssK'
$now = [datetime]::UtcNow

$regPath = 'Registry::HKLM\Software\Microsoft\WindowsUpdate\UX\Settings'

if (!(Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

foreach ($name in @(
    'PauseFeatureUpdatesStartTime',
    'PauseQualityUpdatesStartTime',
    'PauseUpdatesStartTime'
)) {
    Set-ItemProperty -Path $regPath -Name $name -Value $now.ToString($format)
}

foreach ($name in @(
    'PauseFeatureUpdatesEndTime',
    'PauseQualityUpdatesEndTime',
    'PauseUpdatesExpiryTime'
)) {
    Set-ItemProperty -Path $regPath -Name $name -Value $now.AddHours(1).ToString($format)
}

Write-Host "Windows Update pausado por 1 hora."
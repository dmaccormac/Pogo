# Pogo.psm1

# Import helper scripts  
. "$PSScriptRoot\PogoNet.ps1"
. "$PSScriptRoot\PogoSys.ps1"

# Initialize the global geo cache
$global:geoCache = @{}

# Set aliases
New-Alias -Name net -Value New-NetworkMonitor
New-Alias -Name sys -Value New-SystemMonitor
New-Alias -Name ipg -Value Get-IPGeoLocation


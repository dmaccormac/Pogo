# Pogo.psm1

# Import helper scripts  
. "$PSScriptRoot\PogoNet.ps1"
. "$PSScriptRoot\PogoSys.ps1"
. "$PSScriptRoot\PogoCore.ps1"

# Initialize the global geo cache
$global:geoCache = @{}

# Set aliases for the functions
New-Alias -Name net -Value New-NetworkMonitor
New-Alias -Name sys -Value New-SystemMonitor
New-Alias -Name ipg -Value Get-IPGeoLocation

New-Alias -Name adv -Value Show-AdvancedSystemProperties
New-Alias -Name pwr -Value Show-PowerOptionsApplet

New-Alias -Name off -Value Stop-Computer
New-Alias -Name out -Value Exit-UserSession
New-Alias -Name reb -Value Restart-Computer
New-Alias -Name nap -Value Suspend-Computer

New-Alias -Name vol -Value Switch-VolumeMute
New-Alias -Name col -Value Show-ColorGrid

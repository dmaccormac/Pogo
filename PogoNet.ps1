
<#
.SYNOPSIS
Monitors network connections and displays information about the top N connections.

.DESCRIPTION
This function retrieves and displays information about the top N network connections, along with detailed network statistics such as IP addresses, MAC addresses, DNS servers, SSID, and bytes sent and received. It refreshes the information at specified intervals and allows the user to exit or refresh manually.

.PARAMETER top
Specifies the number of top network connections to display.

.PARAMETER refreshInterval
Specifies the interval (in seconds) at which to refresh the network information.

.PARAMETER watchProcess
Specifies the name(s) of the process to highlight in the table view.

.PARAMETER transferWarningThreshold
Specifies the threshold for bytes transfer warning (in MB). Exceeds will highlight the value in yellow.

.PARAMETER transferCriticalThreshold
Specifies the threshold for bytes transfer critical (in MB). Exceeds will highlight the value in red.

.PARAMETER devMode
Enable this switch to show the message "DevMode" in the table headers.

.EXAMPLE
New-PogoNetworkMonitor -top 10 -refreshInterval 60 transferWarningThreshold 10 transferCriticalThreshold 20.0

#>
function New-NetworkMonitor {
    param (
    [int]$top = 20,  # Number of top connections to display
    [int]$refreshInterval = 60,  # Refresh interval in seconds
    [double]$transferWarningThreshold = 5.0,  # Threshold for bytes sent (MB)
    [double]$transferCriticalThreshold = 10.0,  # Threshold for bytes received (MB)
    [string[]]$watchProcess = "watcher",  # Number of items to display
    [switch]$devMode
    )

    # Config Variables
    $colorHealthy = "Green"
    $colorWarning = "Yellow" 
    $colorCritical = "Red"
    
    $colorHeader = $colorHealthy
    $colorData = "White"

    $colorWatch = "Magenta"
    
    $block = [char]0x2588  # Block character for padding
    $upArrow = [char]0x2191
    $downArrow = [char]0x2193

    $transferWarningThreshold = 5.0
    $transferCriticalThreshold = 10.0

    while ($true) {
        Clear-Host
        $macAddress = ""

        # Get network connections and select relevant properties
        $connections = Get-NetTCPConnection -AppliedSetting Internet |
                       Sort-Object -Property CreationTime -Descending |
                       Select-Object -First $top -Property LocalAddress, LocalPort, RemoteAddress, RemotePort, CreationTime, `
                        @{Name='PID'; Expression={$_.OwningProcess}}, `
                        @{Name='Name'; Expression={(Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).Name}}, `
                        @{Name='Time'; Expression={$_.CreationTime}}
                        
        # Gather useful network information
        $ipAddress = Get-LanIP
        $macAddress = Get-MacAddress
        $wanIp = Get-WanIP
        $geoLocation = Get-IPGeoLocation -ipAddress $wanIp -fields "countryCode"
        $countryCode = if ($geoLocation -is [PSCustomObject]) { $geoLocation.countryCode } else { "??" }
        $dnsServers = (Get-DnsClientServerAddress -AddressFamily IPv4).ServerAddresses -join ", "
        $ssid = (netsh wlan show interfaces | Select-String ' SSID ' | ForEach-Object { $_.ToString().Trim() -replace 'SSID\s+:\s+', '' })
        $interfaceName = (Get-NetConnectionProfile).Name

        # Get network bytes sent and received
        $networkAdapters = Get-CimInstance -ClassName Win32_PerfFormattedData_Tcpip_NetworkInterface
        $bytesSentTotal = [math]::Round(($networkAdapters | Measure-Object -Property BytesSentPersec -Sum).Sum / 1MB, 2) # Convert to MB
        $bytesReceivedTotal = [math]::Round(($networkAdapters | Measure-Object -Property BytesReceivedPersec -Sum).Sum / 1MB, 2) # Convert to MB

        # Determine color for bytes sent and received based on thresholds
        $bytesReceivedColor = if ($bytesReceivedTotal -gt $transferCriticalThreshold) { $colorCritical } elseif ($bytesReceivedTotal -gt $transferWarningThreshold) { $colorWarning } else { $colorHeader }
        $bytesSentColor = if ($bytesSentTotal -gt $transferCriticalThreshold) { $colorCritical } elseif ($bytesSentTotal -gt $transferWarningThreshold) { $colorWarning } else { $colorHeader }

        # Monitor Header
        Write-Host "$block LAN $ipAddress $block MAC $macAddress $block DNS $dnsServers $block" -ForegroundColor $colorHeader
        Write-Host "$block WAN $wanIp $block GEO $countryCode $block XFR" -ForegroundColor $colorHeader -NoNewline
        Write-Host " $upArrow $bytesSentTotal MB" -ForegroundColor $bytesSentColor -NoNewline
        Write-Host " $downArrow $bytesReceivedTotal MB" -ForegroundColor $bytesReceivedColor -NoNewline
        Write-Host " $block INT $interfaceName $block SSID $ssid $block $(Get-Timestamp) $block" -ForegroundColor $colorHeader
        Write-Host $(Get-HorizontalBar)

        # Table Header
        Write-Host "ID".PadRight(5) `t "Local".PadRight(15) `t "Port".PadRight(5) `t "Remote".PadRight(15) `
        `t "Port".PadRight(5) `t "Timestamp".PadRight(10) `t "Name".PadRight(9) -ForegroundColor $colorHeader
        Write-Host $(Get-HorizontalBar)

        # Table Data
        foreach ($item in $connections) {
            if ($watchProcess.Contains($item.name)) {$color=$colorWatch} else {$color=$colorData}

            Write-Host $item.PID.ToString().PadRight(5) -ForegroundColor $color -NoNewline
            Write-Host `t $item.LocalAddress.ToString().PadRight(15) -ForegroundColor $color -NoNewline
            Write-Host `t $item.LocalPort.ToString().PadRight(5) -ForegroundColor $color -NoNewline
            Write-Host `t $item.RemoteAddress.ToString().PadRight(15) -ForegroundColor $color -NoNewline
            Write-Host `t $item.RemotePort.ToString().PadRight(5) -ForegroundColor $color -NoNewline
            Write-Host `t $item.Time.ToString().subString(10) -ForegroundColor $color -NoNewline
            Write-Host `t $(if ($item.Name.Length -gt 10) { $item.Name.subString(0,10)} else { $item.Name.PadRight(10)}) -ForegroundColor $color

        }


    # Wait for the specified interval before refreshing
    Start-Sleep -Seconds $refreshInterval
}
}


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

.PARAMETER interfaceName
Specifies the name of the network interface to monitor.

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
    [string]$interfaceName = "Wi-Fi",  # Number of items to display
    [switch]$devMode
    )

    # Config Variables
    $colorHealthy = "Green"
    $colorWarning = "Yellow" 
    $colorCritical = "Red"
    $colorData = "White"

    $colorHeader = $colorHealthy
    $colorWatch = $colorCritical
    
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

                           
        # Clean data
        foreach ($item in $connections){
            $item.Name = $item.Name.subString(0, [System.Math]::Min(15, $item.Name.Length))
            $item.LocalAddress = $item.LocalAddress.subString(0, [System.Math]::Min(15, $item.LocalAddress.Length)) 
            $item.RemoteAddress = $item.RemoteAddress.subString(0, [System.Math]::Min(15, $item.RemoteAddress.Length))
            $item.Time = if ($null -eq $item.Time) {"N/A"} else {$item.Time.ToString()}
            
        }
  
        # Gather network information
        $ipAddress = Get-LanIP
        $macAddress = Get-MacAddress
        $wanIp = Get-WanIP
        $geoLocation = Get-IPGeoLocation -ipAddress $wanIp -fields "countryCode"
        $countryCode = if ($geoLocation -is [PSCustomObject]) { $geoLocation.countryCode } else { "??" }
        $dnsServers = Get-dnsServers 

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
        Write-Host " $block INT $interfaceName $block $(Get-Timestamp) $block" -ForegroundColor $colorHeader
        Write-Host $(Get-HorizontalBar)

        # Table Header
        Write-Host "Name".PadRight(19) "ID".PadRight(9) "Local/Port".PadRight(24) "Remote/Port".PadRight(24) "Date/Time".PadRight(19) -ForegroundColor $colorHeader
        Write-Host $(Get-HorizontalBar)

        # Table Data
        foreach ($item in $connections) {
            if ($watchProcess.Contains($item.name)) {$color=$colorWatch} else {$color=[Console]::BackgroundColor}

            $local = $item.LocalAddress.toString() + " " + $item.LocalPort.ToString()
            $remote = $item.RemoteAddress.toString() + " " + $item.RemotePort.ToString()

            Write-Host $item.Name.PadRight(20) -BackgroundColor $color -ForegroundColor $colorData -NoNewline
            Write-Host $item.PID.ToString().PadRight(10) -BackgroundColor $color -ForegroundColor $colorData -NoNewline
            Write-Host $local.PadRight(25) -BackgroundColor $color -ForegroundColor $colorData -NoNewline
            Write-Host $remote.PadRight(25) -BackgroundColor $color -ForegroundColor $colorData -NoNewline
            Write-Host $item.Time.PadRight(20) -BackgroundColor $color -ForegroundColor $colorData 

        }
    
    # Wait for the specified interval before refreshing
    Start-Sleep -Seconds $refreshInterval
        
    }

}


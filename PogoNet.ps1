<#
.SYNOPSIS
Retrieves the public IP address of the WAN interface.

.DESCRIPTION
This function uses an external API to retrieve the public IP address of the WAN interface. It handles errors gracefully and returns "N/A" if the IP address cannot be retrieved.

.EXAMPLE
PS> Get-WanIP
Returns the public IP address of the WAN interface.

.NOTES
Uses the ipify API to retrieve the IP address.
#>

function Get-WanIP {
    try {
        return (Invoke-RestMethod -Uri 'https://api64.ipify.org?format=json').ip
    } catch {
        return "N/A"
    }
}

<#
.SYNOPSIS
Retrieves the IPv4 address of the LAN interface assigned by DHCP.

.DESCRIPTION
This function retrieves the IPv4 address assigned by DHCP from the LAN interface. If an error occurs, it returns "N/A".

.EXAMPLE
PS> Get-LanIP
Returns the IPv4 address of the LAN interface assigned by DHCP.

.NOTES
Filters the IP addresses to return only those with a DHCP prefix origin.
#>

function Get-LanIP {
    try {
        return (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.PrefixOrigin -eq 'Dhcp' }).IPAddress
    } catch {
        return "N/A"
    }
}

<#
.SYNOPSIS
Retrieves the MAC address of the active network adapter.

.DESCRIPTION
This function retrieves the MAC address of the network adapter with the status "Up". It formats the MAC address by replacing hyphens with colons.

.EXAMPLE
PS> Get-MacAddress
Returns the MAC address of the active network adapter.

.NOTES
Uses the Get-NetAdapter cmdlet to retrieve network adapter information.
#>

function Get-MacAddress {
    $mac = (Get-NetAdapter | Where-Object { $_.Status -eq 'Up' }).MacAddress
    return ($mac -replace '-', ':').Trim()
}

<#
.SYNOPSIS
Retrieves geolocation information for a given IP address.

.DESCRIPTION
This function retrieves geolocation information for the specified IP address using the ip-api.com service. The results are cached globally to avoid repeated requests for the same IP address.

.PARAMETER commandParams
Specifies the IP address to retrieve geolocation information for.

.PARAMETER fields
Specifies additional fields to include in the geolocation information.

.EXAMPLE
PS> Get-IPGeoLocation -commandParams "8.8.8.8" -fields "countryCode"
Returns the country code for the specified IP address.

.NOTES
Uses the ip-api.com service to retrieve geolocation information.
#>

function Get-IPGeoLocation {
    param(
        [string]$commandParams,
        [string]$fields = ""
    )

    # Check if the IP is already in the cache
    if ($global:geoCache.ContainsKey($commandParams)) {
        return $global:geoCache[$commandParams]
    }

    if (Test-IPv4Address $commandParams) {
        $url = "http://ip-api.com/json/${commandParams}"
        if ($fields -ne "") {
            $url += "?fields=$fields"
        }
        $response = Invoke-RestMethod -Method Get -Uri $url

        # Store the result in the cache
        $global:geoCache[$commandParams] = $response
        return $response
    } else {
        return "Could not get IP geo location"
    }
}

<#
.SYNOPSIS
Tests whether a given string is a valid IPv4 address.

.DESCRIPTION
This function checks if the provided string is a valid IPv4 address based on the standard IPv4 address format.

.PARAMETER ipAddress
Specifies the string to be tested as an IPv4 address.

.EXAMPLE
PS> Test-IPv4Address -ipAddress "192.168.1.1"
Returns $true if the string is a valid IPv4 address, otherwise $false.

.NOTES
Uses a regular expression to validate the IPv4 address format.
#>

function Test-IPv4Address {
    param (
        [string]$ipAddress
    )

    if ($ipAddress -match '^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$') {
        return $true
    } else {
        return $false
    }
}

<#
.SYNOPSIS
Displays the contents of the global geolocation cache.

.DESCRIPTION
This function displays the contents of the global geolocation cache in a table format. The cache contains previously retrieved geolocation information for IP addresses.

.EXAMPLE
PS> Show-GeoCache
Displays the IP addresses and their corresponding country codes stored in the global geolocation cache.

.NOTES
Uses a global variable $geoCache to store geolocation information.
#>

function Show-GeoCache {
    # Hardcoded global geoCache variable
    $geoCache = $global:geoCache

    # Convert the hashtable to an array of custom objects for formatting
    $cacheArray = @()
    foreach ($key in $geoCache.Keys) {
        $cacheArray += [PSCustomObject]@{
            IPAddress   = $key
            CountryCode = $geoCache[$key].countryCode
        }
    }

    # Display the cache in a table format
    $cacheArray | Format-Table -AutoSize
}

<#
.SYNOPSIS
Monitors network connections and displays information about the top N connections.

.DESCRIPTION
This function retrieves and displays information about the top N network connections, along with detailed network statistics such as IP addresses, MAC addresses, DNS servers, SSID, and bytes sent and received. It refreshes the information at specified intervals and allows the user to exit or refresh manually.

.PARAMETER topN
Specifies the number of top network connections to display.

.PARAMETER refreshInterval
Specifies the interval (in seconds) at which to refresh the network information.

.PARAMETER sentThreshold
Specifies the threshold for bytes sent (in MB). Exceeds will highlight the value in red.

.PARAMETER receivedThreshold
Specifies the threshold for bytes received (in MB). Exceeds will highlight the value in red.

.EXAMPLE
New-PogoNetworkMonitor -topN 10 -refreshInterval 60 -sentThreshold 10.0 -receivedThreshold 10.0

.NOTES
Press 'q' to exit or 'r' to refresh the display manually.

#>
function New-NetworkMonitor {
    param (
    [int]$topN = 10,  # Number of top connections to display
    [int]$refreshInterval = 60,  # Refresh interval in seconds
    [double]$sentThreshold = 10.0,  # Threshold for bytes sent (MB)
    [double]$receivedThreshold = 10.0  # Threshold for bytes received (MB)
    )

    $block = [char]0x2588  # Block character for padding

    Write-Host "Press 'q' to exit or 'r' to refresh" -ForegroundColor Yellow

    while ($true) {
        # Clear the console
        Clear-Host

        # Ensure MAC address is reset
        $macAddress = ""

        # Get network connections, filter out unwanted remote addresses, and select relevant properties
        $connections = Get-NetTCPConnection |
                       Where-Object { $null -ne $_.RemoteAddress -and $_.RemoteAddress -ne "0.0.0.0" -and $_.RemoteAddress -ne "::" } |
                       Where-Object { $_.CreationTime -ne [datetime]'1600-12-31' } |
                       Sort-Object -Property CreationTime -Descending |
                       Select-Object -First $topN -Property LocalAddress, LocalPort, RemoteAddress, RemotePort, @{Name='PID'; Expression={$_.OwningProcess}}, @{Name='ProcessName'; Expression={(Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).Name}}, CreationTime

        # Gather useful network information
        $ipAddress = Get-LanIP #(Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -ne "Loopback Pseudo-Interface 1" }).IPAddress
        $macAddress = Get-MacAddress
        $wanIp = Get-WanIP
        $geoLocation = Get-IPGeoLocation -commandParams $wanIp -fields "countryCode"
        $countryCode = if ($geoLocation -is [PSCustomObject]) { $geoLocation.countryCode } else { "Unknown" }
        $dnsServers = (Get-DnsClientServerAddress -AddressFamily IPv4).ServerAddresses -join ", "
        $ssid = (netsh wlan show interfaces | Select-String ' SSID ' | ForEach-Object { $_.ToString().Trim() -replace 'SSID\s+:\s+', '' })
        $interfaceName = (Get-NetConnectionProfile).Name

        # Get network bytes sent and received
        $networkAdapters = Get-CimInstance -ClassName Win32_PerfFormattedData_Tcpip_NetworkInterface
        $bytesSentTotal = [math]::Round(($networkAdapters | Measure-Object -Property BytesSentPersec -Sum).Sum / 1MB, 2) # Convert to MB
        $bytesReceivedTotal = [math]::Round(($networkAdapters | Measure-Object -Property BytesReceivedPersec -Sum).Sum / 1MB, 2) # Convert to MB
        $upArrow = [char]0x2191
        $downArrow = [char]0x2193

        # Determine color for bytes sent and received based on thresholds
        $bytesSentColor = if ($bytesSentTotal -gt $sentThreshold) { "Red" } else { "Cyan" }
        $bytesReceivedColor = if ($bytesReceivedTotal -gt $receivedThreshold) { "Red" } else { "Cyan" }

        # Display the header with useful network information in two lines
        Write-Host "LAN $ipAddress $block MAC $macAddress $block DNS $dnsServers" -ForegroundColor Cyan
        Write-Host "WAN $wanIp $block GEO $countryCode $block XFR $upArrow" -ForegroundColor Cyan -NoNewline
        Write-Host " $bytesSentTotal MB" -ForegroundColor $bytesSentColor -NoNewline
        Write-Host " $downArrow" -ForegroundColor Cyan -NoNewline
        Write-Host " $bytesReceivedTotal MB" -ForegroundColor $bytesReceivedColor -NoNewline
        Write-Host " $block INT $interfaceName $block SSID $ssid" -ForegroundColor Cyan

        # Display top N connections with yellow foreground
        $connections | Format-Table -AutoSize | Out-String -Stream | ForEach-Object {
            Write-Host $_ -ForegroundColor Yellow
        }

        # Check for key press to exit or refresh
        if ($Host.UI.RawUI.KeyAvailable) {
            $key = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
            if ($key.VirtualKeyCode -eq 81) {  # 'q' key
                Write-Host "Exiting..." -ForegroundColor Red
                break
            } elseif ($key.VirtualKeyCode -eq 82) {  # 'r' key
                Write-Host "Refreshing..." -ForegroundColor Yellow
                continue  # Skip the sleep and refresh immediately
            }
        }

        # Wait for the specified interval before refreshing
        Start-Sleep -Seconds $refreshInterval
    }
}

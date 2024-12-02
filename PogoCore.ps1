
#################
#   SYSTEM      #
#################

[int]$timeout=10

function Stop-Computer {
    Write-Host "**WARNING**  Shutting down in $timeout seconds..." -ForegroundColor Red
    Start-Sleep -Seconds $timeout
    Start-Process "shutdown" -ArgumentList "/s /t 0"

}

function Exit-UserSession {
    Write-Host "**WARNING**  Logging out in $timeout seconds..." -ForegroundColor Red
    Start-Sleep -Seconds $timeout
    Write-Host "Logging out now" -ForegroundColor Green
    Start-Process "logoff"

}

function Restart-Computer {
    Write-Host "**WARNING**  Restarting computer in $timeout seconds..." -ForegroundColor Red
    Start-Sleep -Seconds $timeout
    Write-Host "Restarting now" -ForegroundColor Green
    Start-Process "shutdown" -ArgumentList "/r /t 0"

}


function Suspend-Computer {
    Write-Host "**WARNING**  Putting computer to sleep in $timeout seconds..." -ForegroundColor Yellow
    Start-Sleep -Seconds $timeout
    Start-Process rundll32.exe -ArgumentList "powrprof.dll,SetSuspendState Sleep"

}

function Show-AdvancedSystemProperties {
    Write-Output "Starting System Properties...";
    Start-Process sysdm.cpl

}

function Show-PowerOptionsApplet {
    Write-Output "Starting Power Configuration...";
    Start-Process powercfg.cpl

}

#################
#   DISPLAY     #
#################

function Show-PsColors {
    
    $List = [enum]::GetValues([System.ConsoleColor])

    ForEach ($Color in $List){
        Write-Host "      $Color" -ForegroundColor $Color -NonewLine
        Write-Host ""

    } #end foreground color ForEach loop

    ForEach ($Color in $List){
        Write-Host "                   " -backgroundColor $Color -noNewLine
        Write-Host "   $Color"

    } #end background color ForEach loop
}

function Switch-VolumeMute {
    $obj = new-object -com wscript.shell 
    $obj.SendKeys([char]173)
}

#################
#   NETWORK     #
#################

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
        [string]$ipAddress,
        [string]$fields = ""
    )

    # Check if the IP is already in the cache
    if ($global:geoCache.ContainsKey($ipAddress)) {
        return $global:geoCache[$ipAddress]
    }

    if (Test-IPv4Address $ipAddress) {
        $url = "http://ip-api.com/json/${ipAddress}"
        if ($fields -ne "") {
            $url += "?fields=$fields"
        }
        $response = Invoke-RestMethod -Method Get -Uri $url

        # Store the result in the cache
        $global:geoCache[$ipAddress] = $response
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

function Get-Timestamp{
    return (Get-Date).ToString("HH:mm")
}

function Get-HorizontalBar{
    $str = "======="

    if ($devMode)
    {
        $str = "DEVMODE"
    }

    $paddedString = $str.PadLeft(50 + $str.Length, '=').PadRight(100, '=')
    return $paddedString 

}


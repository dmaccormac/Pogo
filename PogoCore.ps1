
#################
#   CONFIG      #
#################
$block = [char]0x2588  # Block character for padding
$bar = [char]0x2500
$devMessage = "DevMode"

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
    Start-Process "control" -ArgumentList "sysdm.cpl,,3"

}

function Show-PowerOptionsApplet {
    Write-Output "Starting Power Configuration...";
    Start-Process powercfg.cpl

}

function Get-Timestamp{
    return (Get-Date).ToString("HH:mm")
}


function Get-Uptime{
    $bootTime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
    $uptime = (Get-Date) - $bootTime
    $uptimeHours = [math]::Round($uptime.TotalHours, 2)

    return $uptimeHours
}

#################
#   DISPLAY     #
#################

function Get-HorizontalBar{
    $str = "$bar$bar"

    if ($devMode)
    {
        $str = $devMessage
    }

    $paddedString = $str.PadLeft(50 + $str.Length, $bar).PadRight(100, $bar)
    return $paddedString 

}

function Show-ColorList {
    
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

function Show-ColorGrid
{
    $colors = [enum]::GetValues([System.ConsoleColor])
    Foreach ($bgcolor in $colors){
        Foreach ($fgcolor in $colors) { Write-Host "$fgcolor|"  -ForegroundColor $fgcolor -BackgroundColor $bgcolor -NoNewLine }
        Write-Host " on $bgcolor"
    } 
}

function Switch-VolumeMute {
    $obj = new-object -com wscript.shell 
    $obj.SendKeys([char]173)
}

#################
#   NETWORK     #
#################


function Get-WanIP {
    try {
        return (Invoke-WebRequest https://checkip.amazonaws.com/).Content.Trim()
    } catch {
        return "N/A"
    }
}


function Get-LanIP {
    try {
        return (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -eq $interfaceName }).IPAddress
    } catch {
        return "N/A"
    }
}

function Get-dnsServers {

    $dnsServers = (Get-DnsClientServerAddress -InterfaceAlias $interfaceName -AddressFamily IPv4).ServerAddresses -join ","
    return $dnsServers

}


function Get-MacAddress {
    $mac = (Get-NetAdapter | Where-Object { $_.Name -eq $interfaceName }).MacAddress
    return ($mac -replace '-', ':').Trim()
}

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




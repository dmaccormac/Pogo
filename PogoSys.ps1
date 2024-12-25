<#
.SYNOPSIS
Monitors system metrics such as CPU, memory usage, and disk space, and provides real-time updates.

.DESCRIPTION
This function retrieves and displays system metrics like CPU usage, memory usage, and disk space at specified intervals. It allows the user to monitor system performance in real time and includes error handling to manage potential issues gracefully.

.PARAMETER refreshInterval
Specifies the interval (in seconds) at which to refresh the system metrics.

.PARAMETER sortBy
Specifies the column by which to sort the process list. Valid values are 'CPU', 'Memory', and 'DiskIO'.

.PARAMETER top
Specifies the number of items to display in the view. Default value is 10.

.PARAMETER watchProcess
Specifies the name(s) of the process to highlight in the table view.

.PARAMETER devMode
Enable this switch to show the message "DevMode" in the table headers.

.EXAMPLE
New-PogoSystemMonitor -refreshInterval 60 -sortBy CPU -top 10

.LINK
https://github.com/dmaccormac/pogo
#>

function New-SystemMonitor {
    param (
        [int]$refreshInterval = 60,  # Refresh interval in seconds
        [string]$sortBy = "Memory",  # Column to sort by
        [int]$top = 20, # Number of items to display
        [string[]]$watchProcess = "watcher",  # Number of items to display
        [switch]$devMode
    )

    # Config Variables
    $colorHealthy = "Green"
    $colorWarning = "Yellow" 
    $colorCritical = "Red"
    $colorData = "White"

    $colorHeader = $colorHealthy
    $colorWatch = $colorCritical

    # Threshold Values
    $cpuWarning = 70  
    $cpuCritical = 80  

    $memoryWarning = 70
    $memoryCritical = 80 

    $diskFreeWarning = 40 
    $diskFreeCritical = 20 

    $uptimeWarning = 24 
    $uptimeCritical = 48

    # Get Computer Info
    Clear-Host
    Write-Host "Collecting data..." -ForegroundColor Green
    $computerInfo = Get-ComputerInfo

    $hostname = $computerInfo.CsName
    $username = $computerInfo.CsUserName          
    
    $systemManufacturer = $computerInfo.CsManufacturer
    $systemModel = $computerInfo.CsModel
    $biosVersion = $computerInfo.BiosSMBIOSBIOSVersion
    $serialNumber = (Get-WmiObject -Class Win32_Bios | Select-Object SerialNumber).SerialNumber

    $windowsName = $computerInfo.OsName.replace("Microsoft ","")
    $windowsBuild = $computerInfo.OsBuildNumber
    $windowsVersion = $computerInfo.OSDisplayVersion

    while ($true) {
        try {

            # Uptime
            $uptime = Get-Uptime

            # Net connection
            $uplinkStatus = Test-Connection "google.com" -Quiet

            
            # CPU info
            $cpuUsage = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue 

            # Memory Info
            $memoryInfo = Get-CimInstance -ClassName Win32_OperatingSystem
            $totalMemoryGB = [math]::Round($memoryInfo.TotalVisibleMemorySize / 1MB, 2)
            $freeMemoryGB = [math]::Round($memoryInfo.FreePhysicalMemory / 1MB, 2)
            $usedMemoryGB = [math]::Round($totalMemoryGB - $freeMemoryGB, 2)
            $memoryUsagePercent = [math]::Round((($totalMemoryGB - $freeMemoryGB) / $totalMemoryGB) * 100, 2)

            # Disk Info
            $systemDiskFreeGB = [math]::Round($(Get-PSDrive -Name C).Free / 1GB, 2)

            # Process Info
            $processes = Get-Process
            $diskUsageDetails = @{}

            try {
                $diskCounters = Get-Counter -Counter '\Process(*)\IO Data Bytes/sec'
                foreach ($sample in $diskCounters.CounterSamples) {
                        $processName = $sample.InstanceName
                        $diskBytesPerSec = [math]::Round($sample.CookedValue / 1MB, 2)  # Convert to MB/sec
                        $diskUsageDetails[$processName] = $diskBytesPerSec

                }
            } catch {
                Write-Host $_.Exception.Message
            }

            # Set alert colors
            $cpuColor = if ($cpuUsage -gt $cpuCritical) { $colorCritical } elseif ($cpuUsage -gt $cpuWarning) { $colorWarning } else { $colorHealthy }
            $memoryColor = if ($memoryUsagePercent -gt $memoryCritical) { $colorCritical } elseif ($memoryUsagePercent -gt $memoryWarning) { $colorWarning } else { $colorHealthy }
            $diskColor = if ($systemDiskFreeGB -lt $diskFreeCritical) { $colorCritical } elseif ($systemDiskFreeGB -lt $diskFreeWarning) { $colorWarning } else { $colorHealthy }
            $uptimeColor = if ($uptime -gt $uptimeCritical) { $colorCritical } elseif ($uptime -gt $uptimeWarning) { $colorWarning } else { $colorHealthy }
            $linkColor = if ($uplinkStatus) { $colorHealthy } else { $colorCritical }

            # clean start time
            # foreach ($process in $processes) 
            # {
            #     if ($null -eq $process.StartTime){
            #         $process.StartTime = "00:00"
            #     }
            # }

            # Create a list of custom objects
            $data = @()
            foreach ($process in $processes) 
            {
                # CLEAN DATA
                $timestamp = if ($null -eq $process.StartTime) {"0:00:00 AM"} else {$process.StartTime.ToString().subString(10)}
                $name = if ($process.Name.Length -gt 15) { $process.Name.subString(0,15)} else { $process.Name}


                    $obj = New-Object -TypeName PSObject
                    $obj | Add-Member  -Name Name -MemberType NoteProperty -Value $name
                    $obj | Add-Member -Name ID -MemberType NoteProperty -Value $process.Id
                    $obj | Add-Member  -Name CPU -MemberType NoteProperty -Value $([math]::Round($process.CPU, 2))
                    $obj | Add-Member  -Name Memory -MemberType NoteProperty -Value $([math]::Round($process.WorkingSet64 / 1MB, 2))
                    $obj | Add-Member  -Name DiskIO -MemberType NoteProperty -Value $diskUsageDetails[$process.Name]
                    $obj | Add-Member  -Name Time -MemberType NoteProperty -Value $timestamp.Trim()
                    $data += $obj
            }



            $filteredData = $data | Sort-Object -Property $sortBy -Descending |  Select-Object -First $top

            # Prepare for display
            Clear-Host

            # Monitor Header
            Write-Host "$block $username $block $systemModel $block BIOS $biosVersion $block SERIAL $serialNumber" -ForegroundColor $colorHealthy -NoNewline 
            write-host " $block $windowsName $windowsVersion.$windowsBuild $block" -ForegroundColor $colorHealthy

            Write-Host "$block CPU $([math]::Round($cpuUsage, 2))%" -ForegroundColor $cpuColor -NoNewline
            Write-Host " $block MEM $usedMemoryGB / $totalMemoryGB GB ($memoryUsagePercent%)" -ForegroundColor $memoryColor -NoNewline
            Write-Host " $block DISK FREE $systemDiskFreeGB GB" -ForegroundColor $diskColor -NoNewline
            Write-Host " $block UPTIME $uptime" -ForegroundColor $uptimeColor -NoNewline
            Write-Host " $block UPLINK" -ForegroundColor $linkColor -NoNewline
            Write-Host " $block $(Get-Timestamp) $block" -ForegroundColor $colorHeader
            Write-Host $(Get-HorizontalBar)

            # Table Header
            Write-Host "Name".PadRight(16) "ID".PadRight(11) "CPU".PadRight(16)"Memory".PadRight(16) `
            "Disk".PadRight(16) "Timestamp".PadRight(16) -ForegroundColor $colorHeader
            Write-Host $(Get-HorizontalBar)

            # Table Data
            foreach ($item in $filteredData) {
                if ($watchProcess.Contains($item.name)) {$color=$colorWatch} else {$color=[Console]::BackgroundColor}

                Write-Host $item.name.PadRight(17) -BackgroundColor $color -ForegroundColor $colorData -NoNewline
                Write-Host $item.ID.ToString().PadRight(12) -BackgroundColor $color -ForegroundColor $colorData -NoNewline
                Write-Host $item.CPU.ToString("F2").PadRight(17) -BackgroundColor $color -ForegroundColor $colorData -NoNewline
                Write-Host $item.Memory.ToString("F2").PadRight(17) -BackgroundColor $color -ForegroundColor $colorData -NoNewline
                Write-Host $item.DiskIO.ToString("F2").PadRight(17) -BackgroundColor $color -ForegroundColor $colorData -NoNewline
                Write-Host $item.Time.PadRight(17) -BackgroundColor $color -ForegroundColor $colorData 
     
            }

            # Wait for the specified interval before refreshing
            Start-Sleep -Seconds $refreshInterval
            
        } catch {
            Write-Host "An error occurred: $_" -ForegroundColor Red
        }
    }
}





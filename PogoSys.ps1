<#
.SYNOPSIS
Monitors system metrics such as CPU, memory usage, and disk space, and provides real-time updates.

.DESCRIPTION
This function retrieves and displays system metrics like CPU usage, memory usage, and disk space at specified intervals. It allows the user to monitor system performance in real time and includes error handling to manage potential issues gracefully.

.PARAMETER refreshInterval
Specifies the interval (in seconds) at which to refresh the system metrics.

.PARAMETER sortBy
Specifies the column by which to sort the process list. Valid values are 'CPU', 'Memory', and 'DiskIO'.

.PARAMETER topN
Specifies the number of items to display in the view. Default value is 10.

.EXAMPLE
New-PogoSystemMonitor -refreshInterval 60 -sortBy CPU -topN 10

.LINK
https://yourwebsite.com

.NOTES
Press 'q' to exit or 'r' to refresh the display manually.
#>

function New-SystemMonitor {
    param (
        [int]$refreshInterval = 60,  # Refresh interval in seconds
        [string]$sortBy = "CPU",  # Column to sort by: CPU, Memory, DiskIO
        [int]$topN = 10  # Number of items to display
    )

    # Configurable thresholds
    $cpuThreshold = 50  # greater
    $memoryThreshold = 75  # greater 
    $diskThreshold = 10  # less

    # Colors for retro look
    $colorHeader = "Cyan"
    $colorName = "Green"
    $colorID = "Yellow"
    $colorCPU = "Blue"
    $colorMemory = "Magenta"
    $colorDisk = "Red"
    $colorWarning = "Red"
    $block = [char]0x2588  # Block character for padding

    Write-Host "Press 'q' to exit or 'r' to refresh" -ForegroundColor Yellow

    while ($true) {
        try {
            # Clear the console
            Clear-Host

            # Get user information
            $hostname = [System.Environment]::MachineName
            $username = [System.Environment]::UserName
            $osName = (Get-CimInstance -ClassName Win32_OperatingSystem).Caption
            $systemInfo = Get-CimInstance -ClassName Win32_ComputerSystem
            $systemModel = $systemInfo.Model
            $systemManufacturer = $systemInfo.Manufacturer

            $cpuUsage = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue

            # Get memory information
            $memoryInfo = Get-CimInstance -ClassName Win32_OperatingSystem
            $totalMemoryGB = [math]::Round($memoryInfo.TotalVisibleMemorySize / 1MB, 2)
            $freeMemoryGB = [math]::Round($memoryInfo.FreePhysicalMemory / 1MB, 2)
            $usedMemoryGB = [math]::Round($totalMemoryGB - $freeMemoryGB, 2)
            $memoryUsagePercent = [math]::Round((($totalMemoryGB - $freeMemoryGB) / $totalMemoryGB) * 100, 2)

            # Get disk free space in GB
            $systemDiskFreeGB = [math]::Round($(Get-PSDrive -Name C).Free / 1GB, 2)

            # Determine color for CPU, memory, and disk free space based on conditions
            $cpuColor = if ($cpuUsage -gt $cpuThreshold) { $colorWarning } else { $colorHeader }
            $memoryColor = if ($memoryUsagePercent -gt $memoryThreshold) { $colorWarning } else { $colorHeader }
            $diskColor = if ($systemDiskFreeGB -lt $diskThreshold) { $colorWarning } else { $colorHeader }

            # Get Windows build version
            $windowsBuild = (Get-ItemProperty "HKLM:\Software\Microsoft\Windows NT\CurrentVersion").CurrentBuild

            # Preload the process data and disk I/O counters
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
                Write-Host "Failed to retrieve disk counters: $_" -ForegroundColor Red
            }

            # Prepare the data for display
            $data = foreach ($process in $processes) {
                $name = if ($process.Name.Length -gt 15) { $process.Name.Substring(0, 15) } else { $process.Name.PadRight(15) }
                $id = $process.Id.ToString()
                $cpu = if ($process.CPU) { [math]::Round($process.CPU, 2).ToString() } else { "N/A" }
                $memory = [math]::Round($process.WorkingSet64 / 1MB, 2).ToString()  # Convert to MB
                $diskIO = if ($diskUsageDetails.ContainsKey($process.Name)) { $diskUsageDetails[$process.Name].ToString() } else { "N/A" }

                [PSCustomObject]@{
                    Name     = $name
                    ID       = $id
                    CPU      = $cpu
                    Memory   = $memory
                    DiskIO   = $diskIO
                }
            }

            # Handle "N/A" values before sorting
            $data | ForEach-Object {
                if ($_.CPU -eq "N/A") { $_.CPU = [double]::MinValue }
                if ($_.Memory -eq "N/A") { $_.Memory = [double]::MinValue }
                if ($_.DiskIO -eq "N/A") { $_.DiskIO = [double]::MinValue }
            }

            # Sort the data based on the specified column and take topN items
            $sortedData = switch ($sortBy.ToUpper()) {
                "CPU" { $data | Sort-Object -Property {[double]$_.'CPU'} -Descending | Select-Object -First $topN }
                "MEMORY" { $data | Sort-Object -Property {[double]$_.'Memory'} -Descending | Select-Object -First $topN }
                "DISKIO" { $data | Sort-Object -Property {[double]$_.'DiskIO'} -Descending | Select-Object -First $topN }
                Default { $data | Sort-Object -Property {[double]$_.'CPU'} -Descending | Select-Object -First $topN }
            }

            # Clear the screen for the next refresh
            #Clear-Host

            # Display the header bar with system information in two lines and conditional colors
            Write-Host "USER $username $block HOST $hostname $block OS $osName $block SYSTEM $systemManufacturer $systemModel" -ForegroundColor Cyan
            Write-Host "BUILD $windowsBuild $block CPU $([math]::Round($cpuUsage, 2))%" -ForegroundColor Cyan -NoNewline
            Write-Host " $([math]::Round($cpuUsage, 2))%" -ForegroundColor $cpuColor -NoNewline
            Write-Host " $block MEM $usedMemoryGB/$totalMemoryGB GB (" -ForegroundColor Cyan -NoNewline
            Write-Host "$memoryUsagePercent%" -ForegroundColor $memoryColor -NoNewline
            Write-Host ")" -ForegroundColor Cyan -NoNewline
            Write-Host " $block DISK $systemDiskFreeGB GB" -ForegroundColor $diskColor
            Write-Host

            # Display the table header manually
            Write-Host "Name                ID        CPU(s)       Memory (MB)      Disk I/O (MB/sec)" -ForegroundColor $colorHeader

            # Display each process with colors and adjusted spacing
            foreach ($item in $sortedData) {
                Write-Host "$($item.Name) " -ForegroundColor $colorName -NoNewline
                Write-Host "$($item.ID.PadLeft(10)) " -ForegroundColor $colorID -NoNewline
                Write-Host "$($item.CPU.PadLeft(10)) " -ForegroundColor $colorCPU -NoNewline
                Write-Host "$($item.Memory.PadLeft(15)) " -ForegroundColor $colorMemory -NoNewline
                Write-Host "$($item.DiskIO.PadLeft(20))" -ForegroundColor $colorDisk
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
        } catch {
            Write-Host "An error occurred: $_" -ForegroundColor Red
        }
    }
}

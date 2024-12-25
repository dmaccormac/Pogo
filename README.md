# Pogo (PowerShell Goto)

## Overview

The Pogo PowerShell Module is a collection of functions for system administration including Linux `top` style monitors for system and network information. 

## Features

- **System Monitoring**: Track CPU, memory, and disk space. Customizable refresh intervals and thresholds.
- **Network Monitoring**: Monitor network connections, bytes sent/received, and more.
- **Customizable Display**: Configure the number of items to display and sort by various metrics.

## Installation
Copy the Pogo folder to your PowerShell Modules directory, usually `$HOME\Documents\WindowsPowerShell\Modules`.

```bash
cd $HOME\Documents\WindowsPowerShell\Modules
git clone https://github.com/dmaccormac/Pogo
```

## Usage
Import the module into your PowerShell session with:
```powershell
Import-Module Pogo
```

## Functions

### New-PGSystemMonitor
Monitors system metrics such as CPU usage, memory usage, and disk space, and provides real-time updates.

#### Parameters:
- **refreshInterval**: Specifies the interval (in seconds) at which to refresh the system metrics.
- **sortBy**: Specifies the column by which to sort the process list. Valid values are 'CPU', 'Memory', and 'DiskIO'.
- **top**: Specifies the number of items to display in the view. Default value is 10.
- **watchProcess**: Specifies the name(s) of the process to highlight in the table view.

#### Example:
```powershell
New-PGSystemMonitor -refreshInterval 60 -sortBy CPU -topN 10
```


### New-PGNetworkMonitor
Monitors network connections and displays information about the top N connections.

#### Parameters:
- **interfaceName**: Network interface to monitor. Wi-Fi is default.
- **top**: Specifies the number of top network connections to display.
- **refreshInterval**: Specifies the interval (in seconds) at which to refresh the system metrics.
- **transferWarningThreshold**: Threshold for bytes transfer warning (in MB). Exceeds highlighted in yellow.
- **transferCriticalThreshold**: Threshold for bytes transfer critical (in MB). Exceeds highlighted in red.
- **watchProcess**: Specifies the name(s) of the process to highlight in the table view.

Example:
```powershell
New-PGNetworkMonitor -watchProcess msedge -refreshInterval 30 -transferCriticalThreshold 9.9 
```

## More functions

```bash
PS C:\Users\Dan> Get-Command -Module Pogo

CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Function        Exit-PGUserSession                                 1.2.1      Pogo
Function        Get-PGIPGeoLocation                                1.2.1      Pogo
Function        New-PGNetworkMonitor                               1.2.1      Pogo
Function        New-PGSystemMonitor                                1.2.1      Pogo
Function        Restart-PGComputer                                 1.2.1      Pogo
Function        Show-PGAdvancedSystemProperties                    1.2.1      Pogo
Function        Show-PGColorGrid                                   1.2.1      Pogo
Function        Show-PGColorList                                   1.2.1      Pogo
Function        Stop-PGComputer                                    1.2.1      Pogo
Function        Suspend-PGComputer                                 1.2.1      Pogo
Function        Switch-PGVolumeMute                                1.2.1      Pogo
```

## Aliases

```bash
PS C:\Users\Dan> Get-Alias -Name *PG*

CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Alias           PGadv -> Show-PGAdvancedSystemProperties           1.2.1      Pogo
Alias           PGnap -> Suspend-PGComputer                        1.2.1      Pogo
Alias           PGnet -> New-PGNetworkMonitor                      1.2.1      Pogo
Alias           PGoff -> Stop-PGComputer                           1.2.1      Pogo
Alias           PGout -> Exit-PGUserSession                        1.2.1      Pogo
Alias           PGpwr -> Show-PowerOptionsApplet                   1.2.1      Pogo
Alias           PGreb -> Restart-PGComputer                        1.2.1      Pogo
Alias           PGsys -> New-PGSystemMonitor                       1.2.1      Pogo
Alias           PGvol -> Switch-PGVolumeMute                       1.2.1      Pogo
```


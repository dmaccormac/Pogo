# Pogo (PowerShell Goto)

## Overview

The Pogo PowerShell Module is a collection of functions for system administration including Linux-style `top` monitors for system and network. 

## Features

- **System Monitoring**: Track CPU, memory, disk and system information.
- **Network Monitoring**: Monitor connections, ports, bandwidth and network statistics.
- **More**: Various system shortcuts and utilities which can be mapped to hot keys.

## Installation

1. Download the zip file [here](https://github.com/dmaccormac/Pogo/archive/refs/heads/main.zip)
2. Extract the Pogo folder to `$HOME\Documents\WindowsPowerShell\Modules`
3. Unblock Files

    ```powershell
    Unblock-File $HOME\Documents\WindowsPowerShell\Modules\Pogo\Pogo*
    ``` 

## Usage

### Import Module:

```powershell
Import-Module Pogo
```

### Verify Import:
```powershell
Get-Command -Module Pogo
```

## Functions

### New-PGSystemMonitor
Monitors system metrics such as CPU usage, memory usage, and disk space, and provides real-time updates.

#### Parameters:
- **refreshInterval**: Specifies the interval (in seconds) at which to refresh the system metrics.
- **sortBy**: Specifies the column by which to sort the process list. Valid values are 'CPU', 'Memory', and 'DiskIO'. Default value is 'Memory'.
- **top**: Specifies the number of items to display in the view. Default value is 10.
- **watchProcess**: Specifies the name(s) of the process to highlight in the table view. Must match truncated name (15 chars). 

#### Example 1:
```powershell
New-PGSystemMonitor -top 10 -sortBy CPU
```

#### Example 2:
```powershell
PGsys -watchProcess explorer -refreshInterval 30
```


### New-PGNetworkMonitor
Monitors network connections and displays information about the top N connections.

#### Parameters:
- **interfaceName**: Network interface to monitor. Wi-Fi is default.
- **top**: Specifies the number of top network connections to display.
- **refreshInterval**: Specifies the interval (in seconds) at which to refresh the system metrics.
- **transferWarningThreshold**: Threshold for bytes transfer warning (in MB). Exceeds highlighted in yellow.
- **transferCriticalThreshold**: Threshold for bytes transfer critical (in MB). Exceeds highlighted in red.
- **watchProcess**: Specifies the name(s) of the process to highlight in the table view. Must match truncated name (15 chars). 

#### Example 1:
```powershell
New-PGNetworkMonitor -watchProcess msedge -transferWarningThreshold 9.9
```

#### Example 2:
```powershell
PGnet -watchProcess msedge,firefox -interfaceName Ethernet2 
```

## More functions

```bash
PS C:\Users\Dan> Get-Command -Module Pogo

CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Function        Exit-PGUserSession                                 1.2.3      Pogo
Function        Get-PGIPGeoLocation                                1.2.3      Pogo
Function        New-PGNetworkMonitor                               1.2.3      Pogo
Function        New-PGSystemMonitor                                1.2.3      Pogo
Function        Restart-PGComputer                                 1.2.3      Pogo
Function        Show-PGAdvancedSystemProperties                    1.2.3      Pogo
Function        Show-PGColorGrid                                   1.2.3      Pogo
Function        Show-PGColorList                                   1.2.3      Pogo
Function        Show-PGPowerOptionsApplet                          1.2.3      Pogo
Function        Stop-PGComputer                                    1.2.3      Pogo
Function        Suspend-PGComputer                                 1.2.3      Pogo
Function        Switch-PGVolumeMute                                1.2.3      Pogo
```

## Aliases

```bash
PS C:\Users\Dan> Get-Alias -Name *PG*

CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Alias           PGadv -> Show-PGAdvancedSystemProperties           1.2.3      Pogo
Alias           PGcol -> Show-PGColorGrid                          1.2.3      Pogo
Alias           PGipg -> Get-PGIPGeoLocation                       1.2.3      Pogo
Alias           PGnap -> Suspend-PGComputer                        1.2.3      Pogo
Alias           PGnet -> New-PGNetworkMonitor                      1.2.3      Pogo
Alias           PGoff -> Stop-PGComputer                           1.2.3      Pogo
Alias           PGout -> Exit-PGUserSession                        1.2.3      Pogo
Alias           PGpwr -> Show-PGPowerOptionsApplet                 1.2.3      Pogo
Alias           PGreb -> Restart-PGComputer                        1.2.3      Pogo
Alias           PGsys -> New-PGSystemMonitor                       1.2.3      Pogo
Alias           PGvol -> Switch-PGVolumeMute                       1.2.3      Pogo
```


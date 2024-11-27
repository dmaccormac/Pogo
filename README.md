# Pogo PowerShell Module

## Overview

The Pogo PowerShell Module provides advanced monitoring tools for system and network performance. It includes functions to monitor CPU usage, memory usage, disk space, network connections, and more, in real time.


## Features

- **System Monitoring**: Track CPU, memory usage, and disk space with customizable refresh intervals and thresholds.
- **Network Monitoring**: Monitor network connections, bytes sent/received, and more.
- **Real-Time Updates**: Get real-time performance metrics with options to refresh the data on demand.
- **Customizable Display**: Configure the number of items to display, and sort by various metrics such as CPU, memory, and disk I/O.


## Functions

### New-PogoSystemMonitor
Monitors system metrics such as CPU usage, memory usage, and disk space, and provides real-time updates.

#### Parameters:
- **refreshInterval**: Specifies the interval (in seconds) at which to refresh the system metrics.
- **sortBy**: Specifies the column by which to sort the process list. Valid values are 'CPU', 'Memory', and 'DiskIO'.
- **topN**: Specifies the number of items to display in the view. Default value is 10.

#### Example:
```powershell
New-PogoSystemMonitor -refreshInterval 60 -sortBy CPU -topN 10
```


### New-PogoNetworkMonitor
Monitors network connections and displays information about the top N connections.

#### Parameters:
- **topN**: Specifies the number of top network connections to display.
- **refreshInterval**: Specifies the interval (in seconds) at which to refresh the network information.
- **sentThreshold**: Specifies the threshold for bytes sent (in MB).
- **receivedThreshold**: Specifies the threshold for bytes received (in MB).

Example:
```powershell
New-PogoNetworkMonitor -topN 10 -refreshInterval 60 -sentThreshold 10.0 -receivedThreshold 10.0
```

## Installation
To install the Pogo PowerShell Module, copy the module files to your PowerShell modules directory, typically located at:
```powershell
C:\Users\<YourUsername>\Documents\WindowsPowerShell\Modules\Pogo
```

## Usage
Import the module into your PowerShell session with:
```powershell
Import-Module Pogo
```
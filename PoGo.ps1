<#
.SYNOPSIS
    This script dynamically calls functions based on command-line arguments or user input.

.DESCRIPTION
    If no arguments are provided, the script prompts the user to enter commands in a loop.
    The user can type 'exit' to quit the loop. For each entered command, the script checks 
    if a corresponding function exists and calls it. If no matching function is found, 
    it calls the DefaultFunction.

    Functions:
    pwr - Power Configuration
    sys - System Properties
    nap - System Sleep

.PARAMETER args
    One or more arguments that represent the names of the functions to call.

.EXAMPLE
    .\pogo.ps1 pwr
    Opens the Power Configuration Control Panel Applet

.LINK 
https://github.com/dmaccormac

.NOTES
    24.11.22 - Initial version
#>


# -- Functions --

# System Sleep
function nap {
    Write-Output "Putting the computer to sleep..."
    Start-Process rundll32.exe -ArgumentList "powrprof.dll,SetSuspendState Sleep"

}

# System Properties
function sys {
    Write-Output "Starting System Properties...";
    Start-Process sysdm.cpl

}

# Power Configuration
function pwr {
    Write-Output "Starting Power Configuration...";
    Start-Process powercfg.cpl

}

# Function to get BBC world news headline
function bbc {
    $url = "https://feeds.bbci.co.uk/news/rss.xml"
    $rssContent = Invoke-WebRequest -Uri $url

    # Replace CDATA sections using String.Replace
    $cleanContent = $rssContent.Content.Replace("<![CDATA[", "").Replace("]]>", "")

    # Convert to XML
    $rss = [xml]$cleanContent

    # Get the first item in the RSS feed
    $headline = $rss.rss.channel.item[0].title

    return $headline
}



# This function is called when no matching function is found
function DefaultFunction {
    Write-Output "${arg}: command not found"
}

# -- Main Logic --
if ($args.Count -eq 0) {
    # No arguments provided, enter a looping prompt
    while ($true) {
        $arg = Read-Host "pogo"
        if ($arg -eq 'exit') {
            Write-Output "Goodbye"
            break
        }
        
        # Check if the command exists and call it, otherwise call DefaultFunction
        if (Get-Command $arg -ErrorAction SilentlyContinue) {
            & $arg
        } else {
            DefaultFunction
        }
    }
} else {
    # Arguments provided, iterate through each argument
    foreach ($arg in $args) {
        # Check if the command exists and call it, otherwise call DefaultFunction
        if (Get-Command $arg -ErrorAction SilentlyContinue) {
            & $arg
        } else {
            DefaultFunction
        }
    }
}

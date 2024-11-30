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
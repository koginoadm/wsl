@setlocal enableextensions enabledelayedexpansion & set "PATH0=%~f0" & PowerShell.exe -Command "& (Invoke-Expression -Command ('{#' + ((Get-Content '!PATH0:'=''!') -join \"`n\") + '}'))" %* & exit /b !errorlevel!
#
# - Name
#     sshd.bat
#
# - Contents
#     like init script.
#
# - Install
#     powershell.exe -Command "Invoke-RestMethod -Uri "https://koginoadm.github.io/wsl/service/sshd.bat" -OutFile "$env:USERPROFILE\sshd.bat""
#
# - Reference
#     
#
# - Revision
#     2017-07-07 created.
#     2017-07-08 modified.
#     2017-09-23 modified.
#     yyyy-MM-dd modified.
#

$vDaemonName = 'sshd'
$vDeamonCommand = '/usr/sbin/sshd -D'
$vDeamonStop = '[[ -f /var/run/sshd.pid ]] && kill $(cat /var/run/sshd.pid)'
$vPid = C:\Windows\System32\bash.exe -c 'pgrep -f /usr/sbin/sshd'

function service_start()
{
    if ($vPid)
    {
        Write-Warning "$(Get-Date -Format yyyy-MM-ddTHH:mm:sszzz) [WARN]: $vDaemonName (pid $vPid) is running..."
        Start-Sleep 5
    }
    else
    {
        $wsh = New-Object -comObject WScript.Shell
        $wsh.Run("C:\Windows\System32\bash.exe -c '$vDeamonCommand'", 0)
    }
}

function service_stop()
{
    C:\Windows\System32\bash.exe -c $vDeamonStop
}

function service_restart()
{
    C:\Windows\System32\bash.exe -c $vDeamonStop
    $wsh = New-Object -comObject WScript.Shell
    $wsh.Run("C:\Windows\System32\bash.exe -c '$vDeamonCommand'", 0)
}

function service_status()
{
    if ($vPid)
    {
        Write-Warning "$(Get-Date -Format yyyy-MM-ddTHH:mm:sszzz) [INFO]: $vDaemonName (pid $vPid) is running..."
        Start-Sleep 5
    }
    else
    {
        Write-Warning "$(Get-Date -Format yyyy-MM-ddTHH:mm:sszzz) [INFO]: $vDaemonName is not running..."
        Start-Sleep 5
    }
}

function service_usage()
{
    Write-Warning "$(Get-Date -Format yyyy-MM-ddTHH:mm:sszzz) [INFO]: Usage: $vDaemonName {start|stop|restart|status}"
    Start-Sleep 5
}


if($args[0] -eq 'start')
{
    service_start
}
elseif($args[0] -eq 'stop')
{
    service_stop
}
elseif($args[0] -eq 'restart')
{
    service_restart
}
elseif($args[0] -eq 'status')
{
    service_status
}
else
{
    service_usage
}


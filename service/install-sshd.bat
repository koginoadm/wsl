@setlocal enableextensions enabledelayedexpansion & set "PATH0=%~f0" & PowerShell.exe -Command "& (Invoke-Expression -Command ('{#' + ((Get-Content '!PATH0:'=''!') -join \"`n\") + '}'))" %* & exit /b !errorlevel!
#
# - Name
#     install-sshd.bat
#
# - Contents
#     sshd
#
# - Install
#     powershell.exe -Command "Invoke-RestMethod -Uri "https://koginoadm.github.io/wsl/service/install-sshd.bat" -OutFile "$env:USERPROFILE\install-sshd.bat""
#
# - Reference
#     
#


################
# main
################
### check Administrator
if (-Not([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator'))
{
    Write-Warning "$(Get-Date -Format yyyy-MM-ddTHH:mm:sszzz) [WARN]: Run as Administrator."
    Start-Sleep 5
    exit 1
}

### allow ssh
$netFirewallRule = Get-NetFirewallRule
if (!(($netFirewallRule | Where-Object Name -Match SSH-In-TCP).Enabled))
{
    Write-Host "$(Get-Date -Format yyyy-MM-ddTHH:mm:sszzz) [INFO]: Allow SSH (TCP/22)."
    New-NetFirewallRule -Name SSH-In-TCP -DisplayName "SSH" -Description "Allow SSH (TCP/22)" -Protocol TCP -LocalPort 22 -Enabled True -Profile Any -Action Allow
}

### setup linux
Write-Host "$(Get-Date -Format yyyy-MM-ddTHH:mm:sszzz) [INFO]: Setup `"sshd`""
C:\WINDOWS\system32\bash.exe -c '! ls /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key /etc/ssh/ssh_host_ecdsa_key /etc/ssh/ssh_host_ed25519_key > /dev/null 2>&1 && sudo dpkg-reconfigure openssh-server # for generate ssh-server key'
C:\WINDOWS\system32\bash.exe -c "egrep '^UsePrivilegeSeparation yes' /etc/ssh/sshd_config --quiet && sudo sed -r -e 's/^(UsePrivilegeSeparation )(yes)/# `$(date +%Y%m%d) #\1\2\n\1no/g' /etc/ssh/sshd_config -i_`$(date +%Y%m%d_%H%M%S).backup # edit /etc/ssh/sshd_config"
C:\WINDOWS\system32\bash.exe -c '[[ ! -d ${HOME}/.ssh ]] && mkdir -m 700 -p ${HOME}/.ssh'
C:\WINDOWS\system32\bash.exe -c '[[ ! -s ${HOME}/.ssh/authorized_keys ]] && touch ${HOME}/.ssh/authorized_keys && chmod 600 ${HOME}/.ssh/authorized_keys'

Write-Host "$(Get-Date -Format yyyy-MM-ddTHH:mm:sszzz) [INFO]: Installed."

### add publick key
$judge_authkeys = C:\WINDOWS\system32\bash.exe -c 'cat ${HOME}/.ssh/authorized_keys 2>/dev/null'
if (!($judge_authkeys))
{
    Write-Host "$(Get-Date -Format yyyy-MM-ddTHH:mm:sszzz) [INFO]: Add your public key to authorized_keys"
    Write-Host "$(Get-Date -Format yyyy-MM-ddTHH:mm:sszzz) [INFO]: Example: bash.exe -c `"curl -LRsS https://github.com/`$USER.keys >> /root/.ssh/authorized_keys`""
}

### exit
Write-Host "Pless any key..."
[Console]::ReadKey() | Out-Null



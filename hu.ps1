function Check-Hosts {    
    $is_exist = Test-Path $hosts
    return $is_exist
}

function Update-Hosts {
    $url = "https://someonewhocares.org/hosts/hosts"
    #Write-Host "Downloading update..." $url -ForegroundColor Green
    Invoke-WebRequest -Uri $url -UserAgent [Microsoft.PowerShell.Commands.PSUserAgent]::FireFox -OutFile "hosts.new"
    
    $currentHash = Get-FileHash $hosts -Algorithm MD5
    $newHash = Get-FileHash "hosts.new" -Algorithm MD5
    
    if ($currentHash.Hash -ne $newHash.Hash) {
        Copy-Item -Path $hosts -Destination "${hosts}_BACKUP"
        Remove-Item -Path $hosts
        Copy-Item -Path "hosts.new" -Destination $hosts
        Remove-Item -Path "hosts.new"
    }
    else {
        Remove-Item -Path "hosts.new"
        exit 0
        #$balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
        #$balloon.BalloonTipText = "No need to update hosts file!"
        #$balloon.BalloonTipTitle = "Hosts updater"
        #$balloon.Visible = $true 
        #$balloon.ShowBalloonTip(5000)    
    }
}

function Test-Admin {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

# Main script entry point
if (Test-Admin) {
    Write-Host "Running script with administrator privileges" -ForegroundColor Yellow
}
else {
    Write-Host "Running script without administrator privileges" -ForegroundColor Red
    exit 1
}

$hosts = "C:\Windows\system32\drivers\etc\hosts"
Add-Type -AssemblyName System.Windows.Forms
$global:balloon = New-Object System.Windows.Forms.NotifyIcon
$path = (Get-Process -id $pid).Path
$balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path) 

if (Check-Hosts) {
    try {
        Update-Hosts
        #Write-Host "Operation completed" -ForegroundColor Magenta
        $balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
        $balloon.BalloonTipText = "Hosts file updated successfully!"
        $balloon.BalloonTipTitle = "Hosts updater"
        $balloon.Visible = $true 
        $balloon.ShowBalloonTip(5000)
        #exit 0
    }
    catch [System.Exception] {
        #Write-Host $_.Exception.Message -ForegroundColor Red
        $balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Error
        $balloon.BalloonTipText = "Error updating hosts file!"
        $balloon.BalloonTipTitle = "Hosts updater"
        $balloon.Visible = $true 
        $balloon.ShowBalloonTip(5000)
        exit 1
    }
}
else {
    #Write-Host "Hosts file does not exist!" -ForegroundColor Red
    $balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Error
    $balloon.BalloonTipText = "Hosts file does not exist!"
    $balloon.BalloonTipTitle = "Hosts updater"
    $balloon.Visible = $true 
    $balloon.ShowBalloonTip(5000)
    exit 1
}
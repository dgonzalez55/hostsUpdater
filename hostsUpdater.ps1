#Comprova si estem executant el script en mode Administrador
function Test-Admin {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

#Comprova si existeix el fitxer de hosts dins del sistema
function Check-Hosts {    
    $is_exist = Test-Path $hosts
    return $is_exist
}

#Actualitzar el fitxer de hosts amb darrera llista negra
function Update-Hosts {
    $url = "https://someonewhocares.org/hosts/hosts"
    $balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
    $balloon.BalloonTipText = "Descarregant darrera versió de fitxer de Hosts: " + $url
    $balloon.BalloonTipTitle = "Hosts updater"
    $balloon.Visible = $true 
    $balloon.ShowBalloonTip(3000)    
    
    Invoke-WebRequest -Uri $url -UserAgent [Microsoft.PowerShell.Commands.PSUserAgent]::FireFox -OutFile "hosts.new"
    
    $currentHash = Get-FileHash $hosts -Algorithm MD5
    $newHash = Get-FileHash "hosts.new" -Algorithm MD5
    
    if ($currentHash.Hash -ne $newHash.Hash) {
        Copy-Item -Path $hosts -Destination "${hosts}_BACKUP"
        Copy-Item -Path "hosts.new" -Destination $hosts
        Remove-Item -Path "hosts.new"
    }
    else {
        Remove-Item -Path "hosts.new"
        $balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
        $balloon.BalloonTipText = "El fitxer de hosts ja es troba a la darrera versió!"
        $balloon.BalloonTipTitle = "Hosts updater"
        $balloon.Visible = $true 
        $balloon.ShowBalloonTip(3000)    
        exit 0
    }
}

# Script Principal (Entry Point)
if (Test-Admin) {
    Write-Host "hostsUpdater executant-se amb privilegis d'administrador" -ForegroundColor Yellow
}
else {
    Write-Host "hostsUpdater requereix de privilegis d'administrador" -ForegroundColor Red
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
        Clear-DnsClientCache
        $balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
        $balloon.BalloonTipText = "Fitxer de Hosts Actualitzat!"
        $balloon.BalloonTipTitle = "Hosts updater"
        $balloon.Visible = $true 
        $balloon.ShowBalloonTip(5000)
        exit 0
    }
    catch [System.Exception] {
        $balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Error
        $balloon.BalloonTipText = "Error al actualitzar el fitxer de hosts!"
        $balloon.BalloonTipTitle = "Hosts updater"
        $balloon.Visible = $true 
        $balloon.ShowBalloonTip(5000)
        exit 1
    }
}
else {
    $balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Error
    $balloon.BalloonTipText = "El fitxer de hosts no existeix a la ubicació esperada!"
    $balloon.BalloonTipTitle = "Hosts updater"
    $balloon.Visible = $true 
    $balloon.ShowBalloonTip(5000)
    exit 1
}
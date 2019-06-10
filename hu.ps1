function Check-Hosts {    
    $is_exist = Test-Path $hosts
    return $is_exist
}

function Update-Hosts {
    $url = "https://someonewhocares.org/hosts/hosts"
    Write-Host "Downloading update..." $url -ForegroundColor Green
    Invoke-WebRequest -Uri $url -UserAgent [Microsoft.PowerShell.Commands.PSUserAgent]::FireFox -OutFile "hosts.new"
    Copy-Item -Path $hosts -Destination "${hosts}_BACKUP"
    Remove-Item -Path $hosts
    Copy-Item -Path "hosts.new" -Destination $hosts
    Remove-Item -Path "hosts.new"    
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

if (Check-Hosts) {
    try {
        Update-Hosts
        Write-Host "Operation completed" -ForegroundColor Magenta
    }
    catch [System.Exception] {
        Write-Host $_.Exception.Message -ForegroundColor Red
        exit 1
    }
}
else {
    Write-Host "Hosts file does not exist!" -ForegroundColor Red
    exit 1
}

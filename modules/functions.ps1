function Check-IfInstalled ($executablePath) {
    if ((Test-Path "$x64PF\$executablePath") -or (Test-Path "$x86PF\$executablePath")) {
        return $true
    }
    return $false
}

function Get-InstalledPath ($executablePath) {
    if (Test-Path "$x64PF\$executablePath") {
        return "$x64PF\$executablePath"
    } elseif (Test-Path "$x86PF\$executablePath") {
        return "$x86PF\$executablePath"
    }
    return $null
}

function Check-Process ($processName) {
    if (Get-Process -Name $processName -ErrorAction SilentlyContinue) {
        return $true
    }
    return $false
}

function Kill-Process ($processName) {
    Get-Process -Name $processName | Stop-Process -Force
}
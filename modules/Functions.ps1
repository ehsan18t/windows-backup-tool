function Check-IfInstalled ($executablePath, [switch]$exact) {
    if ($exact) {
        $file1 = Get-ChildItem -Path $executablePath -File -ErrorAction SilentlyContinue
        return $file1 -ne $null
    }

    $file1 = Get-ChildItem -Path "$x64PF\$executablePath" -File -ErrorAction SilentlyContinue
    $file2 = Get-ChildItem -Path "$x86PF\$executablePath" -File -ErrorAction SilentlyContinue

    return ($file1 -ne $null) -or ($file2 -ne $null)
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
    $logger.info("Stopping $processName...")
    Get-Process -Name $processName | Stop-Process -Force
}

function Run-Process ($executablePath, $processName) {
    if (-not $processName) {
        $processName = (Split-Path -Leaf $executablePath)
    }

    $logger.info("Starting $processName...")

    Start-Process -FilePath $executablePath
}
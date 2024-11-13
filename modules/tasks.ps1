$consoleLocation = New-Object System.Drawing.Point($consoleX, $consoleY)
$logger = [Logger]::new($consoleWidth, $consoleHeight, $consoleLocation)

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

$tasks = @(
    [PSCustomObject]@{
        Text = "QBitTorrent"
        BackupAction = {
            $process = "qbittorrent"
            $backupPath = "$baseBackupPath\" + "QBitTorrent"
            $isRunning = (Check-Process $process)
            $executablePath = Get-InstalledPath "qBittorrent\qbittorrent.exe"

            if (-not $executablePath) {
                $logger.error("qBittorrent is not found.")
                return
            }

            if ($isRunning) {
                Kill-Process $process
                $logger.warning("Stopping qBittorrent...")
            }

            if (Test-Path $backupPath) {
                $logger.warning("A backup already exists at $backupPath. Skipping...")
            } else {
                Copy-Item -path "$userProfile\AppData\Local\qBittorrent" -Destination "$backupPath\Local" -Recurse -Force
                Copy-Item -path "$userProfile\AppData\Roaming\qBittorrent" -Destination "$backupPath\Roaming" -Recurse -Force
                $logger.success("Backing up qBittorrent to $backupPath")
            }

            if ($isRunning) {
                $logger.info("Starting $executablePath...")
                Start-Process -FilePath $executablePath
            }
        }
        RestoreAction = {
            "Restore action for Create Sample File task..."
        }
        Visible = (Check-IfInstalled "qBittorrent\qbittorrent.exe")
    }

    [PSCustomObject]@{
        Text = "Delete Sample File"
        BackupAction = {
            # Delete the sample file if it exists
            $filePath = "C:\SampleFile.txt"
            if (Test-Path $filePath) {
                Remove-Item $filePath -Force
                "Deleted file at $filePath"
            } else {
                "File not found at $filePath."
            }
        }
        RestoreAction = {
            "Restore action for Deleted Sample File task..."
        }
        Visible = $true
    }

    [PSCustomObject]@{
        Text = "Task 1"
        BackupAction = { "Task 1..." }
        RestoreAction = { "Restore task 1..." }
        Visible = $true
    }

    [PSCustomObject]@{
        Text = "Task 2"
        BackupAction = { "Task 2..." }
        RestoreAction = { "Restore task 2..." }
        Visible = $true
    }

    [PSCustomObject]@{
        Text = "Task 3"
        BackupAction = { "Task 3..." }
        RestoreAction = { "Restore task 3..." }
        Visible = $false
    }
)

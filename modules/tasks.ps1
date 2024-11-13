function Common {
    param (
        $constants,
        $task = "",
        $backupFunction
    )

    $logger.task("$task $($constants.name)")

    if (-not $constants.executablePath) {
        $logger.error("$($constants.name) is not found.")
        return
    }

    $response = "Yes"
    $alreadyExists = Test-Path $constants.backupPath
    if ($alreadyExists) {
        $logger.warning("A backup already exists at $($constants.backupPath).")
        $response = Show-ChoicePopup -title "Action Required" -message "Do you want to override the old backup?"
    }

    if ($response -eq "Yes") {
        if ($constants.isRunning) {
            Kill-Process $constants.process
        }

        if ($alreadyExists) {
            $logger.warning("Deleting old backup...")
            if ((Test-Path -Path $constants.backupPath -PathType Leaf)) {
                Remove-Item -Path $constants.backupPath -Force
                # $logger.info("Type: File")
            } else {
                Remove-Item $constants.backupPath -Recurse -Force
                # $logger.info("Type: Directory")
            }
        }

        $logger.info("Creating new backup...")

        New-Item -ItemType Directory -Path (Split-Path -Path $constants.backupPath)
        $backupFunction.Invoke()
        $logger.success("Backup created successfully.")

        if ($constants.isRunning) {
            Run-Process $constants.executablePath
        }
    }
}

$tasks = @(
    [PSCustomObject]@{
        Text = "qBittorrent"
        Constants = @{
            name = "qBittorrent"
            process = "qbittorrent"
            isRunning = (Check-Process "qbittorrent")
            backupPath = "$baseBackupPath\qBittorrent"
            executablePath = (Get-InstalledPath "qBittorrent\qbittorrent.exe")
            localDataPath = "$localAppData\qBittorrent"
            roamingDataPath = "$roamingAppData\qBittorrent"
        }
        BackupAction = {
            param (
                $constants
            )

            Common $constants "Backup" {
                Copy-Item -path $constants.localDataPath -Destination "$($constants.backupPath)\Local" -Recurse -Force
                Copy-Item -path $constants.roamingDataPath -Destination "$($constants.backupPath)\Roaming" -Recurse -Force
            }
        }
        RestoreAction = {
            param (
                $constants
            )

            $logger.task("Restore $($constants.name)")

            $response = "Cancel"
            $response = Show-ChoicePopup -message "Choose a restore method" -title "Options" -choices @(
                @{ Text = "Override"; Result = "Override"; Color = [System.Drawing.Color]::FromArgb(0, 91, 65) },
                @{ Text = "Clean"; Result = "Clean"; Color = [System.Drawing.Color]::FromArgb(227,66,52) },
                @{ Text = "Cancel"; Result = "Cancel"; Color = [System.Drawing.Color]::FromArgb(135,169,107) }
            )

            if (($response -eq "Cancel") -or (-not $response)) {
                $logger.warning("Restore operation cancelled.")
                return
            }

            if ($constants.isRunning) {
                Kill-Process $constants.process
            }

            if ($response -eq "Clean") {
                $logger.warning("Cleaning qBittorrent Data...")
                Remove-Item $constants.localDataPath -Recurse -Force
                Remove-Item $constants.roamingDataPath -Recurse -Force
            }

            $logger.info("Restoring qBittorrent Data...")
            Copy-Item -path "$($constants.backupPath)\Local" -Destination $constants.localDataPath -Recurse -Force
            Copy-Item -path "$($constants.backupPath)\Roaming" -Destination $constants.roamingDataPath -Recurse -Force

            if ($constants.isRunning) {
                Run-Process $constants.executablePath
            }
        }
        Visible = (Check-IfInstalled "qBittorrent\qbittorrent.exe")
    }

    [PSCustomObject]@{
        Text = "Windows Terminal"
        Constants = @{
            name = "Windows Terminal"
            backupPath = "$baseBackupPath\WindowsTerminal\settings.json"
            dataPath = "$localAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
            executablePath = "$localAppData\Microsoft\WindowsApps\wt.exe"
        }
        BackupAction = {
            param (
                $constants
            )

            Common $constants "Backup" {
                Copy-Item $constants.dataPath -Destination $constants.backupPath
            }
        }
        RestoreAction = {
            param (
                $constants
            )

            $logger.task("Restore $($constants.name)")

            if (!(Test-Path $constants.backupPath)) {
                $logger.error("Backup not found.")
                return
            }

            Remove-Item $constants.dataPath -Force
            Copy-Item $constants.backupPath -Destination $constants.dataPath
            $logger.success("Restored successfully.")
        }
        Visible = (Check-IfInstalled "$userProfile\AppData\Local\Microsoft\WindowsApps\wt.exe" -exact)
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

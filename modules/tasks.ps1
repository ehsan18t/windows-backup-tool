$tasks = @(
    [PSCustomObject]@{
        Text = "qBittorrent"
        Constants = @{
            name = "qBittorrent"
            process = "qbittorrent"
            isRunning = (Check-Process "qbittorrent")
            backupPath = "$baseBackupPath\qBittorrent"
            executablePath = (Get-InstalledPath "qBittorrent\qbittorrent.exe")
        }
        BackupAction = {
            param (
                $constants
            )

            $logger.task($constants.name)

            if (-not $constants.executablePath) {
                $logger.error("qBittorrent is not found.")
                return
            }

            if ($constants.isRunning) {
                Kill-Process $constants.process
                $logger.warning("Stopping qBittorrent...")
            }

            $response = "Proceed"
            $alreadyExists = Test-Path $constants.backupPath
            if ($alreadyExists) {
                $logger.warning("A backup already exists at $($constants.backupPath).")
                $response = Show-ChoicePopup -choice1 "Proceed" -choice2 "Cancel" -choice1Result "Proceed" -choice2Result "Cancel" -title "Action Required" -message "Do you want to override the old backup?"
            }

            if ($response -eq "Proceed") {
                if ($alreadyExists) {
                    $logger.warning("Deleting old backup...")
                    Remove-Item $constants.backupPath -Recurse -Force
                }

                $logger.info("Creating backup...")
                Copy-Item -path "$userProfile\AppData\Local\qBittorrent" -Destination "$($constants.backupPath)\Local" -Recurse -Force
                Copy-Item -path "$userProfile\AppData\Roaming\qBittorrent" -Destination "$($constants.backupPath)\Roaming" -Recurse -Force
                $logger.success("Backup created successfully.")
            }

            if ($constants.isRunning) {
                $logger.info("Starting qBittorrent...")
                Start-Process -FilePath $constants.executablePath
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

$consoleLocation = New-Object System.Drawing.Point($consoleX, $consoleY)
$logger = [Logger]::new($consoleWidth, $consoleHeight, $consoleLocation)

$tasks = @(
    [PSCustomObject]@{
        Text = "Create Sample File"
        BackupAction = {
            # Create a sample file for testing
            $filePath = "C:\SampleFile.txt"
            if (-not (Test-Path $filePath)) {
                New-Item -ItemType File -Path $filePath
                "Created file at $filePath"
            } else {
                "File already exists at $filePath."
            }
        }
        RestoreAction = {
            "Restore action for Create Sample File task..."
        }
        Visible = $true
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

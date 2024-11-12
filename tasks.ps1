$tasks = @(
    [PSCustomObject]@{
        Text = "Create Sample File"
        Action = {
            # Create a sample file for testing
            $filePath = "C:\SampleFile.txt"
            if (-not (Test-Path $filePath)) {
                New-Item -ItemType File -Path $filePath
                "Created file at $filePath"
            } else {
                "File already exists at $filePath."
            }
        }
        Visible = $true
    }

    [PSCustomObject]@{
        Text = "Delete Sample File"
        Action = {
            # Delete the sample file if it exists
            $filePath = "C:\SampleFile.txt"
            if (Test-Path $filePath) {
                Remove-Item $filePath -Force
                "Deleted file at $filePath"
            } else {
                "File not found at $filePath."
            }
        }
        Visible = $true
    }

    [PSCustomObject]@{
        Text = "Task 1"
        Action = { "Task 1..." }
        Visible = $true
    }

    [PSCustomObject]@{
        Text = "Task 2"
        Action = { "Task 2..." }
        Visible = $true
    }

    [PSCustomObject]@{
        Text = "Task 3"
        Action = { "Task 3..." }
        Visible = $false
    }
)

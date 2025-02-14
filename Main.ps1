# --- Load Constants and Configurations ---
$root = $PSScriptRoot
$backupPath = "$root\Backup"
$userProfile = [System.Environment]::GetFolderPath("UserProfile")
$localAppData = "$userProfile\AppData\Local"
$roamingAppData = "$userProfile\AppData\Roaming"
$x64PF = [System.Environment]::GetFolderPath("ProgramFiles")
$x86PF = [System.Environment]::GetFolderPath("ProgramFilesX86")

# --- Retrieve UI Elements ---
$global:TaskPanelLeft = $global:window.FindName("TaskPanelLeft")
$global:TaskPanelRight = $global:window.FindName("TaskPanelRight")
$global:startButton = $global:window.FindName("StartButton")
$global:OutputBox.Document.Blocks.Clear()
$global:OutputBox.Document.PagePadding = [System.Windows.Thickness]::new(0)

# --- Set Up Runspace Pool and Timer ---
$global:syncHash = [Hashtable]::Synchronized(@{})
$global:syncHash.Jobs = [System.Collections.ArrayList]::new()
$global:syncHash.RunspacePool = [RunspaceFactory]::CreateRunspacePool(1, $global:config.RunspacePoolSize)
$global:syncHash.RunspacePool.Open()
$global:timer = New-Object System.Windows.Threading.DispatcherTimer
$global:timer.Interval = [TimeSpan]::FromMilliseconds(500)

# --- Create and Distribute Checkboxes ---
$totalItems = $global:config.Items.Count
$half = [Math]::Ceiling($totalItems / 2)
$index = 0

foreach ($item in $global:config.Items) {
    $checkbox = New-Object System.Windows.Controls.CheckBox
    $checkbox.Content = $item
    $checkbox.Foreground = "White"
    $checkbox.HorizontalAlignment = "Stretch"
    $checkbox.Margin = "4"
    
    if ($index -lt $half) {
        $global:TaskPanelLeft.Children.Add($checkbox)
    } else {
        $global:TaskPanelRight.Children.Add($checkbox)
    }
    $index++
}

# --- Start Button Click Event: Launch Selected Tasks ---
$global:startButton.Add_Click({
    $global:startButton.IsEnabled = $false

    $response = [System.Windows.MessageBoxResult]::No
    $backExists = Test-Path $backupPath
    if ($backExists) {
        $response = Show-ConfirmationPopup -Message "A backup already exists. Do you want to override the old backup?" -Title "Confirm Task Start"
    }

    if ($response -eq [System.Windows.MessageBoxResult]::Yes) {
        Remove-Item $backupPath -Recurse -Force
    } elseif ($backExists -and ($response -eq [System.Windows.MessageBoxResult]::No)) {
        Log-Warn "Backup creation cancelled."
        $global:startButton.IsEnabled = $true
        return
    }

    $selectedTasksLeft = @($global:TaskPanelLeft.Children | Where-Object { $_ -is [System.Windows.Controls.CheckBox] -and $_.IsChecked -eq $true })
    $selectedTasksRight = @($global:TaskPanelRight.Children | Where-Object { $_ -is [System.Windows.Controls.CheckBox] -and $_.IsChecked -eq $true })
    $selectedTasks = $selectedTasksLeft + $selectedTasksRight

    if (-not $selectedTasks) {
        [System.Windows.MessageBox]::Show("Please select at least one task!", "Warning", "OK", "Warning")
        $global:startButton.IsEnabled = $true
        return
    }

    foreach ($task in $selectedTasks) {
        $taskName = $task.Content
        if ($global:TaskFunctions.ContainsKey($taskName)) {
            $taskScript = $global:TaskFunctions[$taskName]
        } else {
            $taskScript = {
                param($taskName);
                return "$taskName not found!"
            }
        }

        $powershell = [PowerShell]::Create().AddScript($taskScript).AddArgument($taskName)
        $powershell.RunspacePool = $global:syncHash.RunspacePool

        $job = [PSCustomObject]@{
            PowerShell = $powershell
            Handle     = $powershell.BeginInvoke()
            TaskName   = $taskName
            Completed  = $false
        }
        $global:syncHash.Jobs.Add($job) | Out-Null
    }

    # Monitor the jobs using the timer
    $global:timer.Add_Tick({
        foreach ($job in $global:syncHash.Jobs.ToArray()) {
            if ($job.Handle.IsCompleted -and -not $job.Completed) {
                try {
                    $result = $job.PowerShell.EndInvoke($job.Handle)
                    Log-Info "$result"
                } catch {
                    Log-Err "$($_.Exception.Message)"
                } finally {
                    $job.PowerShell.Dispose()
                    $global:syncHash.Jobs.Remove($job)
                }
            }
        }

        if ($global:syncHash.Jobs.Count -eq 0) {
            $global:timer.Stop()
            $global:startButton.Dispatcher.Invoke([Action]{ $global:startButton.IsEnabled = $true })
            Log-Success "All tasks completed!"
        }
    })
    $global:timer.Start()
})

# --- Cleanup When Window Closes ---
$global:window.Add_Closed({
    $global:timer.Stop()
    $global:syncHash.RunspacePool.Close()
    $global:syncHash.RunspacePool.Dispose()
})

# --- Show the Window ---
try {
    $global:window.ShowDialog() | Out-Null
} catch {
    [System.Windows.MessageBox]::Show("Error: $_", "Error", "OK", "Error")
}

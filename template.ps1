Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Drawing

# XAML for the WPF UI
[xml]$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Modern Multi-threaded Task Runner"
    Height="600"
    Width="500"
    WindowStartupLocation="CenterScreen"
    ResizeMode="NoResize"
    Background="#2D2D30"
    Foreground="White">

    <Window.Resources>
        <Style TargetType="ScrollBar">
            <Setter Property="Width" Value="8"/>
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ScrollBar">
                        <Grid Background="{TemplateBinding Background}">
                            <Track x:Name="PART_Track"
                                   Focusable="False"
                                   IsDirectionReversed="True">
                                <Track.DecreaseRepeatButton>
                                    <RepeatButton Command="ScrollBar.LineUpCommand"
                                                  Height="0"
                                                  Opacity="0"
                                                  IsTabStop="False"/>
                                </Track.DecreaseRepeatButton>
                                
                                <Track.Thumb>
                                    <Thumb x:Name="Thumb"
                                           Background="#007ACC"
                                           Opacity="0.8"
                                           Width="8">
                                        <Thumb.Template>
                                            <ControlTemplate TargetType="Thumb">
                                                <Border x:Name="Border"
                                                        Background="{TemplateBinding Background}"
                                                        CornerRadius="4"
                                                        Width="{TemplateBinding Width}"
                                                        Height="{TemplateBinding Height}"
                                                        Opacity="{TemplateBinding Opacity}">
                                                </Border>
                                                <ControlTemplate.Triggers>
                                                    <!-- Hover effect -->
                                                    <Trigger Property="IsMouseOver" Value="True">
                                                        <Setter TargetName="Border" Property="Width" Value="10"/>
                                                        <Setter TargetName="Border" Property="Opacity" Value="1"/>
                                                    </Trigger>
                                                </ControlTemplate.Triggers>
                                            </ControlTemplate>
                                        </Thumb.Template>
                                    </Thumb>
                                </Track.Thumb>

                                <Track.IncreaseRepeatButton>
                                    <RepeatButton Command="ScrollBar.LineDownCommand"
                                                  Height="0"
                                                  Opacity="0"
                                                  IsTabStop="False"/>
                                </Track.IncreaseRepeatButton>
                            </Track>
                        </Grid>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>

    <Grid>
        <!-- Main scroll area for checkboxes -->
        <ScrollViewer Name="TaskScrollViewer"
                      Margin="20,20,20,0"
                      Height="250"
                      VerticalScrollBarVisibility="Auto"
                      HorizontalAlignment="Stretch"
                      VerticalAlignment="Top"
                      FlowDirection="LeftToRight">
            <Grid HorizontalAlignment="Stretch">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>
                <!-- Left column container -->
                <StackPanel Name="TaskPanelLeft" Grid.Column="0" Margin="5" VerticalAlignment="Top"/>
                <!-- Right column container -->
                <StackPanel Name="TaskPanelRight" Grid.Column="1" Margin="5" VerticalAlignment="Top"/>
            </Grid>
        </ScrollViewer>

        <!-- Start button -->
        <Button Name="StartButton"
                Content="Start Tasks"
                HorizontalAlignment="Left"
                Margin="20,0,0,20"
                VerticalAlignment="Bottom"
                Width="100"
                Height="30"
                Background="#007ACC"
                Foreground="White"
                BorderBrush="Transparent"/>

        <!-- Output TextBox -->
        <TextBox Name="OutputBox"
                 Margin="20,0,20,60"
                 VerticalAlignment="Bottom"
                 Height="200"
                 IsReadOnly="True"
                 Background="#1E1E1E"
                 Foreground="White"
                 BorderBrush="#007ACC"
                 VerticalScrollBarVisibility="Auto"
                 TextWrapping="Wrap"/>
    </Grid>
</Window>
"@

# Load the XAML
try {
    $reader = (New-Object System.Xml.XmlNodeReader $xaml)
    $window = [Windows.Markup.XamlReader]::Load($reader)
} catch {
    Write-Host "XAML Error: $_"
    exit
}

# Access UI elements
$TaskPanelLeft = $window.FindName("TaskPanelLeft")
$TaskPanelRight = $window.FindName("TaskPanelRight")
$startButton = $window.FindName("StartButton")
$outputBox = $window.FindName("OutputBox")

# Configuration section - Easy to modify
$config = @{
    Items = @("Task 1", "Task 2", "Task 3", "Task 4", "Task 5", "Task 6", "Task 7", "Task 8", "Task 9", "Task 10", "Task 11", "Task 12", "Task 13", "Task 14", "Task 15")
    RunspacePoolSize = 1  # Maximum concurrent threads
}

# Define individual task functions
$TaskFunctions = @{
    "Task 1" = { param($taskName) ; Start-Sleep -Seconds (Get-Random -Minimum 1 -Maximum 5) ; return "$taskName completed with Function 1" }
    "Task 2" = { param($taskName) ; Start-Sleep -Seconds (Get-Random -Minimum 1 -Maximum 5) ; return "$taskName completed with Function 2" }
    "Task 3" = { param($taskName) ; Start-Sleep -Seconds (Get-Random -Minimum 1 -Maximum 5) ; return "$taskName completed with Function 3" }
    "Task 4" = { param($taskName) ; Start-Sleep -Seconds (Get-Random -Minimum 1 -Maximum 5) ; return "$taskName completed with Function 4" }
    # Add more task-specific functions as needed...
}

# Global variables for thread management
$syncHash = [Hashtable]::Synchronized(@{})
$syncHash.Jobs = [System.Collections.ArrayList]::new()
$syncHash.RunspacePool = [RunspaceFactory]::CreateRunspacePool(1, $config.RunspacePoolSize)
$syncHash.RunspacePool.Open()

# Calculate the number of checkboxes for the left column.
$totalItems = $config.Items.Count
$half = [Math]::Ceiling($totalItems / 2)
$index = 0

foreach ($item in $config.Items) {
    $checkbox = New-Object System.Windows.Controls.CheckBox
    $checkbox.Content = $item
    $checkbox.Foreground = "White"
    $checkbox.HorizontalAlignment = "Stretch"
    $checkbox.Margin = "4"
    
    if ($index -lt $half) {
        $TaskPanelLeft.Children.Add($checkbox)
    } else {
        $TaskPanelRight.Children.Add($checkbox)
    }
    $index++
}

# Timer for monitoring jobs
$timer = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromMilliseconds(500)

# Start button click event: run the selected tasks using their specific functions
$startButton.Add_Click({
    $startButton.IsEnabled = $false

    # Gather selected checkboxes from both left and right panels
    $selectedTasksLeft = $TaskPanelLeft.Children | Where-Object { $_ -is [System.Windows.Controls.CheckBox] -and $_.IsChecked -eq $true }
    $selectedTasksRight = $TaskPanelRight.Children | Where-Object { $_ -is [System.Windows.Controls.CheckBox] -and $_.IsChecked -eq $true }
    $selectedTasks = $selectedTasksLeft + $selectedTasksRight

    if (-not $selectedTasks) {
        [System.Windows.MessageBox]::Show("Please select at least one task!", "Warning", "OK", "Warning")
        $startButton.IsEnabled = $true
        return
    }

    foreach ($task in $selectedTasks) {
        $taskName = $task.Content

        # Use the task-specific function if defined; otherwise, use a default function.
        if ($TaskFunctions.ContainsKey($taskName)) {
            $taskScript = $TaskFunctions[$taskName]
        } else {
            $taskScript = { param($taskName); Start-Sleep -Seconds 2; return "$taskName default function completed" }
        }

        $powershell = [PowerShell]::Create().AddScript($taskScript).AddArgument($taskName)
        $powershell.RunspacePool = $syncHash.RunspacePool

        $job = [PSCustomObject]@{
            PowerShell = $powershell
            Handle     = $powershell.BeginInvoke()
            TaskName   = $taskName
            Completed  = $false
        }

        $syncHash.Jobs.Add($job) | Out-Null
    }

    # Start the timer to monitor job completion
    $timer.Add_Tick({
        foreach ($job in $syncHash.Jobs.ToArray()) {
            if ($job.Handle.IsCompleted -and -not $job.Completed) {
                try {
                    $result = $job.PowerShell.EndInvoke($job.Handle)
                    $outputBox.Dispatcher.Invoke([Action]{
                        $outputBox.AppendText("$($job.TaskName): $result`n")
                        $outputBox.ScrollToEnd()
                    })
                }
                catch {
                    $outputBox.Dispatcher.Invoke([Action]{
                        $outputBox.AppendText("$($job.TaskName): ERROR - $($_.Exception.Message)`n")
                        $outputBox.ScrollToEnd()
                    })
                }
                finally {
                    $job.PowerShell.Dispose()
                    $syncHash.Jobs.Remove($job)
                }
            }
        }

        if ($syncHash.Jobs.Count -eq 0) {
            $timer.Stop()
            $startButton.Dispatcher.Invoke([Action]{ $startButton.IsEnabled = $true })
            $outputBox.Dispatcher.Invoke([Action]{
                $outputBox.AppendText("All tasks completed!`n")
                $outputBox.ScrollToEnd()
            })
        }
    })
    $timer.Start()
})

# Cleanup when window closes
$window.Add_Closed({
    $timer.Stop()  # Stop the timer when the window closes
    $syncHash.RunspacePool.Close()
    $syncHash.RunspacePool.Dispose()
})

# Show the window
try {
    $window.ShowDialog() | Out-Null
} catch {
    [System.Windows.MessageBox]::Show("Error: $_", "Error", "OK", "Error")
}

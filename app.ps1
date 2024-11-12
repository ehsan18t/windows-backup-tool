# Load Windows Forms Assembly
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Function to create the main form
function Create-MainForm {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Windows Backup Tool"
    $form.Size = New-Object System.Drawing.Size(400, 420)
    $form.StartPosition = "CenterScreen"
    $form.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog

    return $form
}

# Function to create a panel for checkboxes
function Create-CheckboxPanel {
    $panel = New-Object System.Windows.Forms.Panel
    $panel.Size = New-Object System.Drawing.Size(350, 180)
    $panel.Location = New-Object System.Drawing.Point(10, 10)
    $panel.AutoScroll = $true

    return $panel
}

# Function to create a styled checkbox
function Create-Checkbox ($text, $location) {
    $checkbox = New-Object System.Windows.Forms.CheckBox
    $checkbox.Text = $text
    $checkbox.AutoSize = $true
    $checkbox.Location = $location
    $checkbox.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Regular)
    $checkbox.ForeColor = [System.Drawing.Color]::FromArgb(45, 45, 48)

    return $checkbox
}


# Function to create a button
function Create-RunButton ($location) {
    $button = New-Object System.Windows.Forms.Button
    $button.Text = "Run Selected Tasks"
    $button.Size = New-Object System.Drawing.Size(200, 35)
    $button.Location = $location
    $button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $button.BackColor = [System.Drawing.Color]::FromArgb(72, 133, 237)  # Nice blue color
    $button.ForeColor = [System.Drawing.Color]::White
    $button.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)

    return $button
}


# Function to create an output textbox
function Create-OutputBox ($location) {
    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Multiline = $true
    $textBox.Size = New-Object System.Drawing.Size(350, 100)
    $textBox.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    $textBox.BackColor = [System.Drawing.SystemColors]::ControlLightLight
    $textBox.Location = $location
    $textBox.ScrollBars = "Vertical"
    $textBox.ReadOnly = $true

    return $textBox
}

# Function to create an output textbox
function Create-OutputDisplay ($location) {
    # Label for "Output" title
    $outputTitleLabel = New-Object System.Windows.Forms.Label
    $outputTitleLabel.Text = "Output:"
    $outputTitleLabel.AutoSize = $true
    $outputTitleLabel.Location = $location

    # Border label for output display
    $outputBorderLabel = New-Object System.Windows.Forms.Label
    $outputBorderLabel.Size = New-Object System.Drawing.Size(350, 100)
    $outputBorderLabel.Location = New-Object System.Drawing.Point($location.X, $location.Y + 20)
    $outputBorderLabel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    $outputBorderLabel.BackColor = [System.Drawing.SystemColors]::ControlLightLight
    $outputBorderLabel.TextAlign = [System.Drawing.ContentAlignment]::TopLeft
    $outputBorderLabel.AutoSize = $false

    return $outputTitleLabel, $outputBorderLabel
}

# Actions for each checkbox
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
    }

    [PSCustomObject]@{
        Text = "Task 1"
        Action = { "Task 1..." }
    }

    [PSCustomObject]@{
        Text = "Task 2"
        Action = { "Task 2..." }
    }

    [PSCustomObject]@{
        Text = "Task 3"
        Action = { "Task 3..." }
    }
)

# Initialize Form and Controls
$form = Create-MainForm
$checkboxPanel = Create-CheckboxPanel
$runButton = Create-RunButton -location (New-Object System.Drawing.Point(100, 210))
$outputTextBox = Create-OutputBox -location (New-Object System.Drawing.Point(20, 260))

# Add Checkboxes dynamically based on the tasks array
$checkboxes = @()
$yPos = 10
foreach ($task in $tasks) {
    $checkbox = Create-Checkbox -text $task.Text -location (New-Object System.Drawing.Point(10, $yPos))
    $checkboxPanel.Controls.Add($checkbox)
    $checkboxes += [PSCustomObject]@{ Checkbox = $checkbox; Action = $task.Action }
    $yPos += 30
}

# Add controls to form
$form.Controls.Add($checkboxPanel)
$form.Controls.Add($runButton)
$form.Controls.Add($outputTextBox)

# Button click event to execute actions for selected checkboxes
$runButton.Add_Click({
    $outputTextBox.Clear()  # Clear the output box each time the button is clicked
    foreach ($item in $checkboxes) {
        if ($item.Checkbox.Checked) {
            $result = $item.Action.Invoke()
            $outputTextBox.AppendText("$result`n")  # Display output in the text box
        }
    }
})

# Show form
$form.Add_Shown({ $form.Activate() })
[void] $form.ShowDialog()

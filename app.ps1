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
    $form.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $form.BackColor = [System.Drawing.SystemColors]::ControlLightLight

    return $form
}

# Function to create a panel for checkboxes
function Create-CheckboxPanel {
    $panel = New-Object System.Windows.Forms.Panel
    $panel.Size = New-Object System.Drawing.Size(360, 180)
    $panel.Location = New-Object System.Drawing.Point(10, 10)
    $panel.AutoScroll = $true
    $panel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle

    return $panel
}

# Function to create a styled checkbox
function Create-Checkbox ($text, $location) {
    $checkbox = New-Object System.Windows.Forms.CheckBox
    $checkbox.Text = $text
    $checkbox.AutoSize = $true
    $checkbox.Location = $location
    $checkbox.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $checkbox.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Regular)

    return $checkbox
}


# Function to create a button
function Create-Button ($location, $text = "Run", $width = 120, $height = 35, $fontSize = 10) {
    $button = New-Object System.Windows.Forms.Button
    $button.Text = $text
    $button.Size = New-Object System.Drawing.Size($width, $height)
    $button.Location = $location
    $button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $button.BackColor = [System.Drawing.Color]::FromArgb(52, 73, 85)
    $button.ForeColor = [System.Drawing.Color]::White
    $button.Font = New-Object System.Drawing.Font("Segoe UI", $fontSize, [System.Drawing.FontStyle]::Bold)

    return $button
}


# Function to create an output textbox
function Create-OutputBox ($location) {
    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Multiline = $true
    $textBox.Size = New-Object System.Drawing.Size(340, 100)
    $textBox.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    $textBox.BackColor = [System.Drawing.SystemColors]::ControlLightLight
    $textBox.Location = $location
    $textBox.AutoScroll = $true
    $textBox.ReadOnly = $true

    return $textBox
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
$btnBackup = Create-Button -location (New-Object System.Drawing.Point(20, 210)) -text "Backup Now"
$btnRestore = Create-Button -location (New-Object System.Drawing.Point(240, 210)) -text "Restore Now"
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
$form.Controls.Add($btnBackup)
$form.Controls.Add($btnRestore)
$form.Controls.Add($outputTextBox)

# Button click event to execute actions for selected checkboxes
$btnBackup.Add_Click({
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

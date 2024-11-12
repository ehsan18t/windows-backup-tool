# Load Windows Forms Assembly
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Load modules
. "$PSScriptRoot\gui.ps1"
. "$PSScriptRoot\tasks.ps1"

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
    if (-not $task.Visible) { continue }
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

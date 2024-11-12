###############################
# Load Windows Forms Assembly #
###############################
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

################
# Load modules #
################
. "$PSScriptRoot\modules\gui.ps1"
. "$PSScriptRoot\modules\tasks.ps1"
. "$PSScriptRoot\modules\constants.ps1"

#############################
# Initialize Some Constants #
#############################
$checkboxPanelLocation = New-Object System.Drawing.Point($checkboxPanelX, $checkboxPanelY)
$outputBoxLocation = New-Object System.Drawing.Point($outputBoxX, $outputBoxY)
$btnRestoreLocation = New-Object System.Drawing.Point($btnRestoreX, $btnRestoreY)
$btnBackupLocation = New-Object System.Drawing.Point($btnBackupX, $btnBackupY)
$btnShowLogsLocation = New-Object System.Drawing.Point($btnShowLogsX, $btnShowLogsY)

################################
# Initialize Form and Controls #
################################
$form = Create-MainForm -title $title -width $initialWidth -height $initialHeight -fontSize $initialFontSize
$checkboxPanel = Create-CheckboxPanel -location $checkboxPanelLocation -width $checkboxPanelWidth -height $checkboxPanelHeight
$btnShowLogs = Create-Button -location $btnShowLogsLocation -text $btnShowLogsText -width $btnShowLogsWidth
$btnBackup = Create-Button -location $btnBackupLocation -text $btnBackupText -width $btnBackupWidth
$btnRestore = Create-Button -location $btnRestoreLocation -text $btnRestoreText -width $btnRestoreWidth
$outputTextBox = Create-OutputBox -location $outputBoxLocation -width $outputBoxWidth -height $outputBoxHeight

##########################################################
# Create Checkboxes dynamically based on the tasks array #
##########################################################
$checkboxes = @()
$yPos = $checkboxStartY
foreach ($task in $tasks) {
    if (-not $task.Visible) { continue }
    $checkbox = Create-Checkbox -text $task.Text -location (New-Object System.Drawing.Point($checkboxStartX, $yPos))
    $checkboxPanel.Controls.Add($checkbox)
    $checkboxes += [PSCustomObject]@{ Checkbox = $checkbox; Backup = $task.BackupAction; Restore = $task.RestoreAction }
    $yPos += $checkboxGap
}

########################
# Add controls to form #
########################
$form.Controls.Add($checkboxPanel)
$form.Controls.Add($btnShowLogs)
$form.Controls.Add($btnBackup)
$form.Controls.Add($btnRestore)
$form.Controls.Add($outputTextBox)

######################
# Add event handlers #
######################
$btnShowLogs.Add_Click({
    if ($outputTextBox.Visible) {
        $outputTextBox.Visible = $false
        $form.Height = $initialHeight
        $btnShowLogs.Text = $btnShowLogsText
    } else {
        $outputTextBox.Visible = $true
        $form.Height = $heightWithLogs
        $btnShowLogs.Text = $btnHideLogsText
    }
})

$btnBackup.Add_Click({
    foreach ($item in $checkboxes) {
        if ($item.Checkbox.Checked) {
            $result = $item.Backup.Invoke()
            $outputTextBox.AppendText("$result`n")
        }
    }
})

$btnRestore.Add_Click({
    foreach ($item in $checkboxes) {
        if ($item.Checkbox.Checked) {
            $result = $item.Restore.Invoke()
            $outputTextBox.AppendText("$result`n")
        }
    }
})

#############
# Show form #
#############
$form.Add_Shown({ $form.Activate() })
[void] $form.ShowDialog()

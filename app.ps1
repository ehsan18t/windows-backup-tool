###############################
# Load Windows Forms Assembly #
###############################
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#########################
# Environment Variables #
#########################
. "$PSScriptRoot\modules\constants.ps1"

$baseBackupPath = "$PSScriptRoot\Backup"
$userProfile = [System.Environment]::GetFolderPath("UserProfile")
$x64PF = [System.Environment]::GetFolderPath("ProgramFiles")
$x86PF = [System.Environment]::GetFolderPath("ProgramFilesX86")

########################
# Enable DPI Awareness #
########################
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class DPIHelper {
    [DllImport("user32.dll")]
    public static extern bool SetProcessDPIAware();
}
"@

[DPIHelper]::SetProcessDPIAware()

################
# Load modules #
################
. "$PSScriptRoot\modules\gui.ps1"
. "$PSScriptRoot\modules\tasks.ps1"

#############################
# Initialize Some Constants #
#############################
$checkboxPanelLocation = New-Object System.Drawing.Point($checkboxPanelX, $checkboxPanelY)
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
$form.Controls.Add($logger.console)

######################
# Add event handlers #
######################
$btnShowLogs.Add_Click({
    if ($logger.console.Visible) {
        $logger.console.Visible = $false
        $form.Height = $initialHeight
        $btnShowLogs.Text = $btnShowLogsText
    } else {
        $logger.console.Visible = $true
        $form.Height = $heightWithLogs
        $btnShowLogs.Text = $btnHideLogsText
    }
})

$btnBackup.Add_Click({
    foreach ($item in $checkboxes) {
        if ($item.Checkbox.Checked) {
            $item.Backup.Invoke()
        }
    }
})

$btnRestore.Add_Click({
    foreach ($item in $checkboxes) {
        if ($item.Checkbox.Checked) {
            $item.Restore.Invoke()
        }
    }
})

#############
# Show form #
#############
$form.Add_Shown({ $form.Activate() })
[void] $form.ShowDialog()

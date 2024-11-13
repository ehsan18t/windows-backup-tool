. "$PSScriptRoot\Logger.ps1"

# Form
$title = "Windows Backup Tool"
$initialWidth = 400
$initialHeight = 300
$heightWithLogs = 420
$initialFontSize = 10

# Checkbox panel
$checkboxPanelWidth = 360
$checkboxPanelHeight = 180
$checkboxPanelX = 10
$checkboxPanelY = 10
$checkboxStartY = 10
$checkboxStartX = 10
$checkboxGap = 30

# Logger console
$logger = [Logger]::new(360, 110, (New-Object System.Drawing.Point(10, 260)))

# Buttons
$btnRestoreText = "Restore Now"
$btnRestoreWidth = 120
$btnRestoreX = 240
$btnRestoreY = 210

$btnBackupText = "Backup Now"
$btnBackupWidth = 120
$btnBackupX = 20
$btnBackupY = 210

$btnShowLogsText = "Show Logs"
$btnHideLogsText = "Hide Logs"
$btnShowLogsWidth = 100
$btnShowLogsX = 140
$btnShowLogsY = 210


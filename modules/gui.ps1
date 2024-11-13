# Function to create the main form
function Create-MainForm ($title, $width, $height, $fontSize) {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = $title
    $form.Size = New-Object System.Drawing.Size($width, $height)
    $form.StartPosition = "CenterScreen"
    $form.Font = New-Object System.Drawing.Font("Segoe UI", $fontSize, [System.Drawing.FontStyle]::Regular)
    $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    $form.BackColor = [System.Drawing.SystemColors]::ControlLightLight

    # Set AutoScaleMode to handle DPI scaling
    $form.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Dpi

    return $form
}

# Function to create a panel for checkboxes
function Create-CheckboxPanel ($location, $width, $height) {
    $panel = New-Object System.Windows.Forms.Panel
    $panel.Size = New-Object System.Drawing.Size($width, $height)
    $panel.Location = $location
    $panel.AutoScroll = $true
    $panel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle

    return $panel
}

# Function to create a styled checkbox
function Create-Checkbox ($text, $location) {
    $checkbox = New-Object System.Windows.Forms.CheckBox
    $checkbox.Text = $text
    $checkbox.UseCompatibleTextRendering = $true
    $checkbox.AutoSize = $true
    $checkbox.Location = $location
    $checkbox.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $checkbox.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Regular)

    return $checkbox
}


# Function to create a button
function Create-Button {
    param (
        [Parameter(Mandatory=$true)]
        [System.Drawing.Point]$location,

        [Parameter(Mandatory=$true)]
        [string]$text,

        [Parameter(Mandatory=$true)]
        [int]$width,

        [int]$height = 35,
        [int]$fontSize = 9,

        [System.Drawing.Color]$backColor = [System.Drawing.Color]::FromArgb(52, 73, 85),  # Default color if not provided
        [System.Drawing.Color]$foreColor = [System.Drawing.Color]::White  # Default color if not provided
    )

    $button = New-Object System.Windows.Forms.Button
    $button.Text = $text
    $button.Size = New-Object System.Drawing.Size($width, $height)
    $button.Location = $location
    $button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $button.BackColor = $backColor
    $button.ForeColor = $foreColor
    $button.UseCompatibleTextRendering = $true
    $button.Font = New-Object System.Drawing.Font("Segoe UI", $fontSize, [System.Drawing.FontStyle]::Bold)

    return $button
}



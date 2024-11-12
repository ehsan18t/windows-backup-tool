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

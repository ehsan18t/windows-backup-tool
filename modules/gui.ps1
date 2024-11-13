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

        [System.Drawing.Color]$backColor = [System.Drawing.Color]::FromArgb(52, 73, 85),
        [System.Drawing.Color]$foreColor = [System.Drawing.Color]::White
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

# Deps: Create-MainForm, Create-Button
function Show-ChoicePopup {
    param (
        [string]$message = "Are you sure?",
        [string]$title = "Confirmation",
        [string]$choice1 = "Yes",
        [string]$choice2 = "No",
        [string]$choice1Result = "Yes",
        [string]$choice2Result = "No"
    )

    # Initialize the popup form
    $logger.query($message)
    $popupForm = Create-MainForm -title $title -width 300 -height 160 -fontSize 10
    $popupForm.MaximizeBox = $false
    $popupForm.MinimizeBox = $false
    $popupForm.TopMost = $true

    # Label for message
    $label = New-Object System.Windows.Forms.Label
    $label.Text = $message
    $label.Size = New-Object System.Drawing.Size(260, 40)
    $label.Location = New-Object System.Drawing.Point(10, 10)
    $label.TextAlign = 'MiddleCenter'
    $label.UseCompatibleTextRendering = $true
    $popupForm.Controls.Add($label)

    # Button 1
    $button1 = Create-Button -location (New-Object System.Drawing.Point(20, 70)) -text $choice1 -backColor ([System.Drawing.Color]::FromArgb(0, 91, 65)) -width 80 -height 30
    $button1.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $popupForm.Controls.Add($button1)

    # Button 2
    $button2 = Create-Button -location (New-Object System.Drawing.Point(180, 70)) -text $choice2 -backColor ([System.Drawing.Color]::FromArgb(190, 49, 68)) -width 80 -height 30
    $button2.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $popupForm.Controls.Add($button2)

    # Handle button clicks to close the form with respective results
    $button1.Add_Click({
        $logger.response($choice1Result)
        $popupForm.Tag = $choice1Result
        $popupForm.Close()
    })
    $button2.Add_Click({
        $logger.response($choice2Result)
        $popupForm.Tag = $choice2Result
        $popupForm.Close()
    })

    $popupForm.ShowDialog() | Out-Null
    return $popupForm.Tag
}



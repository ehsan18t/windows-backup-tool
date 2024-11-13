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

# Dependencies: Create-MainForm, Create-Button
function Show-ChoicePopup {
    param (
        [string]$message = "Are you sure?",
        [string]$title = "Confirmation",
        [Array]$choices = @(
            @{ Text = "Yes"; Result = "Yes"; Color = [System.Drawing.Color]::FromArgb(227,66,52) },
            @{ Text = "No"; Result = "No"; Color = [System.Drawing.Color]::FromArgb(135,169,107) }
        )
    )

    # Initialize the popup form
    $logger.query($message)
    $popupForm = Create-MainForm -title $title -width 300 -height 160 -fontSize 10
    $popupForm.MaximizeBox = $false
    $popupForm.MinimizeBox = $false
    $popupForm.TopMost = $true

    # Label for the message
    $label = New-Object System.Windows.Forms.Label
    $label.Text = $message
    $label.Size = New-Object System.Drawing.Size(260, 40)
    $label.Location = New-Object System.Drawing.Point(10, 10)
    $label.TextAlign = 'MiddleCenter'
    $label.UseCompatibleTextRendering = $true
    $popupForm.Controls.Add($label)

    # Calculate button layout
    $buttonWidth = 80
    $buttonHeight = 30
    $spacing = 10
    $startX = [int](($popupForm.ClientSize.Width - (($choices.Count * $buttonWidth) + (($choices.Count - 1) * $spacing))) / 2)
    $yPosition = 70

    # Loop to create buttons dynamically
    $index = 0
    foreach ($choice in $choices) {
        $buttonX = $startX + (($buttonWidth + $spacing) * $index)
        $button = Create-Button -location (New-Object System.Drawing.Point($buttonX, $yPosition)) `
                                -text $choice.Text `
                                -backColor $choice.Color `
                                -width $buttonWidth `
                                -height $buttonHeight
        $button.DialogResult = [System.Windows.Forms.DialogResult]::None

        $button.Add_Click({
            $logger.response($choice.Result)
            $popupForm.Tag = $choice.Result
            $popupForm.Close()
        }.GetNewClosure())

        $popupForm.Controls.Add($button)
        $index++
    }

    # Show the form and return the result after closing
    $popupForm.ShowDialog() | Out-Null
    return $popupForm.Tag
}


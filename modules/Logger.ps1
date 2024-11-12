# Uncomment these if they are not in main script
# Add-Type -AssemblyName System.Windows.Forms
# Add-Type -AssemblyName System.Drawing

class Logger {
    [System.Windows.Forms.RichTextBox]$console

    Logger([int]$width, [int]$height, [System.Drawing.Point]$location) {
        $this.console = New-Object System.Windows.Forms.RichTextBox
        $this.console.Multiline = $true
        $this.console.Size = New-Object System.Drawing.Size($width, $height)
        $this.console.Location = $location
        $this.console.ReadOnly = $true
        $this.console.ScrollBars = [System.Windows.Forms.RichTextBoxScrollBars]::Vertical
        $this.console.Visible = $false
        $this.console.WordWrap = $false

        # Styles
        $this.console.BorderStyle = [System.Windows.Forms.BorderStyle]::None
        $this.console.BackColor = [System.Drawing.Color]::FromArgb(52, 73, 85)
        $this.console.ForeColor = [System.Drawing.Color]::White
        $this.console.Font = New-Object System.Drawing.Font("Consolas", 10, [System.Drawing.FontStyle]::Regular)  # Monospaced font

        # Text Paddings
        $this.console.SelectionIndent = 10
        $this.console.AppendText("`n")
    }

    # Method to add a general log message (default color)
    [void]Log([string]$type, [string]$message, [System.Drawing.Color]$color = [System.Drawing.Color]::LightGray) {
        $this.console.SelectionStart = $this.console.Text.Length
        $this.console.SelectionColor = $color
        $this.console.SelectedText = $type + ": "
        $this.console.SelectionColor = $this.console.ForeColor  # Reset to default
        $this.console.SelectedText = $message + "`n"
    }

    # Convenience methods for specific log types
    [void]info([string]$message) {
        $this.Log("Info", $message, [System.Drawing.Color]::Cyan)
    }

    [void]warning([string]$message) {
        $this.Log("Warning", $message, [System.Drawing.Color]::Orange)
    }

    [void]error([string]$message) {
        $this.Log("Error", $message, [System.Drawing.Color]::Red)
    }

    [void]success([string]$message) {
        $this.Log("Success", $message, [System.Drawing.Color]::Green)
    }
}

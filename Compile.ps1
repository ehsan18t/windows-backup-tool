$files = @(
    "modules/UI.ps1",
    "modules/Functions.ps1",
    "modules/Tasks.ps1",
    "Main.ps1"
)

$outputFile = "App.ps1"
$outputContent = @()

# Add an optional header
$outputContent += "# Compiled Script - Generated on $(Get-Date)"
$outputContent += ""

foreach ($file in $files) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        $outputContent += $content
        $outputContent += ""  # Blank line for separation
    } else {
        Write-Host "Warning: File $file not found."
    }
}

$outputContent | Set-Content $outputFile -Encoding UTF8
Write-Host "Compiled script created: $outputFile"

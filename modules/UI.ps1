Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Drawing

function Show-ConfirmationPopup {
    param(
        [string]$Message = "Do you want to proceed?",
        [string]$Title = "Confirmation"
    )
    
    # Call the static Show method of MessageBox with explicit parameters.
    $result = [System.Windows.MessageBox]::Show(
        $Message, 
        $Title, 
        [System.Windows.MessageBoxButton]::YesNo, 
        [System.Windows.MessageBoxImage]::Question
    )
    return $result
}

[xml]$global:xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Modern Multi-threaded Task Runner"
    Height="600"
    Width="500"
    WindowStartupLocation="CenterScreen"
    ResizeMode="NoResize"
    Background="#2D2D30"
    Foreground="White">

    <Window.Resources>
        <Style TargetType="ScrollBar">
            <Setter Property="Width" Value="8"/>
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ScrollBar">
                        <Grid Background="{TemplateBinding Background}">
                            <Track x:Name="PART_Track"
                                Focusable="False"
                                IsDirectionReversed="True">
                                <Track.DecreaseRepeatButton>
                                    <RepeatButton Command="ScrollBar.LineUpCommand"
                                                Height="0"
                                                Opacity="0"
                                                IsTabStop="False"/>
                                </Track.DecreaseRepeatButton>
                                
                                <Track.Thumb>
                                    <Thumb x:Name="Thumb"
                                        Background="#007ACC"
                                        Opacity="0.8"
                                        Width="8">
                                        <Thumb.Template>
                                            <ControlTemplate TargetType="Thumb">
                                                <Border x:Name="Border"
                                                        Background="{TemplateBinding Background}"
                                                        CornerRadius="4"
                                                        Width="{TemplateBinding Width}"
                                                        Height="{TemplateBinding Height}"
                                                        Opacity="{TemplateBinding Opacity}">
                                                </Border>
                                                <ControlTemplate.Triggers>
                                                    <!-- Hover effect -->
                                                    <Trigger Property="IsMouseOver" Value="True">
                                                        <Setter TargetName="Border" Property="Width" Value="10"/>
                                                        <Setter TargetName="Border" Property="Opacity" Value="1"/>
                                                    </Trigger>
                                                </ControlTemplate.Triggers>
                                            </ControlTemplate>
                                        </Thumb.Template>
                                    </Thumb>
                                </Track.Thumb>

                                <Track.IncreaseRepeatButton>
                                    <RepeatButton Command="ScrollBar.LineDownCommand"
                                                Height="0"
                                                Opacity="0"
                                                IsTabStop="False"/>
                                </Track.IncreaseRepeatButton>
                            </Track>
                        </Grid>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>

    <Grid>
        <!-- Main scroll area for checkboxes -->
        <ScrollViewer Name="TaskScrollViewer"
                    Margin="20,20,20,0"
                    Height="250"
                    VerticalScrollBarVisibility="Auto"
                    HorizontalAlignment="Stretch"
                    VerticalAlignment="Top"
                    FlowDirection="LeftToRight">
            <Grid HorizontalAlignment="Stretch">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>
                <!-- Left column container -->
                <StackPanel Name="TaskPanelLeft" Grid.Column="0" Margin="5" VerticalAlignment="Top"/>
                <!-- Right column container -->
                <StackPanel Name="TaskPanelRight" Grid.Column="1" Margin="5" VerticalAlignment="Top"/>
            </Grid>
        </ScrollViewer>

        <!-- Start button -->
        <Button Name="StartButton"
                Content="Start Tasks"
                HorizontalAlignment="Left"
                Margin="20,0,0,20"
                VerticalAlignment="Bottom"
                Width="100"
                Height="30"
                Background="#007ACC"
                Foreground="White"
                BorderBrush="Transparent"/>

        <!-- Output RichTextBox -->
        <RichTextBox Name="OutputBox"
                Margin="20,0,20,60"
                VerticalAlignment="Bottom"
                Height="200"
                IsReadOnly="True"
                Background="#1E1E1E"
                BorderBrush="#007ACC"
                VerticalScrollBarVisibility="Auto"
                Padding="10"/>
    </Grid>
</Window>
"@

try {
    $reader = (New-Object System.Xml.XmlNodeReader $global:xaml)
    $global:window = [Windows.Markup.XamlReader]::Load($reader)
    $global:OutputBox = $global:window.FindName("OutputBox")
} catch {
    Write-Host "XAML Error: $_"
    exit
}

# --- Logger Thread ---
# $global:OutputQueue = [System.Collections.Concurrent.ConcurrentQueue[string]]::new()
# $global:LogTimer = New-Object System.Windows.Threading.DispatcherTimer
# $global:LogTimer.Interval = [TimeSpan]::FromMilliseconds(500)

# # Add a tick event handler to dequeue and process messages.
# $global:LogTimer.Add_Tick({
#     # Dequeue all messages currently in the queue.
#     $logMsg = $null
#     while ($global:OutputQueue.TryDequeue([ref]$logMsg)) {
#         $global:OutputBox.Dispatcher.Invoke(
#             [Action[string]]{
#                 param($msg)
#                 Log-Info $msg
#             },
#             [System.Windows.Threading.DispatcherPriority]::Normal,
#             $logMsg
#         )
#     }
# })
# $global:LogTimer.Start()


# --- Logger Functions ---
function Convert-Hex {
    param (
        [string]$hex
    )
    $r = [Convert]::ToByte($hex.Substring(1,2),16)
    $g = [Convert]::ToByte($hex.Substring(3,2),16)
    $b = [Convert]::ToByte($hex.Substring(5,2),16)
    return [System.Windows.Media.Color]::FromRgb($r, $g, $b)
}

function Log-Title {
    param (
        [string]$Message,
        [string]$BorderColorHex = "#007ACC",
        [string]$MessageColorHex = "#FFFFFF"
    )

    # Use a consistent global variable: $global:OutputBox
    $borderColor = Convert-Hex $BorderColorHex
    $messageColor  = Convert-Hex $MessageColorHex

    $borderBrush  = New-Object System.Windows.Media.SolidColorBrush $borderColor
    $messageBrush = New-Object System.Windows.Media.SolidColorBrush $messageColor

    # Compute inner width: add 2 for padding (one space on each side)
    $innerWidth = $Message.Length + 2

    # Define box-drawing characters using Unicode code points.
    $topLeft     = [char]0x2554  # ╔
    $horizontal  = [char]0x2550  # ═
    $topRight    = [char]0x2557  # ╗
    $vertical    = [char]0x2551  # ║
    $bottomLeft  = [char]0x255A  # ╚
    $bottomRight = [char]0x255D  # ╝

    # Create the top and bottom lines (adjusting the inner width as needed).
    $topLine    = "$topLeft" + ([string]::new($horizontal, $innerWidth - 2)) + "$topRight"
    $bottomLine = "$bottomLeft" + ([string]::new($horizontal, $innerWidth - 2)) + "$bottomRight"

    # Build the middle line in three parts:
    $leftRunText  = "$vertical "   # left border + space
    $rightRunText = " $vertical"   # space + right border

    # Create a Paragraph with no extra margin.
    $para = New-Object System.Windows.Documents.Paragraph
    $para.Margin = [System.Windows.Thickness]::new(0)
    $para.LineStackingStrategy = "BlockLineHeight"
    $para.LineHeight = 16

    # Create Run elements.
    $runTop = New-Object System.Windows.Documents.Run ($topLine + "`n")
    $runTop.Foreground = $borderBrush

    $runLeft = New-Object System.Windows.Documents.Run ($leftRunText)
    $runLeft.Foreground = $borderBrush

    $runMessage = New-Object System.Windows.Documents.Run ($Message)
    $runMessage.Foreground = $messageBrush

    $runRight = New-Object System.Windows.Documents.Run ($rightRunText + "`n")
    $runRight.Foreground = $borderBrush

    $runBottom = New-Object System.Windows.Documents.Run ($bottomLine)
    $runBottom.Foreground = $borderBrush

    # Assemble the paragraph.
    $para.Inlines.Add($runTop)
    $para.Inlines.Add($runLeft)
    $para.Inlines.Add($runMessage)
    $para.Inlines.Add($runRight)
    $para.Inlines.Add($runBottom)

    # Append the paragraph to the FlowDocument and scroll to end.
    $global:OutputBox.Document.Blocks.Add($para)
    $global:OutputBox.ScrollToEnd()
}

function Log-Text {
    param (
        [string]$type,
        [string]$message,
        [string]$TypeColorHex = "#FFFFFF",
        [string]$MessageColorHex = "#FFFFFF"
    )

    $typeBrush = New-Object System.Windows.Media.SolidColorBrush (Convert-Hex $TypeColorHex)
    $messageBrush = New-Object System.Windows.Media.SolidColorBrush (Convert-Hex $MessageColorHex)

    $runType = New-Object System.Windows.Documents.Run ("$($type): ")
    $runType.Foreground = $typeBrush

    $runMessage = New-Object System.Windows.Documents.Run ("$message")
    $runMessage.Foreground = $messageBrush

    $para = New-Object System.Windows.Documents.Paragraph
    $para.Margin = "0,0,0,0"
    $para.LineStackingStrategy = "BlockLineHeight"
    $para.LineHeight = 16

    $para.Inlines.Add($runType)
    $para.Inlines.Add($runMessage)

    # Append the Paragraph to the RichTextBox's FlowDocument.
    $global:OutputBox.Document.Blocks.Add($para)
    $global:OutputBox.ScrollToEnd()
}

function Log-Info {
    param (
        [string]$message,
        [string]$TypeColorHex = "#007ACC",
        [string]$MessageColorHex = "#FFFFFF"
    )
    Log-Text -type "INFO" -message $message -TypeColorHex $TypeColorHex -MessageColorHex $MessageColorHex
}

function Log-Error {
    param (
        [string]$message,
        [string]$TypeColorHex = "#FF0000",
        [string]$MessageColorHex = "#FFFFFF"
    )
    Log-Text -type "ERROR" -message $message -TypeColorHex $TypeColorHex -MessageColorHex $MessageColorHex
}

Set-Alias Log-Err Log-Error

function Log-Warning {
    param (
        [string]$message,
        [string]$TypeColorHex = "#FFA500",
        [string]$MessageColorHex = "#FFFFFF"
    )
    Log-Text -type "WARNING" -message $message -TypeColorHex $TypeColorHex -MessageColorHex $MessageColorHex
}

Set-Alias Log-Warn Log-Warning

function Log-Success {
    param (
        [string]$message,
        [string]$TypeColorHex = "#00FF00",
        [string]$MessageColorHex = "#FFFFFF"
    )
    Log-Text -type "SUCCESS" -message $message -TypeColorHex $TypeColorHex -MessageColorHex $MessageColorHex
}

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Drawing

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

        <!-- Output TextBox -->
        <TextBox Name="OutputBox"
                 Margin="20,0,20,60"
                 VerticalAlignment="Bottom"
                 Height="200"
                 IsReadOnly="True"
                 Background="#1E1E1E"
                 Foreground="White"
                 BorderBrush="#007ACC"
                 VerticalScrollBarVisibility="Auto"
                 TextWrapping="Wrap"/>
    </Grid>
</Window>
"@

try {
    $reader = (New-Object System.Xml.XmlNodeReader $global:xaml)
    $global:window = [Windows.Markup.XamlReader]::Load($reader)
} catch {
    Write-Host "XAML Error: $_"
    exit
}

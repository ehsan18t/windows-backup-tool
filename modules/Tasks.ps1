$global:config = @{
    Items = @(
        "qBittorrent", "Windows Terminal", "Microsoft Edge (Stable)", "OBS Studio"
    )
    RunspacePoolSize = 1
}

$global:TaskFunctions = @{
    "qBittorrent" = {
            param($taskName)
            return "$taskName backup completed"
        }
    "Windows Terminal" = {
            param($taskName)
            Start-Sleep -Seconds (Get-Random -Minimum 1 -Maximum 5);
            return "$taskName backup completed"
        }
    "Microsoft Edge (Stable)" = {
            param($taskName)
            Start-Sleep -Seconds (Get-Random -Minimum 1 -Maximum 5);
            return "$taskName backup completed"
        }
    "OBS Studio" = {
            param($taskName)
            Start-Sleep -Seconds (Get-Random -Minimum 1 -Maximum 5);
            return "$taskName backup completed"
        }
}

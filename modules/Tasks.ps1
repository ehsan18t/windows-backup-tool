$global:config = @{
    Items = @(
        "qBittorrent", "Windows Terminal", "Microsoft Edge (Stable)", "OBS Studio"
    )
    RunspacePoolSize = 1
}

$global:TaskFunctions = @{
    "qBittorrent" = {
            param($taskName)
            $global:OutputQueue.Enqueue("$taskName started")
            return "$taskName completed with Function 1"
        }
    "Windows Terminal" = {
            param($taskName)
            $global:OutputQueue.Enqueue("$taskName started")
            Start-Sleep -Seconds (Get-Random -Minimum 1 -Maximum 5);
            return "$taskName completed with Function 2"
        }
    "Microsoft Edge (Stable)" = {
            param($taskName)
            $global:OutputQueue.Enqueue("$taskName started")
            Start-Sleep -Seconds (Get-Random -Minimum 1 -Maximum 5);
            return "$taskName completed with Function 3"
        }
    "OBS Studio" = {
            param($taskName)
            $global:OutputQueue.Enqueue("$taskName started")
            Start-Sleep -Seconds (Get-Random -Minimum 1 -Maximum 5);
            return "$taskName completed with Function 4"
        }
}

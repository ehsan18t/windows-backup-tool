$global:config = @{
    Items = @("Task 1", "Task 2", "Task 3", "Task 4", "Task 5", "Task 6", "Task 7", "Task 8", "Task 9", "Task 10", "Task 11", "Task 12", "Task 13", "Task 14", "Task 15")
    RunspacePoolSize = 1
}

$global:TaskFunctions = @{
    "Task 1" = { param($taskName) ; Start-Sleep -Seconds (Get-Random -Minimum 1 -Maximum 5) ; return "$taskName completed with Function 1" }
    "Task 2" = { param($taskName) ; Start-Sleep -Seconds (Get-Random -Minimum 1 -Maximum 5) ; return "$taskName completed with Function 2" }
    "Task 3" = { param($taskName) ; Start-Sleep -Seconds (Get-Random -Minimum 1 -Maximum 5) ; return "$taskName completed with Function 3" }
    "Task 4" = { param($taskName) ; Start-Sleep -Seconds (Get-Random -Minimum 1 -Maximum 5) ; return "$taskName completed with Function 4" }
    # Add more task-specific functions as needed...
}

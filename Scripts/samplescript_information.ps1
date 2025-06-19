

Write-Host 'Starting...'
Start-Sleep -Seconds 1 # simulating some time-consuming action
Write-Host -ForegroundColor Red "Simulating some alert message"
Write-Host 'Done.'
return 5*12/8  # returning some result
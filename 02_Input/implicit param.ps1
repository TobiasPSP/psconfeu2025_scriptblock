

function Get-Something($Parameter1)
{
    "submitted: $Parameter1"
}


Get-Something -Parameter1 test

# transformed source code:
${function:Get-Something}

(${function:Get-Something}).GetType().Name

# "function:" drive
New-Item -Path function:Start-DumbCommand -Value { param($Name, $Address) "$Name lives at $Address" }
Start-DumbCommand -Name tobias -Address Malmö

# use case:
$code = Invoke-RestMethod -Uri https://aka.ms/install-powershell.ps1 
$null = New-Item -Path function: -Name Install-PowerShell7 -Value $code -Force



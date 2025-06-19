

# all functions are stored on drive "function:"
Get-ChildItem function:te*


# accessing a function via "$" on this drive reveals its scriptblock:
${function:test}
${function:test} | Get-Member
(${function:test}).GetType().Name

# dynamic function creation on drive "function:":
New-Item -Path function:Start-DumbCommand -Value { param($Name, $Address) "$Name lives at $Address" }
Start-DumbCommand -Name tobias -Address Malmö

# actual use case: dynamically adding Install-PowerShell7 from source code received via webservice:
$code = Invoke-RestMethod -Uri https://aka.ms/install-powershell.ps1 
$null = New-Item -Path function: -Name Install-PowerShell7 -Value $code -Force

<#
the source code received as text from Invoke-RestMethod is converted to a scriptblock
when it is used as value for the New-Item command on drive function:
#>

#>
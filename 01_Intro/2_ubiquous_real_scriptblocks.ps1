$rootFolder = $PSScriptRoot | Split-Path
Import-Module -Name $rootFolder\Modules\GuiHelpers -Verbose

#return

# as Arguments (Delegates)

Get-Service | Where-Object { $_.Status -eq 'Running' }
Show-InputBox -Prompt 'Enter Email' -Title 'Send Report' -ButtonOkText 'Send' -ButtonCancelText 'Abort' -Delegate { $_ -like '*?@?*.?*' }

# Function

function test
{
    'This is a test'
}

test

# Remoting
Invoke-Command -ScriptBlock { "I am executing on $env:computername" } #-ComputerName server1, server2, server3

# Attributes
[ValidateScript({ Test-Path -Path $_})]$path = 'c:\windows'
$path = 'c:\windows\system32'
$path = 'c:\notfound'

# Scripts
& "$rootfolder\Scripts\sample1.ps1"

# equivalent:
$code = Get-Content -Path "$rootfolder\Scripts\sample1.ps1" -Raw
$scriptblock = [ScriptBlock]::Create($code)
$scriptblock.Invoke()

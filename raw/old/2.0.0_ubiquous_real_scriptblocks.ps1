
#region Arguments (Delegates)

Get-Service | Where-Object { $_.Status -eq 'Running' }
Show-InputBox -Prompt 'Enter Email' -Title 'Send Report' -ButtonOkText 'Send' -ButtonCancelText 'Abort' -Delegate { $_ -like '*?@?*.?*' }
#endregion Arguments (Delegates)

#region Function

function test {
    'This is a test'
}

test

#region How functions relate to scriptblocks

# all functions are stored on drive "function:"
Get-ChildItem function:te*
# accessing a function via "$" on this drive reveals its scriptblock:
${function:test}
${function:test} | Get-Member

#endregion How functions relate to scriptblocks

#endregion Function

#region Remoting
Invoke-Command -ScriptBlock { "I am executing on $env:computername" } #-ComputerName server1, server2, server3
#endregion Remoting

#region Attributes
[ValidateScript({ Test-Path -Path $_ })]$path = 'c:\windows'
$path = 'c:\windows\system32'
$path = 'c:\notfound'
#endregion Attributes

#region Scripts
& "$rootfolder\Scripts\sample1.ps1"

#region How scripts relate to scriptblocks

# this is what happens when you run a script:
$code = Get-Content -Path "$rootfolder\Scripts\sample1.ps1" -Raw
$scriptblock = [ScriptBlock]::Create($code)
$scriptblock.InvokeReturnAsIs()

#endregion How scripts relate to scriptblocks

#endregion Scripts

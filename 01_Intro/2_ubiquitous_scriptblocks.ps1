# run them NOW:
& { Get-Hotfix } 
. { Get-Hotfix } 

# but WHY? Why not like this:
(Get-Hotfix)
Get-Hotfix


# run them LATER:
function test 
{
    'This is a test'
}

test

& "$rootfolder\Scripts\sample1.ps1"

# *.ps1-Files really are treated as ONE BIG scriptblock
# anything that applies to scriptblock ALSO WORKS in script files

# run them SOMEWHERE ELSE:
Invoke-Command -ScriptBlock { Get-Hotfix } -ComputerName server1, server2

# use them BY SOMEONE ELSE:
Get-Service | Where-Object { $_.Status -eq 'Running' }

Show-InputBox -Prompt 'Enter Email' -Title 'Send Report' -ButtonOkText 'Send' `
    -ButtonCancelText 'Abort' -Delegate { $_ -like '*?@?*.?*' }

[ValidateScript({ Test-Path -Path $_ })]$path = 'c:\windows'
$path = 'c:\windows\system32'
$path = 'c:\notfound'

# have FUN:
[ValidateScript({if((Test-Path -Path $_)) {[Console]::Beep();$true}else{[Console]::Beep(400, 600);$false}})]$path = 'c:\windows'
$path = 'c:\wrongPath'


# run them IN PARALLEL:
# PS7:
1..10 | Foreach-Object -Parallel { "processing $_"; Start-Sleep -Seconds 1 } -ThrottleLimit 10
# WPS:
#requires -Module InvokeParallel
1..10 | Invoke-Parallel { "processing $_"; Start-Sleep -Seconds 1 } -ThrottleLimit 10

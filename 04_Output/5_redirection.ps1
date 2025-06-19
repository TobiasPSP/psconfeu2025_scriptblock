


function test
{
    [CmdletBinding()]
    param()

    Write-Output "Output"                      # 1, visible, Output-Stream
    Get-Date -Format dddd                      # 1, visible, Output-Stream
    Write-Error "Error"                        # 2, visible by default
    Write-Warning "Warning"                    # 3, visible by default
    Write-Verbose 'Verbose Message'            # 4, visible with -Verbose
    Write-Debug "Debug1"                       # 5, visible with -Debug, script halts (default is "Inquire")
    Write-Debug "Debug2"                       # 5, visible with -Debug, script halts (default is "Inquire")
    Write-Information "Information Message"    # 6, not visible by default
    Write-Host "Host"                          # 6, visible by default
    return "Return Value"                      # 1, visible, Output-Stream
}

test
$a = test

# redirect all:
$a = test *>&1
$a | Out-GridView

# redirect individually:
$a = test 2>$null 3>&1 4>&1 5>$env:temp\mylog.txt 6>&1

# did you notice? Information stream turns visible even though $InformationPreference is unchanged:
test 2>$null 3>$null 4>$null 5>$null 6>&1 | Where-Object { $_ -like 'Inf*'}

# error suppression:
Get-Process -FileVersionInfo

& { Get-Process -FileVersionInfo } 2>$null         # works with ANY command, including .NET methods
Get-Process -FileVersionInfo -ErrorAction Ignore   # works only with cmdlets




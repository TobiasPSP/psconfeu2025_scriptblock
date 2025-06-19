
# Using Write-Host for LOGGING:

function test
{
    Write-Host 'Starting...'
    Start-Sleep -Seconds 1 # simulating some time-consuming action
    Write-Host -ForegroundColor Red "Simulating some alert message"
    Write-Host 'Done.'
    return 5*12/8  # returning some result
}

# result goes to variable, messages stay visible in the console:
$result = test 
$result

# Write-Host uses stream #6:
test
test 6>$null

# when redirecting stream #6 to the output stream #1,
# you can post-process it:
$all = test 6>&1
$all

# separate host messages from real output by TYPE:
$all[0].GetType().FullName


test 6>&1 | Foreach-Object {
    if ($_ -is [System.Management.Automation.InformationRecord])
    {
        # do whatever you want with the information record
        # i.e. log it, or write it to a variable and process it later
        $_ | Select-Object -Property MessageData, TimeGenerated, ProcessId, User | Out-String | write-host -ForegroundColor Yellow
    }
    else
    {
        # pass on "normal" output normally:
        $_
    }
}

# works with scripts, too (they are scriptblocks, too, after all):
& "$rootfolder\Scripts\samplescript_information.ps1" 6>&1 | Foreach-Object {
    if ($_ -is [System.Management.Automation.InformationRecord])
    {
        # do whatever you want with the information record
        # i.e. log it, or write it to a variable and process it later
        $_ | Select-Object -Property MessageData, TimeGenerated, ProcessId, User | Out-String | write-host -ForegroundColor Yellow
    }
    else
    {
        # pass on "normal" output normally:
        $_
    }
}


# do the work JUST ONCE and ENCAPSULATE it in a function:
function Tee-Info
{
    #Content
    param
    (
        [String]
        [Parameter(Mandatory)]
        $VariableName,
    
        [Object]
        [Parameter(ValueFromPipeline)]
        $InputObject
    )
  
    begin
    {
        $variable = Set-Variable -Name $VariableName -Value ([System.Collections.ArrayList]::new()) -Scope script -PassThru
    }
  
    process
    {
        if ($InputObject -is [System.Management.Automation.InformationRecord])
        {
            $null = $variable.value.Add($InputObject)
        }
        else
        {
            $InputObject
        }
    }
}

# send all Write-Host messages to a variable of your choice:
test 6>&1 | Tee-Info -VariableName myLoggingData
# here they are now:
$myLoggingData

# remember: Write-Host messages are InformationRecord objects:
$myLoggingData |
    Select-Object -Property MessageData, TimeGenerated, ProcessId, User | 
    Out-String | 
    Write-Host -ForegroundColor Yellow


# more abstraction fun with another helper function that takes any
# property with DateTime (i.e. TimeGenerated) and adds a new property
# with the elapsed time difference:
function Add-Elapsed
{
    param
    (
        [String]
        [Parameter(Mandatory)]
        $SourcePropertyName,
    
        [string]
        $Unit = 'TotalMilliseconds',
    
        [string]
        $NewPropertyName = 'Elapsed',
    
        [Object]
        [Parameter(Mandatory,ValueFromPipeline)]
        $InputObject
    )
  
    begin
    {
        [DateTime]$previousEvent = [DateTime]::MinValue
    }
    process
    {
     
        $elapsed = . { 
            if ($previousEvent -eq [DateTime]::MinValue)
            { 
                0
            }
            else
            {
                ($_.$SourcePropertyName - $previousEvent).$Unit
            }
            $previousEvent = $_.$SourcePropertyName
        }
        $_ | Add-Member -MemberType NoteProperty -Value $elapsed -Name $NewPropertyName -PassThru -Force
    }

}

# take ANY script with Write-Host messages:
& "$rootfolder\Scripts\samplescript_information.ps1" 6>&1 | Tee-Info -VariableName hostMessagesFromScript

# next, post-process the messages found in $hostMessagesFromScript:
$hostmessagesFromScript | 
    Add-Elapsed -SourcePropertyName TimeGenerated -Unit Totalseconds -NewPropertyName Elapsed |
    Select-Object -Property MessageData, Elapsed, ProcessId, User | 
    Out-String | 
    Write-Host -ForegroundColor Yellow
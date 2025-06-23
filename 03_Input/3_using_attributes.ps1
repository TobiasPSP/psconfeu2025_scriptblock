<#
        | Feature                   | no param() | param() | param() + Attribute |
        | ------------------------- | ---------- | ------- | ------------------- |
        | Common Parameter          |      -     |    -    |         yes         |
        | $PSBoundParameters        |      -     |   yes   |         yes         |
        | $PSCmdlet                 |      -     |    -    |         yes         |
        | $PSDefaultParameterValues |      -     |    -    |         yes         |


#>

function WithoutParam
{
    $PSBoundParameters                                                      # not supported
    $PSCmdlet.ShouldProcess($env:COMPUTERNAME, "doing something")           # not supported
    $args
}
WithoutParam 1 2 3 

function WithParam
{
    param
    (
        $Parameter1,
        
        $Parameter2
    )
    $PSBoundParameters                                                      # supported
    $PSCmdlet.ShouldProcess($env:COMPUTERNAME, "doing something")           # not supported
    $Parameter1, $Parameter2
}
WithParam 1 2  


function WithParamAndAttribute
{
    [CmdletBinding(SupportsShouldProcess)]
    param
    (
        $Parameter1,
        
        $Parameter2
    )
    $PSBoundParameters                                                      # supported
    $PSCmdlet.ShouldProcess($env:COMPUTERNAME, "doing something")           # supported
    $Parameter1, $Parameter2
}

WithParamAndAttribute 1 2  
WithParamAndAttribute 1 2 -WhatIf


<#
        CONCLUSION:
        - param() provides best control
        - add Attributes for even more granular control
#>

# hide a specific parameter from intellisense discovery:
# ALSO hides ALL COMMON PARAMETERS:
function test
{
    param(
        $Name,
        
        [Parameter(DontShow)]
        [Switch]
        $IAmSecret
    )
    
    if ($IAmSecret)
    {
        "Doing secret things with $Name"
    }
    else
    {
        "Regular behavior with $Name"
    }
} 

# Adding support for -WhatIf and -Confirm


function Invoke-SomethingEvil
{
    # enable -WhatIf and -Confirm parameters:
    [CmdletBinding(SupportsShouldProcess)]
    param()

    # in critical code paths, evaluate whether to execute evil code or not:
    if ($PSCmdlet.ShouldProcess('On This Computer', 'Do Something Evil'))
    {
        Write-Host 'I am doing evil and non-reversible stuff now.' -ForegroundColor Red -BackgroundColor White
    }
    else
    {
        Write-Host 'I WOULD HAVE wrecked your machine, but actually I am now just simulating it. Good for you.' -ForegroundColor Yellow
    }
}

Invoke-SomethingEvil -WhatIf
Invoke-SomethingEvil
Invoke-SomethingEvil -Confirm

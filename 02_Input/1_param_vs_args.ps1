# by default, scriptblocks receive arguments in $args (POSITIONAL array)

& { 
    Write-Host "I received $($args.Count) arguments: $args"
    
    return $args
} 1 2

# use case:
Invoke-Command -ScriptBlock { "Received $args from source computer" } -ArgumentList (1..10) #-ComputerName server1, server2, server3


# when adding a param() at the beginning, arguments are automatically BOUND to NAMED parameters
& { 
    param
    (
        $Parameter1, 
    
        $Parameter2
    ) 
    
    Write-Host "I received `$Parameter1 = $Parameter1 and `$Parameter2 = $Parameter2."
    
    
    return $Parameter1, $Parameter2 
} 1 2

# when you add the parameter names to your arguments, then the ORDER
# in which they are specified becomes irrelevant:
& { 
    param
    (
        $Parameter1, 
    
        $Parameter2
    ) 
    Write-Host "I received `$Parameter1 = $Parameter1 and `$Parameter2 = $Parameter2."
    
    return $Parameter1, $Parameter2 
} -Parameter2 2 -Parameter1 1

# use case:
Invoke-Command -ScriptBlock { "Received credential $($args[0]) from source computer" } -ArgumentList (Get-Credential) #-ComputerName server1, server2, server3
Invoke-Command -ScriptBlock { param($cred) "Received credential $cred from source computer" } -ArgumentList (Get-Credential) #-ComputerName server1, server2, server3


<#
        IMPORTANT: 

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



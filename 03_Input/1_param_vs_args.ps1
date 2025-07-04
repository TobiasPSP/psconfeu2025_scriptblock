﻿# "magic" variables: $_, $args, $input

& { "> $args <"} 1 2 3 4 5 6 7 8 9 10
1..10 | & { "> $input <" }
1..10 | Foreach-Object { "> $_ <"}
1..10 | & { process { "> $_ <"} }


# use cases:
Invoke-Command -ScriptBlock { "Received $args from source computer" } -ArgumentList (1..10) #-ComputerName server1, server2, server3


# when adding a param() at the beginning, arguments are automatically BOUND to NAMED parameters
& { 
    param
    (
        $Parameter1, 
    
        $Parameter2
    ) 
    
    Write-Host "I received `$Parameter1 = $Parameter1 and `$Parameter2 = $Parameter2."
    # any argument submitted beyond what the param() take will STILL spill over in $args:
    "More than I could eat: $args"    
    
    return $Parameter1, $Parameter2 
} 1 2 spillover I cannot handle this 

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

# using attributes:
function test
{
    param
    (
        [Parameter(Mandatory)]
        [string]
        $YouMustFeedMe, 

        [Parameter(ValueFromPipeline)]
        $AnySide
    ) 

    process
    {
        "Anyside receiving $AnySide"

    }
} 

test -AnySide 1
1..10 | test -YouMustFeedMe "eat this"
# fails now:
test -AnySide 1 -YouMustFeedMe ok 1 2 3  # no automatic spillover in $args anymore


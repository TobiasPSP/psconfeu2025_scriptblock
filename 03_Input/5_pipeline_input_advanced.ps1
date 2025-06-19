
# more consistency and clarity through explicit declarations
# the SAME parameter can now be fed via PIPELINE -or- via ARGUMENT

# IMPORTANT: once you use param(), "cheats" like $_ and $input are no longer working like before

1..10 | & {
    param
    (
        # mark the parameter that should receive pipeline input
        [Parameter(ValueFromPipeline)]
        $myInput
    )

    begin
    {
        "Initializing (if needed)"
    }
    
    process
    {
        "receiving $myInput"
    }

    end
    {
        "Cleanup (if needed)"
    }
}


# wrapped as a function:
function test
{
    param
    (
        # mark the parameter that should receive pipeline input
        [Parameter(ValueFromPipeline)]
        $myInput
    )

    begin
    {
        "Initializing (if needed)"
    }
    
    process
    {
        "receiving $myInput"
    }

    end
    {
        "Cleanup (if needed)"
    }
}

1..10 | test            # pipeline input is automatically triggering the "process"-Block loop (built-in loop)
test -myInput (1..10)   # arguments are taken as-is (no loop). You would have to add your own loop here 
                        # that's why using process{} in scriptblocks, and piping data, is a real benefit

# Example (multiple input from both pipeline AND arguments)

function test2
{
    param
    (
        # mark the parameter that should receive pipeline input
        [Parameter(ValueFromPipeline)]
        [string[]]  # must be an array type (or [object] (default))
        $myInput
    )

    begin
    {
        "Initializing (if needed)"
    }
    
    process
    {
        # adding a manual loop:
        foreach($_ in $myInput)
        {
            "receiving $_"
        }
    }

    end
    {
        "Cleanup (if needed)"
    }
}


1..10 | test2           # process runs 10x with ONE number each time
test2 -myInput (1..10)  # process runs 1x with an ARRAY, foreach runs 10x
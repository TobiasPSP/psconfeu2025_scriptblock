$counter = 0
$20Numbers = foreach($item in (1..10000))
{
    # is the current number in $item
    # dividable by 3?
    $dividableByThree = $item % 3 -eq 0
    
    if ($dividableByThree)
    {
        # yes, increment counter
        $counter++
        # return value
        $item
    }
    # do we have 20?
    if ($counter -ge 20)
    {
        # yes, abort
        break
    }
}

$20Numbers.Count
$20Numbers
<#
        "normal" loops have control statements such as "break" that can ABORT the loop
        when a condition is met.

        Pipelines have no such thing.

        Except if you add it with the knowledge you now have:
#>


function Stop-Pipeline
{
    $sb = { Select-Object -First 1 }
    $steppablePipeline = $sb.GetSteppablePipeline()
    $steppablePipeline.Begin($true)
    $steppablePipeline.Process(1)
    $steppablePipeline.End()
}

# assume we have a lot of input data 
# we would like to ABORT the pipeline operation once we gathered 
# 20 numbers that are evenly dividable by 3


$result = 1..100000 | ForEach-Object -Begin { $counter = 0 } -process {
    $dividableByThree = $_ % 3 -eq 0
    
    if ($dividableByThree)
    {
        $counter++
        $_
    }
    # do we have 20?
    if ($counter -ge 20)
    {
        # yes, abort pipeline!
        Stop-Pipeline
    }
}

$result.Count
$result

# Here is what we are simulating with Stop-Pipeline:
1..1000 | Select-Object -First 20

# FINDING: Select-Object CAN abort the pipeline when it has seen the number of elements -First specifies
# So by invoking Select-Object in an external steppable pipeline, we can make it EMIT the STOP SIGNAL
# since it occurs INSIDE our own pipeline, it ABORTS the pipeline


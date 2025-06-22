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



# the best it gets with the pipeline is this:
$result = 1..100000 | ForEach-Object  {
    $dividableByThree = $_ % 3 -eq 0
    
    if ($dividableByThree)
    {
        $counter++
        $_
    }
} | Select-Object -First 20


# keeping a private "Select-Object" around to stop the pipeline:


function Stop-Pipeline
{
    $sb = { Select-Object -First 1 }
    $steppablePipeline = $sb.GetSteppablePipeline()
    $steppablePipeline.Begin($true)
    $steppablePipeline.Process(1)
    $steppablePipeline.End()
}

# real world problem:
Get-EventLog -LogName System -After '2025-06-22'  # get-eventlog is deprecated, use get-winevent!
Get-EventLog -LogName System -After '2025-06-22' | Foreach-Object { if ($_.TimeGenerated -lt '2025-06-22') { Stop-Pipeline}}



$result = 1..100000 | ForEach-Object {
    
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


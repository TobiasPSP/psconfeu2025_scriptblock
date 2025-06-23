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
# Select-Object is actively breaking the pipeline once it has the requested numbers

# keeping a private "Select-Object" around to stop the pipeline:
function Stop-Pipeline
{
    $sb = { Select-Object -First 1 }
    $steppablePipeline = $sb.GetSteppablePipeline()
    $steppablePipeline.Begin($true)
    $steppablePipeline.Process(1)
    $steppablePipeline.End()
}

$result = 1..100000 | ForEach-Object {
    
    $someInput = Show-InputBox -Prompt 'EOF ends pipeline' -Title 'Really Slow Database Simulator' -ButtonOkText 'Submit' -ButtonCancelText 'Bail Out'
    if ($someInput -like '*EOF*')
    {
        # yes, abort pipeline!
        Stop-Pipeline
    }
    $someInput
}

$result.Count
$result

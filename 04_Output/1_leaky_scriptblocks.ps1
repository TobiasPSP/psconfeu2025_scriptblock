# scriptblocks are "leaky":
# anything you output through stream #1 is part of the results:
#
# - unassigned
# - Write-Output
# - return

function test
{
    "I am starting"
    $value = 10
    $result = $value * 100
    "Done!"
    return $result
}

test

$output = test
$output.Count
$output
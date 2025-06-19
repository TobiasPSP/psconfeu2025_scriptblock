$myvalue = 1
$myresult = 1

# "." instead of "&" waives scope
. {
    $myvalue = 123
    $myresult = $myvalue * 100
    "`$myresult = $myresult"
    # this now raises an exception because there IS NO parent scope anymore:
    "`$myresult (parent scope) = $(Get-Variable -Name myresult -ValueOnly -Scope 1)"
}

# script variables have changed because they SHARE THE SCOPE with the scriptblock
$myvalue
$myresult

# why would you ever waive a scope?
# remember "leaky" scriptblocks?
# UTILIZE the scriptblock RETURN VALUE functionality, but WAIVE its SCOPE functionality:

$null = . { 'discarded' }


function test
{
    # silence all output and ONLY return the value defined by RETURN:
    $null = . {
        "I am starting"
        $value = 10
        $result = $value * 100
        "Done!"
    }
    return $result
}
test
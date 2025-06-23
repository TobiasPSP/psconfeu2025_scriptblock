$myvalue = 1
$myresult = 1

& {
    # by default, scriptblocks establish a new variable scope
    $myvalue = 123
    $myresult = $myvalue * 100
    "`$myresult = $myresult"
    "`$myresult (parent scope) = $(Get-Variable -Name myresult -ValueOnly -Scope 1)"
    # when the scriptblock is done, its content is discarded
    # -> variables of parent scopes, even with SAME NAME, remain unaffected
    #    and appear to be "restored" (when in reality, they never changed)
}

# parent scope variables remain untouched by scriptblock
# no "magic cleaning", rather a "diaper" that gets thrown away
$myvalue
$myresult


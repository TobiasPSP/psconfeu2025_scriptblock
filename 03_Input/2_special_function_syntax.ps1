
# special case for functions:
#
# NO param() block???

function Convert-Euro2Dollar($Value, $ExchangeRate)
{
    $result = $Value * $ExchangeRate
    
    return $result
}

Convert-Euro2Dollar -Value 123 -ExchangeRate 1.2

# this is what the PowerShell parser creates:

${function:Convert-Euro2Dollar}

<# 
        CONCLUSION:

        - param() is the default technique
        - used behind the scenes
        - avoid inline parameters (they exist only to help VBScript people transition)
#>

# Best practice (using common standards):
function Convert-Euro2Dollar
{
    param
    ($Value, $ExchangeRate)
    
    $result = $Value * $ExchangeRate
    
    return $result
}

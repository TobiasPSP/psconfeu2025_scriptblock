

# Magic of automatic pipeline delegates revealed:

function test
{
    param
    (
        # Requirement #1: receive pipeline objects byValue
        # make sure this is NOT MANDATORY! Else, your function works ONLY with pipeline input
        [Object]
        [Parameter(ValueFromPipeline)]
        $InputObject,
        
        # Requirement #2: let parameter ALSO receive THE SAME pipeline object, but this time ByPropertyName
        # (let it ALSO receive ByVal to directly process data)
        [String]
        [Parameter(Mandatory,ValueFromPipeline, ValueFromPipelineByPropertyName)]
        $SomeData
    )
  
    process
    {
        # show what we receive:
        "Received: $SomeData"
    }
}

# Test cases:

# ByVal:
1..10 | test

# ByPropertyName:
'Name, SomeData
    Tobias,data1
    Jenny,data2
    Gael,data3' | ConvertFrom-Csv | test
    
# using classic [string] argument:
test -SomeData 'myLiteral'

# using AUTOMATIC DELEGATE
1..10 | test
1..10 | test -SomeData 'makes no sense anymore as we have more than ONE input'
1..10 | test -SomeData { $_ * 10 }
1..10 | test -SomeData { "I can now handle each input individually, currently processing $_" }
1..10 | test -SomeData { "IP generator: 192.168.2.$_" }

Get-Process | Where-Object StartTime | test -SomeData { '{0} started {1}' -f $_.Name, $_.StartTime }
Get-Process | Where-Object StartTime | test -SomeData { '{0} started {1:n1} minutes ago' -f $_.Name, ((Get-Date) - $_.StartTime).TotalMinutes }

# Parameter declaration:
Get-Help test -Parameter SomeData
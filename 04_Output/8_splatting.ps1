
# Splatting: dynamically binding arguments to parameters
# requires a param() block 


function test
{
    param
    (
        $Name = $env:username,
  
        [String]
        $Address = '[unspecified]'
    )
  
    "$Name lives at $Address"
}

# normally, arguments are supplied STATICALLY (fixed in code):
test
test -Name Tobias -Address Germany
test -Name Gael

# splatting uses a hashtable to DYNAMICALLY assign arguments to parameters:
$hashtable = @{
    Name    = 'Will'
    Address = 'a place unknown to many'
}

# use "@" in place of "$" to splat the hashtable stored in the variable:
test @hashtable






# "magic" variables revisited:

& { "> $args <"} 1 2 3 4 5 6 7 8 9 10
1..10 | & { $args }  ## huh? WRONG!
1..10 | & { "> $input <" } # > RIGHT!
1..10 | Foreach-Object { "> $_ <"} # gets confusing
1..10 | & { process { "> $_ <"} }

# we must talk about SCRIPTBLOCK COMPARTMENTS: begin, process, end
{ $_ }.Ast | Select-Object BeginBlock, ProcessBlock, EndBlock

# $_       : individual pipeline element in PROCESS block
# $input   : all received pipeline input in END block (enumerator, can only be read ONCE)
# CAVE: CANNOT BE COMBINED! When there is a PROCESS block, $input is not available in END anymore

# accepting pipeline input requires a PROCESS block:
1..10 | & { process { "receiving: $_" } }
1..10 | & { end { "receiving: $input" } }

1..10 | & { "receiving: $input" } # END is the default anyway
# fails:
1..10 | & { process {} end { "receiving: $input" } }  # $input works only when there is NO process block!

<#
        Use Case: Foreach/Where-Object
        both are just thin wrappers for SCRIPTBLOCKS
#>

# FOREACH-OBJECT:
1..10 | Foreach-Object { "192.168.2.$_" }  # normal
1..10 | & { process { "192.168.2.$_" }}    # underlying scriptblock


# a simple pipeline counter:
Get-Service | Foreach-Object -Begin { $c=0 } -Process { $c++ } -End { $c }
Get-Service | & { begin { $c=0 } process { $c++ } end { $c } }

# make scriptblock reusable by adding a function name:
function Count-Object
{ begin { $c=0 } process { $c++ } end { $c } }

Get-Service | Count-Object
Get-Process | Count-Object
1..100 | Count-Object

# WHERE-OBJECT
Get-Service | Where-Object { $_.Status -eq 'Running' }               # normal
Get-Service | . { process { if($_.Status -eq 'Running') { $_ } }}    # underlying scriptblock
# make scriptblock reusable: by adding a function name (again):
function Limit-Running
{ process { if($_.Status -eq 'Running') { $_ } }}

Get-Service | Limit-Running

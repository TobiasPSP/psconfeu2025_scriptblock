
# runs ONCE, does NOTHING (uh?):
1..10 | & { "Received: $args" }

# pipeline input does not go to $args
# $_       : individual pipeline element in PROCESS block
# $input   : all received pipeline input in END block (enumerator, can only be read ONCE)
# CAVE: CANNOT BE COMBINED! When there is a PROCESS block, $input is not available in END anymore

# accepting pipeline input requires a PROCESS block:
1..10 | & { process { "receiving: $_" } }
1..10 | & { end { "receiving: $input" } }
1..10 | & { "receiving: $input" } # END is the default anyway

1..10 | & { process {} end { "receiving: $input" } }  # DOES NOT WORK!

<#
        Use Case: Foreach/Where-Object
#>

# FOREACH-OBJECT:
1..10 | Foreach-Object { "192.168.2.$_" }
1..10 | & { process { "192.168.2.$_" }}
# a simple pipeline counter:
Get-Service | Foreach-Object -Begin { $c=0 } -Process { $c++ } -End { $c }
Get-Service | & { begin { $c=0 } process { $c++ } end { $c } }

# reusable:
function Count-Object
{ begin { $c=0 } process { $c++ } end { $c } }

Get-Service | Count-Object
Get-Process | Count-Object
1..100 | Count-Object

# WHERE-OBJECT
Get-Service | Where-Object { $_.Status -eq 'Running' }
# boils down to:
Get-Service | . { process { if($_.Status -eq 'Running') { $_ } }}

# reusable:
function Limit-Running
{ process { if($_.Status -eq 'Running') { $_ } }}

Get-Service | Limit-Running


# manually accessing BEGIN, PROCESS, END
function test3
{ 
     begin { Write-Host "Ready to go!" -ForegroundColor Yellow }
     process {"receiving $_"} 
     end { Write-Host "COMPLETED." -ForegroundColor Red }
 }
 
 1..10 | test3
 
 
 
$pipeline = { test3 }.GetSteppablePipeline()
$pipeline.begin($true)
$pipeline.Process('AABC')
$pipeline.Process('Test')
$pipeline.End()
$pipeline.Dispose() # free memory

$pipeline = { Out-GridView }.GetSteppablePipeline()
$pipeline.begin($true)

$pipeline.Process('AABC')
$pipeline.Process('Test')

$pipeline.End()
$pipeline.Dispose() # free memory
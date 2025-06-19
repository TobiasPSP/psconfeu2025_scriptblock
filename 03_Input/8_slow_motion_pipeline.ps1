

# each scriptblock has BEGIN, PROCESS, END
# same is true for any command DERIVED from scriptblocks, i.e. functions and cmdlets

# SIMULATING a pipeline operation:

# sample function:
function test
{ 
     begin { Write-Host "Ready to go!" -ForegroundColor Yellow }
     process {"receiving $_"} 
     end { Write-Host "COMPLETED." -ForegroundColor Red }
 }
 
# normal operation:
1..10 | test
 
# MANUAL pipelining:
$pipeline = { test }.GetSteppablePipeline()
$pipeline.begin($true)
$pipeline.Process('AABC')
$pipeline.Process('Test')
$pipeline.End()
$pipeline.Dispose() # free memory

# same with a Cmdlet written by someone else:
$pipeline = { Out-GridView }.GetSteppablePipeline()
$pipeline.begin($true)

$pipeline.Process('AABC')
$pipeline.Process('Test')

$pipeline.End()
$pipeline.Dispose() # free memory


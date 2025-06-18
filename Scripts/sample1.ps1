$starttime = Get-Date
$hotfixes = Get-Hotfix
$count = $hotfixes.Count
$endtime = Get-Date

$runtime = $endtime - $starttime
$milliseconds = $runtime.TotalMilliseconds

"Found $count installed hotfixes. Took $milliseconds ms to complete."
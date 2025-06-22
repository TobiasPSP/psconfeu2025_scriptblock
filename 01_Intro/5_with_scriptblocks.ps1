
$smbPort = 445

Get-Ipv4Segment -From 10.30.2.1 -To 10.30.3.230 |
    Foreach-Parallel {
        Test-Port -ComputerName $_ -Port $smbPort -TimeoutMilliSec 500 -ResolveIp
    } -ThrottleLimit 128 -UseLocalVariables <#-Verbose#> | 
    Where-Object Response

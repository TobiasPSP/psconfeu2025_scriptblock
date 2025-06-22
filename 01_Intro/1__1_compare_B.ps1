
$smbPort = 445

Get-Ipv4Segment -From 192.168.2.1 -To 192.168.4.230 |
    Foreach-Parallel {
        Test-Port -ComputerName $_ -Port $smbPort -TimeoutMilliSec 500 -ResolveIp
    } -ThrottleLimit 128 -UseLocalVariables <#-Verbose#> | 
    Where-Object Response

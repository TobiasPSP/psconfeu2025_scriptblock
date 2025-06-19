#requires -Version 2.0 -Modules TwNetworkHelpers

<#
parallel processing runs in different threads
all cmdlets used in a thread MUST BE discoverable
Modules i.e. must be located at known locations
#>

$printerPort = 9100
$webserver = 80
$smbPort = 445


Get-Ipv4Segment -From 192.168.2.1 -To 192.168.4.230 |
    Foreach-Parallel -Process {
        Test-Port -ComputerName $_ -Port $smbPort -TimeoutMilliSec 500
    } -ThrottleLimit 128 -UseLocalVariables -Verbose | 
    Where-Object Response |
    #Get-NetworkPrinterInfo |
    Out-GridView
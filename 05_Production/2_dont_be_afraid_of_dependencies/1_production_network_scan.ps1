#requires -Version 2.0 -Modules TwNetworkHelpers

<#
        parallel processing runs in different threads
        all cmdlets used in a thread MUST BE discoverable
        Modules i.e. must be located at known locations
#>

$printerPort = 9100
$webserver = 80
$smbPort = 445

# port-scanning 742 IP addresses can take A LONG TIME 
#
# may coincidentally trigger INTRUSION DETECTION in your company. 
#
# when you run this, you may get the opportunity to make acquaintances 
# with your new colleagues from other departments

# this is very fast (and very simple to understand and maintain):
Get-Ipv4Segment -From 192.168.2.1 -To 192.168.4.230 |
    Foreach-Parallel -Process {
        Test-Port -ComputerName $_ -Port $smbPort -TimeoutMilliSec 500 -ResolveIp
    } -ThrottleLimit 128 -UseLocalVariables <#-Verbose#> | 
    Where-Object Response #|
    #Get-NetworkPrinterInfo 

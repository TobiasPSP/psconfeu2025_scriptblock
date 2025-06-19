function Test-Ping
{
  


    param
    (
        # Computername or IP address to ping
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]
        $ComputerName,
    
        # Timeout in milliseconds
        [int]
        $TimeoutMillisec = 1000
    )
  
    begin
    {
        $obj = [System.Net.NetworkInformation.Ping]::new()
    }
  
    process
    {
        $obj.Send($ComputerName, $TimeoutMillisec) |
            Select-Object -Property @{N='ComputerName';E={$_.Address}}, @{N='Port';E={'ICMP'}}, @{N='Response';E={$_.Status -eq 'Success'}}
        
    }
    end
    {
        $obj.Dispose()
    }
}
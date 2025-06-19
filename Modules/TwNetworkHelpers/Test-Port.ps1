function Test-Port
{
    
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]
        $ComputerName,
        
        [Parameter(Mandatory)]
        [int]
        $Port,
        
        [int]
        $TimeoutMilliSec = 1000,
        
        [Switch]
        $ResolveIp
    )
    
    process
    {
        try
        {
            $client = [System.Net.Sockets.TcpClient]::new()
            $task = $client.ConnectAsync($ComputerName, $Port)
            if ($task.Wait($TimeoutMilliSec))
            {
                $success = $client.Connected
            }
            else
            {
                $success = $false
            }
        }
        catch
        {
            $success = $false
        }
        finally
        {
            $client.Close()
            $client.Dispose()
        }
        
        if ($success -and $ResolveIp)
        {
            try
            {
                $ComputerName = [System.Net.Dns]::GetHostEntry($ComputerName).HostName
            }
            catch
            {
            
            }
        }
    
        [PSCustomObject]@{
            ComputerName = $ComputerName
            Port = $Port
            Response = $success
        }
    }
}
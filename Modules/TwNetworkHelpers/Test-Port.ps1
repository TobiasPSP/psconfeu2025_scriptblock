function Test-Port
{
    
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory, Position=0, ValueFromPipeline)]
        [string]
        $ComputerName,
        
        [Parameter(Mandatory, Position=1)]
        [int]
        $Port,
        
        [Parameter(Position=2)]
        [int]
        $TimeoutMilliSec = 1000
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
    
        [PSCustomObject]@{
            ComputerName = $ComputerName
            Port = $Port
            Response = $success
        }
    }
}
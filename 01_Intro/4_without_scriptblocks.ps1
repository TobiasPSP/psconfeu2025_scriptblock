$ipFromBytes = ('10.30.2.1' -as [IPAddress]).GetAddressBytes()
$ipToBytes = ('10.30.3.230' -as [IPAddress]).GetAddressBytes()
[array]::Reverse($ipFromBytes)
[array]::Reverse($ipToBytes)
$start=[BitConverter]::ToUInt32($ipFromBytes, 0)
$end=[BitConverter]::ToUInt32($ipToBytes, 0)
$addresses = for($x = $start; $x -le $end; $x++)
{
    $ip=[bitconverter]::getbytes($x)
    [Array]::Reverse($ip)
    $ip -join '.'
}
$SessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
$ps = [Powershell]::Create()
$null = $ps.AddCommand('Get-Variable')
$oldVars = $ps.Invoke().Name
$ps.Runspace.Close()
$ps.Dispose()
Get-Variable | 
Where-Object { $_.Name -notin $oldVars } |
Foreach-Object {
    $SessionState.Variables.Add((New-Object System.Management.Automation.Runspaces.SessionStateVariableEntry($_.Name, $_.Value, $null)))
}
$RunspacePool = [Runspacefactory]::CreateRunspacePool(1, 128, $SessionState, $host)
$RunspacePool.Open() 
$ThreadList = New-Object System.Collections.ArrayList  
$threadid = 0
foreach($address in $addresses)
{
    $Code = '$args | Foreach-Object { ' + {
        $ComputerName = $_
        $Port=445
        $TimeoutMilliSec = 1000
        $ResolveIp = $true
        try
        {
            $client = [System.Net.Sockets.TcpClient]::new()
            $task = $client.ConnectAsync($ComputerName, $Port)
            $success = if ($task.Wait($TimeoutMilliSec)) { $client.Connected } else { $false}
        }
        catch { $success = $false }
        finally
        {
            $client.Close()
            $client.Dispose()
        }
        
        if ($success -and $ResolveIp)
        {
            try { $ComputerName = [System.Net.Dns]::GetHostEntry($ComputerName).HostName }
            catch {}
        }
        if ($success) {
            [PSCustomObject]@{
                ComputerName = $ComputerName
                Port = $Port
                Response = $success
            }
        }
        
    }.toString() + '}'
    $powershell = [powershell]::Create()
    $null = $PowerShell.AddScript($Code).AddArgument($address)
    $powershell.RunspacePool = $RunspacePool
    $threadID++
    Write-Verbose "Starte Thread $threadID"
    $threadInfo = @{
        PowerShell = $powershell
        StartTime = Get-Date
        ThreadID = $threadID
        Runspace = $powershell.BeginInvoke()
    }
    $null = $ThreadList.Add($threadInfo)
}

try
{
    Do {
        Foreach($thread in $ThreadList) {
            If ($thread.Runspace.isCompleted) {
                if($thread.powershell.Streams.Error.Count -gt 0) 
                {
                    foreach($ErrorRecord in $thread.powershell.Streams.Error) {
                        Write-Error -ErrorRecord $ErrorRecord
                    }
                }
                if ($thread.TimedOut -ne $true)
                {
                    $thread.powershell.EndInvoke($thread.Runspace)
                    Write-Verbose "empfange Thread $($thread.ThreadID)"
                }
                $thread.Done = $true
            }
            elseif (-1 -gt 0 -and $thread.TimedOut -ne $true)
            {
                $runtimeSeconds = ((Get-Date) - $thread.StartTime).TotalSeconds
                if ($runtimeSeconds -gt -1)
                {
                    Write-Error -Message "Thread $($thread.ThreadID) timed out."
                    $thread.TimedOut = $true
                    $null = $thread.PowerShell.BeginStop({}, $null)
                }
            }
        }
        $ThreadCompletedList = $ThreadList | Where-Object { $_.Done -eq $true }
        if ($ThreadCompletedList.Count -gt 0)
        {
            foreach($threadCompleted in $ThreadCompletedList)
            {
                $threadCompleted.powershell.Stop()
                $threadCompleted.powershell.dispose()
                $threadCompleted.Runspace = $null
                $threadCompleted.powershell = $null
                $ThreadList.remove($threadCompleted)
            }
          
            Start-Sleep -milliseconds 200
        }
    } while ($ThreadList.Count -gt 0)
      
}
finally
{
    foreach($thread in $ThreadList)
    {
        $thread.powershell.dispose() 
        $thread.Runspace = $null
        $thread.powershell = $null
    }
    $RunspacePool.close()
    [GC]::Collect() 
}
   


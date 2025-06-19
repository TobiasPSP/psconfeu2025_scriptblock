function Foreach-Parallel 
{
    param (   
        [Parameter(Mandatory=$true)]
        [ScriptBlock]
        $Process,

        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        $InputObject,

        [Int]
        [ValidateRange(2,200)]
        $ThrottleLimit = 32,

        [Int]
        [ValidateRange(100,10000)]
        $CheckIntervalMilliseconds = 200,

        [Int]
        $TimeoutSec = -1,
    
        [Switch]
        $UseLocalVariables
    )
  
    # Initialisierungsarbeiten durchführen
    Begin {
        # einen initialen Standard-Zustand der PowerShell beschaffen:
        $SessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
    
        # darin auf Wunsch alle lokalen Variablen einblenden:
        if ($UseLocalVariables)
        {
            # zuerst in einer "frischen" PowerShell alle Standardvariablen ermitteln:
            $ps = [Powershell]::Create()
            $null = $ps.AddCommand('Get-Variable')
            $oldVars = $ps.Invoke().Name
            $ps.Runspace.Close()
            $ps.Dispose()

            # nun aus der vorhandenen PowerShell alle eigenen Variablen in der neuen PowerShell einblenden,
            # (die nicht zu den Standardvariablen zählen):
            Get-Variable | 
            Where-Object { $_.Name -notin $oldVars } |
            Foreach-Object {
                $SessionState.Variables.Add((New-Object System.Management.Automation.Runspaces.SessionStateVariableEntry($_.Name, $_.Value, $null)))
            }
        }

        # einen Runspace-Pool mit den nötigen Threads anlegen:
        $RunspacePool = [Runspacefactory]::CreateRunspacePool(1, $ThrottleLimit, $SessionState, $host)
        $RunspacePool.Open() 

        # in dieser Liste die aktuell noch laufenden Threads vermerken:
        $ThreadList = New-Object System.Collections.ArrayList        
    }


    # für jedes empfangene Pipeline-Element einen Thread starten:
    Process
    {
        # Code in eine Pipeline einbetten, damit $_ gefüllt ist:
        $Code = '$args | Foreach-Object { ' + $Process.toString() + '}'
    
        # Thread anlegen:
        $powershell = [powershell]::Create()
        $null = $PowerShell.AddScript($Code).AddArgument($InputObject)
        $powershell.RunspacePool = $RunspacePool

        # Informationen über diesen Thread in einem Hashtable speichern:
        $threadID++
        Write-Verbose "Starte Thread $threadID"
        $threadInfo = @{
            PowerShell = $powershell
            StartTime = Get-Date
            ThreadID = $threadID
            Runspace = $powershell.BeginInvoke()
        }

        # diese Information in der Liste der laufenden Threads vermerken:
        $null = $ThreadList.Add($threadInfo)
    }


    # am Ende überprüfen, welche Threads inzwischen fertiggestellt sind:
    End 
    {
        $aborted = 0 
        try
        {
            Do {
                # alle noch vorhandenen Threads untersuchen:
                Foreach($thread in $ThreadList) {
                    If ($thread.Runspace.isCompleted) {
                        # wenn der Thread abgeschlossen ist, Ergebnis abrufen und
                        # Thread als "erledigt" kennzeichnen:
                        if($thread.powershell.Streams.Error.Count -gt 0) 
                        {
                            # falls es zu Fehlern kam, Fehler ausgeben:
                            foreach($ErrorRecord in $thread.powershell.Streams.Error) {
                                Write-Error -ErrorRecord $ErrorRecord
                            }
                        }
                        if ($thread.TimedOut -ne $true)
                        {
                            # Ergebnisse des Threads lesen:
                            $thread.powershell.EndInvoke($thread.Runspace)
                            Write-Verbose "empfange Thread $($thread.ThreadID)"
                        }
                        $thread.Done = $true
                    }
                    # falls eine maximale Laufzeit festgelegt ist, diese überprüfen:
                    elseif ($TimeoutSec -gt 0 -and $thread.TimedOut -ne $true)
                    {
                        # Thread abbrechen, falls er zu lange lief:
                        $runtimeSeconds = ((Get-Date) - $thread.StartTime).TotalSeconds
                        if ($runtimeSeconds -gt $TimeoutSec)
                        {
                            Write-Error -Message "Thread $($thread.ThreadID) timed out."
                            $thread.TimedOut = $true
                            $null = $thread.PowerShell.BeginStop({}, $null)
                        }
                    }
                }

                # alle abgeschlossenen Threads ermitteln:
                $ThreadCompletedList = $ThreadList | Where-Object { $_.Done -eq $true }
                if ($ThreadCompletedList.Count -gt 0)
                {
                    # diese Threads aus der Liste der aktuellen Threads entfernen:
                    foreach($threadCompleted in $ThreadCompletedList)
                    {
                        # Thread entsorgen:
                        $threadCompleted.powershell.Stop()
                        $threadCompleted.powershell.dispose()
                        $threadCompleted.Runspace = $null
                        $threadCompleted.powershell = $null
                        $ThreadList.remove($threadCompleted)
                    }
          
                    Start-Sleep -milliseconds $CheckIntervalMilliseconds
                }
                # erneut versuchen, falls es weitere unerledigte Threads gibt:
            } while ($ThreadList.Count -gt 0)
      
        }
        # abschließend Aufräumungsarbeiten durchführen:
        finally
        {
            # falls es noch laufende Threads gibt (Benutzer hat CTRL+C gedrückt)
            # diese abbrechen und entsorgen:
            foreach($thread in $ThreadList)
            {
                $thread.powershell.dispose() 
                $thread.Runspace = $null
                $thread.powershell = $null
            }
            # RunspacePool schließen:
            $RunspacePool.close()
            # Speicher aufräumen:
            [GC]::Collect() 
        }
    }
}
function Get-Ipv4Segment
{
    <#
            .SYNOPSIS
            liefert ein IPv4 Adress-Segment
        
            .EXAMPLE
            Get-Ipv4Segment -From '192.168.2.12' -To '192.168.3.11'
            liefert alle IP-Adressen zwischen angegebener Start- und End-Adresse
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ipaddress]
        $From,
        
        [Parameter(Mandatory)]
        [ipaddress]
        $To
    )
    
    $ipFromBytes =$From.GetAddressBytes()
    $ipToBytes = $to.GetAddressBytes()
    
    # change endianness (reverse bytes)
    [array]::Reverse($ipFromBytes)
    [array]::Reverse($ipToBytes)
    
    # convert reversed bytes to uint32
    $start=[BitConverter]::ToUInt32($ipFromBytes, 0)
    $end=[BitConverter]::ToUInt32($ipToBytes, 0)
    
    # enumerate from start to end uint32
    for($x = $start; $x -le $end; $x++)
    {
        # split uit32 back into bytes
        $ip=[bitconverter]::getbytes($x)
        # reverse bytes back to normal
        [Array]::Reverse($ip)
        # output ipv4 address as string
        $ip -join '.'
    }
}

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

    Test-Port -ComputerName $_ -Port $smbPort -TimeoutMilliSec 500
} -ThrottleLimit 128 -UseLocalVariables -Verbose | 
Where-Object Response |
#Get-NetworkPrinterInfo |
Out-GridView

function Get-MetaData
{
    <#
            .SYNOPSIS
            Reads Metadata from File and provides dynamic IntelliSense for Parameter -MetadataId depending on available MetaData Ids
            .EXAMPLE
            Get-MetaData -Path c:\windows\explorer.exe -MetadataId 
    
    #>
    [CmdletBinding(DefaultParameterSetName='Selected')]
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [String]
        [Alias('FullName')]
        $Path,
    
        [ArgumentCompleter({
                    # receive information about current state:
                    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
        
              
                    # fakeboundparameters provide access to other arguments the user has submitted
                    # HOWEVER this applies only to LITERAL arguments. 
                    # when the user submits variables, or pipes data to a parameter, it DOES NOT SHOW
                    # in fakeboundparameters
                    # -> Smart Intellisense works here ONLY IF the user has specified a LITERAL PATH in -Path
                    #    and there are files in this folder that can be examined. Else, PS falls back to 
                    #    default intellisense
                    if ($fakeBoundParameters.ContainsKey('Path') -eq $false) { return }
                    $path = $fakeBoundParameters['Path']
        
                    #$path = $ExecutionContext.InvokeCommand.ExpandString($path)
        
                    $Directory = Split-Path -Path $path
                    $FileName = Split-Path -Path $path -Leaf
  
                    $shellObject = New-Object -Com Shell.Application
                    $folderObject = $shellObject.NameSpace($Directory)
                    $item = $folderObject.ParseName($FileName)
                    1..400 | ForEach-Object { 
                        $Label = $folderObject.GetDetailsOf($null, $_)
                        if ($Label -ne '') {
                            $displayname = $Label
                            $id = $_
                            [System.Management.Automation.CompletionResult]::new($id, $displayname, "ParameterValue", "$displayName`r`n$id")

                        }
                    }
        })]
        [int[]]
        $MetadataId = 1..600,
        
        [switch]
        $ExcludeEmpty,
        
        [switch]
        $IncludeRawId
    )
  
    process
    {
        # get the location of the file
        $Directory = Split-Path -Path $path
        $FileName = Split-Path -Path $path -Leaf
  
        # use COM interface to access file
        $shellObject = New-Object -Com Shell.Application
        $folderObject = $shellObject.NameSpace($Directory)
        $item = $folderObject.ParseName($FileName)
        
        # retrieve the requested metadata items
        $MetadataId | ForEach-Object -Begin { $h = [Ordered]@{} } -Process { 
            # get the metadata description
            $Label = if ($IncludeRawId)
            {                    
                $folderObject.GetDetailsOf($null, $_) + " ($_)"
            } else 
            {
                $folderObject.GetDetailsOf($null, $_)
            }
            # if present, get the metadata value
            if ($Label -ne '') 
            {
                $value = $folderObject.GetDetailsOf($item, $_)
                if ($value -or (!$ExcludeEmpty))
                {
                    $h.$Label = $value
                }
        
            }
        } -End { [PSCustomObject]$h }
    }
}
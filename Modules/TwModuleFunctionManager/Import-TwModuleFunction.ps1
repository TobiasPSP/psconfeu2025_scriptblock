function Import-TwModuleFunction
{
  param
  (
    [String]
    [Parameter(Mandatory)]
    $Path,
    
    [string]
    $OutPath='',
  
    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [Alias('Name')]
    [String]
    $FunctionName,
    
    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [String]
    $ModuleName,
    
    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [String]
    $ModulePath
  )
  
  begin 
  {
    [string[]]$incorporatedFunctions = @()
    [string[]]$externalModules = @()
    
    if ([String]::IsNullOrWhiteSpace($OutPath))
    {
      $name = [System.Io.Path]::GetFileNameWithoutExtension($Path) + '_combined.ps1'
      $parentFolder = [System.Io.Path]::GetDirectoryName($Path)
      $OutPath = Join-Path -Path $parentFolder -ChildPath $name
    }
  }
  process
  {
    # we can only incorporate functions from modules where the function is present
    # as an individual script file carrying the name of the function
    $searchPath = Join-Path -Path $ModulePath -ChildPath "$FunctionName.ps1"
    $exists = Test-Path -Path $searchPath
    if ($exists)
    {
      $incorporatedFunctions += Get-Content -Path $searchPath -Encoding UTF8 -Raw
    }
    else
    {
      $externalModules += $ModuleName
      Write-Warning "Function '$FunctionName' is not importable because it is not stored as a separate script file."
    }
  }
  
  end
  {
    if ($externalModules.Count -gt 0)
    {
      $modules = $externalModules -join ', '
      $requires = "#requires -Modules $modules"
    }
    else
    {
      $requires
    }
    $originalContent = Get-Content -Path $Path -Encoding UTF8 -Raw
    $addedContent = $incorporatedFunctions | Out-String
    $requires, $addedContent, $originalContent | Set-Content -Path $OutPath -Encoding UTF8 -Force
    
    Write-Warning "New Script saved to $OutPath"
    Get-Item $OutPath
  }
}
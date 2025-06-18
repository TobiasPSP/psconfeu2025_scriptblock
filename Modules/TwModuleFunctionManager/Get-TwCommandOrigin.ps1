function Get-TwCommandOrigin
{
  param
  (
    [string[]]
    [Parameter(Mandatory,ValueFromPipeline)]
    $Command
  )
  
  begin
  {
    $ModuleBase = @{
      Name = 'ModulePath'
      Expression = { 
        if ($_.Module)
        {
          if ($_.Module.ModuleBase)
          {
            $_.Module.ModuleBase 
          }
          else
          {
            '[module location unknown]'
          }
        }
        else
        {
          '[unknown origin]'
        }
      
      }
    }
  }
  process
  {
    $Command | Foreach-Object {
      foreach($commandname in $_)
      {
        $result = Get-Command -Name $_ -ErrorAction SilentlyContinue -ErrorVariable notfound
        # if the function was found in memory, search for the module
        if ($notfound.Count -eq 0 -and [string]::IsNullOrWhiteSpace($_.Source))
        {
          $result = Get-Command -Name $_ -ErrorAction SilentlyContinue -ErrorVariable notfound -All | Where-Object Source | Select-Object -First 1
        }


        if ($notfound.count -gt 0)
        {
          return [PSCustomObject]@{
            Name = $commandname
            ModuleName = ''
            ModulePath = { '' }
          }
        }
        elseif ($result.ModuleName -notlike 'Microsoft.PowerShell.*')
        {
          return $result
        }
      }
    } |
    Select-Object -Property Name, ModuleName, $ModuleBase

  }
}
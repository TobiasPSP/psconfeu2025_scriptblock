function Import-TwDependency
{
  param
  (
    [String]
    [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
    [Alias('FullName')]
    $Path
  )
  
  process
  {
    
    $functions = Get-TwAst -Path $Path -AstType FunctionDefinitionAst | Select-Object -ExpandProperty Name
    
    Get-TwAst -Path $Path -AstType CommandAst | 
      Get-TwCommandName | 
      Get-TwCommandOrigin | 
      Where-Object { $_.Name -notin $functions } | 
      Sort-Object -Property Name -Unique |
      Import-TwModuleFunction -Path $Path
  }

}
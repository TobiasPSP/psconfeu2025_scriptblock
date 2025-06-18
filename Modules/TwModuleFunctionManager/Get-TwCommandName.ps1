function Get-TwCommandName
{
  param
  (
    [System.Management.Automation.Language.CommandAst]
    [Parameter(Mandatory,ValueFromPipeline)]
    $CommandAst
  )
  
  process
  {
    $_.CommandElements[0].Value
  }
  
}
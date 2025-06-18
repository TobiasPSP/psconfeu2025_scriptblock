function Get-TwAst
{
  [CmdletBinding(DefaultParameterSetName='Path')]
  param
  (
    # PowerShell code to examine:
    [Parameter(Mandatory,ValueFromPipeline,ParameterSetName='Text',Position=0)]
    [ScriptBlock]
    $ScriptBlock,
    
    [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,ParameterSetName='File',Position=0)]
    [Alias('FullName')]
    [string]
    $Path,
    
    
    # requested Ast type
    # use dynamic argument completion:
    [ArgumentCompleter({
          # receive information about current state:
          param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    
    
          # get all ast types
          [PSObject].Assembly.GetTypes().Where{$_.Name.EndsWith('Ast')}.Name | 
          Sort-Object |
          # filter results by word to complete
          Where-Object { $_ -like "*$wordToComplete*" } | 
          Foreach-Object { 
            # create completionresult items:
            [System.Management.Automation.CompletionResult]::new($_, $_, "ParameterValue", $_)
          }
    })]
    $AstType = '*',
    
    # when set, do not recurse into nested scriptblocks:
    [Switch]
    $NoRecursion
  )

  begin
  {
    # create the filter predicate by using the submitted $AstType
    # if the user did not specify it is "*" by default, including all:
    $predicate = { param($astObject) $astObject.GetType().Name -like "*$AstType*" }
  }  
  # do this for every submitted code:
  process
  {
    
  
    # we need to read the errors because we are accepting text which
    # can contain syntax errors:
    $errors = $null
    
    $ast = if ($PSCmdlet.ParameterSetName -eq 'File')
    {
      [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$null, [ref]$errors)
    }
    else
    {
      [System.Management.Automation.Language.Parser]::ParseInput($ScriptBlock, [ref]$null, [ref]$errors)
    }
    
    # if the code contains syntax errors and is invalid, bail out:
    if ($errors) { throw [System.InvalidCastException]::new("Syntax errors in code: $($errors | Out-String)")}
    
    # search for all requested ast...
    $ast.FindAll($predicate, !$NoRecursion) |
    # and dynamically add a visible property for the ast object type:
    Add-Member -MemberType ScriptProperty -Name Type -Value { $this.GetType().Name } -PassThru
  }
}
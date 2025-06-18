# ANY scriptblock MUST contain valid PowerShell code:

$scriptblock = 
{
    $starttime = Get-Date
    $hotfixes = Get-Hotfix
    $count = $hotfixes.Count
    $endtime = Get-Date

    $runtime = $endtime - $starttime
    $milliseconds = $runtime.TotalMilliseconds

    "Found $count installed hotfixes. Took $milliseconds ms to complete."
}

# run the scriptblock first to see what it does:
$scriptblock.Invoke()

# For efficiency, when a scriptblock is DEFINED (not run), 
# PowerShell automatically invokes its Parser, and the code is later
# already structured and ready to be executed.
# That's a speed benefit when scriptblocks need to execute repeatedly,
# i.e. in a loop.

# access the RESULT of the parsing:
$ast = $scriptblock.Ast
$ast

# each scriptblock code is separated into BEGIN, PROCESS, END compartements
# if you don't care, your code goes to END:
$ast | Select-Object -Property BeginBlock, ProcessBlock, EndBlock

# another DELEGATE is used to traverse the AST
$ast.FindAll( { $true }, $true )

# each part of the code is organized in a separate TYPE of object
# this ADDS THE TYPE NAME to each object:
$ast.FindAll( { $true }, $true ) | 
Add-Member -MemberType ScriptProperty -Name Class -Value { $this.GetType().FullName } -PassThru -Force

# once you know the type name of anything that interests you, you can filter
# this dumps all variables in a scriptblock:
$ast.FindAll( { $args[0] -is [System.Management.Automation.Language.AssignmentStatementAst] }, $true ) 

$ast.FindAll( { $args[0] -is [System.Management.Automation.Language.AssignmentStatementAst] }, $true ) |
Select-Object -Property Left, Operator, Right

# yet another (delegate) scriptblock in action:
$ast.FindAll( { $args[0] -is [System.Management.Automation.Language.AssignmentStatementAst] }, $true ) |
Select-Object -Property Left, Operator, Right, { $_.Extent.StartLineNumber }


# OBSERVATIONS:

# 1. Arguments
# Scriptblocks receive all input via arguments
# - either use $args as an array (POSITIONAL)
# - or use a param() block for NAMED arguments

# POSITIONAL with $args
$ast.FindAll( { $args[0] -is [System.Management.Automation.Language.AssignmentStatementAst] }, $true ) |
Select-Object -Property Left, Operator, Right
  
# NAMED with param()
$ast.FindAll( { param($node) $node -is [System.Management.Automation.Language.AssignmentStatementAst] }, $true ) |
Select-Object -Property Left, Operator, Right

# 2. Invocation
# Scriptblocks can be sent to another command which then (may) execute it,  i.e.:
Invoke-Command $scriptblock
& $scriptblock
# HOWEVER, Scriptblocks can also be invoked directly. This allows you to control whether you 
# - always get a collection of PSObjects that "wrap" the original results for better compatibility
# - get the return data as-is
$default = { Get-Service -Name Spooler }.Invoke()
$pure = { Get-Service -Name Spooler }.InvokeReturnAsIs() 
$default.GetType().FullName
$pure.GetType().FullName
# with Invoke(), you always get a (predictable) collection, even if the scriptblock returns NULL or just one object



{ Get-Service -Name Spooler }.InvokeReturnAsIs().GetType().FullName
{ Get-Service -Name Spooler }.Invoke().GetType().FullName
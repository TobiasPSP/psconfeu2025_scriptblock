# What happens when a ScriptBlock is created?


$scriptblock =
{
    $starttime = Get-Date
    $hotfixes = Get-HotFix
    $count = $hotfixes.Count
    $endtime = Get-Date

    $runtime = $endtime - $starttime
    $milliseconds = $runtime.TotalMilliseconds

    Write-Host "Found $count installed hotfixes. Took $milliseconds ms to complete." -ForegroundColor Yellow
}

$scriptblock | Get-Member

# run the scriptblock first to see what it does:
$scriptblock.InvokeReturnAsIs()

# For efficiency, whenever a new scriptblock is DEFINED,
# PowerShell invokes the Parser.
# This way, the scriptblock is ready to be executed:
# Efficient for repeated execution, i.e. in a loop.

# access the RESULT of the parsing:
$ast = $scriptblock.Ast
$ast

# each scriptblock code is separated into BEGIN, PROCESS, END compartements
# if you don't care, your code goes to END:
$ast | Select-Object -Property BeginBlock, ProcessBlock, EndBlock

# yet another DELEGATE is used to traverse the AST
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
# Scriptblocks receive input via arguments
# - use $args as an array (POSITIONAL)
# - use a param() block for NAMED arguments

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

# plenty of web references for AST, i.e. randomly picked: https://doitpshway.com/powershell-ast-your-friend-when-it-comes-to-powershell-code-analysis-and-extraction
# my own blog: https://powershell.one/powershell-internals/parsing-and-tokenization/abstract-syntax-tree
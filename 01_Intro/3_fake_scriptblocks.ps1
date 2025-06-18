

# PowerShell LANGUAGE constructs DO NOT use real scriptblocks:

if ($PSVersionTable.PSVersion.Major -le 5)
{
    'Windows PowerShell'
}
else
{
    'PowerShell'
}

for ($x = 1000; $x -lt 15000; $x += 300) 
{
    "Frequency $x Hz"
    [Console]::Beep($x, 500)
}

try
{
    1/0
}
catch
{
    "Error was $_"
    $line = $_.InvocationInfo.ScriptLineNumber
    "Error was in Line $line"
}


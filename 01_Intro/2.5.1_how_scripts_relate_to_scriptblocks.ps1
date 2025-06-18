

# this is what happens when you run a script:

# 1. raw text content of file is read:
$code = Get-Content -Path "$rootfolder\Scripts\sample1.ps1" -Raw
# 2. text is converted to a scriptblock:
$scriptblock = [ScriptBlock]::Create($code)
# 3. ScriptBlock is invoked:
$scriptblock.InvokeReturnAsIs()
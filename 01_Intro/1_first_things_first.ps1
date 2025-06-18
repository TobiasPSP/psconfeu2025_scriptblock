
# () : Code that is executed immediately

(Get-Date)
(Get-Date).AddMinutes(30)


# {} : Code that is NOT executed immediately

{ Get-Date }

<#
Scriptblocks are containers for *valid* PowerShell code.
When you DEFINE a scriptblock using {}, the PowerShell parser is invoked (when you RUN a scriptblock, the code is already parsed).
#>
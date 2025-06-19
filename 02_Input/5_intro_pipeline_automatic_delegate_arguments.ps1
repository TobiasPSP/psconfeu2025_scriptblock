
# Take a look at this cmdlet:

Rename-Item -Path C:\windows\explorer.exe -NewName mynewexplorer.exe -WhatIf


# How can this cmdlet scale when using the pipeline?

Get-ChildItem -Path c:\windows -File | Rename-Item -NewName mynewexplorer.exe -WhatIf

# We cannot use the SAME new name for ALL pipeline input


# SOLUTION: delegates

Get-ChildItem -Path c:\windows -File | Rename-Item -NewName { $_.BaseName + "-old" + $_.Extension } -WhatIf

# works with many cmdlets, i.e.:

Get-ChildItem -Path c:\windows -File | Copy-Item -Destination { '{0}\{1}{2}' -f $env:temp, ($_.BaseName + "-old"), $_.Extension } -WhatIf

# WEIRD THOUGH: parameters such as -NewName or -Destination are of type [string] - not [scriptblock] or [object].

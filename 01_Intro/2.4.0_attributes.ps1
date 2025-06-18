
# Attributes:

[ValidateScript({ Test-Path -Path $_ })]$path = 'c:\windows'


# works:
$path = 'c:\windows\system32'
# invalid (non-existing) path throws exception:
$path = 'c:\notfound'

# scriptblock is executed whenever values are assigned to the variable:
[ValidateScript({
        $exists = Test-Path -Path $_
        if ($exists) {
            [Console]::Beep()
            $true
        }
        else {
            [Console]::Beep(400, 600)
            $false
        }
    })]$path = 'c:\windows'

$path = 'c:\wrongPath'


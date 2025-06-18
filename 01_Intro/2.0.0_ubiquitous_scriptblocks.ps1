function Get-InstalledSoftware
{
    param
    (
        [Parameter(Position=0)]
        [string]
        $DisplayName = '*'
    )
    
    $path64 = '\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
    $path32 = '\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    
    Get-ItemProperty -Path "HKLM:$path64","HKCU:$path64", "HKLM:$path32", "HKCU:$path32" -ErrorAction Ignore |
        Select-Object -Property DisplayName, DisplayVersion, Version, Publisher |
        Where-Object { $_.DisplayName -and $_.DisplayName -like "*$DisplayName*" } |
        Sort-Object -Property DisplayName 
}

$result = Get-InstalledSoftware -DisplayName git*

if ($result.Count) { $result } else { Write-Warning 'No Git Software' }
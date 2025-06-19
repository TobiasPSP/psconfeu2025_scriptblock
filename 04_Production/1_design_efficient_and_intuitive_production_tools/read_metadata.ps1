$modulePath = Join-Path -Path $PSScriptRoot -ChildPath MetadataReader
$picturePath = Join-Path -Path $PSScriptRoot -ChildPath SamplePics

Import-Module -Name $modulePath -Verbose -Force

Get-MetaData -Path "$picturePath\bilder (1).png" -ExcludeEmpty
dir $picturePath -File | Get-Metadata -ExcludeEmpty
# slowish:
dir $picturePath -File | Get-Metadata -ExcludeEmpty | Select-Object -Property FileName, Dimensions, BitDepth, Height

dir $picturePath -File | Get-Metadata -ExcludeEmpty -IncludeRawId | Select-Object -First 1
# fast:
dir $picturePath -File | Get-Metadata -MetadataId 165,31,174,178 

# interactive intellisense even more intuitive but requires LITERAL path
Get-MetaData -Path "C:\Kurse\Kurse\psconfeu2025_scriptblock\raw\SamplePics\bilder (1).png" -MetadataId 165, 31, 174, 178
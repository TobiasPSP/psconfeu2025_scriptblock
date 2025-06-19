
# generic vanilla cmdlets provide vanilla information:
Get-ChildItem -Path $picturePath

# for special use cases, add special use case cmdlets
# so that it remains AS SIMPLE as before to do what YOUR COMPANY needs:
Get-MetaData -Path "$picturePath\bilder (1).png" -ExcludeEmpty

# make sure your tools (Cmdlets, Functions) DO ALL THE WORK that OPERATIONS requires
# - NARROW and DEEP
# - good parameters
# - pipeline-aware

Get-ChildItem -Path $picturePath | Get-Metadata -ExcludeEmpty | Out-GridView
Get-ChildItem -Path $picturePath | Get-Metadata -ExcludeEmpty | Select-Object -Property FileName, Dimensions, BitDepth, Height

# provide FLEXIBILITY through well-defined parameters
# i.e. select specific metadata for performance:
Get-ChildItem -Path $picturePath | Get-Metadata -ExcludeEmpty -IncludeRawId | Select-Object -First 1
# MUCH faster:
Get-ChildItem -Path $picturePath | Get-Metadata -MetadataId 165,31,174,178 

# provide GREAT INTELLISENSE where possible:
Get-MetaData -Path "$picturePath\bilder (1).png" -MetadataId 165, 31, 174, 178
Get-MetaData -Path "C:\Kurse\Kurse\psconfeu2025_scriptblock\SamplePics\bilder (1).png" -MetadataId 165, 31, 174, 178

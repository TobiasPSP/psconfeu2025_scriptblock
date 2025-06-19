
# do it again with the PICTURE METADATA script:
$path = "$rootfolder\05_Production\1_design_efficient_and_intuitive_production_tools\1_use_case_reading_picture_metadata.ps1"
$newScript = Import-TwDependency -Path $path
ise $newScript.fullName

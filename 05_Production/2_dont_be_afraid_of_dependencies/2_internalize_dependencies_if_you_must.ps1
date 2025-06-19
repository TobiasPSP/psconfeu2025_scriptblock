
# take a script that requires functions from an external module:
$path = "$rootfolder\05_Production\2_dont_be_afraid_of_dependencies\1_production_network_scan.ps1"

# automatically paste all required functions from all modules into a new script:
$newScript = Import-TwDependency -Path $path

# new script can be opened for review and fine-tuning:
ise $newScript.fullName

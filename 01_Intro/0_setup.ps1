# some initializing

# I am loading these modules MANUALLY from their current location
# you can as well COPY the module folders to any of the monitored folder paths specified in $env:psmodulepath

$rootFolder = $PSScriptRoot | Split-Path
$picturePath = Join-Path -Path $rootFolder -ChildPath SamplePics
$ofs = ','

<#
I am adding the module folder with the presentation modules
temporarily to the $env:PSModulePath variable to not mess
up the presentation computer:
#>

# adding custom folder to the START of the string to ENSURE MODULE PRIORITY
# if ambiguities exist, MY modules WIN:
$env:PSModulePath = "$rootFolder\Modules;$env:PSModulePath"
<#
# you can ENFORCE this also by manually loading plus -FORCE:
Import-Module -Name $rootFolder\Modules\GuiHelpers -Verbose -Force
Import-Module -Name $rootFolder\Modules\MetadataReader -Verbose -Force
Import-Module -Name $rootFolder\Modules\TwModuleFunctionManager -Verbose -Force
Import-Module -Name $rootFolder\Modules\TwNetworkHelpers -Verbose -Force
#>



function prompt { 'PS> ' }

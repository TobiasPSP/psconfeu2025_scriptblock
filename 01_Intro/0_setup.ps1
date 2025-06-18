# some initializing
$rootFolder = $PSScriptRoot | Split-Path
Import-Module -Name $rootFolder\Modules\GuiHelpers -Verbose

function prompt { 'PS> ' }

# make use of "leaky scriptblocks" to create arrays
# (collect information from multiple commands)

$myArray = & {
    "Hello"
    12
    Get-Date
    Get-CimInstance -ClassName Win32_LogicalDisk

}

$myArray.Count
$myArray[0,1]
$myArray[-1]
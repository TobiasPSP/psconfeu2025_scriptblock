$Capitals = 1
$Numbers = 1
$LowerCase = 3
$SpecialCharacters = 2
    
# collecting characters from four different sources:
$characters = & {
    'ABCDEFGHKLMNPRSTUVWXYZ'.ToCharArray() | 
            Get-Random -Count $Capitals

    '23456789'.ToCharArray() | 
            Get-Random -Count $Numbers

    'abcdefghkmnprstuvwxyz'.ToCharArray() | 
            Get-Random -Count $LowerCase

    '§$%&?=#*+-'.ToCharArray() | 
            Get-Random -Count $SpecialCharacters
            
} | 
# another delegate use-case: Sort-Object uses Get-Random to randomize the array:
Sort-Object -Property { Get-Random } 

$password = $characters -join ''
$password
    
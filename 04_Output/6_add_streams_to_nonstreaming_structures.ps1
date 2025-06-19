
# PowerShell language structures (conditions, loops) cannot stream:
do
{
    $ip = Read-Host 'Enter IPv4:'
    $ip
    
    # SYNTAX ERROR:  
} while ($ip) | Out-GridView

# by wrapping structures inside a scriptblock, you can add
# real-time streaming:

& {

    do
    {
        $ip = Read-Host 'Enter IPv4:'
        $ip
    } while ($ip)

} | Out-Gridview

<#
        CONCLUSION:
        This can be extremely useful with database reads or any other task where you
        have an EOF (end of file) that can occur any time.

        For this, you typically need a do..while loop.
        Now, you can make it stream its results while still reading the data source:
#>


& {
    $record = ''
    do 
    {
        $record = Read-Host -Prompt 'simulating incoming data base entries from i.e. SQL'
        $record
    } until ($record -eq 'EOF')
} | Out-GridView
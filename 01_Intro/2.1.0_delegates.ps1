# Delegates:

Get-Service | Where-Object { $_.Status -eq 'Running' }

Show-InputBox -Prompt 'Enter Email' -Title 'Send Report' -ButtonOkText 'Send' `
    -ButtonCancelText 'Abort' -Delegate { $_ -like '*?@?*.?*' }
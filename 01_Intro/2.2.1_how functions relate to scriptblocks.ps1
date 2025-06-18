

# all functions are stored on drive "function:"
Get-ChildItem function:te*


# accessing a function via "$" on this drive reveals its scriptblock:
${function:test}
${function:test} | Get-Member
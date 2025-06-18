
# Remoting
# (excuting a scriptblock on one or many other computers)


Invoke-Command -ScriptBlock { "I am executing on $env:computername" } #-ComputerName server1, server2, server3
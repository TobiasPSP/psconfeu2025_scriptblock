

# () : Code is executed IMMEDIATELY

(Get-Date)
(Get-Date).AddMinutes(30)


# {} : Code is executed NOT IMMEDIATELY

{ Get-Date }

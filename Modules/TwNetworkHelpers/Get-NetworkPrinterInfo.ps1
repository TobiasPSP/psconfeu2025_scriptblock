function Get-NetworkPrinterInfo
{
    <#
            .SYNOPSIS
            liefert SNMP Druckerinformationen von Netzwerkdruckern
            .EXAMPLE
            Get-NetworkPrinterInfo -ComputerName 192.168.12.200
            kontaktiert den Netzwerkdrucker über seine IP-Adresse und liefert
            seine Druckerinfos zurück
    #>
    param
    (
        [Parameter(Mandatory, ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [string]
        $ComputerName,

        [Switch]
        $NoEmpty
    )
        
    begin
    {
        $oid = @{
            RAW_DATA = ".1.3.6.1.2.1.43.18.1.1"
            CONSOLE_DATA = ".1.3.6.1.2.1.43.16"
            CONTACT = ".1.3.6.1.2.1.1.4.0"
            LOCATION = ".1.3.6.1.2.1.1.6.0"
            SERIAL_NUMBER = ".1.3.6.1.2.1.43.5.1.1.17.1"
            SYSTEM_DESCRIPTION = ".1.3.6.1.2.1.1.1.0"
            DEVICE_DESCRIPTION = ".1.3.6.1.2.1.25.3.2.1.3.1"
            DEVICE_STATE = ".1.3.6.1.2.1.25.3.2.1.5.1"
            DEVICE_ERRORS = ".1.3.6.1.2.1.25.3.2.1.6.1"
            UPTIME = ".1.3.6.1.2.1.1.3.0"
            MEMORY_SIZE = ".1.3.6.1.2.1.25.2.2.0"
            PAGE_COUNT = ".1.3.6.1.2.1.43.10.2.1.4.1.1"
            HARDWARE_ADDRESS = ".1.3.6.1.2.1.2.2.1.6.1"
            TRAY_1_NAME = ".1.3.6.1.2.1.43.8.2.1.13.1.1"
            TRAY_1_CAPACITY = ".1.3.6.1.2.1.43.8.2.1.9.1.1"
            TRAY_1_LEVEL = ".1.3.6.1.2.1.43.8.2.1.10.1.1"
            TRAY_2_NAME = ".1.3.6.1.2.1.43.8.2.1.13.1.2"
            TRAY_2_CAPACITY = ".1.3.6.1.2.1.43.8.2.1.9.1.2"
            TRAY_2_LEVEL = ".1.3.6.1.2.1.43.8.2.1.10.1.2"
            TRAY_3_NAME = ".1.3.6.1.2.1.43.8.2.1.13.1.3"
            TRAY_3_CAPACITY = ".1.3.6.1.2.1.43.8.2.1.9.1.3"
            TRAY_3_LEVEL = ".1.3.6.1.2.1.43.8.2.1.10.1.3"
            TRAY_4_NAME = ".1.3.6.1.2.1.43.8.2.1.13.1.4"
            TRAY_4_CAPACITY = ".1.3.6.1.2.1.43.8.2.1.9.1.4"
            TRAY_4_LEVEL = ".1.3.6.1.2.1.43.8.2.1.10.1.4"
            BLACK_TONER_CARTRIDGE_NAME = ".1.3.6.1.2.1.43.11.1.1.6.1.1"
            BLACK_TONER_CARTRIDGE_CAPACITY = ".1.3.6.1.2.1.43.11.1.1.8.1.1"
            BLACK_TONER_CARTRIDGE_LEVEL = ".1.3.6.1.2.1.43.11.1.1.9.1.1"
            CYAN_TONER_CARTRIDGE_NAME = ".1.3.6.1.2.1.43.11.1.1.6.1.2"
            CYAN_TONER_CARTRIDGE_CAPACITY = ".1.3.6.1.2.1.43.11.1.1.8.1.2"
            CYAN_TONER_CARTRIDGE_LEVEL = ".1.3.6.1.2.1.43.11.1.1.9.1.2"
            MAGENTA_TONER_CARTRIDGE_NAME = ".1.3.6.1.2.1.43.11.1.1.6.1.3"
            MAGENTA_TONER_CARTRIDGE_CAPACITY = ".1.3.6.1.2.1.43.11.1.1.8.1.3"
            MAGENTA_TONER_CARTRIDGE_LEVEL = ".1.3.6.1.2.1.43.11.1.1.9.1.3"
            YELLOW_TONER_CARTRIDGE_NAME = ".1.3.6.1.2.1.43.11.1.1.6.1.4"
            YELLOW_TONER_CARTRIDGE_CAPACITY = ".1.3.6.1.2.1.43.11.1.1.8.1.4"
            YELLOW_TONER_CARTRIDGE_LEVEL = ".1.3.6.1.2.1.43.11.1.1.9.1.4"
            WASTE_TONER_BOX_NAME = ".1.3.6.1.2.1.43.11.1.1.6.1.5"
            WASTE_TONER_BOX_CAPACITY = ".1.3.6.1.2.1.43.11.1.1.8.1.5"
            WASTE_TONER_BOX_LEVEL = ".1.3.6.1.2.1.43.11.1.1.9.1.5"
            BELT_UNIT_NAME = ".1.3.6.1.2.1.43.11.1.1.6.1.6"
            BELT_UNIT_CAPACITY = ".1.3.6.1.2.1.43.11.1.1.8.1.6"
            BELT_UNIT_LEVEL = ".1.3.6.1.2.1.43.11.1.1.9.1.6"
            BLACK_DRUM_UNIT_NAME = ".1.3.6.1.2.1.43.11.1.1.6.1.7"
            BLACK_DRUM_UNIT_CAPACITY = ".1.3.6.1.2.1.43.11.1.1.8.1.7"
            BLACK_DRUM_UNIT_LEVEL = ".1.3.6.1.2.1.43.11.1.1.9.1.7"
            CYAN_DRUM_UNIT_NAME = ".1.3.6.1.2.1.43.11.1.1.6.1.8"
            CYAN_DRUM_UNIT_CAPACITY = ".1.3.6.1.2.1.43.11.1.1.8.1.8"
            CYAN_DRUM_UNIT_LEVEL = ".1.3.6.1.2.1.43.11.1.1.9.1.8"
            MAGENTA_DRUM_UNIT_NAME = ".1.3.6.1.2.1.43.11.1.1.6.1.9"
            MAGENTA_DRUM_UNIT_CAPACITY = ".1.3.6.1.2.1.43.11.1.1.8.1.9"
            MAGENTA_DRUM_UNIT_LEVEL = ".1.3.6.1.2.1.43.11.1.1.9.1.9"
            YELLOW_DRUM_UNIT_NAME = ".1.3.6.1.2.1.43.11.1.1.6.1.10"
            YELLOW_DRUM_UNIT_CAPACITY = ".1.3.6.1.2.1.43.11.1.1.8.1.10"
            YELLOW_DRUM_UNIT_LEVEL = ".1.3.6.1.2.1.43.11.1.1.9.1.10"
        }
    }

    process
    {
        # connect to printer:
        $SNMP = New-Object -ComObject olePrn.OleSNMP
        $SNMP.Open($ComputerName,'public')
    
        $hash = [Ordered]@{}
        $hash['IPAddress'] = $ComputerName
    
        $oid.Keys | 
        Sort-Object |
        ForEach-Object {
            try 
            { 
                $hash[$_] = $SNMP.Get($oid[$_]) 
            } 
            catch 
            {
                if ($NoEmpty -eq $false)
                { 
                    $hash[$_] = '<NOINFO>' 
                }
            }


            
        }
    
        $SNMP.Close()
    
        [PSCustomObject]$hash
    }

}
# dieses Skript zeigt, wie sich Abhängigkeiten in ein Skript zurückverlagern lassen
# Pfad zum Zielskript anpassen:

$path = "C:\Kurse\Kurse\kpmg_25_01\Tag3\4_Extras\1 Dependencies\beispielskript.ps1"
$newScript = Import-TwDependency -Path $path

# in ISE öffnen
ise $newScript.fullName

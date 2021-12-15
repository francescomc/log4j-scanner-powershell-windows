# log4j-scanner-powershell-windows
A powershell script which allows you to scan your (windows) infrastructure in search of vulnerability log4j.

## Intro
This powershell script (work in progress) will allow you to scan your network (for the moment only windows machines) in search of vulnerability log4j.
The script creates a list of machines, starting from the file IncludedMachine.txt or from Active Directory.

In this first version, you can start this script in a Powershell ISE console, launched as Administrator. I suggest you to launch this powershell script as a Domain Admin User context or an other user with sufficient privileges to access the paths to be scanned.

The script use the GCI (Get-ChildItem (Microsoft.PowerShell.Management)) and require the module ServerManager and the Feature named RSAT-AD-Powershell. During the process, if you choose active directory, the script check the availability of this components and if it is not present is downloaded and installed.

The command inside the script for check the presence of module
Import-Module ServerManager
Add-WindowsFeature -Name "RSAT-AD-PowerShell" –IncludeAllSubFeature

If you choose to generate the list of machines starting from the includedmachine.txt file, the script skip the check module "RSAT-AD-PowerShell". In this case this module is not needed.

The program generating a output file for the results: if a vulnerable jar is founded into the scanned machine, will be written a linew like this:

Machine name
c:\Program Files\..\..\..\log4j-core-2.13.3.jar

## Prerequisites

1 - Copy al files inside any folder over a machine in your domain (tipically a service machine)
2 - I suggest to Launch Powershell Ise in Administrator mode.
3 - for the moment it is not possible to specify the access credentials so i suggest you to launch this script in Domain admin context or another user which has enough permissions for access to remote machines.


## Usage
Launch the script. The console ask if you want


## Notes
**This script has been tested in various infrastructures but I still cannot guarantee its perfect functioning.
I am implementing new functions including requesting general credentials to access machines and A.D.
Actually, inside the script, you can find the section for use the function with others credentials.**

$username = "Username"
$Password = ConvertTo-SecureString -String "Password" -AsPlainText -Force
$cred = [pscredential]::new($username,$Password)
Invoke-Command -ComputerName $i -credential $cred -ScriptBlock $command 

**Feel free to participate, modify and improve this script**

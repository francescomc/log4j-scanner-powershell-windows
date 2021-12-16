# log4j-scanner-powershell-windows
A powershell script which allows you to scan your (windows) infrastructure in search of vulnerability log4j.

## Intro
This powershell script (work in progress) will allow you to scan your network (for the moment only windows machines) in search of vulnerability log4j.
The script creates a list of machines, starting from the file IncludedMachine.txt or from Active Directory.

In this first version, you can start this script in a Powershell ISE console, launched as Administrator. I suggest you to launch this powershell script as a Domain Admin User context or an other user with sufficient privileges to access the paths to be scanned. The script also prompt you some questions like:
If you want use a global credentials for this script and allow you to use it one time
If you choose no the script ask you if you want use the 


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
3 - during the process, the script ask if you want use a different credentials to make the basic operations
    You can choose to insert a one time global credentials (like domain\user and password) or a different credentials for the different operations
    es.: you can specify credentials for the active directory scan, others credentials for connect to the machine during scan process ecc..
4 - The machine used for launching the script need to have powershell script execution allowed.


## Usage
Launch the script. The console ask if you want:
Use a global credentials: 
- if you press yes, a popup will ask you for a domain credentials and use them everywhere in the program without asking anymore 
- if you press no the script continue

Now the program ask you if you want discovery the machines with active directory.
- If you answer yes the script check if all AD module are installed.
   - If not the script ask you if you want to use different credentials for install it
     - if you choose to install it with a different credentials the script prompt a popup for the request of credentials
     - if you choose no, the installation proceed with the current context credentials
   - After the Module check The script ask if you want use a different credentials for the connection to AD
     - if you choose yes the script prompt a popup for the request of credentials
     - if you choose no, the program contact AD with the current context credentials
- If you answer no (to search machines in AD), the script get the machines from the includedmachines.txt file.
  You can populate the includedmachines.txt and excludedmachines.txt with list like this:
  Pc-01
  Server-02
  SRV-EMAIL
  SRVService

- Now the program ask if you want to use an exclsuion list of path (for scan exclusion)
  - if you choose yes, you can write and exclude from the scanning activity, some root path like windows, Program Files(x86). You need to insert a string of paths comma    separated like windows, Program Data,Users

- Now The program ask you if you want coose the partition to be scanned
  - if you answer yes, you need to insert a partition letter to scan, comma separated like:   C,D,F,O
  - if you answer no, the default partition C is choosed

- When the list of Machines is ready, and you have answer to other questions, the program ask you if you want to use a different set of credentials for contact the remote machine in your list.
  - If you choose yes the script prompt a popup for the request of credentials
  - if you choose no, the program contact the machines with the current context credentials

The scan process starting, and generate output in output.txt file at the same level of the script.

**KEEP ATTENTION: if you populate the file excludedmachines.txt, with a list of machines you don't want to scan, this machines will be skipped.**
**If you want scan all the retrieved Machines leave empty the exclusion file**


## Notes
**This script has been tested in various infrastructures but I still cannot guarantee its perfect functioning.**  
**I am implementing new functions and I'm reordering the code**  
**Actually, inside the script, you can find and add the section reported below, used for connect to the machine with specific credentials.**

if($i.name -eq "Machine 1") #add case or multiple cases of machine with other credentials
        {
            $username = "Username"
            $Password = ConvertTo-SecureString -String "Password" -AsPlainText -Force
            $cred = [pscredential]::new($username,$Password)
            $command = { gci 'C:\' -rec -force -include *.jar -ea 0 | foreach {select-string "JndiLookup.class" $_} | select -exp Path}

**Feel free to participate, modify and improve this script**

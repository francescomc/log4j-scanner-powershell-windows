# log4j-scanner-powershell-windows
A powershell script which allows for you to scan your (Microsoft Windows) infrastructure in search of the Log4Shell 
vulnerability.

## Intro
This Powershell script (work in progress) will allow you to scan your network (only Windows machines at the moment) in 
order to check whether the Log4Shell vulnerability is affecting any of the nodes.

The script creates a list of machines, starting from the file IncludedMachine.txt or from Active Directory.

In this first version, you can start this script in a Powershell ISE console, and execute it as Administrator. 
Aa a good practice, you could also execute the script as a Domain Admin User context or any different another user, 
provided it has sufficient privileges to access the paths to be scanned. 

The script also prompts you with some questions like:
* Whether you'd want to use global credentials for it and allow you to use it one time
* If you choose "No", the script would ask you if you want to use the ... (missing text here?)

The script uses the GCI (Get-ChildItem (Microsoft.PowerShell.Management)) and requires the `ServerManager` module and 
a feature, named `RSAT-AD-Powershell`. 
During the process, in case you previously you chose the `Active Directory` option, the script will eventually check for 
it to be locally available and attempt to download and install it in case it isn't.

The following commands inside the script will check the presence of module:

* `Import-Module ServerManager`
* `Add-WindowsFeature -Name "RSAT-AD-PowerShell" –IncludeAllSubFeature`

Conversely, in case you'll choose to generate the list of machines starting from the IncludedMachine.txt file, the 
script will skip the `RSAT-AD-PowerShell`, which can be considered optional in such case.

The program will generate an output file for the results: if a vulnerable jar is founded into the scanned machine, a 
line similar to the following  will be written:

```shell
Machine name
c:\Program Files\..\..\..\log4j-core-2.13.3.jar
```

## Prerequisites

1 - Copy al files inside any folder over a machine in your domain (typically a service machine)  
2 - Launch Powershell Ise in Administrator mode.  
3 - During the process, the script will ask you whether you'd want to use different credentials to make the basic operations.
    
    You can choose to insert a one time global credentials (like domain\user and password) or a different credentials for the different operations
    es.: you can specify credentials for the active directory scan, others credentials for connecting to the machine during scan process etc.

4 - The machine used which is executing the script needs to have the Powershell script execution allowed.


## Usage

* Execute the script. The console will ask whether you'd like to:
 Use global credentials: 
    - if you choose `Yes`, a popup dialog will ask you for a domain credentials and use them everywhere in the program 
   without asking anymore 
    - if you press `No` the script will continue

* Now the program will ask you if you want to discover the machines set through Active Directory.
    - If you choose `Yes` the script will check whether all of the Active Directory modules are installed.
       - In case such modules are not installed locally, the script will ask you whether you'd want to use different 
         credentials for installing them
         - if you choose to install it with different credentials, the script will display yet another popup for filling 
           providing them
         - if you choose not to install with different credentials, then the installation will proceed with the 
           current context credentials
       - After this modules check the script will finally ask if you want use yet some different credentials for the 
         connection to Active Directory
         - as usual, if you choose `Yes` then the script will prompt for the desired credentials
         - if you choose `No`, then the program will present the current context credentials to Active Directory
    - If you choose `No`, the script will get the machines from the IncludedMachine.txt file. You can populate both 
      the IncludedMachines.txt and ExcludedMachines.txt with a list similar to the following one:
      Pc-01
      Server-02
      SRV-EMAIL
      SRVService

* As the next step, the program will ask whether you'd want to use an exclusion list of path, in order to optimize the 
  scan process. The required format is a comma separated list of paths, e.g: `Windows,Program Data,Users`

* At this point the program will ask you whether you'd want to choose a partition to be scanned
  - if your answer is `Yes`, you need to insert a partition letter to scan, comma separated like:   C,D,F,O
  - if your answer is `No`, the default partition (i.e.: `C`) is chosen

* Now that the machines list is ready, and you have answered to other questions, the program ask you if you want to use 
  a different set of credentials for contact the remote machine in your list.
  - If you choose `Yes` the script prompts a popup for the request of credentials
  - if you choose `No`, the program contacts the machines with the current context credentials

* Finally the scan process can start, and generate output in an `output.txt` file which will be located at the same 
  level of the script.

**IMPORTANT: if you populate the file ExcludedMachines.txt, with a list of machines you don't want to scan, this machines will be skipped.**
**Conversely, leave it empty in case you want scan all the retrieved machines**


## Notes

**This script has been tested in different environments but I still cannot guarantee its perfect functioning.**  
**New functions are being implemented and  code is being cleaned**  
**Currently, inside the script, you can find and add the section reported below, used for connect to the machine with
specific credentials.**

if($i.name -eq "Machine 1") #add case or multiple cases of machine with other credentials
        {
            $username = "Username"
            $Password = ConvertTo-SecureString -String "Password" -AsPlainText -Force
            $cred = [pscredential]::new($username,$Password)
            $command = { gci 'C:\' -rec -force -include *.jar -ea 0 | foreach {select-string "JndiLookup.class" $_} | select -exp Path}

**Feel free to participate, modify and improve this script**

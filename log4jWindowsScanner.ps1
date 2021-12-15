$LocalPath = Split-Path -parent $PSCommandPath
[string[]]$exclusions = Get-Content -Path "$($LocalPath)\ExcludedMachine.txt"
#chose source type:
#ActiveDirectory: scan domain with AD and get list of machine
#List: compile your file "IncludedMachine.txt" with your personal list of Machine 
     
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    $result = [System.Windows.Forms.MessageBox]::Show('Do you want discovery Machine list with ActiveDirectory?' , "Info" , 4)
    if ($result -eq 'Yes') {
    #check if the module ActiveDirectory is installed
        if (Get-Module -ListAvailable -Name "ActiveDirectory") {
            Write-Output "Module ActiveDirectory exists"
        } 
        else {
            Write-Output "Module ActiveDirectory not exists"
            $result2 = [System.Windows.Forms.MessageBox]::Show('Do you want to install Active Directory module for Powershell?' , "Info" , 4)
            if ($result2 -eq 'Yes') {
                Write-Output "Installing Module ActiveDirectory"
                Import-Module ServerManager
                Add-WindowsFeature -Name "RSAT-AD-PowerShell" –IncludeAllSubFeature
            }
            else{
                Write-Output "Module ActiveDirectory needed for this execution"
                exit
            }
        }

        Write-Output "Get Machine list from ActiveDirectory"
        $listaTmp = Get-ADComputer -Filter 'enabled -eq "true"' -Properties Name | where-object { !([string]$_.Name -in $esclusioni)} | Select-Object -Property Name
        foreach ($lst in $listaTmp) {
            $MachineList+=$lst.Name
        }
    }
    else{
        Write-Output "Get Machine list from File"
        $MachineList = Get-Content -Path "$($LocalPath)\IncludedMachine.txt"
    }

$command = { gci 'C:\' -rec -force -include *.jar -ea 0 | foreach {select-string "JndiLookup.class" $_} | select -exp Path}
$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
Start-Transcript -path "$($LocalPath)\output.txt" -append

Foreach ($i in $MachineList)
{
    Write-Output $i
    try
    { #if added only for show how use the credentials method
        if($i.name -eq "Machine 1") #add name of machine with other credentials
        {
            $username = "Username"
            $Password = ConvertTo-SecureString -String "Password" -AsPlainText -Force
            $cred = [pscredential]::new($username,$Password)
            Invoke-Command -ComputerName $i -credential $cred -ScriptBlock $command 
        }
        elseif($i.name -eq "Machine 2") #add name of machine with other credentials
        {
            $username = "Username"
            $Password = ConvertTo-SecureString -String "Password" -AsPlainText -Force
            $cred = [pscredential]::new($username,$Password)
            Invoke-Command -ComputerName $i -credential $cred -ScriptBlock $command 
        }
        #this section is the default basic execution
        else{
            Invoke-Command -ComputerName $i -ScriptBlock $command  
        }
    }
    catch{

    }
}
Stop-Transcript

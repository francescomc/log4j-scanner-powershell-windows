Function TestCredentials{
    param($crede)
    Process{
        $username = $crede.username
        $password = $crede.GetNetworkCredential().password
        $CurrentDomain = "LDAP://" + ([ADSI]"").distinguishedName
        $domain = New-Object System.DirectoryServices.DirectoryEntry($CurrentDomain,$UserName,$Password)

            if ($domain.name -eq $null)
            {
                $resultAsk = [System.Windows.Forms.MessageBox]::Show('The domain credentials Appears to be wrong. Do you want block this script?' , "Info" , 4)
			    if ($resultAsk -eq 'Yes') 
                {
                    exit #terminate the script.
                }
                else
                {
                    write-host "Successfully authenticated with domain $domain.name"
                }
            }
    }
}


$LocalPath = Split-Path -parent $PSCommandPath
$exclusions = @()
$listaTmpFile = @()
$credAD = $null
$credGetFeature = $null
$credMachine = $null
$credGlobal = $null
$MachineList=@()
$listaTmp = $null
$command = $null
$excludedFolder= $null
$partitions = $null
$listPartitions=@()

#chose source type:
#ActiveDirectory: scan domain with AD and get list of machine
#List: compile your file "IncludedMachine.txt" with your personal list of Machine 
    
    
    $exclusions = Get-Content -Path "$($LocalPath)\ExcludedMachine.txt"
    $listaTmpFile = Get-Content -Path "$($LocalPath)\IncludedMachine.txt"
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    $result = [System.Windows.Forms.MessageBox]::Show('Do you want set a global credentials for this script (like a domain admin credentials)?' , "Info" , 4)
    if ($result -eq 'Yes'){
        $credGlobal = Get-Credential -Message 'Please enter your company user (es.: contoso\user1) and password.'
        TestCredentials $credGlobal
        $credAD = $credGlobal
        $credGetFeature = $credGlobal
        $credMachine = $credGlobal
    }

    $result = [System.Windows.Forms.MessageBox]::Show('Do you want discovery Machine list with ActiveDirectory?' , "Info" , 4)
    if ($result -eq 'Yes') 
    {
        #check if the module ActiveDirectory is installed
        if (Get-Module -ListAvailable -Name "ActiveDirectory")
        {
            Write-Output "Module ActiveDirectory exists"
        } 
        else
        {
            Write-Output "Module ActiveDirectory not exists"
            $result2 = [System.Windows.Forms.MessageBox]::Show('Do you want to install Active Directory module for Powershell?' , "Info" , 4)
            if ($result2 -eq 'Yes') 
            {
                if(!$credGetFeature)
                {
                    $result3 = [System.Windows.Forms.MessageBox]::Show('Do you want use a specific credentials to install ad feature?' , "Info" , 4)
                    if ($result3 -eq 'Yes') 
                    {
                        $credGetFeature = Get-Credential -Message 'Please enter your company user (es.: contoso\user1) and password.'
                        TestCredentials $credGetFeature
                    }
                }
                Write-Output "Installing Module ActiveDirectory"
                Import-Module ServerManager
                if($credGetFeature)
                {
                    Add-WindowsFeature -credential $credGetFeature -Name "RSAT-AD-PowerShell" –IncludeAllSubFeature
                }
                else
                {
                    Add-WindowsFeature -Name "RSAT-AD-PowerShell" –IncludeAllSubFeature
                }
            }
            else
            {
                Write-Output "Module ActiveDirectory needed for this execution"
                end
            }
        }
		Write-Output "Get Machine list from ActiveDirectory"
        if(!$credAD)
        {
		$result = [System.Windows.Forms.MessageBox]::Show('Do you want use a different credentials for AD machines search?' , "Info" , 4)
            if ($result -eq 'Yes') 
            {
			    $credAD = Get-Credential -Message 'Please enter your company user (es.: contoso\user1) and password.'
                TestCredentials $credAD
		    }
        }
		if ($credAD) 
        {
            Write-Output "Launching with specified credentials"
			$listaTmp = Get-ADComputer -credential $credAD -Filter 'enabled -eq "true"' -Properties Name | where-object { !([string]$_.Name -in $exclusions)} | Select-Object -Property Name
		}
		else
        {
            Write-Output "Launching with current context user credentials"
			$listaTmp = Get-ADComputer -Filter 'enabled -eq "true"' -Properties Name | where-object { !([string]$_.Name -in $exclusions)} | Select-Object -Property Name
		}
		foreach ($lst in $listaTmp)
        {
            if($exclusions){
                if(!($exclusions).contains($lst)){
                    $MachineList+=$lst.Name
                }
                else{
                    $MachineList+=$lst.Name
                }
            }
            else
            {
                $MachineList+=$lst.Name
            }
			
	    }		
    }
    else{
        foreach ($lst in $listaTmpFile)
        {
            if($exclusions){
                if(!($exclusions).contains($lst)){
                    $MachineList+=$lst
                }
            }
            else
            {
                $MachineList+=$lst
            }
	    }
	
    }

    $resultExclusion = [System.Windows.Forms.MessageBox]::Show('Do you want to add list of path to exclude from scanning process? (like Windows,Program Data,Program Files(x86))' , "Info" , 4)
    if ($resultExclusion -eq 'Yes')
    {    
        [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')

        $title = 'Write the exclusion path comma separated ,'
        $msg   = 'Enter your path or multiple paths:'

        $excludedFolder = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
        
    }
    $resultExclusion = [System.Windows.Forms.MessageBox]::Show('Do you want to define a list of volume included in scan (es.: C,D,E). Default is C' , "Info" , 4)
    if ($resultExclusion -eq 'Yes')
    {    
        [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')

        $title = 'Write the partitions letter comma separated es.(c,d,e)'
        $msg   = 'Enter your text:'

        $partitions = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
        $listPartitions=$partitions.split(“,”);
    }


$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
Start-Transcript -path "$($LocalPath)\output.txt" -append

if(!$credMachine)
{
    $resultAsk = [System.Windows.Forms.MessageBox]::Show('Do you want use a different general credentials for connect to the machines?' , "Info" , 4)
    if ($resultAsk -eq 'Yes')
    {
        $CredMachine = Get-Credential -Message 'Please enter your company user (es.: contoso\user1) and password.'
        TestCredentials $CredMachine
    }
}

if($exclusions){
Write-Output "===========Actual exclusion list is: ============"
    Foreach ($i in $exclusions)
    {
        Write-Host $i
    }
Write-Output "===========End of List==============================="
Write-Output ""
}

Write-Output "===========Generated Machine list, without excluded machine is: ============"
Foreach ($i in $MachineList)
    {
        Write-Host ($i)
    }
Write-Output "===========End of List==============================="
Write-Output ""


Foreach ($i in $MachineList)
{
    
    Write-Output "Launching script for the machine $i"
    try
    {
        if($i.name -eq "Machine 1") #add case or multiple cases of machine with other credentials
        {
            $username = "Username"
            $Password = ConvertTo-SecureString -String "Password" -AsPlainText -Force
            $cred = [pscredential]::new($username,$Password)
            $command = { gci 'C:\' -rec -force -include *.jar -ea 0 | foreach {select-string "JndiLookup.class" $_} | select -exp Path}
            if($partToScan){
            foreach($l in $partList){
                if($excludedFolder){
                    $command = { gci $l':\' -Exclude $excludedFolder -rec -force -include *.jar -ea 0 | foreach {select-string "JndiLookup.class" $_} | select -exp Path}
                }
                if($crede){
                    Invoke-Command -ComputerName $i -credential $cred -ScriptBlock $command 
                }
                else
                {
                    Invoke-Command -ComputerName $i -ScriptBlock $command 
                } 
            }
             }
             else{
                    if($excludedFolder){
                        $command = { gci 'C:\' -Exclude $excludedFolder -rec -force -include *.jar -ea 0 | foreach {select-string "JndiLookup.class" $_} | select -exp Path}
                    }
                    if($crede){
                        Invoke-Command -ComputerName $i -credential $cred -ScriptBlock $command 
                    }
                    else
                    {
                        Invoke-Command -ComputerName $i -ScriptBlock $command 
                    } 
              }
        }
        else
        {
            $command = { gci 'C:\' -rec -force -include *.jar -ea 0 | foreach {select-string "JndiLookup.class" $_} | select -exp Path}
            if($partToScan){
            foreach($l in $partList){
                if($excludedFolder){
                    $command = { gci $l':\' -Exclude $excludedFolder -rec -force -include *.jar -ea 0 | foreach {select-string "JndiLookup.class" $_} | select -exp Path}
                }
                if($credMachine){
                    Invoke-Command -ComputerName $i -credential $credMachine -ScriptBlock $command 
                }
                else
                {
                    Invoke-Command -ComputerName $i -ScriptBlock $command 
                } 
            }
             }
             else{
                    if($excludedFolder){
                        $command = { gci 'C:\' -Exclude $excludedFolder -rec -force -include *.jar -ea 0 | foreach {select-string "JndiLookup.class" $_} | select -exp Path}
                    }
                    if($crede){
                        Invoke-Command -ComputerName $i -credential $credMachine -ScriptBlock $command 
                    }
                    else
                    {
                        Invoke-Command -ComputerName $i -ScriptBlock $command 
                    } 
              }

	    }
    }
    catch{

    }
    
}
Stop-Transcript


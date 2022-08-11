<#
Jacob Dorsey
4/3/2019

USER CONFIG VERSION

Script checks for existence of User's properties file to modify, if it's not there, rather than trying to create it and confuse alertus, wait 30 seconds and try again.
Clear any pre existing info from text files just in case.
For  user file where the fields may not be there, if a search doesn't find them, insert string at the end
After confirming the existence of those to files, generates Name, Room, and Building variables based off hard coded value for this script, and will input that into a properties file





#>
#################################################################################################################




#HIDDEN Directory where log is stored, chosed PUBLIC DOCUMENTS b/c all users may read/write #
$LogDirectory = "C:\Users\Public\Documents\logs"


Function New-LogDirectory {

##Create Hidden Directory Logs will be stored in ##
New-Item -ItemType Directory -Path $LogDirectory -Force | ForEach-Object {$_.Attributes = "hidden"}
}



New-LogDirectory

##############################################################################################################################
###Variables####
#User Text File which handles information passed to alert
$UserTextFile = "${env:userprofile}\DesktopActivator.user.properties"

#If Text File doesn't exist, create it, rather than use IF statement just using Silently Continue if Error occurs
New-Item -Path ${env:userprofile} -Name 'DesktopActivator.user.properties' -ItemType File -ErrorAction SilentlyContinue

#Makes file writeable
Set-ItemProperty $UserTextFile -name IsReadOnly -value $false



#Not using this file anymore, just have it in here just in case
# $TextFile = "C:\Program Files (x86)\Alertus Technologies\Desktop Activator\DesktopActivator.org.properties"



$PhonePrefix = 'EXTN '

#Name of Process we will kill before modifying config file
$ProcessName = 'DesktopActivator'
#Name of executable to resume process
$ProcessPath = "C:\Program Files (x86)\Alertus Technologies\Desktop Activator\DesktopActivator.exe"

#Original Strings Used for Replacements Later in main config file
$OriginalBuilding = 'setting.contactInformation.building='
$OriginalBuilding = 'setting.contactInformation.building='
$OriginalRoom = 'setting.contactInformation.room='
$OriginalName = 'setting.contactInformation.name='
$OriginalPhoneNumber = 'setting.contactInformation.phoneNumber='
$OriginalPort = 'preventMultipleInstances.port.current=51785'

#Environmental variable for computer's hostname
$Hostname = $env:COMPUTERNAME

#Error Log
$ErrorLog = "${LogDirectory}\AlertusActivatorErrorLog.txt"
##############################################################################################################################
#################################################################################################################




#################################################################################################################




Function Populate-CSVFile {

    #1/29/2018 - Process Can't be stopped within powershell script due to permissions
    #Kill Process before modifying text file
    #Get-Process -Name $ProcessName | Stop-Process

    ##############################################################################################################################
    ###Variables####
    #User Text File which handles information passed to alert
    $UserTextFile = "${env:userprofile}\DesktopActivator.user.properties"

    #If Text File doesn't exist, create it
    $TestTextFile = Test-Path $UserTextFile
    if ($TestTextFile -eq $null) {
    New-Item -Path ${env:userprofile} -Name 'DesktopActivator.user.properties' -ItemType File
    }

    $TestTextFile = Test-Path $UserTextFile


    #Not using this file anymore, just have it in here just in case
    # $TextFile = "C:\Program Files (x86)\Alertus Technologies\Desktop Activator\DesktopActivator.org.properties"

   


    $PhonePrefix = 'EXTN '

    #Name of Process we will kill before modifying config file
    $ProcessName = 'DesktopActivator'
    #Name of executable to resume process
    $ProcessPath = "C:\Program Files (x86)\Alertus Technologies\Desktop Activator\DesktopActivator.exe"

    #Original Strings Used for Replacements Later in main config file
    $OriginalBuilding = 'setting.contactInformation.building='
    $OriginalBuilding = 'setting.contactInformation.building='
    $OriginalRoom = 'setting.contactInformation.room='
    $OriginalName = 'setting.contactInformation.name='
    $OriginalPhoneNumber = 'setting.contactInformation.phoneNumber='
    $OriginalPort = 'preventMultipleInstances.port.current=51785'

    #Environmental variable for computer's hostname
    $Hostname = $env:COMPUTERNAME

    #Error Log
    $ErrorLog = "${LogDirectory}\AlertusActivatorErrorLog.txt"
    ##############################################################################################################################



    #No matter what script will reset properties file to replace lines that may have been modified previously by script


    #Start By Resetting Variables (In case you had to run script a 2nd time)
    #Error action parameter is used b/c these variables will only be filled of the script was being run multiple times
    Clear-Variable -Name PhoneNumber -ErrorAction SilentlyContinue
    Clear-Variable -Name BuildingNumber -ErrorAction SilentlyContinue
    Clear-Variable -Name Room -ErrorAction SilentlyContinue
    Clear-Variable -Name Name -ErrorAction SilentlyContinue


    #Resetting User Text File, The .+ at the end of replace this means match and replace rest of line
    #Room #
    $a = Get-Content $UserTextFile | ForEach-Object { $_ -replace "$OriginalRoom.+","$OriginalRoom"} 
    $a | Set-Content $UserTextFile
    #Building
    $b = Get-Content $UserTextFile | ForEach-Object { $_ -replace "$OriginalBuilding.+", "$OriginalBuilding" }
    $b | Set-Content $UserTextFile
    #Phone in User config file
    $c = Get-Content $UserTextFile | ForEach-Object { $_ -replace "$OriginalPhoneNumber.+" , "$OriginalPhoneNumber" }
    $c | Set-Content $UserTextFile
    #Name
    $d = Get-Content $UserTextFile | ForEach-Object { $_ -replace "$OriginalName.+","$OriginalName" }
    $d | Set-Content $UserTextFile

    #Commenting out since standard user will not be able to write to program files config file
    <#

    #Going to also reset the main configuration file just in case
    #Resetting Text File, The .+ at the end of replace this means match and replace rest of line
    #Room #
    $a = Get-Content $TextFile | ForEach-Object { $_ -replace "$OriginalRoom.+","$OriginalRoom"} 
    $a | Set-Content $TextFile
    #Building
    $b = Get-Content $TextFile | ForEach-Object { $_ -replace "$OriginalBuilding.+", "$OriginalBuilding" }
    $b | Set-Content $TextFile
    #Phone in User config file
    $c = Get-Content $TextFile | ForEach-Object { $_ -replace "$OriginalPhoneNumber.+" , "$OriginalPhoneNumber" }
    $c | Set-Content $TextFile
    #Name
    $d = Get-Content $TextFile | foreach { $_ -replace "$OriginalName.+","$OriginalName" }
    $d | Set-Content $TextFile
    ############################################################################################################

    #>
    ####################################################
    #Hard code room information:
      $Building = 'Markstein Hall'
    $Room = '227'
    $PhoneNumber = 'No Extention Available'
    $Name = 'Shared Lecturer Office'
    ####################################################


    #Strings Updated with Classroom specific 
    $NewBuilding = "setting.contactInformation.building=$Building"
    $NewRoom = "setting.contactInformation.room=$Room"
    $NewPhoneNumber = "setting.contactInformation.phoneNumber=$PhoneNumber"
    $NewName = "setting.contactInformation.name=$Name"


    #Check if TextFile Exists one last time, since will get error 'you cannot call a method on a null-valued expression if text file doesn't exist
    if ($TestTextFile -ne $true) {
    New-Item -Path ${env:userprofile} -Name 'DesktopActivator.user.properties' -ItemType File
    #User Text File which handles information passed to alert
    $UserTextFile = "${env:userprofile}\DesktopActivator.user.properties"
    }
    
    Get-Content $UserTextFile
    
    #Testing 2/19/2018 Getting a Null error on this line, need to try some error handling logic
    #Start Adding info onto end of strings if they exist
    <#
    
    Write-Host "UserTextFile"
    $UserTextFile
    Write-Host "Original Building New Building"
    Write-Host $OriginalBuilding $NewBuilding
    Write-Host "Original Room, New Room"
    Write-Host $OriginalRoom $NewRoom
    Write-Host "Original Name, New Name"
    Write-Host $OriginalName $NewName
    Write-Host "Original Phone, new Phone"
    Write-Host  $OriginalPhoneNumber $NewPhoneNumber

    #>

    #2/21/2018 Added ErrorAction SilentlyContinue because if the text file was created by script, it wont have the original lines
    (Get-Content -ErrorAction SilentlyContinue $UserTextFile).Replace($OriginalBuilding,$NewBuilding) | Set-Content $UserTextFile
    (Get-Content -ErrorAction SilentlyContinue $UserTextFile).Replace($OriginalRoom, $NewRoom) | Set-Content $UserTextFile
    (Get-Content -ErrorAction SilentlyContinue $UserTextFile).Replace($OriginalName, $NewName) | Set-Content $UserTextFile
    (Get-Content -ErrorAction SilentlyContinue $UserTextFile).Replace($OriginalPhoneNumber, $NewPhoneNumber) | Set-Content $UserTextFile


    Get-Content $UserTextFile

    #Now to test for any strings that may not exist
    $TestRoom = Get-Content $UserTextFile | Select-String $OriginalRoom
    $TestBuilding = Get-Content $UserTextFile | Select-String $OriginalBuilding
    $TestName = Get-Content $UserTextFile | Select-String $OriginalName
    $TestPhone = Get-Content $UserTextFile | Select-String $OriginalPhoneNumber
    $TestPort = Get-Content $UserTextFile | Select-Object $OriginalPort

        #If any of the lines mentioned above are missing, append rather than replace strings
        #Very important for if text file was created by script rather than program
        if ($TestRoom -eq $null) {
        Add-Content -Path $UserTextFile -Value $NewRoom
        }

        if ($TestBuilding -eq $null) {
        Add-Content -Path $UserTextFile -Value $NewBuilding

        }

        if ($TestName -eq $null) {
        Add-Content -Path $UserTextFile -Value $NewName

        }

        if ($TestPhone -eq $null) {
        Add-Content -Path $UserTextFile -Value $NewPhoneNumber

        }

        #Use $OriginalPort variable since I'm not modifying the line, the port # is static, this line is just to make sure that if this function creates the text file (rather than the program) it gets all the config info it needs
        if ($TestPort -eq $null) {
        Add-Content -Path $UserTextFile -Value $OriginalPort
        }
    
    Get-Content $UserTextFile

    #end of function 'PopulateCSVFile' block
    }



############################################################################################################################################

$ProcessName = 'DesktopActivator'

$TestTextFile = Test-Path $UserTextFile

#Need to make sure Process is started, and that CSV file and text file are in reference
if ($TestTextFile -eq $true) {

#invoke function
Populate-CSVFile


}

    else {
    $Global:RetryCount = 0
    
    do {
        
        Start-Sleep -Seconds 15
        if ($TestCSV -eq $true -and $TestTextFile -eq $true) {

        #invoke function
        Populate-CSVFile



        } 
        #Add one to the attempt counter
        $Global:RetryCount ++
       
    } while ($Global:RetryCount -le 2)

        if ($Global:RetryCount -ge 1) {
        Start-Transcript -Path $ErrorLog -Append
        Get-Date
        $Env:USERNAME 
        Write-Host "TextFile Detected: " $TestTextFile 
        Write-Host "CSVFile Detected: " $TestCSV
        Write-Host "Process Detected: " $TestProcess | Out-String
        Stop-Transcript


        }




    }

#Last Resort if text file isn't generated for user
#Need to make sure Process is started, and that CSV file and text file are in reference
if ($TestTextFile -ne $true) {

Start-Transcript -Path $ErrorLog -Append

Write-Host "Text File was not generated, creating now"

New-Item -Path ${env:userprofile} -Name 'DesktopActivator.user.properties' -ItemType File
    
#invoke function
Populate-CSVFile
    

Stop-Transcript

}

 


#Very Last thing
#Makes file read only, to prevent alertus from overwriting it
Set-ItemProperty $UserTextFile -name IsReadOnly -value $true
        
<#
Jacob Dorsey
1/9/2018

Updated on 
9/8/2020

At Login, checks for existence of CSV to get room info from
Then checks for existence of User's properties file to modify, if it's not there, rather than trying to create it and confuse alertus, wait 30 seconds and try again.
Clear any pre existing info from text files just in case.
For  user file where the fields may not be there, if a search doesn't find them, insert string at the end
After confirming the existence of those to files, based off hostname, generates Name, Room, and Building variables based off hostname of computer, and will input that into a properties file
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

#Declare some variables
$CSVFile = "C:\Program Files (x86)\Alertus Technologies\Desktop Activator\ClassroomExtensions.csv"
$CSVInput = Import-Csv $CSVFile
$PhonePrefix = 'EXTN '
#Original Strings Used for Replacements Later in main config file
$OriginalBuilding = 'setting.contactInformation.building='
$OriginalBuilding = 'setting.contactInformation.building='
$OriginalRoom = 'setting.contactInformation.room='
$OriginalName = 'setting.contactInformation.name='
$OriginalPhoneNumber = 'setting.contactInformation.phoneNumber='
$OriginalPort = 'preventMultipleInstances.port.current=51785'
#Values that warrant exception
$ELB = "902"
#Error Log
$ErrorLog = "${LogDirectory}\AlertusActivatorErrorLog.txt"
##############################################################################################################################

Function Populate-CSVFile {
    ##############################################################################################################################
    ###Variables####
    #User Text File which handles information passed to alert
    $UserTextFile = "${env:userprofile}\DesktopActivator.user.properties"

    #If Text File doesn't exist, create it
    $TestTextFile = Test-Path $UserTextFile
    if ($TestTextFile -eq $null) {
    New-Item -Path ${env:userprofile} -Name 'DesktopActivator.user.properties' -ItemType File
    }

    $TestCSV = Test-Path $CSVFile
    $TestTextFile = Test-Path $UserTextFile

    #Environmental variable for computer's hostname
    $Hostname = $env:COMPUTERNAME
    #$Hostname = '03316ATS27-01'

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
    ############################################################################################################
            if ($Hostname.Length -eq 13) {

            #Takes first 2 characters of string
            $BuildingNumber = $Hostname.Substring(0,2)
            #Takes the 3rd, 4th, and 5th characters of the string
            $Room = $Hostname.Substring(2,3)

            #Looks in CSV File to Find Building Name, Contact Name, and Phone Extension
            $ext = $CSVInput | Where-Object {$_.BldgNum -eq $BuildingNumber -and $_.Room -eq $Room} | Select-Object -ExpandProperty Extn 
            $NamePrefix = $CSVInput | Where-Object {$_.BldgNum -eq $BuildingNumber -and $_.Room -eq $Room} | Select-Object -ExpandProperty ContactName
            $Name = "${NamePrefix} $Room"               
            $PhoneNumber = "${PhonePrefix}${ext}"    
            $Building = $CSVInput | Where-Object {$_.BldgNum -eq $BuildingNumber -and $_.Room -eq $Room} | Select-Object -ExpandProperty Bldg
                #1st IF Statement bracket
                }

                #Some buildings with 4 numbers in room number also have letters after their room number, going to try adding that
                #QUAD Classrooms are the only ones without a proper building Number
                #Ideally will replace this later on
                if ($Hostname.Length -ge 15) {

                    #If first for characters are quad
                    if ($Hostname.Substring(0,4) -eq 'QUAD') {
                
                     #Takes first 4 characters of string
                    $BuildingNumber = $Hostname.Substring(0,4)
                    #Takes 5th, 6th, and 7th characters of the string
                    $Room = $Hostname.Substring(4,3)

                       #Looks in CSV File to Find Building Name, Contact Name, and Phone Extension
                        $ext = $CSVInput | Where-Object {$_.Bldg -eq $BuildingNumber -and $_.Room -eq $Room} | Select-Object -ExpandProperty Extn 
                        $NamePrefix = $CSVInput | Where-Object {$_.Bldg -eq $BuildingNumber -and $_.Room -eq $Room} | Select-Object -ExpandProperty ContactName
                        $Name = "${NamePrefix} $Room"               
                        $PhoneNumber = "${PhonePrefix}${ext}"    
                        $Building = $CSVInput | Where-Object {$_.Bldg -eq $BuildingNumber -and $_.Room -eq $Room} | Select-Object -ExpandProperty Bldg
                    }

                    else {

                    #Takes first 2 characters of string
                    $BuildingNumber = $Hostname.Substring(0,2)
                    #Takes 5th, 6th, and 7th characters of the string
                    $Room = $Hostname.Substring(2,5)

                    #Looks in CSV File to Find Building Name, Contact Name, and Phone Extension
                    $ext = $CSVInput | Where-Object {$_.BldgNum -eq $BuildingNumber -and $_.Room -eq $Room} | Select-Object -ExpandProperty Extn 
                    $NamePrefix = $CSVInput | Where-Object {$_.BldgNum -eq $BuildingNumber -and $_.Room -eq $Room} | Select-Object -ExpandProperty ContactName
                    $Name = "${NamePrefix} $Room"               
                    $PhoneNumber = "${PhonePrefix}${ext}"    
                    $Building = $CSVInput | Where-Object {$_.BldgNum -eq $BuildingNumber -and $_.Room -eq $Room} | Select-Object -ExpandProperty Bldg
                }
                
                }

                #UVA Classroom is currently not named correctly, until i can get it properly named, going to make another exception if clause
                if ($Hostname.Length -eq 8) {

                #Takes first 3 characters of string
                $BuildingNumber = $Hostname.Substring(0,3)
                #No Room Number ATM so just going to use Classroom value here
                $Room = 'Classroom'
                $Name = "Instructor Station UVA $Room"
                $Building = "UVA"
                $ext = 'N/A'
                $PhoneNumber = "${PhonePrefix}${ext}"    
                }


                elseif ($Hostname.Length -eq 14 ) {

                    #first need to check if the first 3 numbers are 902, if that's the case, they'll need a special rule since that building has 3 numbers
                    if ($hostname.Substring(0,3) -eq $ELB) {
                        $BuildingNumber = $hostname.Substring(0,3)
                        $Room = $hostname.Substring(3,3)
                        
                    }
                        else {
                        #Takes first 2 characters of string
                        $BuildingNumber = $Hostname.Substring(0,2)
                        #Takes the 3rd, 4th, 5th, and 6th characters of the string
                        $Room = $Hostname.Substring(2,4)
                }
               
                      #Looks in CSV File to Find Building Name, Contact Name, and Phone Extension
                        $ext = $CSVInput | Where-Object {$_.BldgNum -eq $BuildingNumber -and $_.Room -eq $Room} | Select-Object -ExpandProperty Extn 
                        $NamePrefix = $CSVInput | Where-Object {$_.BldgNum -eq $BuildingNumber -and $_.Room -eq $Room} | Select-Object -ExpandProperty ContactName
                        $Name = "${NamePrefix} $Room"               
                        $PhoneNumber = "${PhonePrefix}${ext}"    
                        $Building = $CSVInput | Where-Object {$_.BldgNum -eq $BuildingNumber -and $_.Room -eq $Room} | Select-Object -ExpandProperty Bldg
                    #else if bracket
                    }

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

    #2/21/2018 Added ErrorAction SilentlyContinue because if the text file was created by script, it wont have the original lines
    (Get-Content -ErrorAction SilentlyContinue $UserTextFile).Replace($OriginalBuilding,$NewBuilding) | Set-Content $UserTextFile
    (Get-Content -ErrorAction SilentlyContinue $UserTextFile).Replace($OriginalRoom, $NewRoom) | Set-Content $UserTextFile
    (Get-Content -ErrorAction SilentlyContinue $UserTextFile).Replace($OriginalName, $NewName) | Set-Content $UserTextFile
    (Get-Content -ErrorAction SilentlyContinue $UserTextFile).Replace($OriginalPhoneNumber, $NewPhoneNumber) | Set-Content $UserTextFile

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



$TestCSV = Test-Path $CSVFile
$TestTextFile = Test-Path $UserTextFile

#Need to make sure Process is started, and that CSV file and text file are in reference
if ($TestCSV -eq $true -and $TestTextFile -eq $true) {

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

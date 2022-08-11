$TextFile = 'C:\users\jdorsey\Downloads\temp\dave_ad_computers.txt'
$ListOfComputers = Get-Content $TextFile

foreach ($Computer in $ListOfComputers) {

   Get-ADComputer $Computer | Remove-ADObject -Recursive -Confirm:$false
}
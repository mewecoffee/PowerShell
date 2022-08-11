#CSV File with Username & Passwords
$CSVFileOfUsers = Import-csv "C:\users\jdorsey\downloads\csv.csv"

function Test-Cred {
#Parameters to pass to the function           
param (
    $Username,
    $Password
)
      
    
    Try
    {
        # Get Domain
        $Root = "LDAP://" + ([ADSI]'').distinguishedName
        $Domain = New-Object System.DirectoryServices.DirectoryEntry($Root,$UserName,$Password)
    }
    Catch
    {
        $_.Exception.Message
        Continue
    }
  
    If(!$domain)
    {
        Write-Warning "Something went wrong"
    }
    Else
    {
        If ($domain.name -ne $null)
        {
            write-host "_________________________________________"
            write-host $User.Username
            return "Authenticated"
            write-host "_________________________________________"
        }
        Else
        {
            write-host "_________________________________________"
            write-host $User.Username
            return "Not authenticated"
            write-host "_________________________________________"
        }
    }
}


Foreach ($User in $CSVFileOfUsers) {
    $Username = $User.Username
    $Password = $User.Password

    Test-Cred -Username $Username -Password $Password
}
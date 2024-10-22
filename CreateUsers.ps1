# Retrieve users from CSV-file
$users = Import-CSV -Path 'UsersCSV.csv' -Delimiter ","

$PasswordProfile = @{
    Password = '3fs#dsaDAf224s#'
}
# Creating each user:
foreach ($user in $users) {
    $Params = @{
        UserPrincipalName = $user.givenName + "." + $user.surName + "@DigSecIndustry.onmicrosoft.com"
        DisplayName = $user.givenName + " " + $user.surName
        GivenName = $user.GivenName
        SurName = $user.surName
        MailNickname = $user.givenName + "." + $user.surName
        AccountEnabled = $true
        PasswordProfile = $PasswordProfile
        ForceChancePasswordNextSignIn = $true
        Department = $user.Department
        CompanyName = $user.CompanyName
        Country = $user.Country
        City = $user.City
        JobTitle = $user.JobTitle
    }
    $Params
    New-MgUser @Params
} 


$group = Get-MgGroup -Filter "displayName eq 'Utvikling'"
(Get-MgGroupMember -GroupID $Group.Id).AdditionalProperties.UserPrincipalName


foreach ($user in $users){
    $getuser = Get-MgUser -Filter "givenName eq '$($user.givenName)'"
    Remove-MgUser -UserId $getuser.Id
}

# Create a new user
$newUser = New-MgUser -AccountEnabled -DisplayName "Tim Admin" -MailNickname "TimAdmin" `
-UserPrincipalName "TimAdmin@DigSecIndustry.onmicrosoft.com" `
-PasswordProfile @{ Password = "adsfg3!weafg_fsdf"; ForceChangePasswordNextSignIn = $false } `
-GivenName "Tim" -Surname "Admin"

# Get the Global Administrator role definition
$globalAdminRole = Get-MgDirectoryRole | Where-Object { $_.DisplayName -eq "Global Administrator" }

# Assign the Global Administrator role to the new user
New-MgDirectoryRoleMember -DirectoryRoleId $globalAdminRole.Id -RoleMemberId $newUser.Id
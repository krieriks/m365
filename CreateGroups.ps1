# If connected skip this part
$TenantID = "cc3d062d-6a68-49a5-82a5-f6bbf7d96507"
Connect-MgGraph -TenantId $TenantID `
    -Scope  "User.ReadWrite.All", `
            "Group.ReadWrite.All", `
            "Directory.ReadWrite.All", `
            "RoleManagement.ReadWrite.Directory"


# Create groups
Get-Help New-MgGroup -Online

# Create M365 Groups:

$departments = @("Ledelse", "Utvikling", "Salg", "Kundesupport", "IT-drift", "Administrasjon")
foreach ($department in $departments) {
    $membershiprule = "user.department -eq `"$department`""
    $Params = @{
        DisplayName = "$department"
        Description = "Gruppe for ansatte i avedlingen $department"
        MailEnabled = $true
        MailNickname = $department
        SecurityEnabled = $true
        GroupTypes = @("Unified", "DynamicMembership")
        membershipRule = $membershiprule
        MembershipRuleProcessingState = "On"
    }

    New-MgGroup @Params
}

# List group members - UserPrincipalName
$group = Get-MgGroup -Filter "displayName eq 'HR Team'"
(Get-MgGroupMember -GroupID $Group.Id).AdditionalProperties.UserPrincipalName


$Params = @{
    DisplayName = "m365-license"
    Description = "Members of this group will get a M365 license"
    MailEnabled = $false
    MailNickname = "m365-license"
    SecurityEnabled = $true
    GroupTypes = "assigned"
}

New-MgGroup @Params

New-MgGroup -DisplayName 'm365-license' -MailEnabled:$false -MailNickname "m365-license" -SecurityEnabled
# Function to check if a user exists
function Test-UserExists {
    param ($UserEmail)
    try {
        $user = Get-EXOMailbox -Identity $UserEmail -ErrorAction Stop
        return $true
    } catch {
        Write-Host "User $UserEmail not found." -ForegroundColor Yellow
        return $false
    }
}

$groupName = "SoMeGroup1"
$groupEmail = "SoMe1@DigSecIndustry.onmicrosoft.com"
$UserEmails = @("Dagfinn.Warholm@DigSecIndustry.onmicrosoft.com", "Daniel.Thorsen@DigSecIndustry.onmicrosoft.com", "Emilie.Lien@DigSecIndustry.onmicrosoft.com")

# Check if group already exists
$groupExists = $false
try {
    $existingGroup = Get-UnifiedGroup -Identity $groupName -ErrorAction Stop
    Write-Host "Group '$groupName' already exists." -ForegroundColor Yellow
    $groupExists = $true
} catch {
    Write-Host "Group '$groupName' does not exist. Proceeding with creation." -ForegroundColor Green
}

# Create the group if it doesn't exist
if (-not $groupExists) {
    try {
        $newGroup = New-UnifiedGroup -DisplayName $groupName -Alias $groupName -EmailAddresses $groupEmail -AccessType Private
        Write-Host "Group '$groupName' created successfully." -ForegroundColor Green
        Start-Sleep -Seconds 30  # Wait for group creation to propagate
    } catch {
        Write-Host "Error creating group: $_" -ForegroundColor Red
        exit
    }
} else {
    $newGroup = $existingGroup
}


# Get The group's details
$groupDetails = Get-UnifiedGroup -Identity $groupName | Select-Object ExternalDirectoryObjectId, PrimarySmtpAddress

foreach ($UserEmail in $UserEmails) {
    if (Test-UserExists -UserEmail $UserEmail) {
        try {
            # Add user to the group¨
            Add-UnifiedGroupLinks -Identity $groupName -LinkType Members -Links $UserEmail -Confirm:$false
            Write-Host "Added $userEmail to the group." -ForegroundColor Green

            # Grant Full Access permission
            Write-Host "Full Access granted through group membership for $userEmail." -ForegroundColor Green

            # Grant Send as permission
            Add-RecipientPermission -Identity $groupDetails.PrimarySmtpAddress -Trustee $UserEmail -AccessRights SendAs -Confirm:$false
            Write-Host "Granted Send As permission for $userEmail." -ForegroundColor Green
        } catch {
            Write-Host "Error processing user $userEmail : $_" -ForegroundColor Red
        }
    }
}

Write-Host "Script execution completed." -ForegroundColor Green

#Display final permissions
Write-Host "`nFinal Permissions:" -ForegroundColor Cyan
Write-Host "Group Members (Full Access):" -ForegroundColor Yellow
try {
    Get-UnifiedGroupLinks -Identity $groupName -LinkType Members | Format-Table DisplayName, PrimarySmtpAddress
} catch {
    Write-Host "Unable to retrieve group members: $_" -ForegroundColor Red
}
Write-Host "Send As:" -ForegroundColor Yellow
try {
    Get-RecipientPermission -Identity $groupDetails.PrimarySmtpAddress | Where-Object {$_.AccessRights -eq "SendAs"} | Format-Table Trustee, AccessRights
} catch {
    Write-Host "Unable to retrieve Send As permissions: $_" -ForegroundColor Red
}
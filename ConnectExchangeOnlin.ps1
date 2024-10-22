# Check if ExchangeOnlineManagement module is installed, if not it will be installed
if(!(Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
    Write-Host "ExchangeOnlineManagement module not found. Installing..."
    Install-Module -Name ExchangeOnlineManagement -Force -AllowClobber
} else {
    Write-Host "ExchangeOnlineManagement module is already installed."
}

# Import the module
Import-Module ExchangeOnlineManagement

# Connect to Exchange Online
try {
    Connect-ExchangeOnline -ShowProgress $true
    Write-Host "Successfully connected to Exchange Online."
}

catch {
    Write-Host "Error connecting to Exchange ONline: $_"
}
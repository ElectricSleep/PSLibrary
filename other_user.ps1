<# 
    Author: Robert Bisek
    Version: 2024.08.14
#>

param (
    [switch]$Force
)

# Function to check if the script is running as Administrator
function Check-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $adminRole = [Security.Principal.WindowsPrincipal] $currentUser
    $isAdmin = $adminRole.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    return $isAdmin
}

# Start of the script
try {
    # Check for Administrator privileges
    if (-Not (Check-Admin)) {
        Write-Output "This script must be run as an Administrator. Please run the script with elevated privileges."
        Exit 1
    }

    # Set the registry path and key
    $policyPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System"
    $policyName = "dontdisplaylastusername"
    $policyValue = 1

    # Check if the key exists, if not, create it
    if (-Not (Test-Path $policyPath)) {
        New-Item -Path $policyPath -Force
    }

    # Set the policy value
    Set-ItemProperty -Path $policyPath -Name $policyName -Value $policyValue

    # Inform the user if ran from console
    Write-Output "The registry setting to hide the last user name has been applied."

    # Handle the -Force parameter
    if ($Force) {
        Write-Output "The server will restart now..."
        Restart-Computer -Force
    } else {
        Write-Output "A restart is required for the changes to take effect. Use the -Force parameter to restart the server automatically."
    }

} catch {
    Write-Error "An error occurred: $_"
    Exit 1
}

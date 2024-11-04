<#
.SYNOPSIS
Connects to an Azure VM over PowerShell Remoting (HTTPS) using self-signed certificates.

.DESCRIPTION
This script prompts for the Azure VM's public IP address and username, 
then connects to the VM using PowerShell Remoting over HTTPS with SSL checks bypassed.

.NOTES
Run this script on the client machine, not on the Azure VM.
Make sure that PowerShell Remoting over HTTPS is enabled on the Azure VM.

#>

# Step 1: Prompt for connection details
$VM_IP = Read-Host "Enter the Azure VM's Public IP Address"
$Username = Read-Host "Enter the username for the Azure VM"

# Step 2: Create session options to bypass SSL checks (required for self-signed certificates)
$sessionOption = New-PSSessionOption -SkipCACheck -SkipCNCheck

# Step 3: Attempt to connect to the Azure VM
Write-Host "🌐 Attempting to connect to $VM_IP as $Username over HTTPS..." -ForegroundColor Cyan

try {
    # Initiate the remote session
    Enter-PSSession -ComputerName $VM_IP -Credential $Username -UseSSL -SessionOption $sessionOption
    Write-Host "🎉 Successfully connected to the Azure VM!" -ForegroundColor Green
}
catch {
    Write-Host "❌ Failed to connect. Please check the IP address, username, and network settings." -ForegroundColor Red
}



<#
.SYNOPSIS
Cleans up PowerShell Remoting over HTTPS setup on the Azure VM.

.DESCRIPTION
This script will:
1. Remove the self-signed SSL certificate.
2. Delete the WinRM HTTPS listener.
3. Reset WinRM configurations to default (optional).
4. Remove the firewall rule for port 5986.

.NOTES
Run this script on the Azure VM as an administrator.

#>

# Variables
$CertStoreLocation = "Cert:\LocalMachine\My"
$Port = 5986
$FirewallRuleName = "WinRM HTTPS-In"

# Step 1: Remove the Self-Signed SSL Certificate
Write-Host "🔐 Removing self-signed SSL certificate..." -ForegroundColor Cyan
$cert = Get-ChildItem -Path $CertStoreLocation | Where-Object { $_.DnsNameList -contains "localhost" }

if ($cert) {
    $cert | Remove-Item -Force
    Write-Host "Certificate removed successfully." -ForegroundColor Green
} else {
    Write-Host "No self-signed certificate found for localhost." -ForegroundColor Yellow
}

# Step 2: Delete the WinRM HTTPS Listener
Write-Host "🖥️ Removing WinRM HTTPS listener..." -ForegroundColor Cyan
$listener = Get-Item -Path WSMan:\localhost\Listener | Where-Object { $_.Keys -contains "Transport=HTTPS" }
if ($listener) {
    Remove-Item -Path WSMan:\localhost\Listener -Recurse
    Write-Host "HTTPS listener removed successfully." -ForegroundColor Green
} else {
    Write-Host "No HTTPS listener found." -ForegroundColor Yellow
}

# Step 3: (Optional) Reset WinRM Configuration to Default
# This step resets WinRM to its default configuration, removing all listeners and settings.
# Uncomment if you want a complete WinRM reset.
# Write-Host "⚙️ Resetting WinRM configuration to default..." -ForegroundColor Cyan
# winrm invoke Restore winrm/config

# Step 4: Remove Firewall Rule for HTTPS on Port 5986
Write-Host "🔒 Removing firewall rule for WinRM HTTPS on port $Port..." -ForegroundColor Cyan
$firewallRule = Get-NetFirewallRule -DisplayName $FirewallRuleName
if ($firewallRule) {
    Remove-NetFirewallRule -DisplayName $FirewallRuleName
    Write-Host "Firewall rule removed successfully." -ForegroundColor Green
} else {
    Write-Host "No firewall rule found for WinRM HTTPS." -ForegroundColor Yellow
}

# Summary
Write-Host "`n🎉 Cleanup complete. The server is now reset and ready for reconfiguration." -ForegroundColor Green

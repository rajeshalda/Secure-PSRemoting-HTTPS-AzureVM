<#
.SYNOPSIS
Enables PowerShell Remoting over HTTPS on an Azure VM with the necessary configurations.

.DESCRIPTION
This script configures PowerShell Remoting over HTTPS by:
1. Generating a self-signed SSL certificate if one does not already exist.
2. Configuring WinRM for HTTPS.
3. Setting the network profile to Private.
4. Adding a firewall rule for port 5986 (HTTPS).

.NOTES
Run this script on the Azure VM as an administrator.
#>

# Set variables
$DnsName = "localhost"
$CertPath = "Cert:\LocalMachine\My"
$Port = 5986
$FirewallRuleName = "WinRM HTTPS-In"

# Step 1: Set Network Profile to Private (this prevents WinRM errors on Public networks)
Write-Host "🔧 Setting the network profile to Private..." -ForegroundColor Cyan
Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private

# Step 2: Create a Self-Signed SSL Certificate if it doesn’t already exist
$cert = Get-ChildItem -Path $CertPath | Where-Object { $_.DnsNameList -contains $DnsName }
if (-not $cert) {
    Write-Host "🔐 Generating self-signed SSL certificate for $DnsName..." -ForegroundColor Cyan
    $cert = New-SelfSignedCertificate -DnsName $DnsName -CertStoreLocation $CertPath
} else {
    Write-Host "🔍 Using existing self-signed certificate for $DnsName." -ForegroundColor Green
}

# Display certificate thumbprint
$thumbprint = $cert.Thumbprint
Write-Host "Certificate Thumbprint: $thumbprint" -ForegroundColor Green

# Step 3: Configure WinRM for HTTPS with the certificate
winrm quickconfig -quiet
Set-Item -Path WSMan:\localhost\Service\AllowUnencrypted -Value $false
Set-Item -Path WSMan:\localhost\Service\Auth\Basic -Value $true
Set-Item -Path WSMan:\localhost\Service\EnableCompatibilityHttpListener -Value $true
Enable-PSRemoting -Force

# Check if HTTPS listener already exists; skip creation if it does
$existingListener = Get-ChildItem -Path WSMan:\localhost\Listener -ErrorAction SilentlyContinue | Where-Object { $_.Keys -contains "Transport=HTTPS" }
if ($existingListener) {
    Write-Host "⚠️ HTTPS listener already exists. Skipping listener creation." -ForegroundColor Yellow
} else {
    # Create a new HTTPS listener with the certificate thumbprint
    Write-Host "🖥️ Creating HTTPS listener for WinRM..." -ForegroundColor Cyan
    New-Item -Path WSMan:\localhost\Listener -Transport HTTPS -Address * -CertificateThumbprint $thumbprint -Force
    Write-Host "✅ HTTPS listener created successfully." -ForegroundColor Green
}

# Step 4: Configure Firewall Rule for HTTPS on Port 5986
$firewallRule = Get-NetFirewallRule -DisplayName $FirewallRuleName -ErrorAction SilentlyContinue
if (-not $firewallRule) {
    New-NetFirewallRule -DisplayName $FirewallRuleName -Direction Inbound -Protocol TCP -LocalPort $Port -Action Allow -Profile Any
    Write-Host "✅ Firewall rule created for HTTPS on port $Port." -ForegroundColor Green
} else {
    Write-Host "⚠️ Firewall rule for HTTPS already exists. Skipping firewall rule creation." -ForegroundColor Yellow
}

# Summary
Write-Host "`n🎉 PowerShell Remoting over HTTPS has been enabled on the server." -ForegroundColor Green
Write-Host "You can now connect from a client machine using the following command:"
Write-Host "`$sessionOption = New-PSSessionOption -SkipCACheck -SkipCNCheck" -ForegroundColor Yellow
Write-Host "Enter-PSSession -ComputerName <VM_Public_IP> -Credential <Username> -UseSSL -SessionOption `$sessionOption" -ForegroundColor Yellow

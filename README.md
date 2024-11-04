# 🔐 PowerShell Remoting Over HTTPS to Azure VM

# This guide provides step-by-step instructions to set up PowerShell Remoting over HTTPS for an Azure Virtual Machine (VM)
# using a self-signed certificate to secure communication. This enables remote management over HTTPS (port 5986). 🚀

# 📋 Prerequisites
# 1. Azure Virtual Machine (VM): Make sure you have an active Azure VM running either Windows Server or Windows Desktop OS.
# 2. Public IP Address: Your VM needs a public IP address to allow remote connections over the internet.
# 3. Network Security Group (NSG): Ensure the NSG associated with your VM allows inbound traffic on port 5986 for HTTPS.

# 🛠 Step 1: Configure SSL Certificate on the VM
# Run the following PowerShell commands on the VM to create a self-signed SSL certificate.

New-SelfSignedCertificate -DnsName "localhost" -CertStoreLocation "Cert:\LocalMachine\My"

# Verify the certificate
Get-ChildItem -Path Cert:\LocalMachine\My

# 🔧 Step 2: Enable and Configure WinRM on the VM
# Run these commands to configure WinRM for HTTPS and set the necessary authentication options.

winrm quickconfig

# Set WinRM to disallow unencrypted connections
Set-Item -Path WSMan:\localhost\Service\AllowUnencrypted -Value $false

# Enable Basic authentication
Set-Item -Path WSMan:\localhost\Service\Auth\Basic -Value $true

# Enable HTTP compatibility listener
Set-Item -Path WSMan:\localhost\Service\EnableCompatibilityHttpListener -Value $true

# Enable PowerShell Remoting
Enable-PSRemoting -Force

# 🛠 If WinRM is not running, start it:
# Check if WinRM service is running
Get-Service -Name winrm

# Start WinRM service if necessary
Start-Service -Name winrm

# 🌐 Step 3: Set the Network Profile to Private (on the VM)
# 1. Go to Settings > Network & Internet > Status on the VM.
# 2. Select Change connection properties for your network connection.
# 3. Set the network profile to Private.

# 🔒 Step 4: Create the HTTPS Listener for WinRM
# Replace "YOUR_CERT_THUMBPRINT_HERE" with your actual certificate thumbprint.

New-Item -Path WSMan:\localhost\Listener -Transport HTTPS -Address * -CertificateThumbprint "YOUR_CERT_THUMBPRINT_HERE"

# 🔥 Step 5: Configure Firewall Rules for HTTPS (Port 5986)
# 1. Open Windows Firewall with Advanced Security on the VM.
# 2. Create a New Inbound Rule:
#    - Choose Port as the rule type.
#    - Select TCP and specify port 5986.
#    - Choose Allow the connection.
#    - Apply to Public, Private, and Domain profiles.
#    - Name the rule, e.g., "WinRM HTTPS-In".

# 💻 Step 6: Connect from Your Local Machine
# Use the following commands on your local machine to connect securely via PowerShell Remoting.
# Note: -SkipCACheck and -SkipCNCheck options are used to bypass SSL checks, which is necessary for self-signed certificates.

$sessionOption = New-PSSessionOption -SkipCACheck -SkipCNCheck

# Connect to the Azure VM
Enter-PSSession -ComputerName <VM_Public_IP> -Credential <Username> -UseSSL -SessionOption $sessionOption

# 🛠 Troubleshooting
# - WinRM Service Issues: Ensure the WinRM service is running (Get-Service -Name winrm) and start it if necessary.
# - Firewall Rules: Double-check that port 5986 is allowed in both the NSG and Windows Firewall.
# - Network Profile: Ensure the VM's network profile is set to Private.

# 🎉 This setup should enable a secure remote PowerShell session to your Azure VM over HTTPS! 🔐

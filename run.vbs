'-----------------------------
' File:  D:\run.vbs
'-----------------------------
Set objShell = CreateObject("Wscript.Shell")

' Powershell arguments:
'   -NoProfile           = don’t load any user profile
'   -ExecutionPolicy Bypass = ignore local policy to allow the .ps1 to run
'   -WindowStyle Hidden  = never show a console window
'   -File "C:\Users\Zain\Desktop\SS_Email.ps1" = path to your script
cmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""C:\Users\Zain\Desktop\SS_Email.ps1"""

' 0 = window style (0 = hidden), False = don’t wait for completion
objShell.Run cmd, 0, False

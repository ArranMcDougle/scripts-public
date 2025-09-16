@echo off
:: Run MdmDiagnosticsTool.exe with elevated rights and wait for it to complete
powershell -Command "Start-Process cmd.exe -ArgumentList '/c MdmDiagnosticsTool.exe -area Autopilot -zip C:\temp\Autopilot.zip' -Verb RunAs -Wait"

:: Open the folder in Explorer
start explorer.exe "C:\temp"
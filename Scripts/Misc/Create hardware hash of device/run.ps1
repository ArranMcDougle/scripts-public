$cmdCommand = "MdmDiagnosticsTool.exe -area Autopilot -zip C:\temp\Autopilot.zip"
Start-Process cmd.exe -ArgumentList "/c $cmdCommand" -Verb RunAs
Start-Process explorer.exe "C:\temp"
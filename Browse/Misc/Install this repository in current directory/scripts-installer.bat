@echo off
echo Before continuing - make sure you are running this file in the location where you want the scripts to be saved! If not, please close this terminal.
pause
where winget >nul 2>&1
if %errorlevel%==0 (
    winget install --id Git.Git -e --source winget
    git clone https://github.com/ArranMcDougle/scripts-public.git
) else (
    echo ERROR: winget is not installed on this system!
    echo Please install winget
)

cls

echo Enabling Powershell scripts...

Powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%CD%\scripts-public\Browse\Local Permissions\Allow running of PowerShell scripts\run.ps1"

echo Install complete!
pause
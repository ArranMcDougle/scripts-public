@echo off
setlocal

REM Check if Git is installed
where git >nul 2>&1

if %errorlevel%==0 (
    echo Ready to update...
) else (
    echo Git not found. Installing via winget...
    
    REM Check if winget is available
    where winget >nul 2>&1
    if %errorlevel%==0 (
        winget install --id Git.Git -e --source winget
    ) else (
        echo ERROR: winget is not installed on this system.
        echo Please install Git via https://git-scm.com/downloads
    )
)

pause


git fetch
git pull
pause
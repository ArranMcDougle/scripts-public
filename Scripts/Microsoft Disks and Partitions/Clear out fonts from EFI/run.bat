@echo off
set /p letter=Enter unused drive letter: 

mountvol %letter%: /s || goto :error
set FontPath=%letter%:\EFI\Microsoft\Boot\Fonts
set BackupPath="C:\ESP Font Backup"
if not exist "%FontPath%" goto :error

echo Creating backup at %BackupPath%
mkdir "%BackupPath%" 2>nul
xcopy "%FontPath%\*" "%BackupPath%\" /e /i /h /y

echo Backup stored at %BackupPath%

echo Removing non-essential boot fonts...
del /q "%FontPath%\*.*"

echo Clearout complete

pause
exit /b

:error
echo.
echo ERROR: Failed to locate EFI System Partition or Fonts directory.
pause
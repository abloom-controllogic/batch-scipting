::Created by Aaron Bloom
::
::Batch Script

:: ###################################History#################################################
::	1/04/2021	Script Created via bat_template

::To Do
::
::	Fill in help section
::	Implement base fuctionality
::		mklink /D .ssh "OneDrive - Control Logic\.dotfiles\.ssh"
::		mklink .lesshst "OneDrive - Control Logic\.dotfiles\.lesshst"

@echo off
setlocal enableextensions enabledelayedexpansion
set returnCode=0



if "%*" EQU "" (
	echo No Input provided
	GOTO END
)

:parse
set in1=%1
if "%in1:~0,1%" NEQ "-" GOTO endparse
if "%in1%" EQU "-d" set debug=Y
if "%in1%" EQU "-h" GOTO HELP
SHIFT
GOTO parse

:endparse

:MAIN
	if "%debug%" EQU "Y" (
		echo Debugging by echoing commands
		@echo on
	)
	::Get Dot Folders list
	dir "%ONEDRIVE%\.dotfiles" /b /A:D > "%TEMP%\tempdirdots.txt"
	::Set symbolic link for each dot dir
	

	::Get Dot Files
	dir "%ONEDRIVE%\.dotfiles" /b /A:-D > "%TEMP%\tempfiledots.txt"
	::Set symbolic link for each dot file



	GOTO END

:HELP
	Echo Help Section not yet implemented

	GOTO END


:END
	::Pause to allow user to read output and exit
	PAUSE
	echo Exiting!
	exit /B !returnCode!
::Help file command line utility
::
::Created by Aaron Bloom
::This Script is to open a .chm help file from within Aaron's Windows Utility folder

:: ###################################History#################################################
::	20/02/2021	Script Created
::	10/03/2021	Added basic parser for switches

::To Do
::	
::	List Help files in directory (-l Switch)
::	Add Help section (-h Switch)
::	Handle spaces in help file name

@echo off
setlocal enableextensions enabledelayedexpansion
set returnCode=0
set help_dir="%USERPROFILE%\OneDrive - Control Logic\Tools\Windows Utilities\help\"


if "%*" EQU "" (
	echo No Input provided
	GOTO END
)

:parse
set in1=%1
if "%in1:~0,1%" NEQ "-" GOTO endparse
if "%in1%" EQU "-d" set debug=Y
if "%in1%" EQU "-h" GOTO HELP
if "%in1%" EQU "-l" GOTO LIST
SHIFT
GOTO parse

:endparse

:MAIN
	if "%debug%" EQU "Y" (
		echo Debugging by echoing commands
		@echo on
	)


::Start a new CMD to open the .chm so the current one doe not hang
START C:\Windows\System32\cmd.exe /c "%help_dir%%1%.chm"


GOTO END

:LIST
	echo Avalible help files are:
	dir /B %help_dir%
	GOTO END

:HELP
	Echo Open a Windows Utility help file
	Echo Currently help directory: %help_dir%
	Echo:
	Echo Supported Switches:
	Echo       -l	List avalible files
	Echo       -h	Show this help
	Echo       -d	Debug by echoing all commands

	GOTO END
	

:END
	exit /B %returncode%
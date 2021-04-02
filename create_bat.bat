::Created by Aaron Bloom
::
::Script to create .bat files from bat_template

:: ###################################History#################################################
::	27/02/2021	Script Created
::	10/03/2021	Added basic parser for switches
::	02/04/2021	Changed the default output directory to the current directory
::			Added switch for output directory


::To Do
::
::	Fill in Help Section
::	Add switches for deciding what options to put in
:: 	Check if Script alread exists and add overwrite switch
::	Call notepad so console does not hang
::	Update template with new default switches

@echo off
setlocal enableextensions enabledelayedexpansion
set returnCode=0
set outputdir=.

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
if "%in1%" EQU "-o" (set outputdir=%2 && SHIFT)
SHIFT
GOTO parse

:endparse

:MAIN
	if "%debug%" EQU "Y" (
		echo Debugging by echoing commands
		@echo on
	)
	TYPE "%MYUTILITIES%\Scripts\bat_template.bat" >"%outputdir%\%1.bat" && echo %1.bat created && notepad "%outputdir%\%1.bat"


	GOTO END

:HELP
	Echo Help Section not yet implemented

	GOTO END


:END
	::Pause to allow user to read output and exit
	PAUSE
	echo Exiting!
	exit /B !returnCode!
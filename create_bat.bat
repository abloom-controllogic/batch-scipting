::Created by Aaron Bloom
::
::Script to create .bat files from bat_template

:: ###################################History#################################################
::	27/02/2021	Script Created
::	10/03/2021	Added basic parser for switches

::To Do
::
::	Fill in Help Section
::	Add switches for deciding what options to put in
:: 	Check if Script alread exists and add overwrite switch
::	Call notepad so console does not hang

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
if "%in1%" EQU "-l" GOTO LIST
SHIFT
GOTO parse

:endparse

:MAIN
	if "%debug%" EQU "Y" (
		echo Debugging by echoing commands
		@echo on
	)
	TYPE "%MYUTILITIES%\Scripts\bat_template.bat" >"%MYUTILITIES%\Scripts\%1.bat" && echo %1.bat created && notepad "%MYUTILITIES%\Scripts\%1.bat"


	GOTO END

:HELP
	Echo Help Section not yet implemented

	GOTO END


:END
	::Pause to allow user to read output and exit
	PAUSE
	echo Exiting!
	exit /B !returnCode!
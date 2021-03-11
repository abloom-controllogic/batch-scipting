::Created by Aaron Bloom
::
::My script to have greated control over echo

:: ###################################History#################################################
::	27/02/2021	Script Created
::	09/03/2021	Changed  main echo to echo all input parameters
::			Added parser to capture leading switches

::To Do
::
::	Add a switch to select argument number to echo
::	Figure out if this should be completely redesigned

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
set MY_ECHO=%*
:MAIN
	if "%debug%" EQU "Y" (
		echo Debugging by echoing commands
		@echo on
	)
	echo %MY_ECHO%

	GOTO END

:HELP
	Echo MyEcho for more control of echo
	Echo Currently will echo all arguments

	GOTO END


:END
	::Pause to allow user to read output and exit
	PAUSE
	echo Exiting!
	exit /B !returnCode!
::Retrieved from https://ss64.com/nt/syntax-elevate.html on 07/02/2021

::This script is meant to test if it was run as admin
:: ###################################History#################################################
::	20/02/2021	Script Retrieved
::	10/03/2021	Added basic parser for switches


::To do
::	Add option for logical return instead of echo

@echo off
setlocal enableextensions enabledelayedexpansion
set returnCode=0


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

fsutil dirty query %SYSTEMDRIVE% >nul
If %errorLevel% NEQ 0 (
   Echo Failure, please rerun this script from an elevated command prompt. Exiting...
   Ping 127.0.0.1 2>&1 > nul
   set returnCode=1
	GOTO END
) 
Echo Success: this script is running elevated.
GOTO END

:HELP
	Echo Help Section not yet implemented

	GOTO END


:END

EXIT /B !returnCode!
	
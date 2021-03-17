::Created by Aaron Bloom
::
::Batch Script

:: ###################################History#################################################
::	08/03/2021	Script Created via bat_template
::	10/03/2021	Added basic parser for switches
::			Outlined Script plan
::	17/03/2021	Added Start and finish times

::To Do
::
::	Fill in help section
::	Implement base fuctionality
::		Compare difference between start and end times
::	Implement check for too many arguments being supplied

@echo off
setlocal enableextensions enabledelayedexpansion
set returnCode=0

::if %* > 9 (echo Too many arguments provided; GOTO END)

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
	::Write your scripting here
	::Store current time
	set Starttime=%TIME%
	::Call function to be timed
	CALL %1 %2 %3 %4 %5 %6 %7 %8 %9
	:: Store time again
	set Endtime=%TIME%
	echo %Starttime% 
	echo %Endtime%
	::Workout diffrence
	echo xxx time taken
	GOTO END

:HELP
	Echo Help Section not yet implemented

	GOTO END


:END
	::Pause to allow user to read output and exit
	PAUSE
	echo Exiting!
	exit /B !returnCode!
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
::		
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

	::Store current time
		set Starttime=%TIME%
	::Call function to be timed
		CALL %1 %2 %3 %4 %5 %6 %7 %8 %9
	:: Store time again
		set Endtime=%TIME%
	::Workout diffrence
		set /A Milsecdif=(%Endtime:~9,2%-%Starttime:~9,2%)*10
		if %Milsecdif% LSS 0 (
			set /A Milsecdif=%Milsecdif%+1000
			set /A Secdif=%Endtime:~6,2%-%Starttime:~6,2%-1
		) ELSE (
			set /A Secdif=%Endtime:~6,2%-%Starttime:~6,2%
		)
		if %Secdif% LSS 0 (
			set /A Secdif=%Secdif%+60
			set /A Mindif=%Endtime:~3,2%-%Starttime:~3,2%-1
		) ELSE (
			set /A Mindif=%Endtime:~3,2%-%Starttime:~3,2%
		)
		if %Mindif$ LSS 0 (
			set /A Mindif=%Mindif%+60
			set /A Hourdif=%Endtime:~0,2%-%Starttime:~0,2%-1
		) ELSE (
			set /A Hourdif=%Endtime:~0,2%-%Starttime:~0,2%
		)
		if %Hourdif% LSS 0 (
			set /A Hourdif=%Hourdif%+24
		)




	:COMPLETE
		set Output="%Hourdif%h %Mindif%m %Secdif%s %Milsecdif%ms has elasped"


	echo !Output:^"=!
	GOTO END

:HELP
	Echo Timer function to time time taken by other functions
	Echo Usage: timer myfunction arg1 arg2 .... arg8
	Echo ''
	Echo Currently limited to 8 arguments after function
	Echo Cannot time longer than 1 day
	Echo Accuracy limited to 10ms increments

	GOTO END


:END
	::Pause to allow user to read output and exit
	PAUSE
	echo Exiting!
	exit /B !returnCode!
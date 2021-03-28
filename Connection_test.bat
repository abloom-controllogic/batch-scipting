::Created by Aaron Bloom
::
::Batch Script

:: ###################################History#################################################
::	28/03/2021	Script Created via bat_template
::			Added Base functionality

::To Do
::
::	Fill in help section
::	Add looping to constant check

@echo off
setlocal enableextensions enabledelayedexpansion
set returnCode=0
set outputfile=N
set gateway=N
set internet=1.1.1.1


if "%*" EQU "exit" (
	echo No Input provided
	GOTO END
)

:parse
set in1=%1
if "%in1:~0,1%" NEQ "-" GOTO endparse
if "%in1%" EQU "-d" set debug=Y
if "%in1%" EQU "-h" GOTO HELP
if "%in1%" EQU "-g" (set gateway=%2 && SHIFT)
SHIFT
GOTO parse

:endparse

:MAIN
	if "%debug%" EQU "Y" (
		echo Debugging by echoing commands
		@echo on
	)
	if "%outputfile%" EQU "N" (
		echo Setting output file to result.txt
		set outputfile=result.txt
	)
	::Get Start with checking the path to internet (This can take a couple mintues)
	echo Checking Path to internet this can take a couple of minutes
	::pathping 1.1.1.1 >> %outputfile%
	::Get default gateway
	if "%gateway%" EQU "N" (
		for /f "tokens=1-2 delims=:" %%a in ('ipconfig^|find "Default"') do (
			set gateway=%%b
		)
		set gateway=!gateway:~1!
		echo Setting gateway to !gateway!
	)
	::Test if gateway is avalible
	for /f %%i in ('ping -n 1 !gateway!^|findstr /C:"Reply from !gateway!"') do (
		echo Local gateway is avalible
	)
	
	::Test if internet is avalible
	for /f %%i in ('ping -n 1 !internet!^|findstr /C:"Reply from !internet!"') do (
		echo Internet is avalible
	)	




	GOTO END

:HELP
	Echo Help Section not yet implemented

	GOTO END


:END
	::Pause to allow user to read output and exit
	PAUSE
	echo Exiting!
	exit /B !returnCode!
::Created by Aaron Bloom
::
::Batch Script

:: ###################################History#################################################
::	28/03/2021	Script Created via bat_template
::			Added Base functionality

::To Do
::

@echo off
setlocal enableextensions enabledelayedexpansion
set returnCode=0
set outputfile=result.txt
set gateway=N
set internet=1.1.1.1
set num_loop=3600
set time_out=30


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
if "%in1%" EQU "-i" (set internet=%2 && SHIFT)
if "%in1%" EQU "-n" (set num_loops=%2 && SHIFT)
if "%in1%" EQU "-t" (set time_out=%2 && SHIFT)
if "%in1%" EQU "-o" (set outputfile=%2 && SHIFT)
SHIFT
GOTO parse

:endparse

:MAIN
	if "%debug%" EQU "Y" (
		echo Debugging by echoing commands
		@echo on
	)

	if "%outputfile%" EQU "result.txt" echo Setting output file to result.txt

	echo Checking Path to internet this can take a couple of minutes
	::pathping 1.1.1.1 > %outputfile%
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
	for /f %%a in ('ping -n 1 !internet!^|findstr /C:"Reply from !internet!"') do (
		echo Internet is avalible
	)	
	::Loop time to log connections
	echo Script will now continuinaly check gateway and internet connection
	set /A time_end=%num_loops%*%time_out%
	echo This will take %time_end% seconds press Ctrl + C to end early
	for /L %%a in (1,1,%num_loops%) do (
		echo %DATE:~4% %TIME:~0,-3%>>%outputfile%
		(ping -n 1 !gateway!|findstr /C:"Reply from !gateway!")>>%outputfile%
		(ping -n 1 !internet!|findstr /C:"Reply from !internet!")>>%outputfile%
		timeout /t %time_out% > null
	)
	echo Test done see %outputfile%

	GOTO END

:HELP
	Echo Connection tester utility
	Echo:
	Echo This Script will test connection to local gateway and internet by using ICMP ping
	Echo Usage: Connection_test [switches]
	Echo Defaults: 
	Echo      Output file -		%outputfile%
	Echo      Number of Loops -	%num_loops%
	Echo      Loop wait time -	%time_out%
	Echo      Internet address -	%internet%
	Echo:     
	Echo Switch options:
	Echo    -d = Debug script by changing ECHO to ON
        Echo    -h = Display this help info
	Echo    -g = Local Gateway IP
	Echo    -i = Internet IP
	Echo    -t = Wait time between checks
	Echo    -n = Number of checks to do
	Echo    -o = Output file to store the results
	GOTO END


:END
	::Pause to allow user to read output and exit
	PAUSE
	echo Exiting!
	exit /B !returnCode!
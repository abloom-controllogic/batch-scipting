:: Control Logic SmartVPN Router config parser Batch file

:: ###################################History#################################################
::	30/07/2020 	Intial Script Created - Aaron Bloom
::	27/01/2021 	??
::	28/06/2021 	Moved into git
::			Change format to conform with Aaron's other .bat utilites

::To Do
::
::	Parse basic config
::	Include all openVPN config options


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

	set input=%1
	IF "%2"=="" (
		SET output=output.ovpn
		echo Output set to: %output%
	) ELSE (
		set output=%2
	)


	::if Input is not *.cfg exit
	IF %input~x==.cfg (
		echo Input is not a .cfg
		exit /b
	)


	::if output is not *.ovpn exit
	IF EXIST %output% (
		::Delete existing file
		DEL %output%
		echo Tried to Delete
	)


	::Open input
	SETLOCAL ENABLEDELAYEDEXPANSION
	echo Starting Parse

	echo client >> %output%
	echo dev tun >> %output%

	FOR /F "skip=2 delims=" %%y in ('findstr /R /C:"OPENVPN.*=" %input%') DO (
		SET temp=%%y
		SET temp=!temp:OPENVPN_=!

		echo !temp:~0,10!
		echo !temp:*.==!
		GOTO !temp:~0,4!
			REM This will set ErrorLevel = 1 if Label does not exist
		GOTO FOR_END
			REM Label not found go to end of loop

		:ENABLED
			GOTO FOR_END
		
		:PROTO
		IF /I "!temp:~0,5!"=="PROTO" (
			echo !temp:~6!>>%output%
			echo PROTO Caught
		)



		REM	To Do setup a switch case based on the inputs DON"T FORGET to find the ?equals sign?
		REM	Use the first 4 characters after striping off OPENVPN_
			GOTO FOR_END		
		:DESCRIPTION
			GOTO FOR_END
		:PORT
			GOTO FOR_END
		:REMOTE
			REM Find remote sub category
			
			GOTO !REMOTE_SUB!
			GOTO FOR_END
			:IPADDR
				GOTO FOR_END
			:NETWORK
				GOTO FOR_END
			:NETMASK
				GOTO FOR_END
			:IF_IPADDR
				GOTO FOR_END
			:NETWORK6
				GOTO FOR_END
			:PREFIX6
				GOTO FOR_END
			:IF_IPADDR6
				GOTO FOR_END
		:LOCAL_IF_IPADDR
			GOTO FOR_END
		:LOCAL_IF_IPADDR6
			GOTO FOR_END
		:REDIRECT_GW
			GOTO FOR_END
		:PING_INTVL
			GOTO FOR_END
		:PING_TOUT
			GOTO FOR_END
		:RENEG_SEC
			GOTO FOR_END
		:FRAGMENT
			GOTO FOR_END
		:COMP
			GOTO FOR_END
		:NAT
			GOTO FOR_END
		:AUTH
			GOTO FOR_END
		:SECRET
			GOTO FOR_END
		:CA_CERT
			GOTO FOR_END
		:DH_PARAMS
			GOTO FOR_END
		:LOCAL_CERT
			GOTO FOR_END
		:LOCAL_KEY
			GOTO FOR_END
		:USERNAME
			GOTO FOR_END
		:PASSWORD
			GOTO FOR_END
		:EXTRA_OPTS
			GOTO FOR_END


		:FOR_END
	)

	::echo %test:_SearchString=OPEN%
	::	value>>%output%
	GOTO END

:HELP
	Echo Help Section not yet implemented
	echo This Batch file is meant to convert .cfg files from to .ovpn
	Echo Usage: cfgTOovpn.bat <switches> input.cfg output.ovpn
	Echo Switches:
	Echo           -d = echo output for debugging
	Echo           -h = Display this Help section
	Echo           
	GOTO END

:END
	::Pause to allow user to read output and exit
	PAUSE
	echo Exiting!
	exit /B !returnCode!

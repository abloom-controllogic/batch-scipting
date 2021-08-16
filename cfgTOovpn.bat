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
::	Fix help section echo


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
		echo Tried to Delete output
	)


	::Open input
	SETLOCAL ENABLEDELAYEDEXPANSION
	echo Starting Parse

	echo client >> %output%
	echo dev tun >> %output%

	FOR /F delims^=^ eol^= %%y in ('findstr /R /C:"OPENVPN.*=" %input%') DO (
		SET temp=%%y
		SET temp=!temp:OPENVPN_=!

		REM	To Do setup a switch case based on the inputs DON"T FORGET to find the ?equals sign?
		REM	Use the first 4 characters after striping off OPENVPN_

		echo !temp:~0,10!
		echo !temp:*.==!
		

		IF /I "!temp:~0,7!"=="ENABLED" echo #Config Enabled=!temp:~8!>>%output%
		IF /I "!temp:~0,5!"=="PROTO" echo !temp:~6!>>%output%
		IF /I "!temp:~0,11!"=="DESCRIPTION" echo #!temp:~12!>>%output%
		IF /I "!temp:~0,4!"=="PORT" echo !temp:~5!>>%output%
		IF /I "!temp:~0,13!"=="REMOTE_IPADDR" echo !temp:~14!>>%output%
		IF /I "!temp:~0,14!"=="REMOTE_NETWORK" echo !temp:~15!>>%output%
		IF /I "!temp:~0,14!"=="REMOTE_NETMASK" echo !temp:~15!>>%output%
		IF /I "!temp:~0,16!"=="REMOTE_IF_IPADDR" echo !temp:~17!>>%output%
		IF /I "!temp:~0,15!"=="REMOTE_NETWORK6" echo !temp:~16!>>%output%
		IF /I "!temp:~0,14!"=="REMOTE_PREFIX6" echo !temp:~15!>>%output%
		IF /I "!temp:~0,17!"=="REMOTE_IF_IPADDR6" echo !temp:~18!>>%output%
		IF /I "!temp:~0,15!"=="LOCAL_IF_IPADDR" echo !temp:~16!>>%output%
		IF /I "!temp:~0,16!"=="LOCAL_IF_IPADDR6" echo !temp:~17!>>%output%
		IF /I "!temp:~0,11!"=="REDIRECT_GW" echo !temp:~12!>>%output%
		IF /I "!temp:~0,10!"=="PING_INTVL" echo !temp:~11!>>%output%
		IF /I "!temp:~0,9!"=="PING_TOUT" echo !temp:~10!>>%output%
		IF /I "!temp:~0,9!"=="RENEG_SEC" echo !temp:~10!>>%output%
		IF /I "!temp:~0,8!"=="FRAGMENT" echo !temp:~9!>>%output%
		IF /I "!temp:~0,4!"=="COMP" echo !temp:~5!>>%output%
		IF /I "!temp:~0,3!"=="NAT" echo !temp:~4!>>%output%
		IF /I "!temp:~0,4!"=="AUTH" echo !temp:~5!>>%output%
		IF /I "!temp:~0,6!"=="SECRET" echo !temp:~17!>>%output%
		IF /I "!temp:~0,7!"=="CA_CERT" echo !temp:~8!>>%output%
		IF /I "!temp:~0,9!"=="DH_PARAMS" echo !temp:~10!>>%output%
		IF /I "!temp:~0,10!"=="LOCAL_CERT" echo !temp:~11!>>%output%
		IF /I "!temp:~0,9!"=="LOCAL_KEY" echo !temp:~10!>>%output%
		IF /I "!temp:~0,8!"=="USERNAME" echo !temp:~9!>>%output%
		IF /I "!temp:~0,8!"=="PASSWORD" echo !temp:~18!>>%output%
		IF /I "!temp:~0,10!"=="EXTRA_OPTS" echo !temp:~11!>>%output%

	)

	::echo %test:_SearchString=OPEN%
	::	value>>%output%
	GOTO END

:HELP
	Echo This Batch file is meant to convert .cfg files from to .ovpn
	Echo "Usage- cfgTOovpn <switches> input.cfg output.ovpn"
	Echo Switches:
	Echo           -d = echo output for debugging
	Echo           -h = Display this Help section
	Echo           
	GOTO END

:END
	::Pause to allow user to read output and exit
	ENDLOCAL
	PAUSE
	echo Exiting!
	exit /B !returnCode!

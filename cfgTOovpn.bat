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

	echo dev tun >> %output%
	::This seems wrong but is in the bash script
	echo syslog>>%output%

	FOR /F delims^=^ eol^= %%y in ('findstr /R /C:"OPENVPN.*=" %input%') DO (

		SET temp=%%y
		SET temp=!temp:OPENVPN_=!

		IF /I "!temp:~0,7!"=="ENABLED" echo #Config Enabled=!temp:~8!>>%output%
		IF /I "!temp:~0,5!"=="PROTO" echo proto !temp:~6!>>%output%
		IF /I "!temp:~0,11!"=="DESCRIPTION" echo #!temp:~12!>>%output%
		IF /I "!temp:~0,4!"=="PORT" echo port !temp:~5!>>%output%
		IF /I "!temp:~0,13!"=="REMOTE_IPADDR" echo remote !temp:~14!>>%output%
		IF /I "!temp:~0,14!"=="REMOTE_NETWORK" SET REMOTE_NETWORK=!temp:~15!
		IF /I "!temp:~0,14!"=="REMOTE_NETMASK" echo route !REMOTE_NETWORK! !temp:~15!>>%output%
		IF /I "!temp:~0,16!"=="REMOTE_IF_IPADDR" SET REMOTE_IF_IPADDR=!temp:~17!
		IF /I "!temp:~0,15!"=="REMOTE_NETWORK6" SET REMOTE_NETWORK6=!temp:~16!
		IF /I "!temp:~0,14!"=="REMOTE_PREFIX6" echo route-ipv6 !REMOTE_NETWORK6!/!temp:~15!>>%output%
		IF /I "!temp:~0,17!"=="REMOTE_IF_IPADDR6" SET REMOTE_IF_IPADDR6=!temp:~18!
		IF /I "!temp:~0,15!"=="LOCAL_IF_IPADDR" echo ifconfig !temp:~16! REMOTE_IF_IPADDR>>%output%
		IF /I "!temp:~0,16!"=="LOCAL_IF_IPADDR6" (
			echo tun-ipv6 >>%output%
			echo ifconfig-ipv6 !temp:~17! !REMOTE_IF_IPADDR6!>>%output%
		)
		IF /I "!temp:~0,11!"=="REDIRECT_GW" (
			IF /I "!temp:~12!"=="1" echo redirect-gateway>>%output%
		)
		IF /I "!temp:~0,10!"=="PING_INTVL" echo ping !temp:~11!>>%output%
		IF /I "!temp:~0,9!"=="PING_TOUT" (
			echo ping-restart !temp:~10!>>%output%
			echo persist-tun>>%output%
			echo persist-key>>%output%
		)
		IF /I "!temp:~0,9!"=="RENEG_SEC" echo reneg-sec !temp:~10!>>%output%
		IF /I "!temp:~0,8!"=="FRAGMENT" echo fragment !temp:~9!>>%output%
		IF /I "!temp:~0,4!"=="COMP" echo compress !temp:~5!>>%output%
		IF /I "!temp:~0,3!"=="NAT" (
			IF /I "!temp:~4!"=="1" echo ##NAT Needs to be applied - Yet to be implemented>>%output%
		)
		IF /I "!temp:~0,4!"=="AUTH" (
			IF /I "!temp:~5!"=="secret" (
				echo !temp:~5!>>%output%
				SET auth=secret
			)
			IF /I "!temp:~5!"=="passwd" (
				echo client>>%output%
				echo auth-retry nointeract>>%output%
				echo hand-window 120>>%output%
				echo key-direction 1 >>%output%
				SET auth=passwd
				echo auth-user-pass option please include auth.txt with %output%.ovpn
				echo auth-user-pass auth.txt>>%output%
			)
			IF /I "!temp:~5!"=="tls-mclient" (
				echo client>>%output%
				echo auth-retry nointeract>>%output%
				echo hand-window 120>>%output%
				echo key-direction 1 >>%output%
				SET auth=tls
			)
			IF /I "!temp:~5!"=="tls-client" (
				echo tls-client>>%output%
				echo auth-retry nointeract>>%output%
				echo hand-window 120>>%output%
				echo key-direction 1 >>%output%
				SET auth=tls
			)
			IF /I "!temp:~5!"=="tls-server" (
				echo tls-server>>%output%
				echo auth-retry nointeract>>%output%
				echo hand-window 120>>%output%
				echo key-direction 1 >>%output%
				SET auth=tls
			)
		)
		IF /I "!temp:~0,6!"=="SECRET" (
			echo !temp:~7! > %TEMP%\cfgTObat.base64
			certutil -f -decode %TEMP%\cfgTObat.base64 %TEMP%\cfgTObat.output > NUL
			IF /I "!auth!"=="secret" echo ^<secret^> >>%output%
			IF /I "!auth!"=="passwd" echo ^<tls-auth^> >>%output%
			IF /I "!auth!"=="tls" echo ^<tls-auth^> >>%output%
			FOR /F delims^=^ eol^= %%D in ('type %TEMP%\cfgTObat.output') DO (
				echo %%D >>%output%
			)
			IF /I "!auth!"=="secret" echo ^</secret^> >>%output%
			IF /I "!auth!"=="passwd" echo ^</tls-auth^> >>%output%
			IF /I "!auth!"=="tls" echo ^</tls-auth^> >>%output%
		)
		IF /I "!temp:~0,7!"=="CA_CERT" (
			echo !temp:~8! > %TEMP%\cfgTObat.base64
			certutil -f -decode %TEMP%\cfgTObat.base64 %TEMP%\cfgTObat.output > NUL
			echo ^<ca^> >>%output%
			FOR /F delims^=^ eol^= %%D in ('type %TEMP%\cfgTObat.output') DO (
				echo %%D >>%output%
			)
			echo ^</ca^> >>%output%
		)
		IF /I "!temp:~0,9!"=="DH_PARAMS" (
			echo !temp:~10! > %TEMP%\cfgTObat.base64
			certutil -f -decode %TEMP%\cfgTObat.base64 %TEMP%\cfgTObat.output > NUL
			echo ^<dh^> >>%output%
			FOR /F delims^=^ eol^= %%D in ('type %TEMP%\cfgTObat.output') DO (
				echo %%D >>%output%
			)
			echo ^</dh^> >>%output%
		)
		IF /I "!temp:~0,10!"=="LOCAL_CERT" (
			echo !temp:~11! > %TEMP%\cfgTObat.base64
			certutil -f -decode %TEMP%\cfgTObat.base64 %TEMP%\cfgTObat.output > NUL
			echo ^<cert^> >>%output%
			FOR /F delims^=^ eol^= %%D in ('type %TEMP%\cfgTObat.output') DO (
				echo %%D >>%output%
			)
			echo ^</cert^> >>%output%
		)
		IF /I "!temp:~0,9!"=="LOCAL_KEY" (
			echo !temp:~10! > %TEMP%\cfgTObat.base64
			certutil -f -decode %TEMP%\cfgTObat.base64 %TEMP%\cfgTObat.output > NUL
			echo ^<key^> >>%output%
			FOR /F delims^=^ eol^= %%D in ('type %TEMP%\cfgTObat.output') DO (
				echo %%D >>%output%
			)
			echo ^</key^> >>%output%
		)
		IF /I "!temp:~0,8!"=="USERNAME" echo !temp:~9!>>auth.txt
		IF /I "!temp:~0,8!"=="PASSWORD" echo !temp:~18!>>auth.txt
		::Outputing in double quotes
		IF /I "!temp:~0,10!"=="EXTRA_OPTS" (
			SET options=!temp:~12,-1!
			echo !options:--=^

!>>%output%
		)
	)
	echo Removing temporary files
	del /F %TEMP%\cfgTObat.output %TEMP%\cfgTObat.base64 2>NUL

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

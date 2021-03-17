::Created by Aaron Bloom
::
::OWL CLI Editor Batch Script

:: ###################################History#################################################
::	05/03/2021	Script Created via bat_template
::			Help Section Added
::	10/03/2021	Added basic parse for switches
::	17/03/2021	Base function implemented

::To Do
::
::	change sed to make a back up
::	Verify inputs??

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
	set IPaddr=%1
	set Cfgfile=%2
	set Cfgline=%3
	set Cfgvalue='%4'

:MAIN
	if "%debug%" EQU "Y" (
		echo Debugging by echoing commands
		@echo on
	)
	echo SSHing into OWL admin password needed
	ssh admin@!IPaddr! "Cfgvalue=!Cfgvalue! && sudo sed -i  '/!Cfgline!/ s/.*/'"!Cfgline!=\'$Cfgvalue\'"'/g' /etc/!Cfgfile!"

	GOTO END

:HELP
	Echo OWL CLI Config editor utility
	Echo This Script was created to get around the forbiden characters issue on the Hirschmann OWL 4G
	Echo Usage:
	Echo OWL_Config_edit IPaddress Cfgfile Cfgline Cfgvalue
	Echo IPaddr = IP address of the OWL 4G eg 192.168.1.1
	Echo Cfgfile = config file in the OWL 4G to change eg settings.openvpn
	Echo Cfgline = Line in the configuration file to change eg OPENVPN2_PASSWORD
	Echo Cfgvalue = value that will be added to the configuration line eg mypassword
	
	

	
	GOTO END


:END
	::Pause to allow user to read output and exit
	PAUSE
	echo Exiting!
	exit /B !returnCode!
:: Interface IP Utility
::
:: By Aaron Bloom
:: Sections taken from Sixnet Firmware sn_reflash Tool

:: ###################################History#################################################
::	06/02/2021	Script created
::			All Networking adapters found, 4 incorrect adapters identifeid, Adapter Names not correctly captrured
::	07/02/2021	Bugfix
::			Removed incorrect adapter identification, Captured entire adapter name
::			Reworked variables to be arrays where appropriate
::	08/02/2021	Removed excess adapter name function
::	09/02/2021	Working functionality acchieved (Must be run as admin)
::	20/02/2021	Added in debug and help switches (Help not yet implemented)
::	10/03/2021	Added basic paser for switches
::			Defined no inputs as interactive mode
::	
			

:: To do
::	Check and fix field captures (include current IP address?)
::	Rewrite tool in Powershell (Netsh not guaranteed in future Windows)
::	More commenting
::	Change adapter selection to a choice
::	Create command line input option
::

@echo off
setlocal enableextensions enabledelayedexpansion
set returnCode=0
set IP_addr="192.168.0.231"
set Mask="255.255.255.0"
set GW=""


if "%*" EQU "" (
	::interactive mode
	GOTO MAIN
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

:: The following is used to capture the list of Ethernet Adapters present on this PC
set numAdapter=0
set inEth=0
for /F "usebackq tokens=1,* delims=^^" %%F in (`ipconfig /all`) DO (
	set line=%%F

	if not "!line:adapter=!"=="!line!" (
		if "!line:Description=!"=="!line!" (
			set  /A numAdapter=!numAdapter! + 1
			set adapterName[!numAdapter!]=!line!
			set ipAlreadySet[!numAdapter!]=no
			set dhcpEnabled[!numAdapter!]=?
			set inEth=1
		)
    ) else if "!line:~0,39!" == "   Physical Address. . . . . . . . . : " (
			if "!inEth!" == "1" set adapterPhy[!numAdapter!]=!line:~39!
    ) else if "!line:~0,44!" == "        Physical Address. . . . . . . . . : " (
			if "!inEth!" == "1" set adapterPhy[!numAdapter!]=!line:~44,17!
    ) else if "!line:~0,39!" == "   DHCP Enabled. . . . . . . . . . . : " (
			if "!inEth!" == "1" set dhcpEnabled[!numAdapter!]=!line:~39!
    ) else if "!line:~0,44!" == "        Dhcp Enabled. . . . . . . . . . . : " (
			if "!inEth!" == "1" set dhcpEnabled[!numAdapter!]=!line:~44,3!
    ) else if "!line!" EQU "" (
	    rem ignore blank lines
    ) else if not "!line:~0,3!" EQU "   " (
	    rem set inEth=0
    )
)
if ERRORLEVEL 1 set returnCode=2


:: Let the user decide which interface he/she wants to change
if %numAdapter% EQU 0 (
    echo No Ethernet adapter has been detected on this PC.
	set returnCode=2
	goto END
) else if %numAdapter% EQU 1 (
    set selAdapter=1
) else (
:getAdapter
   echo Attention: %numAdapter% ethernet adapters have been found on this PC:
   echo =========
   For /L %%k in (1,1,%numAdapter%) Do (
       Echo     %%k "!adapterName[%%k]!"
       Echo           PHY:                        !adapterPhy[%%k]!
	   Echo           DHCP enabled:               !dhcpEnabled[%%k]!
	   Echo           TFTP default IP configured: !ipAlreadySet[%%k]!
       Echo.
   )
   set /P selAdapter=Please select which Ethernet adapter you want to use [1..%numAdapter%]:
   :: Exit if nothing selected or if 0 is selected
   if "!selAdapter!" EQU "" (
        Echo No adapter selected
		goto END
   )
   if !selAdapter! EQU 0 (
        Echo Interface change aborted.
		goto END
   )
   if !selAdapter! LSS 1 (
        Echo Invalid adapter number [1..%numAdapter%].
		goto getAdapter
   )
   if !selAdapter! GTR %numAdapter% (
        Echo Invalid adapter number [1..%numAdapter%].
		goto getAdapter
   )
)

::For loop to find position of substring "adapter" in adapterName and then strip all characters before then
::Rewrite to use string length rather than 20 as the max number of loop
FOR /L %%i in (1,1,20) do (
	if "!adapterName[%selAdapter%]:~%%i,7!" == "adapter" (
		set /A temp1=%%i+8
	)
)

::Strip trailing colon character
if "!adapterName[%selAdapter%]:~-1,1!" == ":" (
    set ETH_IF="!adapterName[%selAdapter%]:~%temp1%,-1!"
) else (
    set ETH_IF="!adapterName[%selAdapter%]:~%temp1%!"
)

echo Selected adapter is %selAdapter% %ETH_IF%
Echo     !selAdapter! "!adapterName[%selAdapter%]!"
       Echo           PHY:                        !adapterPhy[%selAdapter%]!
	   Echo           DHCP enabled:               !dhcpEnabled[%selAdapter%]!
	   Echo           TFTP default IP configured: !ipAlreadySet[%selAdapter%]!
       Echo.


set /P client_type=Select DHCP or Static [D/S]

if "!client_type!" == "D" (
	echo Setting %ETH_IF% to DHCP
	netsh interface ip set address name=%ETH_IF% source=dhcp
) else if "!client_type!" == "S" (
	set /P IP_addr="Enter IP address (e.g. 192.168.200.5) /24 is assumed:"
	set /P GW="Enter Gateway IP (e.g. 192.168.200.254):" 
	echo Setting %ETH_IF% to !IP_addr! !Mask! !GW!
	netsh interface ip set address name=%ETH_IF% static !IP_addr! !Mask! !GW!
)

GOTO END

:HELP
	Echo CLI tool to change IP address
	Echo This script will allow you to set static or DHCP client address and gateway of any of the current adapter.
	Echo hanges occur via netsh commands so script must be run as admin and should return an error if run as non-admin.
	Echo Usage:
	Echo	interface_set [-d -h]
	Echo Switch Options:
	Echo	-d = Debug script by changing ECHO to ON
	Echo    -h = Display this help info

	GOTO END


:END
	::Pause to allow user to read output and exit
	PAUSE
	echo Exiting!
	exit /B !returnCode!
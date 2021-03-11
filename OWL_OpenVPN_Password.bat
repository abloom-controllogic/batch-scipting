@echo off
setlocal
set /P OVPN_PASS="Set OpenVPN password here>"
set OVPN_PASS='%OVPN_PASS%'
echo Now The OWL's admin password
ssh admin@192.168.1.1 "OVPN_PASS=%OVPN_PASS% && sudo sed -i  '/OPENVPN2_PASSWORD=/ s/.*/'"OPENVPN2_PASSWORD=\'$OVPN_PASS\'"'/g' /etc/settings.openvpn"

endlocal
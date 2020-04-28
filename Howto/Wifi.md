# Configure my Wifi (Outdated)

On modem:

- Reset modem
- Plug a computer with network cable
- Access 192.168.0.1
- WAN Setup -> Uncheck DHCP -> Apply
- WIFI -> Uncheck all -> Apply
- Firewall -> Uncheck Firewall and ping block
- LAN setup -> Uncheck DHCP
- LAN setup -> Switch "Routed with NAT" with "Bridged" -> Apply
- Turn off modem, wait, turn it back on

On router:

- Connect router to WAN port
- Plug a computer with network cable
- Access 192.168.0.1
- Click on the "Advanced" tab
- Network -> IPv4: Renew and Release
- IPv6 -> Disable
- 2.4ghz - Type: Auto, ASCII, 64-bit
- 5ghz - As-is
- Enable TxBF,MU-MIMO

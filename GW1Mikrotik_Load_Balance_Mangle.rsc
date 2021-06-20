# jun/20/2021 14:58:27 by RouterOS 6.43.8
# software id = 
#
#
#
/interface bridge
add name=local
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no name=\
    ether1-WAN_Trunk
set [ find default-name=ether2 ] disable-running-check=no name=\
    ether2-LAN_Trunk
set [ find default-name=ether3 ] disable-running-check=no
set [ find default-name=ether4 ] disable-running-check=no
/interface vlan
add interface=ether1-WAN_Trunk name=eth1_vlan101 vlan-id=101
add interface=ether1-WAN_Trunk name=eth1_vlan102 vlan-id=102
add interface=ether2-LAN_Trunk name=eth2_vlan10 vlan-id=10
add interface=ether2-LAN_Trunk name=eth2_vlan20 vlan-id=20
/interface vrrp
add interface=eth2_vlan10 name=vrrp10 password=vrrp10_lan priority=105 vrid=\
    10
add interface=eth2_vlan20 name=vrrp20 password=vrrp20_lan priority=105 vrid=\
    20
add interface=eth1_vlan101 name=vrrp101 password=vrrp101 priority=105 vrid=\
    101
add interface=eth1_vlan102 name=vrrp102 password=vrrp102 vrid=102
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/ip pool
add name=dhcp_pool0 ranges=192.168.88.3-192.168.88.254
/interface bridge port
add bridge=local interface=ether3
/ip address
add address=192.168.88.1/24 interface=local network=192.168.88.0
add address=192.168.101.2/24 interface=eth1_vlan101 network=192.168.101.0
add address=10.10.10.1/24 interface=vrrp10 network=10.10.10.0
add address=192.168.102.2/24 interface=eth1_vlan102 network=192.168.102.0
add address=20.20.20.1/24 interface=vrrp20 network=20.20.20.0
add address=10.10.10.2/24 interface=eth2_vlan10 network=10.10.10.0
add address=20.20.20.2/24 interface=eth2_vlan20 network=20.20.20.0
add address=192.168.101.1/24 interface=vrrp101 network=192.168.101.0
add address=192.168.102.1/24 interface=vrrp102 network=192.168.102.0
/ip dhcp-client
add disabled=no interface=ether1-WAN_Trunk
add dhcp-options=hostname,clientid disabled=no interface=local
/ip dhcp-server network
add address=192.168.88.0/24 dns-server=192.168.88.1 gateway=192.168.88.1
/ip dns
set allow-remote-requests=yes servers=8.8.8.8,1.1.1.1
/ip firewall address-list
add address=20.20.20.0/24 list=Bloque_Vlan20
add address=10.10.10.0/24 list=Bloque_Vlan10
add address=10.0.0.0/8 list="Bloque Local 10"
add address=20.0.0.0/8 list="Bloque Local 20"
/ip firewall mangle
add action=mark-routing chain=prerouting dst-address-list="!Bloque Local 10" \
    log=yes log-prefix=PBR_a_WAN1 new-routing-mark=a_WAN1 passthrough=no \
    src-address-list=Bloque_Vlan10
add action=mark-routing chain=prerouting dst-address-list="!Bloque Local 20" \
    log=yes log-prefix=PBR_a_WAN2 new-routing-mark=a_WAN2 passthrough=no \
    src-address-list=Bloque_Vlan20
/ip route
add distance=1 gateway=192.168.101.254 routing-mark=a_WAN1
add distance=1 gateway=192.168.102.254 routing-mark=a_WAN2
add check-gateway=ping distance=1 gateway=192.168.101.254
add check-gateway=ping distance=2 gateway=192.168.102.254

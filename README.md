## Node-red-on-iox-for-plc-s
 ## 0. Configure and Install Local manager on Cisco Router 
### Instruction were built using IR829 router   
#### 1. Upgrade to latest/recommended IOS
For IR829 download latest version of IOS at: https://software.cisco.com/download/home/286287074/type/280805680/release/15.9.3M1  &nbsp;
Download the driver:         https://www.silabs.com/products/development-tools/software/usb-to-uart-bridge-vcp-drivers  &nbsp;

     Copy .𝘣𝘪𝘯 image to flash &nbsp;
     Use 𝘣𝘶𝘯𝘥𝘭𝘦 𝘪𝘯𝘴𝘵𝘢𝘭𝘭 𝘧𝘭𝘢𝘴𝘩:<𝘧𝘪𝘭𝘦𝘯𝘢𝘮𝘦> exec command &nbsp;
     Updates '𝘣𝘰𝘰𝘵 𝘴𝘺𝘴𝘵𝘦𝘮' command automatically &nbsp;
    
Hypervisor, BIOS & modem updates can take some time after reboot &nbsp;
Multiple automatic reboots will occur as BIOS & Modem f/w is upgraded &nbsp;
NOTE: When configuring the router for a new installation, it is best to erase any existing configuration AFTER completing the upgrade, then proceed to the configuration steps below.
##### Erase existing configuration:
     write erase
     Reload (After reload, router should boot to a generic IOS prompt. The prompt should look like
     #IR829
#### 2. IOS Configuration:
 **Overview:**
**IR829>**

     en to go into enable mode
     #config t   to go into configure mode 
     Configure time:
     Configure for local time:
     clock timezone EST -5 0
     clock summer-time EDT recurring
     Sync to NTP server:
     ntp server 216.239.35.0 
**Configure Interface to wired network:**
*Example: Using WAN GE0 SFP Port:*

     interface GigabitEthernet 0
     ip address dhcp
     no shut

*Example: Using GE1-4 switch ports:*

     interface vlan 1
     ip address dhcp
     no shut
 
**Configure access via browser:**

     username cisco privilege 15 password 0 cisco
     ip http server
     ip http secure-server
     Enable IPV6:
     ipv6 unicast-routing


**Configure DHCP address pools for Guest OS:**
**IPV4:**

     ip dhcp excluded-address 172.16.10.1 172.16.10.5 !
     ip dhcp pool gospool
     network 172.16.10.0 255.255.255.0
     default-router 172.16.10.1 
     dns-server 8.8.8.8 remember

**IPV6:**

     ipv6 dhcp pool v6gospool
     address prefix 2001:172:16:10::/64 lifetime infinite infinite
#### Configure Interface to Guest OS/Docker containers

     interface GigabitEthernet5
     ip address 172.16.10.1 255.255.255.0  
     ip virtual-reassembly in
     duplex auto
     speed auto
 *! NOTE: IPv6 addressing required on int Gig 5 for guest OS to be enabled*
 
     ipv6 address 2001:172:16:10::1/64
     ipv6 enable
     ipv6 dhcp server v6gospool
     no shut
#### 3 Nat Configuration 
**Configure default routes (not necessary when using DHCP):**
   
     ip route 0.0.0.0 0.0.0.0 192.168.1.1    
**NAT Configuration:**
*Designate inside & outside interfaces:*
*Inside: Gig 5 will always be 'inside interface' for NAT'ing to IOx*

     interface GigabitEthernet5
     ip nat inside
     ip virtual-reassembly in

**Outside**
*Outside interface can be Gig 0 or VLAN1 (or VLAN used on switchport interfaces)*
*interface GigabitEthernet0*
    
     ip nat outside
     ip virtual-reassembly in

*Example below uses port forwarding to direct any traffic for 2222 & 8443 to Guest OS*

     Port forwarding example when Guest OS requires specific ports:
     ip nat inside source list NAT_ACL interface GigabitEthernet0 overload
     ip nat inside source static tcp 172.16.10.6 22 interface GigabitEthernet0 2222
     ip nat inside source static tcp 172.16.10.6 1880 interface GigabitEthernet0 1880
     ip nat inside source static tcp 172.16.10.6 8443 interface GigabitEthernet0 8443
     ip access-list standard NAT_ACL permit 172.16.10.0 0.0.0.255
#### 4 Start/stop guest OS & Verify operation:
*Stop Guest OS:*

     #guest-os 1 stop
*Start Guest OS:*

     #guest-os 1 start
Verify status & show guest OS details:
Note:

**It takes a couple minutes for the IOX guest OS container to initialize**
*Once initialized, you will see console messages like this:*
IR800# :
- Jun 29 17:34:45.089: %IOX-6-SOCK_CONNECT: Received socket connection request from IOX Client
- Jun 29 17:34:45.093: %IOX-6-SOCK_MESSAGE: Received IOX_REQUEST message with opcode IOX_REQUEST_REGISTER from IOX Client
- Jun 29 17:34:47.494: %IOX-6-SOCK_CONNECT: Received socket connection request from IOX Client

After guest OS has initialized, you can confirm as follows:
    
    - #sh iox host list detail
	IOX Server is running. Process ID: 332
	Count of hosts registered: 1

Host registered:
===============
    IOX Server Address: FE80::2E4F:52FF:FED8:180C; Port: 22222

    Link Local Address of Host: FE80::1FF:FE90:8B05
    IPV4 Address of Host:       172.16.10.6
    IPV6 Address of Host:       2001:172:16:10:0:1ff:fe90:8b05
    Client Version:             0.4
    Session ID:                 1
    OS Nodename:                IR800-GOS-1
    Host Hardware Vendor:       Cisco Systems, Inc.
    Host Hardware Version:      1.0
    Host Card Type:             not implemented
    Host OS Version:            1.10.0.14
    OS status:                  RUNNING

    Interface Hardware Vendor:  None
    Interface Hardware Version: None
    Interface Card Type:        None


Services:
===============
   Service Name:                 Secure Storage Service
   Service Status:               RUNNING
   Session ID:                   2

   Service Name:                 Host Device Management Service
   Service Status:               DISABLED
   Session ID:                   0
#### 5. Access IOx Local GUI interface 
Determine outside IP address:
 IR800#sh ip int brief:

Interface                  IP-Address      OK? Method Status                Protocol
GigabitEthernet0           192.168.1.197   YES DHCP   up                    up  

*Access to Local Manager GUI interface using outside address:*
https://192.168.1.197:8443/admin
-login with level 15 credentials

*Direct access to GUI interface without NAT:*
https://172.16.10.6:8443/admin
-login with level 15 credentials

NOTE: Initial access to Local Manager GUI may fail if guest OS is still initializing


## 1. Build Node-Red Docker Image and create IOx application package
## 2. Build Node-RED slim Docker image
## 3. Build Package.tar file 
## 4. Deploy and start IOx Package
## 5. Verify and Troubleshoot the app running 
## References:
Install IOx on 829:
https://developer.cisco.com/docs/iox/#!platform-information/ir8xx-platforms

How to Access the Console of Running Applications/Container:
https://www.cisco.com/c/en/us/support/docs/routers/ic3000-industrial-compute-gateway/214479-how-to-access-the-console-of-running-app.html

Node Slim(docker build based off of node slim):
https://github.com/CiscoIOx/node-red-slim-for-iox


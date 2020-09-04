## Node-red-on-iox-for-plc-s
 ## 0. Configure and Install Local manager on Cisco Router 
### Verified with IOS 15.9(3)M1, 6/29/2020   
#### 1. Upgrade to latest/recommended IOS
For IR829 download latest version of IOS at:<br/> https://software.cisco.com/download/home/286287074/type/280805680/release/15.9.3M1<br/><br/>
Download the driver:<br/>         https://www.silabs.com/products/development-tools/software/usb-to-uart-bridge-vcp-drivers<br/><br/>
    Copy ```.bin``` image to flash<br/><br/>
    Use ```bundle install flash:<filename>``` exec command<br/><br/>
    Updates ```boot system``` command automatically<br/><br/>
Hypervisor, BIOS & modem updates can take some time after reboot<br/><br/>
Multiple automatic reboots will occur as BIOS & Modem f/w is upgraded<br/><br/>
NOTE: When configuring the router for a new installation, it is best to erase any existing configuration AFTER completing the upgrade, then proceed to the configuration steps below.
##### Erase existing configuration:
```write erase``` and then reload (After reload, router should boot to a generic IOS prompt. The prompt should look like: #IR829
#### 2. IOS Configuration:
**Overview:**<br/><br/>
**IR829>**<br/><br/>
    Configure time:<br/><br/>
    Configure for local time:<br/><br/>
    ```clock timezone EST -5 0```<br/><br/>
     ```clock summer-time EDT recurring```<br/><br/>
  Sync to NTP server:<br/><br/>
     ```ntp server 216.239.35.0```<br/><br/>
**Configure Interface to wired network:**<br/> <br/>
*Example: Using WAN GE0 SFP Port:*<br/><br/>
```interface GigabitEthernet 0```<br/><br/>
```ip address dhcp```<br/><br/>
```no shut```<br/><br/>
*Example: Using GE1-4 switch ports:*<br/><br/>
```interface vlan 1```<br/><br/>
```ip address dhcp```<br/><br/>
```no shut```<br/><br/>
**Configure access via browser:**<br/><br/>
```username cisco privilege 15 password 0 cisco```<br/><br/>
```ip http server```<br/><br/>
```ip http secure-server```<br/><br/>
     Enable IPV6:<br/><br/>
```ipv6 unicast-routing```<br/><br/>
**Configure DHCP address pools for Guest OS:**<br/><br/>
**IPV4:**<br/><br/>
```ip dhcp excluded-address 172.16.10.1 172.16.10.5 !```<br/><br/>
```ip dhcp pool gospool```<br/><br/>
```network 172.16.10.0 255.255.255.0```<br/><br/>
```default-router 172.16.10.1 ```<br/><br/>
```dns-server 8.8.8.8 remember```<br/><br/>
**IPV6:**<br/><br/>
```ipv6 dhcp pool v6gospool```<br/><br/>
```address prefix 2001:172:16:10::/64 lifetime infinite infinite```<br/><br/>
#### Configure Interface to Guest OS/Docker containers<br/><br/>
```interface GigabitEthernet5```<br/><br/>
```ip address 172.16.10.1 255.255.255.0```  <br/><br/>
```ip virtual-reassembly in```<br/><br/>
```duplex auto```<br/><br/>
```speed auto```<br/><br/>
 *! NOTE: IPv6 addressing required on int Gig 5 for guest OS to be enabled*<br/><br/>
```ipv6 address 2001:172:16:10::1/64```<br/><br/>
```ipv6 enable```<br/><br/>
```ipv6 dhcp server v6gospool```<br/><br/>
```no shut```<br/><br/>
#### 3 Nat Configuration 
**Configure default routes (not necessary when using DHCP):**<br/> <br/>
```ip route 0.0.0.0 0.0.0.0 192.168.1.1```<br/>    <br/>
**NAT Configuration:**<br/> <br/>
*Designate inside & outside interfaces:*<br/><br/>
*Inside: Gig 5 will always be 'inside interface' for NAT'ing to IOx*<br/><br/>
```interface GigabitEthernet5```<br/><br/>
```ip nat inside```<br/><br/>
```ip virtual-reassembly in```<br/><br/>
**Outside**
*Outside interface can be Gig 0 or VLAN1 (or VLAN used on switchport interfaces)*<br/><br/>
*interface GigabitEthernet0*<br/><br/>
```ip nat outside```<br/><br/>
```ip virtual-reassembly in```<br/><br/> 
*Example below uses port forwarding to direct any traffic for 2222 & 8443 to Guest OS*<br/>
     Port forwarding example when Guest OS requires specific ports:<br/>
     ip nat inside source list NAT_ACL interface GigabitEthernet0 overload<br/>
     ip nat inside source static tcp 172.16.10.6 22 interface GigabitEthernet0 2222<br/>
     ip nat inside source static tcp 172.16.10.6 1880 interface GigabitEthernet0 1880<br/>
     ip nat inside source static tcp 172.16.10.6 8443 interface GigabitEthernet0 8443<br/>
     ip access-list standard NAT_ACL permit 172.16.10.0 0.0.0.255<br/>
#### 4 Start/stop guest OS & Verify operation:
*Stop Guest OS:*<br/><br/>
```#guest-os 1 stop```<br/><br/>
*Start Guest OS:*<br/><br/>
```#guest-os 1 start```<br/><br/>
Verify status & show guest OS details:
Note:

**It takes a couple minutes for the IOX guest OS container to initialize**
*Once initialized, you will see console messages like this:*
IR800# :
- Jun 29 17:34:45.089: %IOX-6-SOCK_CONNECT: Received socket connection request from IOX Client
- Jun 29 17:34:45.093: %IOX-6-SOCK_MESSAGE: Received IOX_REQUEST message with opcode IOX_REQUEST_REGISTER from IOX Client
- Jun 29 17:34:47.494: %IOX-6-SOCK_CONNECT: Received socket connection request from IOX Client

After guest OS has initialized, you can confirm as follows:<br/><br/>
```#sh iox host list detail```<br/><br/>
IOX Server is running. Process ID: 332<br/><br/>
Count of hosts registered: 1<br/><br/>

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
 IR800 ```#sh ip int brief:```

Interface                  IP-Address      OK? Method Status                Protocol
GigabitEthernet0           192.168.1.197   YES DHCP   up                    up  

*Access to Local Manager GUI interface using outside address:*
https://192.168.1.197:8443/admin
-login with level 15 credentials

*Direct access to GUI interface without NAT:*
https://172.16.10.6:8443/admin
-login with level 15 credentials

NOTE: Initial access to Local Manager GUI may fail if guest OS is still initializing


## 1. Build Node-Red Docker Image and
```git clone``` the repository 
-If you want to play with the Node-RED without IOx specific nodes, you can now package the files using:
ioxclient:
```docker package node0:1.0```
## 2. Build Package.tar file 
-Put iox client in the same directory as your clonded repo and run: 
```ioxclient docker package node0:1.0 .```
## 3. Deploy and start IOx Package 
-Go to local manager and at the url: https://172.16.10.6:8443/admin login with a username of cisco and a pasword of cisco.
-Deploy the app using the name nodered and the package package.tar that you created:

![image](https://user-images.githubusercontent.com/47573639/52669802-ec58eb80-2ecb-11e9-98ac-655385899b88.png)

![image](https://user-images.githubusercontent.com/47573639/52669839-0692c980-2ecc-11e9-8e75-940cd17bec35.png)

Activate the app with these configurations:
- Choose `iox-nat0` for network and `1880:1880` for custom port mapping.
- Choose `async1` and `async0` for device serial ports.
- The recommended resource profile is:
  - CPU: 200 cpu-units
  - Memory: 128 MB
  - Disk: 10 MB

![image](https://user-images.githubusercontent.com/47573639/52669886-21653e00-2ecc-11e9-9a46-a0d7893ebd6c.png)

![image](https://user-images.githubusercontent.com/47573639/52669905-33df7780-2ecc-11e9-9e87-2034a9c277c3.png)

![image](https://user-images.githubusercontent.com/47573639/52669953-478ade00-2ecc-11e9-8b28-372632210bfc.png)

Finally start the app.

![image](https://user-images.githubusercontent.com/47573639/52670022-730dc880-2ecc-11e9-9e7d-596e5a8aed68.png) 
  
## References:
Install IOx on 829:
https://developer.cisco.com/docs/iox/#!platform-information/ir8xx-platforms

How to Access the Console of Running Applications/Container:
https://www.cisco.com/c/en/us/support/docs/routers/ic3000-industrial-compute-gateway/214479-how-to-access-the-console-of-running-app.html

Node Slim(docker build based off of node slim):
https://github.com/CiscoIOx/node-red-slim-for-iox


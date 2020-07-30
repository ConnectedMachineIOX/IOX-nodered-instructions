## Node-red-on-iox-for-plc-s
 ## 0. Configure and Install Local manager on Cisco Router 
### Instruction were built using IR829 router   
#### 1. Upgrade to latest/recommended IOS
For IR829 download latest version of IOS at: https://software.cisco.com/download/home/286287074/type/280805680/release/15.9.3M1&nbsp;
Download the driver:         https://www.silabs.com/products/development-tools/software/usb-to-uart-bridge-vcp-drivers&nbsp;
   Copy ```.bin``` image to flash&nbsp;
    Use ```bundle install flash:<filename>``` exec command&nbsp;
     Updates ```boot system``` command automatically&nbsp;
    
Hypervisor, BIOS & modem updates can take some time after reboot&nbsp;
Multiple automatic reboots will occur as BIOS & Modem f/w is upgraded&nbsp;

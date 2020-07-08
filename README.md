# node-red-on-iox-for-plc-s
## 0. Configure and Install Local manager on Cisco Router 
### The router that we are going to use is the IR829 instructions for IOx on IR829
#### 0. Creating a console connection for Router:
Download and Install Putty at : https://www.puttygen.com/download-putty
Create a Console Connection between your Router and PC:

#### 1. Upgrade to latest/recommended IOS
-Copy .bin image to flash
-Use 'bundle install flash:<filename>' exec command
-updates 'boot system' command automatically
-Hypervisor, BIOS & modem updates can take some time after reboot
-Multiple automatic reboots will occur as BIOS & Modem f/w is upgraded
NOTE: When configuring the router for a new installation, it is best to erase any existing configuration AFTER completing the upgrade, then proceed to the configuration steps below.
##### Erase existing configuration:
    #write erase
    #reload
 After reload, router should boot to a generic IOS prompt (not rommon) with no configuration:
#IR829
  
## 1. Build Node-Red Docker Image and create IOx application package
## 2. Build Node-RED slim Docker image
## 3. Build Package.tar file 
## 4. Deploy and start IOx Package
## 5. Verify and Troubleshoot the app running 

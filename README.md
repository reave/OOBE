## Out of Box Experience Script
Script to automation of drivers installation after clean windows install.
### Usage
``` .\OOBE.ps1 -ComputerName Computer1 ```

### Driver repository
Directory on network share (necessary) that contains all drivers for this script. 
Directory structure:
- Root
  * HP EliteBook 8460p
    * Driver1
      * OOBE_Install.ini 
    * Driver2
      * OOBE_Install.ini 
    * Driver3
      * OOBE_Install.ini 
  * HP ProBook 6460b
    * Driver1
      * OOBE_Install.ini 
    * Driver2
      * OOBE_Install.ini
    * Driver3
      * OOBE_Install.ini 
  * etc
 
### OOBE_Install.ini
Config file that describes how to install specified driver. File structure:
```
[Installation]
; File to execute
Exec=pnputil.exe
; Parameters
Args=-i -a accelerometer.inf
```

### Supported computers and drivers
* **Computers:**
These are all folders in the main directory
* **Drivers:**
These are all folders in the computer directory that contain the OOBE_Install.ini file

### Notes
* Change **$Repository** variable before start.
* You will be prompted for credentials to map network drive.
* At this point BIOS updates is not supported
* The directory name of the computer must be the same as the model given at the beginning of the script

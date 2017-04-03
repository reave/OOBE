########################################################
# Script: Out of Box Experience                        #
# Author: Rafał Babiarz                                #
# Date: 30.03.2017                                     #
# Version: 1.1                                         #
# Keywords: Computers, drivers, OOBE, automation       #
########################################################

# Params
 Param([string]$ComputerName='.')
Invoke-Command -ComputerName $ComputerName -SessionOption (New-PSSessionOption -NoMachineProfile) -ScriptBlock {
    # Folder that contains driver repository
    $Repository = "\\network-share\OOBE";
    # Map network drive
    New-PSDrive -Name O -PSProvider FileSystem -Root $Repository -Credential (Get-Credential) | Out-Null
    # Drive that contains driver repository
    $DriversRepositoryPath = "O:\";

    # Get hardware info
    $Hardware = Get-WmiObject -Class Win32_ComputerSystem;
    $Name = $Hardware.Name;
    $Manufacturer = $Hardware.Manufacturer;
    $Model = $Hardware.Model;

    # Get system info
    $System = Get-WmiObject -Class Win32_OperatingSystem;
    $SystemVersion = $System.Caption;
    $SystemArch = $System.OSArchitecture;

    # Write information about Computers
    Write-Host "====================================================="
    Write-Host "Name: " -ForegroundColor Red -NoNewline
    Write-Host $Name -ForegroundColor Green 
    Write-Host "Manufacturer: " -ForegroundColor Red -NoNewline
    Write-Host $Manufacturer -ForegroundColor Green
    Write-Host "Model: " -ForegroundColor Red -NoNewline
    Write-Host $Model -ForegroundColor Green
    Write-Host "====================================================="


    # Check if driver repository path exists
    if (!(Test-Path -Path $DriversRepositoryPath)) {
        Write-Host
        Write-Host "Sorry. Driver repository path doesn't exists. Verify path and try again." -ForegroundColor Red
        Exit 
    }

    # Get supported computers from driver repository
    $SupportedComputers = Get-ChildItem -Directory -Path $DriversRepositoryPath | Select-Object Name | ForEach-Object {$_.Name}

    # Check if computer manufacturer is supported by this script
    if (!($Model -in $SupportedComputers)) {
        Write-Host
        Write-Host "Sorry. This computer is not supported." -ForegroundColor Red
        Exit     
    }

    # Get avaliable drivers for computer
    $AvaliableDrivers = Get-ChildItem -Directory -Path "$DriversRepositoryPath\$Model" | Select-Object Name | ForEach-Object {$_.Name}

    # Write avaliable drivers for computer
    Write-Host "Drivers that are avaliable for this computer:" -ForegroundColor Red
    foreach ($Driver in $AvaliableDrivers) {
        if ($Driver -like "*BIOS*") {continue} #TEMP - Skip BIOS update
        Write-Host $Driver -ForegroundColor Green
    }
    # Wait for confirmation
    Write-Host 
    Write-Host "Press any key to install these drivers" -ForegroundColor Red
    Read-Host

    # Installation 

    foreach($Driver in $AvaliableDrivers) {
        Write-Host "Installing driver: " -ForegroundColor Red -NoNewline
        Write-Host $Driver -ForegroundColor Green
        # Skip driver if that doesn't have installation settings file
        if (!(Test-Path -Path "$DriversRepositoryPath\$Model\$Driver\OOBE_Install.ini")) {continue}
        # Get drivers installation settings
        Get-Content "$DriversRepositoryPath\$Model\$Driver\OOBE_Install.ini" | foreach-object -begin {$settings=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $settings.Add($k[0], $k[1]) } }
        
        # Install driver
        Set-Location "$DriversRepositoryPath\$Model\$Driver"
        Start-Process -FilePath $Settings["Exec"] -ArgumentList $Settings["Args"] -Wait
    }
    Set-Location "~"
    Remove-PSDrive -Name "O";
}
# Loading Feature Installation Modules
# --------------------------------------------------------------------
Import-Module ServerManager 

$title = "OutSystems Version"
$message = "Please select the version of OutSystems installation you are validating the requirements for"


$one = New-Object System.Management.Automation.Host.ChoiceDescription "&10", `
    "Version 10"

$two = New-Object System.Management.Automation.Host.ChoiceDescription "&9.1", `
    "Version 9.1"
    

$options = [System.Management.Automation.Host.ChoiceDescription[]]($one, $two)

$result = $host.ui.PromptForChoice($title, $message, $options, 0) 

switch ($result)
    {
        0 {$PlatformVersion = "10" ; "You selected version 10" } 
        1 {$PlatformVersion = "9.1" ; "You selected version 9.1"}
    }

if ($PlatformVersion -eq "10" )
  {
    Write-Host "Validating .NET Framework 4.6" -ForegroundColor Gray  
    $NET46Version = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -recurse |
    Get-ItemProperty -name Version,Release -EA 0 |
    Where { $_.PSChildName -match '^(?!S)\p{L}'} |
    Select PSChildName, Version, Release, @{
      name="Product"
      expression={
        switch -regex ($_.Release) {
          "378675|378758" { [Version]"4.5.1" }
          "379893" { [Version]"4.5.2" }
          "393295|393297" { [Version]"4.6" }
          "394254|394271" { [Version]"4.6.1" }
          "394802|394806" { [Version]"4.6.2" }
          {$_ -gt 394806} { [Version]"Undocumented 4.6.2 or higher, please update script" }
        }
      }
    }
 
    if ($NET46Version -Match "4.6.1" -or $NET46Version -Match "4.6.2")
    {
        write-host ".NET Framework 4.6.1 version or superior is installed" "`n" -ForegroundColor Green
    }
    else
    { 
        write-host ".NET Framework 4.6.1 version or superior is not installed" "`n" -ForegroundColor Red 
        $FileDotNET461 = Get-ChildItem *.exe  | Where-Object {("{0}" -f [System.Diagnostics.FileVersionInfo]::GetVersionInfo($_).FileDescription) -match ".NET Framework 4.6.1"}

        if($FileDotNET461){
        		write-host ".NET Framework 4.6.1 executable detected, starting installation now" "`n" -ForegroundColor Green 
                Start-Process $FileDotNET461 
        	}else{
        		write-host ".NET Framework 4.6.1 executable not detected, please install .NET Framework 4.6.1 or higher" "`n" -ForegroundColor Red 
            } 
    }
 }



# Install Web Server role
  Write-Host "Installing Web Server Role" -ForegroundColor Gray
  Add-WindowsFeature -Name "Application-Server"
  Add-WindowsFeature -Name "Web-WebServer"  
  
  $AppServer_CheckIfInstalled = Get-WindowsFeature | Where-Object {$_.Name -eq "Application-Server"}
  $WebServer_CheckIfInstalled = Get-WindowsFeature | Where-Object {$_.Name -eq "Web-WebServer"}
  if(($AppServer_CheckIfInstalled).Installed -and ($WebServer_CheckIfInstalled).Installed)
  {
    Write-Host "Web Server Role was successfully installed" "`n" -ForegroundColor Green
  }
  Else
  {
    Write-Host "Web Server Role installation failed" "`n" -ForegroundColor Red  
  }
  
  #Common HTTP Features  
  # --------------------------------------------------------------------
  
  # IIS feature Default Document
  Write-Host "Installing IIS Default Document" -ForegroundColor Gray
  Add-WindowsFeature -Name "Web-Default-Doc"
  
  $CheckIfInstalled = Get-WindowsFeature | Where-Object {$_.Name -eq "Web-Default-Doc"}
  if($CheckIfInstalled.Installed)
  {
    Write-Host "IIS Default Document was successfully installed" "`n" -ForegroundColor Green
  }
  Else
  {
    Write-Host "IIS Default Document installation has failed" "`n" -ForegroundColor Red  
  }
  
  # IIS feature Directory Browsing
  Write-Host "Installing IIS feature Directory Browsing" -ForegroundColor Gray
  Add-WindowsFeature -Name "Web-Dir-Browsing"
  
  $CheckIfInstalled = Get-WindowsFeature | Where-Object {$_.Name -eq "Web-Dir-Browsing"}
  if($CheckIfInstalled.Installed)
  {
    Write-Host "IIS feature Directory Browsing was successfully installed" "`n" -ForegroundColor Green
  }
  Else
  {
    Write-Host "IIS feature Directory Browsing installation has failed" "`n" -ForegroundColor Red  
  }
  
  # IIS feature HTTP Errors
  Write-Host "Installing IIS feature HTTP Errors" -ForegroundColor Gray
  Add-WindowsFeature -Name "Web-Http-Errors"
  
  $CheckIfInstalled = Get-WindowsFeature | Where-Object {$_.Name -eq "Web-Http-Errors"}
  if($CheckIfInstalled.Installed)
  {
    Write-Host "IIS feature HTTP Errors was successfully installed" "`n" -ForegroundColor Green
  }
  Else
  {
    Write-Host "IIS feature HTTP Errors installation has failed" "`n" -ForegroundColor Red  
  }
  
   # IIS feature Static Content
  Write-Host "Installing IIS feature Static Content" -ForegroundColor Gray
  Add-WindowsFeature -Name "Web-Static-Content"
  
  $CheckIfInstalled = Get-WindowsFeature | Where-Object {$_.Name -eq "Web-Static-Content"}
  if($CheckIfInstalled.Installed)
  {
    Write-Host "IIS feature Static Content was successfully installed" "`n" -ForegroundColor Green
  }
  Else
  {
    Write-Host "IIS feature Static Content installation has failed" "`n" -ForegroundColor Red  
  }
  
  
  #Application Development  
  # --------------------------------------------------------------------
  
  
  # ASP.NET 3.5
  Write-Host "Installing ASP.NET 3.5" -ForegroundColor Gray
  Add-WindowsFeature -Name "Web-Asp-Net"
  
  $CheckIfInstalled = Get-WindowsFeature | Where-Object {$_.Name -eq "Web-Asp-Net"}
  if($CheckIfInstalled.Installed)
  {
    Write-Host ".ASP.NET 3.5 was successfully installed" "`n" -ForegroundColor Green
  }
  Else
  {
    Write-Host "ASP.NET 3.5 installation has failed" "`n" -ForegroundColor Red  
  }
  
  
  # .NET Extensibility 3.5 
  Write-Host "Installing .NET Extensibility 3.5" -ForegroundColor Gray
  Add-WindowsFeature -Name "Web-Net-Ext"
  
  $CheckIfInstalled = Get-WindowsFeature | Where-Object {$_.Name -eq "Web-Net-Ext"}
  if($CheckIfInstalled.Installed)
  {
    Write-Host ".NET Extensibility 3.5  was successfully installed" "`n" -ForegroundColor Green
  }
  Else
  {
    Write-Host ".NET Extensibility 3.5  installation has failed" "`n" -ForegroundColor Red  
  }
  
    
  # ISAPI Extensions
  Write-Host "Installing ISAPI Extensions" -ForegroundColor Gray
  Add-WindowsFeature -Name "Web-ISAPI-Ext"
  
  $CheckIfInstalled = Get-WindowsFeature | Where-Object {$_.Name -eq "Web-ISAPI-Ext"}
  if($CheckIfInstalled.Installed)
  {
    Write-Host "ISAPI Extensions was successfully installed" "`n" -ForegroundColor Green
  }
  Else
  {
    Write-Host "ISAPI Extensions installation has failed" "`n" -ForegroundColor Red  
  }
  
  
  # ISAPI Filters
  Write-Host "Installing ISAPI Filters" -ForegroundColor Gray
  Add-WindowsFeature -Name "Web-ISAPI-Filter"
  
  $CheckIfInstalled = Get-WindowsFeature | Where-Object {$_.Name -eq "Web-ISAPI-Filter"}
  if($CheckIfInstalled.Installed)
  {
    Write-Host "ISAPI Filters was successfully installed" "`n" -ForegroundColor Green
  }
  Else
  {
    Write-Host "ISAPI Filters installation has failed" "`n" -ForegroundColor Red  
  }
  
   
  # ASP.NET 4.5
  Write-Host "Installing ASP.NET 4.5" -ForegroundColor Gray
  Add-WindowsFeature -Name "Web-Asp-Net45"
  
  $CheckIfInstalled = Get-WindowsFeature | Where-Object {$_.Name -eq "Web-Asp-Net45"}
  if($CheckIfInstalled.Installed)
  {
    Write-Host ".ASP.NET 4.5 was successfully installed" "`n" -ForegroundColor Green
  }
  Else
  {
    Write-Host "ASP.NET 4.5 installation has failed" "`n" -ForegroundColor Red  
  }
  
  # .NET Extensibility 4.5 
  Write-Host "Installing .NET Extensibility 4.5" -ForegroundColor Gray
  Add-WindowsFeature -Name "Web-Net-Ext45"
  
  $CheckIfInstalled = Get-WindowsFeature | Where-Object {$_.Name -eq "Web-Net-Ext45"}
  if($CheckIfInstalled.Installed)
  {
    Write-Host ".NET Extensibility 4.5  was successfully installed" "`n" -ForegroundColor Green
  }
  Else
  {
    Write-Host ".NET Extensibility 4.5  installation has failed" "`n" -ForegroundColor Red  
  }
  
  
  #Health and Diagnostics  
  # --------------------------------------------------------------------
  
  # HTTP Logging
  Write-Host "Installing HTTP Logging" -ForegroundColor Gray
  Add-WindowsFeature -Name "Web-Http-Logging"
  
  $CheckIfInstalled = Get-WindowsFeature | Where-Object {$_.Name -eq "Web-Http-Logging"}
  if($CheckIfInstalled.Installed)
  {
    Write-Host "HTTP Logging was successfully installed" "`n" -ForegroundColor Green
  }
  Else
  {
    Write-Host "HTTP Logging installation has failed" "`n" -ForegroundColor Red  
  }
  
  
  # Request Monitor
  Write-Host "Installing Request Monitor" -ForegroundColor Gray
  Add-WindowsFeature -Name "Web-Request-Monitor"
  
  $CheckIfInstalled = Get-WindowsFeature | Where-Object {$_.Name -eq "Web-Request-Monitor"}
  if($CheckIfInstalled.Installed)
  {
    Write-Host "Request Monitor was successfully installed" "`n" -ForegroundColor Green
  }
  Else
  {
    Write-Host "Request Monitor installation has failed" "`n" -ForegroundColor Red  
  }
  
  #Security 
  # --------------------------------------------------------------------
  
  # Windows Authentication
  Write-Host "Installing Windows Authentication" -ForegroundColor Gray
  Add-WindowsFeature -Name "Web-Windows-Auth"
  
  $CheckIfInstalled = Get-WindowsFeature | Where-Object {$_.Name -eq "Web-Windows-Auth"}
  if($CheckIfInstalled.Installed)
  {
    Write-Host "Windows Authentication was successfully installed" "`n" -ForegroundColor Green
  }
  Else
  {
    Write-Host "Windows Authentication installation has failed" "`n" -ForegroundColor Red  
  }
  
  
  # Request Filtering
  Write-Host "Installing Request Filtering" -ForegroundColor Gray
  Add-WindowsFeature -Name "Web-Filtering"
  
  $CheckIfInstalled = Get-WindowsFeature | Where-Object {$_.Name -eq "Web-Filtering"}
  if($CheckIfInstalled.Installed)
  {
    Write-Host "Request Filtering was successfully installed" "`n" -ForegroundColor Green
  }
  Else
  {
    Write-Host "Request Filtering installation has failed" "`n" -ForegroundColor Red  
  }
  
  
  
  #Performance  
  # --------------------------------------------------------------------
  
  # Static Content Compression
  Write-Host "Installing Static Content Compression" -ForegroundColor Gray
  Add-WindowsFeature -Name "Web-Stat-Compression"
  
  $CheckIfInstalled = Get-WindowsFeature | Where-Object {$_.Name -eq "Web-Stat-Compression"}
  if($CheckIfInstalled.Installed)
  {
    Write-Host "Static Content Compression was successfully installed" "`n" -ForegroundColor Green
  }
  Else
  {
    Write-Host "Static Content Compression installation has failed" "`n" -ForegroundColor Red  
  }
  
  
  # Dynamic Content Compression
  Write-Host "Installing Dynamic Content Compression" -ForegroundColor Gray
  Add-WindowsFeature -Name "Web-Dyn-Compression"
  
  $CheckIfInstalled = Get-WindowsFeature | Where-Object {$_.Name -eq "Web-Dyn-Compression"}
  if($CheckIfInstalled.Installed)
  {
    Write-Host "Dynamic Content Compression was successfully installed" "`n" -ForegroundColor Green
  }
  Else
  {
    Write-Host "Dynamic Content Compression installation has failed" "`n" -ForegroundColor Red  
  }
  
  
  #Management Tools  
  # --------------------------------------------------------------------
  
  # IIS Management Console
  Write-Host "Installing IIS Management Console" -ForegroundColor Gray
  Add-WindowsFeature -Name "Web-Mgmt-Console"
  
  $CheckIfInstalled = Get-WindowsFeature | Where-Object {$_.Name -eq "Web-Mgmt-Console"}
  if($CheckIfInstalled.Installed)
  {
    Write-Host "IIS Management Console was successfully installed" "`n" -ForegroundColor Green
  }
  Else
  {
    Write-Host "IIS Management Console installation has failed" "`n" -ForegroundColor Red  
  }
  
  #Add-WindowsFeature -Name "Web-Mgmt-Tools"
  
  #$CheckIfInstalled = Get-WindowsFeature | Where-Object {$_.Name -eq "Web-Mgmt-Tools"}
  #if($CheckIfInstalled.Installed)
  #{
  #  Write-Host "IIS Management Console was successfully installed" "`n" -ForegroundColor Green
  #}
  #Else
  #{
  #  Write-Host "IIS Management Console installation has failed" "`n" -ForegroundColor Red  
  #}
  
  # IIS 6 Management Compatibility
  Write-Host "Installing IIS 6 Management Compatibility" -ForegroundColor Gray
  Add-WindowsFeature -Name "Web-Metabase"
  
  $CheckIfInstalled = Get-WindowsFeature | Where-Object {$_.Name -eq "Web-Metabase"}
  if($CheckIfInstalled.Installed)
  {
    Write-Host "IIS 6 Management Compatibility was successfully installed" "`n" -ForegroundColor Green
  }
  Else
  {
    Write-Host "IIS 6 Management Compatibility installation has failed" "`n" -ForegroundColor Red  
  }
  
  
  #Features  
  # --------------------------------------------------------------------
  
  # Message Queuing Server
  Write-Host "Installing Message Queuing Server" -ForegroundColor Gray
  Add-WindowsFeature -Name "MSMQ-Server"
  
  $CheckIfInstalled = Get-WindowsFeature | Where-Object {$_.Name -eq "MSMQ-Server"}
  if($CheckIfInstalled.Installed)
  {
    Write-Host "Message Queuing Server was successfully installed" "`n" -ForegroundColor Green
  }
  Else
  {
    Write-Host "Message Queuing Server installation has failed" "`n" -ForegroundColor Red  
  }
  
  #Process Model
  Write-Host "Installing Process Model" -ForegroundColor Gray
  Add-WindowsFeature -Name "WAS-Process-Model"
  
  $CheckIfInstalled = Get-WindowsFeature | Where-Object {$_.Name -eq "WAS-Process-Model"}
  if($CheckIfInstalled.Installed)
  {
    Write-Host "Process Model was successfully installed" "`n" -ForegroundColor Green
  }
  Else
  {
    Write-Host "Process Model installation has failed" "`n" -ForegroundColor Red  
  }
  
  #.NET Environment
  Write-Host "Installing .NET Environment" -ForegroundColor Gray
  Add-WindowsFeature -Name "WAS-NET-Environment"
  
  $CheckIfInstalled = Get-WindowsFeature | Where-Object {$_.Name -eq "WAS-NET-Environment"}
  if($CheckIfInstalled.Installed)
  {
    Write-Host ".NET Environment was successfully installed" "`n" -ForegroundColor Green
  }
  Else
  {
    Write-Host ".NET Environment installation has failed" "`n" -ForegroundColor Red  
  }
  
  
  #Configuration APIs
  Write-Host "Installing Configuration APIs" -ForegroundColor Gray
  Add-WindowsFeature -Name "WAS-Config-APIs"
  
  $CheckIfInstalled = Get-WindowsFeature | Where-Object {$_.Name -eq "WAS-Config-APIs"}
  if($CheckIfInstalled.Installed)
  {
    Write-Host "Configuration APIs were successfully installed" "`n" -ForegroundColor Green
  }
  Else
  {
    Write-Host "Configuration APIs installation has failed" "`n" -ForegroundColor Red  
  }
  
  
  #Disable FIPS Compliant Algorithms
  # --------------------------------------------------------------------
  
  Set-ItemProperty -Path HKLM:\HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy -Name Enabled -Value 0
  
  $FIPS = Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy\" | Select-Object -ExpandProperty "Enabled"
  
  # Recommended value = 0
  if($FIPS -eq "0")
  {
    Write-Host 'FIPS Compliant Algorithms are disabled'"`n" -ForegroundColor Green
  }
  Else
  {
    Write-Host 'FIPS Compliant Algorithms are still enabled'"`n" -ForegroundColor Red
  }
  
  
  #Add the AlwaysWithoutDS DWORD
  # --------------------------------------------------------------------  
  $AlwaysWithoutDS = Get-ItemProperty -Path "HKLM:\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSMQ\Parameters\Setup" | Select-Object -ExpandProperty "AlwaysWithoutDS"
  
  if(!$AlwaysWithoutDS){
    New-ItemProperty -Path "HKLM:\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSMQ\Parameters\Setup" -Name "AlwaysWithoutDS" -Value 1
  }
  
  Write-Host "AlwaysWithoutDS registry key added" "`n" -ForegroundColor Green
    
  #Set appropriate size for Event Logs:
  # --------------------------------------------------------------------
  
  Limit-EventLog -MaximumSize 20480KB -OverflowAction OverwriteAsNeeded -LogName Security
  
  
  #Windows Management Instrumentation Service 
  # --------------------------------------------------------------------
  
  Set-Service -Name Winmgmt -StartupType Automatic
  
  $WMIService = Get-Service -Name "Winmgmt"
  $WMIServiceStartMode = (Get-WmiObject Win32_Service -filter "Name='Winmgmt'").StartMode

  if($WMIService.Status -eq "Running"){	

   	if($WMIServiceStartMode -eq "Auto") {
  		Write-Host "Windows Management Instrumentation Service is Running and in Automatic start mode" "`n" -ForegroundColor Green
    }
  }
  
  
  
  #Windows Search Service 
  # --------------------------------------------------------------------  
  
  $WSearchService = Get-Service -Name "WSearch"
  $WSearchServiceStartMode = (Get-WmiObject Win32_Service -filter "Name='WSearch'").StartMode

  if(!$WSearchService){	

    Write-Host "Windows Search Service does not exists" "`n" -ForegroundColor Green
	
  }else{
	Stop-Service WSearch -StartupType Disable
  }  
  
  Read-Host -Prompt 'Press any key to exit the validator and close this window'
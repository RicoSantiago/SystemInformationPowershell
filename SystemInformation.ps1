$DesktopPath = [Environment]::GetFolderPath("Desktop")
$OutputFile = Join-Path $DesktopPath "SystemInformation.txt"

$ReportHeader = "System Information `n"
Write-Host ""
Write-Host $ReportHeader
$Report = "$($ReportHeader)`n"

$OSInfo = Get-CimInstance -ClassName Win32_OperatingSystem
$OSName = $OSInfo.Name
$OSVersion = $OSInfo.Version
$OSNameReport = "OS Name: $($OSName)"
$OSVersionReport = "OS Version: $($OSVersion)"
Write-Host $OSNameReport
Write-Host $OSVersionReport
$Report += "$($OSNameReport)`n"
$Report += "$($OSVersionReport)`n"

$ComputerInfo = Get-CimInstance -ClassName Win32_ComputerSystem
$ComputerName = $ComputerInfo.Name
$ComputerNameReport = "Computer Name: $($ComputerName)"
Write-Host $ComputerNameReport
$Report += "$($ComputerNameReport)`n"

$CPUInfo = Get-CimInstance -ClassName Win32_Processor | Select-Object -First 1
$CPUName = $CPUInfo.Name
$CPUNumberofCores = $CPUInfo.NumberOfCores
$CPUMaxClockSpeed = $CPUInfo.MaxClockSpeed
$CPUNameReport = "`tName: $($CPUName)"
$CPUNumberofCoresReport = "`tNumber of Cores: $($CPUNumberofCores)"
$CPUMaxClockSpeedReport = "`tMax Clock Speed: $($CPUMaxClockSpeed) MHz"
Write-Host "CPU"
Write-Host $CPUNameReport
Write-Host $CPUNumberofCoresReport
Write-Host $CPUMaxClockSpeedReport
$Report += "CPU`n"
$Report += "$($CPUNameReport)`n"
$Report += "$($CPUNumberofCoresReport)`n"
$Report += "$($CPUMaxClockSpeedReport)`n"

$TotalRAM = [math]::round($ComputerInfo.TotalPhysicalMemory / 1GB, 2)
$TotalRAMReport = "Total RAM: ${TotalRAM} GB"
Write-Host $TotalRAMReport
$Report += "$($TotalRAMReport)`n"

$NetworkAdapters = Get-NetAdapter | Where-Object {$_.Status -eq "Up"}
Write-Host "IP Config"
$Report += "IP Config`n"
foreach ($Adapter in $NetworkAdapters) {
    $AdapterName = $Adapter.Name
    $AdapterMAC = $Adapter.MacAddress
    $AdapterNameReport = "`tNetwork Adapter Name: $($AdapterName)"
    $AdapterMACReport = "`tNetwork Adapter MAC Address: $($AdapterMAC)"
    Write-Host $AdapterNameReport
    Write-Host $AdapterMACReport

    $Report += "$($AdapterNameReport)`n"
    $Report += "$($AdapterMACReport)`n"

    $IPv4 = Get-NetIPAddress -InterfaceIndex $Adapter.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue
    if ($IPv4) {
        $IPv4Address = $IPv4.IPAddress
        $IPv4PrefixLength = $IPv4.PrefixLength
        $IPv4SubnetMask = ([System.Net.IPAddress]::Parse("255.255.255.255")).Address -bxor ((1 -shl (32 - $IPv4PrefixLength)) - 1)
        $IPv4SubnetMaskFormat = ([System.Net.IPAddress]$IPv4SubnetMask).IPAddressToString
        $IPv4AddressReport = "`t`tIPv4 Address: $($IPv4Address)"
        $IPv4SubnetMaskReport = "`t`tIPv4 Subnet Mask: $($IPv4SubnetMaskFormat)"
        $IPv4PrefixLengthReport = "`t`tIPv4 Prefix Length: /$($IPv4PrefixLength)"
        Write-Host "`tIPv4"
        Write-Host $IPv4AddressReport
        Write-Host $IPv4SubnetMaskReport
        Write-Host $IPv4PrefixLengthReport
        $Report += "`tIPv4`n"
        $Report += "$($IPv4AddressReport)`n"
        $Report += "$($IPv4SubnetMaskReport)`n"
        $Report += "$($IPv4PrefixLengthReport)`n"
    }
    $IPv6 = Get-NetIPAddress -InterfaceIndex $Adapter.InterfaceIndex -AddressFamily IPv6 -ErrorAction SilentlyContinue
    if ($IPv6) {
        $IPv6Address = $IPv6.IPAddress
        $IPv6PrefixLength = $IPv6.PrefixLength
        $IPv6AddressReport = "`t`tIPv6 Address: $($IPv6Address)"
        $IPv6PrefixLengthReport = "`t`tIPv6 Prefix Length: /$($IPv6PrefixLength)"
        Write-Host "`tIPv6"
        Write-Host $IPv6AddressReport
        Write-Host $IPv6PrefixLengthReport
        $Report += "`tIPv6`n"
        $Report += "$($IPv6AddressReport)`n"
        $Report += "$($IPv6PrefixLengthReport)`n"
    }
}

$Report | Out-File -FilePath $OutputFile -Encoding UTF8
# ==============================
# SQL Server Upgrade: OS & System Compatibility Check
# Author: ChatGPT (GPT-5)
# ==============================

# Create report folder
$ReportFolder = "C:\Upgrade"
if (!(Test-Path $ReportFolder)) { New-Item -Path $ReportFolder -ItemType Directory -Force | Out-Null }
$ReportFile = "$ReportFolder\OS_Compatibility_Report.txt"

"==============================" | Out-File $ReportFile
" SQL Server Upgrade - OS & System Compatibility Report" | Out-File $ReportFile -Append
"==============================" | Out-File $ReportFile -Append
"`nGenerated On: $(Get-Date)" | Out-File $ReportFile -Append
"`n==============================" | Out-File $ReportFile -Append

# ---- OS Information ----
"🔹 OS DETAILS:" | Out-File $ReportFile -Append
Get-CimInstance Win32_OperatingSystem | 
Select-Object Caption, Version, OSArchitecture, BuildNumber, ServicePackMajorVersion, InstallDate |
Format-List | Out-String | Out-File $ReportFile -Append

# ---- CPU Information ----
"🔹 CPU DETAILS:" | Out-File $ReportFile -Append
Get-CimInstance Win32_Processor | 
Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed |
Format-List | Out-String | Out-File $ReportFile -Append

# ---- Memory ----
"🔹 MEMORY DETAILS:" | Out-File $ReportFile -Append
Get-CimInstance Win32_ComputerSystem | 
Select-Object TotalPhysicalMemory | 
ForEach-Object { "Total RAM (GB): {0:N2}" -f ($_.TotalPhysicalMemory/1GB) } | 
Out-File $ReportFile -Append

# ---- Disk Space ----
"🔹 DISK DETAILS:" | Out-File $ReportFile -Append
Get-PSDrive -PSProvider FileSystem | 
Select-Object Name, @{Name="Free(GB)";Expression={[math]::Round($_.Free/1GB,2)}}, @{Name="Used(GB)";Expression={[math]::Round(($_.Used/1GB),2)}}, @{Name="Total(GB)";Expression={[math]::Round($_.Used/1GB + $_.Free/1GB,2)}} |
Format-Table | Out-String | Out-File $ReportFile -Append

# ---- .NET Framework Version ----
"🔹 .NET FRAMEWORK VERSION:" | Out-File $ReportFile -Append
try {
    $Release = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").Release
    switch ($Release) {
        {$_ -ge 533320} {$ver = "4.8.1 or later"}
        {$_ -ge 528040} {$ver = "4.8"}
        {$_ -ge 461808} {$ver = "4.7.2"}
        {$_ -ge 461308} {$ver = "4.7.1"}
        {$_ -ge 460798} {$ver = "4.7"}
        {$_ -ge 394802} {$ver = "4.6.2"}
        {$_ -ge 394254} {$ver = "4.6.1"}
        {$_ -ge 393295} {$ver = "4.6"}
        {$_ -ge 379893} {$ver = "4.5.2"}
        {$_ -ge 378675} {$ver = "4.5.1"}
        {$_ -ge 378389} {$ver = "4.5"}
        default {$ver = "Lower than 4.5 or not installed"}
    }
    "Detected: .NET Framework $ver ($Release)" | Out-File $ReportFile -Append
}
catch {
    "Error: Unable to detect .NET Framework version." | Out-File $ReportFile -Append
}

# ---- PowerShell Version ----
"🔹 POWERSHELL VERSION:" | Out-File $ReportFile -Append
$PSVersion = $PSVersionTable.PSVersion.ToString()
"Detected PowerShell Version: $PSVersion" | Out-File $ReportFile -Append

# ---- Network ----
"🔹 NETWORK DETAILS:" | Out-File $ReportFile -Append
Get-NetIPAddress | Where-Object {$_.AddressFamily -eq "IPv4" -and $_.IPAddress -notlike "169.*"} | 
Select-Object InterfaceAlias, IPAddress, PrefixLength | 
Format-Table | Out-String | Out-File $ReportFile -Append

# ---- SQL Server (if installed) ----
"🔹 SQL SERVER INSTANCES (if any):" | Out-File $ReportFile -Append
Get-Service -Name 'MSSQL*' -ErrorAction SilentlyContinue | 
Select-Object Name, Status, DisplayName | 
Format-Table | Out-String | Out-File $ReportFile -Append

# ---- Summary ----
"`n==============================" | Out-File $ReportFile -Append
"NOTE: Compare OS version and edition with Microsoft’s supported OS list for your target SQL Server version (e.g., 2022 supports Windows Server 2019/2022)." | Out-File $ReportFile -Append
"==============================" | Out-File $ReportFile -Append

Write-Host "✅ OS Compatibility Report generated: $ReportFile" -ForegroundColor Green

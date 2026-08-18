#Run first the Execution policy bypass
#powershell.exe -ExecutionPolicy Bypass -File .\Get-VolatileData.ps1

# Requires -RunAsAdministrator
[CmdletBinding()]
param (
    [string]$OutputDir = ".\VolatileData_$(ENV:COMPUTERNAME)_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
)

# 1. Admin Privilege Check
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as an Administrator to collect all volatile artifacts."
    exit 1
}

# 2. Initialize Output Directory
$OutputDir = [System.IO.Path]::GetFullPath($OutputDir)
if (-not (Test-Path -Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

Write-Host "[+] Artifact collection directory: $OutputDir" -ForegroundColor Green

# Helper function to safely execute and log artifacts
function Export-DFIRArtifact {
    param (
        [string]$Name,
        [scriptblock]$ScriptBlock
    )
    Write-Host "[*] Collecting: $Name..." -ForegroundColor Cyan
    $txtFile  = Join-Path $OutputDir "$Name.txt"
    $jsonFile = Join-Path $OutputDir "$Name.json"

    try {
        $result = & $ScriptBlock
        if ($result) {
            $result | Out-File -FilePath $txtFile -Encoding utf8
            $result | ConvertTo-Json -Depth 4 -ErrorAction SilentlyContinue | Out-File -FilePath $jsonFile -Encoding utf8
        } else {
            "No data returned." | Out-File -FilePath $txtFile
        }
    } catch {
        Write-Warning "Failed to collect $Name : $_"
        "ERROR: $_" | Out-File -FilePath $txtFile
    }
}

# ----------------------------------------------------------------------
# Artifact Collection Phase
# ----------------------------------------------------------------------

# System Information & Timezone
Export-DFIRArtifact -Name "01_SystemInfo" -ScriptBlock {
    [PSCustomObject]@{
        ComputerName   = $env:COMPUTERNAME
        Domain         = $env:USERDOMAIN
        OSVersion      = (Get-CimInstance Win32_OperatingSystem).Caption
        OSBuild        = (Get-CimInstance Win32_OperatingSystem).BuildNumber
        LastBootTime   = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
        CollectionTime = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss 'UTC'")
    }
}

# Logged-On Users & Active Sessions
Export-DFIRArtifact -Name "02_LoggedOnUsers" -ScriptBlock {
    Get-CimInstance -ClassName Win32_LoggedOnUser | Select-Object @{N='Domain';E={$_.Antecedent.Domain}}, @{N='User';E={$_.Antecedent.Name}} -Unique
}

# Running Processes (With Command Line, Parent PID, and Executable Path)
Export-DFIRArtifact -Name "03_Processes" -ScriptBlock {
    Get-CimInstance Win32_Process | Select-Object ProcessId, ParentProcessId, Name, ExecutablePath, CommandLine, CreationDate | Sort-Object ProcessId
}

# Network Connections mapped to Processes
Export-DFIRArtifact -Name "04_NetworkConnections" -ScriptBlock {
    Get-NetTCPConnection -ErrorAction SilentlyContinue | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State, OwningProcess,
        @{N='ProcessName';E={(Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName}}
}

# DNS Cache (Critical for malware C2 domain discovery)
Export-DFIRArtifact -Name "05_DNSCache" -ScriptBlock {
    Get-DnsClientCache -ErrorAction SilentlyContinue | Select-Object Entry, Name, Type, Status, Data
}

# ARP Table & Routing Table
Export-DFIRArtifact -Name "06_ARP_and_Routes" -ScriptBlock {
    @{
        ARPTable = Get-NetNeighbor -AddressFamily IPv4 -ErrorAction SilentlyContinue | Select-Object IPAddress, LinkLayerAddress, State
        Routes   = Get-NetRoute -AddressFamily IPv4 -ErrorAction SilentlyContinue | Select-Object DestinationPrefix, NextHop, RouteMetric
    }
}

# Services
Export-DFIRArtifact -Name "07_Services" -ScriptBlock {
    Get-CimInstance Win32_Service | Select-Object Name, DisplayName, State, StartMode, PathName, ProcessId
}

# Scheduled Tasks
Export-DFIRArtifact -Name "08_ScheduledTasks" -ScriptBlock {
    Get-ScheduledTask | Where-Object { $_.State -ne 'Disabled' } | Select-Object TaskName, TaskPath, State, @{N='Actions';E={$_.Actions.Execute}}
}

# Startup / Auto-run Items
Export-DFIRArtifact -Name "09_StartupItems" -ScriptBlock {
    Get-CimInstance Win32_StartupCommand | Select-Object Name, Command, Location, User
}

# Installed Software (Safe Registry Lookup - replacing WMIC)
Export-DFIRArtifact -Name "10_InstalledSoftware" -ScriptBlock {
    $regPaths = @(
        'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    Get-ItemProperty $regPaths -ErrorAction SilentlyContinue | 
        Where-Object { $_.DisplayName } | 
        Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | 
        Sort-Object DisplayName
}

# Loaded Drivers
Export-DFIRArtifact -Name "11_LoadedDrivers" -ScriptBlock {
    Get-CimInstance Win32_SystemDriver | Select-Object Name, DisplayName, State, StartMode, PathName
}

# ----------------------------------------------------------------------
# Integrity Manifest (Chain of Custody)
# ----------------------------------------------------------------------
Write-Host "[*] Generating SHA256 integrity manifest..." -ForegroundColor Cyan
$manifestPath = Join-Path $OutputDir "manifest.sha256"
Get-ChildItem -Path $OutputDir -File | Where-Object { $_.Name -ne "manifest.sha256" } | ForEach-Object {
    $hash = Get-FileHash -Path $_.FullName -Algorithm SHA256
    [PSCustomObject]@{
        Algorithm = $hash.Algorithm
        Hash      = $hash.Hash
        Path      = $_.Name
    }
} | Format-Table -AutoSize | Out-File -FilePath $manifestPath

Write-Host "`n[+] Collection complete! All data stored in: $OutputDir" -ForegroundColor Green
# Agentless Volatile Data Collector

A cross-platform triage collection repository for Digital Forensics and Incident Response (DFIR) and CSOC teams[cite: 1, 2, 3]. It contains scripts to gather volatile system artifacts across Windows, Linux, and macOS environments prior to reboot or network isolation[cite: 1, 2, 3].

---

## 📂 Repository Contents

| Script Name | Target OS | Runtime / Language | Output Format |
| :--- | :--- | :--- | :--- |
| `Windows-Volatile-Data.ps1` | Windows | PowerShell | Folder containing `.txt`, `.json`, and `manifest.sha256` |
| `Linux-Volatile-Data.sh` *(or script 3)* | Linux | Bash | Compressed ZIP archive |
| `Mac-Volatile-Data.sh` *(or script 2)* | macOS | Bash | Compressed ZIP archive |

---

## 📊 Collected Volatile Artifacts

### 1. Windows (`Windows-Volatile-Data.ps1`)
Collects both human-readable (`.txt`) and structured (`.json`) artifacts, along with an integrity manifest:
* **01_SystemInfo**: OS build, computer/domain name, last boot time, collection UTC timestamp.
* **02_LoggedOnUsers**: Active logged-on user sessions and domains.
* **03_Processes**: Running processes including PID, Parent PID, execution path, and full command lines.
* **04_NetworkConnections**: Active TCP connections mapped to owning process names.
* **05_DNSCache**: Local DNS resolver cache entries.
* **06_ARP_and_Routes**: IPv4 ARP cache table and system routing table.
* **07_Services**: Windows services state, start modes, path names, and PIDs.
* **08_ScheduledTasks**: Enabled scheduled tasks and execution binaries.
* **09_StartupItems**: Auto-run items and registry startup commands.
* **10_InstalledSoftware**: Installed software enumerated via HKLM Uninstall registry hives.
* **11_LoadedDrivers**: Loaded kernel drivers and startup modes.
* **manifest.sha256**: SHA-256 integrity hash of all collected output files for chain of custody.

### 2. Linux (`Linux-Volatile-Data.sh`)
Collects core volatile Linux metrics into `volatile_data_YYYYMMDD_HHMMSS.zip`:
* System date (`date`), uptime (`uptime`), and detailed active user sessions (`who -a`).
* Running process trees (`ps aux`).
* Network interface details (`ifconfig -a`) and active network socket connections (`netstat -anpt`).
* Open files and active file descriptors (`lsof`).
* Loaded kernel modules (`lsmod`) and mounted filesystems (`mount`).

### 3. macOS (`Mac-Volatile-Data.sh`)
Collects macOS volatile metrics into `volatile_data_YYYYMMDD_HHMMSS.zip`:
* System date (`date`), uptime (`uptime`), and active user sessions (`who`).
* Active process list (`ps aux`).
* Network interface configurations (`ifconfig`) and network socket connections (`netstat -anv`).
* Open file descriptors (`lsof`).
* Loaded macOS Kernel Extensions (`kextstat`) and mounted storage volumes (`mount`).

---

## 🚀 Execution Instructions

### Windows

Run PowerShell with **Administrator privileges**:

```powershell
# 1. Bypass execution policy for the current PowerShell session
powershell.exe -ExecutionPolicy Bypass -File .\Windows-Volatile-Data.ps1

# Alternative inside an elevated PowerShell prompt:
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
.\Windows-Volatile-Data.ps1

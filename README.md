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
* **02_LoggedOnUsers**: Active logged-on user sessions and domains[cite: 1].
* **03_Processes**: Running processes including PID, Parent PID, execution path, and full command lines[cite: 1].
* **04_NetworkConnections**: Active TCP connections mapped to owning process names[cite: 1].
* **05_DNSCache**: Local DNS resolver cache entries[cite: 1].
* **06_ARP_and_Routes**: IPv4 ARP cache table and system routing table[cite: 1].
* **07_Services**: Windows services state, start modes, path names, and PIDs[cite: 1].
* **08_ScheduledTasks**: Enabled scheduled tasks and execution binaries[cite: 1].
* **09_StartupItems**: Auto-run items and registry startup commands[cite: 1].
* **10_InstalledSoftware**: Installed software enumerated via HKLM Uninstall registry hives[cite: 1].
* **11_LoadedDrivers**: Loaded kernel drivers and startup modes[cite: 1].
* **manifest.sha256**: SHA-256 integrity hash of all collected output files for chain of custody[cite: 1].

### 2. Linux (`Linux-Volatile-Data.sh`)
Collects core volatile Linux metrics into `volatile_data_YYYYMMDD_HHMMSS.zip`:
* System date (`date`), uptime (`uptime`), and detailed active user sessions (`who -a`).
* Running process trees (`ps aux`)[cite: 3].
* Network interface details (`ifconfig -a`) and active network socket connections (`netstat -anpt`)[cite: 3].
* Open files and active file descriptors (`lsof`)[cite: 3].
* Loaded kernel modules (`lsmod`) and mounted filesystems (`mount`)[cite: 3].

### 3. macOS (`Mac-Volatile-Data.sh`)
Collects macOS volatile metrics into `volatile_data_YYYYMMDD_HHMMSS.zip`:
* System date (`date`), uptime (`uptime`), and active user sessions (`who`)[cite: 2].
* Active process list (`ps aux`)[cite: 2].
* Network interface configurations (`ifconfig`) and network socket connections (`netstat -anv`)[cite: 2].
* Open file descriptors (`lsof`)[cite: 2].
* Loaded macOS Kernel Extensions (`kextstat`) and mounted storage volumes (`mount`)[cite: 2].

---

## 🚀 Execution Instructions

### Windows

Run PowerShell with **Administrator privileges**[cite: 1]:

```powershell
# 1. Bypass execution policy for the current PowerShell session
powershell.exe -ExecutionPolicy Bypass -File .\Windows-Volatile-Data.ps1

# Alternative inside an elevated PowerShell prompt:
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
.\Windows-Volatile-Data.ps1

# Live Response & Volatile Data Collector

A lightweight, agentless Digital Forensics and Incident Response (DFIR) collection suite designed for rapid triage and volatile data acquisition across Linux, macOS, and Windows systems.

> **CSOC / Triage Note:** Run these scripts at the very beginning of an incident prior to powering down or rebooting target hosts to preserve volatile memory, network states, and active execution context.

---

## 🛠️ Collection Capabilities

| Operating System | Script | Primary Artifacts Collected |
| :--- | :--- | :--- |
| **Linux** | `collect_linux.sh` | Running processes (`ps`, `top`), active connections (`netstat`/`ss`), loaded kernel modules (`lsmod`), open file descriptors (`lsof`), logged-in users (`who`, `w`), cron jobs, and environment variables. |
| **macOS** | `collect_macos.sh` | Running processes (`ps`), active socket connections (`netstat`), launch daemons/agents (`launchctl`), logged-in users, system logs, and shell history. |
| **Windows** | `collect_windows.ps1` | Process details with command-line arguments (`Get-CimInstance`), network sockets (`Get-NetTCPConnection`), active services, scheduled tasks, logged-on sessions, persistent startup items, and DNS cache. |

---

## 🚀 Quick Execution Guide

Ensure scripts are run from an external storage device, a secured network share, or directly staged via an Incident Response orchestration platform (e.g., EDR live terminal).

### 1. Windows Execution (PowerShell)

Launch PowerShell as an **Administrator**:

```powershell
# Set execution policy for current session only
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# Execute collection script
.\collect_windows.ps1 -OutputPath "C:\ProgramData\Triage"

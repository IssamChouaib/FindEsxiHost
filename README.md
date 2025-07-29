<div style="text-align: right;">
  [Español](README.es.md)
</div>

# FindEsxiHost.exe — ESXi Network Scanner

**Version**: 1.0  
**Author**: Issam Chouaib  
**License**: GNU All‑permissive License (see LICENSE.txt)

## Description  
Lightweight network scanner to discover operational VMware ESXi hosts on a LAN via TCP port 902 without requiring authentication. Built as a portable executable with GUI for Windows PowerShell 5.1.

## Features
- Scans a configurable IP range using fast asynchronous TCP (`BeginConnect`) with default timeout of **50 ms**.
- Detects ESXi by analyzing initial connection banner for “VMware” or “esx”.
- Modern WinForms interface with start button, progress bar and results grid.
- Single “Export Results” button to generate output in TXT, CSV or HTML formats.
- Portable: no installation, runs directly in Windows environment.

## Usage
1. Run `FindEsxiHost.exe`.
2. Enter **Start IP**, **End IP** and optional **Timeout (ms)**.
3. Click **Start Scan**.
4. View results in the table.
5. Click **Export Results** to save.

## Why use this tool?
Quick and efficient detection of ESXi servers in LAN for system administration, inventory or security audits — no dependencies, simple UI, zero installation.

## License  
This project is licensed under the **GNU All‑permissive License**. See [LICENSE.txt](LICENSE.txt) for full terms.

## Files
- `FindEsxiHost.exe` — executable scanner.
- `README.md`, `README.es.md` — bilingual documentation.
- `LICENSE.txt` — license details.

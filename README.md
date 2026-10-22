# Bash Automation Scripts

A collection of practical Bash scripts for Linux and Kali Linux, focused on automation, system administration, networking, cybersecurity, monitoring, and backup management.

This repository is a hands-on project for building useful command-line tools that automate repetitive tasks and solve real-world problems.

## Features

- **System Administration:** System information, CPU and memory monitoring, process inspection, disk usage alerts, and resource auditing.
- **File Management:** File searching, duplicate detection, directory analysis, archive extraction, and file organization.
- **Backup & Recovery:** Automated backups, Git backups, backup integrity verification, and SHA-256 checksum validation.
- **Networking:** Port checking, network information, HTTP status checks, DNS enumeration, and network reconnaissance.
- **Cybersecurity:** Web vulnerability checks, API security auditing, endpoint mapping, TLS inspection, and security log analysis.
- **Monitoring:** Website health checks, service monitoring, process monitoring, system change detection, and subdomain monitoring.
- **Automation:** Project initialization, Git repository auditing, download organization, system cleanup, and daily task management.
- **Utilities:** Password generation, quick notes, and other command-line productivity tools.

## Notable Scripts

| Script | Description |
|---|---|
| `smart_resource_guard.sh` | Monitors CPU, RAM, swap, disk, and processes. |
| `smart_storage_auditor.sh` | Analyzes storage usage, large files, and old files. |
| `smart_git_guard.sh` | Audits Git status, branches, remotes, and potential secret exposure. |
| `smart_backup_verifier.sh` | Verifies file integrity using SHA-256 manifests. |
| `web_vuln_scanner.sh` | Checks common web security misconfigurations. |
| `api_security_checker.sh` | Audits API headers, CORS, cookies, and HTTP methods. |
| `api_endpoint_mapper.sh` | Maps known API endpoints and records response information. |
| `tls_auditor.sh` | Checks TLS certificates and protocol support. |
| `subdomain_monitor.sh` | Tracks subdomain DNS, IP, and HTTP status changes. |
| `system_change_detector.sh` | Detects differences between system snapshots. |
| `log_anomaly_detector.sh` | Identifies unusual patterns in system logs. |
| `site_health_report.sh` | Generates website health and configuration reports. |
| `process_watchdog.sh` | Checks selected processes and logs their status. |

## Requirements

- Linux or Kali Linux
- Bash
- Git
- Standard Linux command-line utilities

Some scripts require additional tools, including `curl`, `openssl`, `nmap`, `gobuster`, `whatweb`, `nikto`, or `subfinder`.

## Getting Started

Clone the repository:

```bash
git clone <YOUR_GITHUB_REPOSITORY_URL>
cd bash-automation-scripts
```

Make a script executable:

```bash
chmod +x script_name.sh
```

Run it:

```bash
./script_name.sh
```

Some scripts require arguments or configuration files. Check their usage instructions before running them.

## Security & Responsible Use

- Run security and reconnaissance scripts only on systems you own or have explicit permission to test.
- Review scripts before execution, especially scripts that modify files or system settings.
- Never commit passwords, API keys, tokens, or private credentials.
- Treat scanner results as preliminary findings that may require manual verification.
- Keep backups before running scripts that perform cleanup or other system modifications.

## Learning Objectives

This project helps develop practical experience with:

- Bash scripting and automation
- Linux system administration
- Networking and DNS troubleshooting
- Cybersecurity auditing and reconnaissance
- Process and resource monitoring
- Backup management and file integrity
- Git and version control

## Contributing

Suggestions, improvements, bug fixes, and new scripts are welcome.

1. Fork the repository.
2. Create a new branch.
3. Add and test your changes.
4. Submit a pull request.

## License

A license can be added to define how others may use, modify, and distribute this project.

---

**A growing collection of practical Linux automation and cybersecurity tools.**

<a href="https://www.buymeacoffee.com/thibaut_watrisse" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="41" width="174"></a>

# Ansible Infrastructure Management

A comprehensive Ansible setup for managing heterogeneous environments with Proxmox virtualization, Windows and Linux systems, and 3CX telephony integration.

## ✨ Features

- **Dynamic Inventory**: Proxmox-based automatic host discovery
- **Multi-Platform**: Windows, Linux, and 3CX systems support
- **Secure Credentials**: Encrypted vault management with templates
- **Modular Design**: Reusable roles and organized playbooks
- **Health Monitoring**: Built-in connectivity and system checks
- **Update Management**: Automated Windows and Linux updates

## 🚀 Quick Start

1. **Clone and Setup**
   ```bash
   git clone <repository-url>
   cd ansible_infrastructure
   ansible-galaxy install -r requirements.yml
   ```

2. **Configure Credentials** (see [Vault Setup](#vault-setup))
   ```bash
   # Copy and edit the global vault with your Proxmox credentials
   cp inventories/production/group_vars/all/vault.yml.example \
      inventories/production/group_vars/all/vault.yml
   nano inventories/production/group_vars/all/vault.yml
   ansible-vault encrypt inventories/production/group_vars/all/vault.yml
   ```

3. **Test Connection**
   ```bash
   ansible-inventory -i inventories/production/proxmox.yml --list --ask-vault-pass
   ```

## 📋 Prerequisites

### System Requirements
- **Control Node**: Linux with Ansible 2.12+, Python 3.8+
- **Proxmox**: VE 7.0+ with API access
- **Network**: SSH/WinRM connectivity to targets

### Target Systems
- **Windows**: Server 2016+ or Windows 10+ with WinRM/SSH
- **Linux**: Ubuntu 18.04+, Debian 9+, CentOS 7+, RHEL 7+
- **3CX**: Phone System v18+

## 🏗️ Architecture

```
ansible_infrastructure/
├── inventories/           # Environment configurations
│   └── production/
│       ├── proxmox.yml    # Dynamic inventory
│       └── group_vars/    # Group variables and vaults
├── playbooks/            # Automation playbooks
│   ├── common/           # Cross-platform
│   ├── linux/            # Linux-specific
│   └── windows/          # Windows-specific
├── roles/                # Reusable roles
└── scripts/              # Utility scripts
```

## 🔐 Vault Setup

### Essential Configuration

Create encrypted vault files from the provided examples:

**1. Global Vault (Required for Proxmox)**
```bash
cp inventories/production/group_vars/all/vault.yml.example \
   inventories/production/group_vars/all/vault.yml
nano inventories/production/group_vars/all/vault.yml  # Edit credentials
ansible-vault encrypt inventories/production/group_vars/all/vault.yml
```

**Required variables:**
```yaml
vault_PVE_TOKEN_USER: "your-proxmox-user@pve"
vault_PVE_TOKEN_ID: "your-token-id"
vault_PVE_TOKEN_SECRET: "your-token-secret"
```

**2. Platform-Specific Vaults (As Needed)**
```bash
# Windows systems
cp inventories/production/group_vars/machines_windows/vault.yml.example \
   inventories/production/group_vars/machines_windows/vault.yml

# Linux systems  
cp inventories/production/group_vars/machines_linux/vault.yml.example \
   inventories/production/group_vars/machines_linux/vault.yml

# 3CX systems
cp inventories/production/group_vars/machines_3cx/vault.yml.example \
   inventories/production/group_vars/machines_3cx/vault.yml
```

### Vault Management Commands

```bash
# Edit vault
ansible-vault edit vault_file.yml

# View vault (read-only)
ansible-vault view vault_file.yml

# Change vault password
ansible-vault rekey vault_file.yml
```

⚠️ **Security**: Never commit unencrypted vault files. The `.gitignore` protects you, but always verify before pushing.

## 🔗 Proxmox Integration

### API Token Setup

1. **In Proxmox Web Interface:**
   - Go to `Datacenter → Permissions → API Tokens`
   - Create token: User: `ansible-user@pve`, Token ID: `ansible`
   - Set permissions: Path `/`, Role `PVEAuditor` (minimum)

2. **Add to Vault:**
   ```yaml
   vault_PVE_TOKEN_USER: "ansible-user@pve"
   vault_PVE_TOKEN_ID: "ansible"
   vault_PVE_TOKEN_SECRET: "your-generated-secret"
   ```

### Auto-Generated Groups

The dynamic inventory creates groups based on:
- **VM Names**: `machines_windows`, `machines_linux`, `machines_3cx`
- **Status**: `status_running`, `status_stopped`
- **Types**: `type_qemu`, `type_lxc`
- **Tags**: `tag_production`, `tag_development`

## 📖 Common Usage

### Basic Operations

```bash
# List discovered hosts
ansible-inventory --list --ask-vault-pass

# Test connectivity
ansible machines_windows -m ansible.windows.win_ping --ask-vault-pass
ansible machines_linux -m ping --ask-vault-pass

# Run health checks
ansible-playbook playbooks/common/health_check.yml --ask-vault-pass
```

### Windows Management

```bash
# System information and connectivity
ansible-playbook playbooks/windows/test_windows_common.yml --ask-vault-pass

# Update management
ansible-playbook playbooks/windows/manage_windows_updates.yml --ask-vault-pass

# Registry operations
ansible-playbook playbooks/windows/test_registry.yml --ask-vault-pass
```

### Linux Management

```bash
# System updates
ansible-playbook playbooks/linux/linux_updates.yml --ask-vault-pass
```

### Using Tags

```bash
# Run specific sections
ansible-playbook playbook.yml --tags connectivity --ask-vault-pass

# Skip sections
ansible-playbook playbook.yml --skip-tags debug --ask-vault-pass
```

## 📚 Key Playbooks

### Cross-Platform
- `playbooks/common/health_check.yml` - System health verification
- `playbooks/site.yml` - Main orchestration playbook

### Windows
- `test_windows_common.yml` - Basic connectivity and system info
- `manage_windows_updates.yml` - Comprehensive update management
- `test_registry.yml` - Registry management examples

### Linux
- `linux_updates.yml` - Package management and updates

## 🎭 Key Roles

### windows_common
Provides Windows system management:
- Connectivity testing (WinRM/SSH)
- System information collection
- Network configuration details

**Usage:**
```yaml
roles:
  - windows_common
vars:
  windows_common_collect_network_info: true
```

### Other Roles
- `common` - Cross-platform base functionality
- `linux_base` - Linux system baseline
- `windows_base` - Windows system baseline

## 🔧 Configuration

### Environment Variables

Edit `inventories/production/group_vars/all/common.yml`:

```yaml
# Global settings
log_level: INFO
log_retention_days: 30
backup_enabled: true
monitoring_enabled: true
```

### Ansible Configuration

The `ansible.cfg` is pre-configured with optimal settings:
- Dynamic Proxmox inventory
- Optimized performance settings
- Secure defaults

## 🔍 Troubleshooting

### Connection Issues

```bash
# Test specific connectivity
ansible windows_host -m ansible.windows.win_ping --ask-vault-pass
ansible linux_host -m ping --ask-vault-pass

# Verify inventory
ansible-inventory --graph --ask-vault-pass

# Enable verbose output
ansible-playbook playbook.yml -vvv --ask-vault-pass
```

### Vault Issues

```bash
# Verify vault decryption
ansible-vault view vault_file.yml

# Test vault password
echo "test" | ansible-vault encrypt_string --stdin-name test_var
```

### Proxmox API

```bash
# Test API connectivity
curl -k https://proxmox.example.com:8006/api2/json/version
```

## 🔒 Security Best Practices

- **Use SSH keys** instead of passwords where possible
- **Encrypt all sensitive data** with ansible-vault
- **Rotate credentials** regularly
- **Use WinRM over HTTPS** for Windows connections
- **Limit network access** to management interfaces
- **Monitor and audit** all automation activities

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes and test thoroughly
4. Follow Ansible best practices
5. Update documentation
6. Submit a pull request

### Development Guidelines
- Use 2-space YAML indentation
- Use descriptive variable names with prefixes
- Document complex logic
- Test in staging before production
- Never commit unencrypted vault files

## 📝 Windows Setup Helper

For Windows systems, use this PowerShell script to configure SSH access:

```powershell
# Run as Administrator - Creates ansible user and configures SSH
param([Parameter(Mandatory=$true)][string]$AnsibleUserPassword)

# Install OpenSSH
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'

# Create ansible user
$SecurePassword = ConvertTo-SecureString $AnsibleUserPassword -AsPlainText -Force
New-LocalUser -Name "ansible" -Password $SecurePassword -FullName "Ansible User"
Add-LocalGroupMember -Group "Administrators" -Member "ansible"

# Configure firewall
New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
```

## 📞 Support

- **Issues**: Create GitHub issues for bugs and features
- **Documentation**: Check role-specific READMEs in `roles/*/README.md`
- **Community**: Ansible forums and documentation

---

⚠️ **Remember**: Always use `--ask-vault-pass` when running playbooks containing encrypted data.

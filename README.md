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

## 📁 Directory Structure Explained

### Core Configuration Files
```
├── ansible.cfg           # Main Ansible configuration (inventory path, defaults)
├── requirements.yml      # Ansible Galaxy collections and roles dependencies
├── README.md            # This documentation
├── QUICKSTART.md        # Quick setup guide
└── LICENSE              # Project license
```

### Inventories Structure
```
inventories/
├── production/          # Production environment
│   ├── proxmox.yml      # Dynamic inventory configuration (Proxmox API)
│   ├── proxmox_env.yml  # Environment-specific Proxmox settings
│   ├── group_vars/      # Variables applied to groups of hosts
│   │   ├── all/         # Variables for ALL hosts
│   │   │   ├── common.yml       # General settings (logging, monitoring)
│   │   │   ├── vault.yml        # Encrypted secrets (Proxmox API, domain creds)
│   │   │   └── vault.yml.example # Template for vault creation
│   │   ├── machines_windows/    # Variables specific to Windows hosts
│   │   │   ├── main.yml         # Windows-specific settings
│   │   │   ├── vault.yml        # Encrypted Windows credentials
│   │   │   └── vault.yml.example # Template for Windows vault
│   │   ├── machines_linux/      # Variables specific to Linux hosts
│   │   └── machines_3cx/        # Variables specific to 3CX hosts
│   └── host_vars/       # Variables for individual hosts (when needed)
└── staging/             # Staging environment (mirrors production structure)
```

### Playbooks Organization
```
playbooks/
├── site.yml             # Master playbook that orchestrates everything
├── common/              # Cross-platform playbooks
│   └── health_check.yml # System health verification
├── windows/             # Windows-specific automation
│   ├── manage_windows_updates.yml  # Comprehensive update management
│   ├── test_registry.yml          # Registry operations examples
│   ├── test_windows_common.yml    # Basic connectivity & info gathering
│   ├── test_win_updates.yml       # Update testing scenarios
│   └── README_windows_updates.md  # Windows updates documentation
└── linux/               # Linux-specific automation
    └── linux_updates.yml # Package management and updates
```

### Roles Structure
```
roles/
├── common/              # Base role for all systems
├── windows_base/        # Windows baseline configuration
├── linux_base/          # Linux baseline configuration
└── windows_common/      # Windows system management utilities
    ├── tasks/           # Main automation tasks
    │   ├── main.yml         # Entry point (includes other task files)
    │   ├── connectivity.yml # WinRM/SSH connection testing
    │   └── system_info.yml  # System information gathering
    ├── defaults/        # Default variables (can be overridden)
    │   └── main.yml         # Role default settings
    ├── handlers/        # Event-driven tasks (restarts, notifications)
    │   └── main.yml         # Service restart handlers
    ├── meta/           # Role metadata and dependencies
    │   └── main.yml         # Role dependencies and Galaxy info
    ├── vars/           # Role variables (higher priority than defaults)
    │   └── main.yml         # Internal role variables
    └── README.md       # Role-specific documentation
```

### Supporting Directories
```
├── files/              # Static files to be copied to hosts
├── templates/          # Jinja2 templates (.j2 files) for dynamic configs
├── scripts/            # Utility scripts and helpers
├── vars/              # Additional variable files
└── vault/             # Legacy vault storage (use group_vars instead)
```

### Key Concepts

**Inventory Hierarchy (highest to lowest priority):**
1. `host_vars/` - Individual host settings
2. `group_vars/machines_*` - Platform-specific settings  
3. `group_vars/all/` - Global settings
4. Role `vars/` - Role-internal variables
5. Role `defaults/` - Default fallback values

**Naming Convention:**
- `machines_*` groups match VM name patterns in Proxmox
- `vault.yml` files contain encrypted secrets
- `main.yml` files contain non-sensitive configuration
- `.example` files are templates for creating actual config files

**Role Components:**
- **tasks/**: The actual automation steps
- **handlers/**: Actions triggered by task changes (like service restarts)
- **defaults/**: Default values that can be overridden
- **vars/**: Internal role variables (not meant to be overridden)
- **meta/**: Role dependencies and Galaxy metadata

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

```bash
# Create role with adapted permissions
pveum role add AnsibleProv -privs "Datastore.Allocate Datastore.AllocateSpace Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Console VM.Migrate VM.Monitor VM.PowerMgmt SDN.Use"

# Create dedicated PVE user for ansible
pveum user add ansible-user@pve --password <password>

# Assign group membership to new user
pveum aclmod / -user ansible-user@pve -role AnsibleProv

# Generate Proxmox API token with this user 
pveum user token add ansible-user@pve ansible -expire 0 -privsep 0 -comment "Ansible token"

# -> Take notes of full-token-id and returned token
```

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
# Script PowerShell pour configuration SSH et utilisateur Ansible
# À exécuter en tant qu'administrateur sur chaque machine Windows

param(
    [Parameter(Mandatory=$true)]
    [string]$AnsibleUserPassword
)

Write-Output "=== Début de la configuration SSH et utilisateur Ansible ==="

# Vérification des privilèges administrateur
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "Ce script doit être exécuté en tant qu'administrateur"
    exit 1
}

# 1. Installation d'OpenSSH
Write-Output "Installation d'OpenSSH..."
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'

# Install the OpenSSH Client
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0

# Install the OpenSSH Server
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# 2. Configuration du service SSH
Write-Output "Configuration du service SSH..."
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'
Restart-Service -Name sshd

# 3. Configuration du firewall
Write-Output "Configuration du firewall..."
if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
    Write-Output "Création de la règle firewall 'OpenSSH-Server-In-TCP'..."
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
} else {
    Write-Output "La règle firewall 'OpenSSH-Server-In-TCP' existe déjà."
}

# 4. Création de l'utilisateur ansible
Write-Output "Création de l'utilisateur ansible..."
$AnsibleUser = "ansible"

# Vérifier si l'utilisateur existe déjà
if (Get-LocalUser -Name $AnsibleUser -ErrorAction SilentlyContinue) {
    Write-Output "L'utilisateur '$AnsibleUser' existe déjà. Mise à jour du mot de passe..."
    $SecurePassword = ConvertTo-SecureString $AnsibleUserPassword -AsPlainText -Force
    Set-LocalUser -Name $AnsibleUser -Password $SecurePassword
} else {
    Write-Output "Création de l'utilisateur '$AnsibleUser'..."
    $SecurePassword = ConvertTo-SecureString $AnsibleUserPassword -AsPlainText -Force
    New-LocalUser -Name $AnsibleUser -Password $SecurePassword -FullName "Ansible Automation User" -Description "User for Ansible automation" -PasswordNeverExpires
}

# 5. Ajout de l'utilisateur au groupe Administrateurs
Write-Output "Ajout de l'utilisateur ansible au groupe Administrateurs..."

# Détecter automatiquement le nom du groupe Administrateur selon la langue
$adminGroup = "Administrators"
if (-not (Get-LocalGroup -Name $adminGroup -ErrorAction SilentlyContinue)) {
    $adminGroup = "Administrateurs"
}

try {
    Add-LocalGroupMember -Group $adminGroup -Member $AnsibleUser -ErrorAction Stop
    Write-Output "Utilisateur ajouté au groupe $adminGroup avec succès."
} catch {
    if ($_.Exception.Message -like "*already a member*") {
        Write-Output "L'utilisateur est déjà membre du groupe $adminGroup."
    } else {
        Write-Error "Erreur lors de l'ajout au groupe $adminGroup : $($_.Exception.Message)"
    }
}


# 6. Configuration SSH spécifique pour l'utilisateur ansible
Write-Output "Configuration SSH avancée..."

# Créer le répertoire .ssh pour l'utilisateur ansible
$AnsibleUserHome = "C:\Users\$AnsibleUser"
$SSHDir = "$AnsibleUserHome\.ssh"

if (!(Test-Path $SSHDir)) {
    New-Item -ItemType Directory -Path $SSHDir -Force
    Write-Output "Répertoire SSH créé: $SSHDir"
}

# Configuration sshd_config pour sécuriser l'accès
$SSHDConfigPath = "C:\ProgramData\ssh\sshd_config"
$SSHDConfigBackup = "C:\ProgramData\ssh\sshd_config.backup"

# Sauvegarde de la configuration originale
if (!(Test-Path $SSHDConfigBackup)) {
    Copy-Item $SSHDConfigPath $SSHDConfigBackup
    Write-Output "Sauvegarde de sshd_config créée"
}

# Configuration SSH sécurisée
$SSHDConfig = @"
# Configuration SSH sécurisée pour Ansible
Port 22
Protocol 2
PermitRootLogin no
PasswordAuthentication yes
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM no
X11Forwarding no
PrintMotd no
AcceptEnv LANG LC_*
Subsystem sftp sftp-server.exe

# Autoriser seulement l'utilisateur ansible
AllowUsers ansible

# Restrictions de sécurité
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2
"@

Set-Content -Path $SSHDConfigPath -Value $SSHDConfig
Write-Output "Configuration SSH mise à jour"

# 7. Redémarrage du service SSH
Write-Output "Redémarrage du service SSH..."
Restart-Service sshd

# 8. Test de la configuration
Write-Output "Test de la configuration..."
$SSHStatus = Get-Service sshd
Write-Output "Statut du service SSH: $($SSHStatus.Status)"

# Vérification de l'écoute sur le port 22
$Listening = Get-NetTCPConnection -LocalPort 22 -State Listen -ErrorAction SilentlyContinue
if ($Listening) {
    Write-Output "SSH écoute correctement sur le port 22"
} else {
    Write-Warning "SSH ne semble pas écouter sur le port 22"
}

Write-Output "=== Configuration terminée ==="
Write-Output "Utilisateur: $AnsibleUser"
Write-Output "Répertoire SSH: $SSHDir"
Write-Output "Pour tester la connexion depuis votre machine Debian:"
Write-Output "ssh $AnsibleUser@$(hostname)"
```

## 📞 Support

- **Issues**: Create GitHub issues for bugs and features
- **Documentation**: Check role-specific READMEs in `roles/*/README.md`
- **Community**: Ansible forums and documentation

---

⚠️ **Remember**: Always use `--ask-vault-pass` when running playbooks containing encrypted data.

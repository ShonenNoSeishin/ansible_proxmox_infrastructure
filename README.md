
# Ansible Infrastructure Management

A comprehensive Ansible infrastructure setup for managing heterogeneous environments with Proxmox virtualization, Windows and Linux systems, and 3CX telephony systems.

## 🚀 Quick Start

1. **Clone and Setup**
   ```bash
   git clone <repository-url>
   cd ansible_infrastructure
   ```

2. **Install Dependencies**
   ```bash
   ansible-galaxy install -r requirements.yml
   ```

3. **Create Vault Files** (Manual Process)
   ```bash
   # Create global vault (required)
   cp inventories/production/group_vars/all/vault.yml.example \
      inventories/production/group_vars/all/vault.yml
   nano inventories/production/group_vars/all/vault.yml  # Edit with real credentials
   ansible-vault encrypt inventories/production/group_vars/all/vault.yml
   
   # Create additional vaults as needed for your environment
   # See "Vault Management" section for detailed instructions
   ```

4. **Test Connectivity**
   ```bash
   ansible-inventory -i inventories/production/proxmox.yml --list --ask-vault-pass
   ```

## 📋 Table of Contents

- [Features](#-features)
- [Architecture](#-architecture)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Vault Management](#-vault-management)
- [Proxmox Integration](#-proxmox-integration)
- [Usage Examples](#-usage-examples)
- [Playbooks](#-playbooks)
- [Roles](#-roles)
- [Directory Structure](#-directory-structure)
- [Security](#-security)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)

## ✨ Features

- **Dynamic Inventory**: Proxmox-based dynamic inventory with automatic host discovery
- **Multi-Platform Support**: Windows, Linux, and 3CX systems
- **Secure Vault Management**: Encrypted credentials with example templates
- **Modular Design**: Reusable roles and organized playbooks
- **Health Monitoring**: Built-in connectivity and system health checks
- **Update Management**: Automated Windows and Linux update workflows
- **Registry Management**: Windows registry automation
- **Telephony Integration**: 3CX PBX management capabilities

## 🏗️ Architecture

```
ansible_infrastructure/
├── inventories/           # Environment-specific configurations
│   ├── production/        # Production environment
│   └── staging/          # Staging environment
├── playbooks/            # Automation playbooks
│   ├── common/           # Cross-platform playbooks
│   ├── linux/            # Linux-specific playbooks
│   └── windows/          # Windows-specific playbooks
├── roles/                # Reusable Ansible roles
├── scripts/              # Utility scripts
├── templates/            # Jinja2 templates
└── files/               # Static files
```

## 📦 Prerequisites

### System Requirements

- **Ansible Control Node**: Linux system with Ansible 2.12+
- **Python**: 3.8+ with pip
- **Network Access**: SSH/WinRM connectivity to target hosts
- **Proxmox**: Proxmox VE 7.0+ with API access

### Target Systems

- **Windows**: Windows Server 2016+ or Windows 10+ with WinRM/SSH
- **Linux**: Ubuntu 18.04+, Debian 9+, CentOS 7+, RHEL 7+
- **3CX**: 3CX Phone System v18+

## 🔧 Installation

### 1. Clone Repository

```bash
git clone <repository-url>
cd ansible_infrastructure
```

### 2. Install Ansible Collections

```bash
ansible-galaxy install -r requirements.yml
```

### 3. Configure Ansible

The `ansible.cfg` file is pre-configured with optimal settings:

```ini
[defaults]
inventory = inventories/production/proxmox.yml
roles_path = roles
host_key_checking = False
timeout = 30
log_path = /var/log/ansible.log
stdout_callback = yaml
forks = 10
```

### 4. Create and Configure Vault Files

Create encrypted vault files from the provided examples:

```bash
# Start with the global vault (contains Proxmox credentials)
cp inventories/production/group_vars/all/vault.yml.example \
   inventories/production/group_vars/all/vault.yml

# Edit with your actual credentials
nano inventories/production/group_vars/all/vault.yml

# Encrypt the file (you'll be prompted for a vault password)
ansible-vault encrypt inventories/production/group_vars/all/vault.yml

# Repeat for other vault files as needed:
# - machines_windows/vault.yml.example → machines_windows/vault.yml
# - machines_linux/vault.yml.example → machines_linux/vault.yml  
# - machines_3cx/vault.yml.example → machines_3cx/vault.yml
```

See the [Vault Management](#-vault-management) section for detailed instructions.

## ⚙️ Configuration

### Environment Structure

Each environment (production/staging) contains:

```
inventories/production/
├── proxmox.yml                    # Dynamic inventory configuration
├── group_vars/
│   ├── all/
│   │   ├── common.yml            # Global variables
│   │   └── vault.yml             # Encrypted global secrets
│   ├── machines_windows/
│   │   ├── main.yml              # Windows-specific variables
│   │   └── vault.yml             # Encrypted Windows credentials
│   ├── machines_linux/
│   │   ├── main.yml              # Linux-specific variables
│   │   └── vault.yml             # Encrypted Linux credentials
│   └── machines_3cx/
│       ├── main.yml              # 3CX-specific variables
│       └── vault.yml             # Encrypted 3CX credentials
└── host_vars/                     # Host-specific variables
```

### Global Variables

Edit `inventories/production/group_vars/all/common.yml`:

```yaml
# Logging
log_level: INFO
log_retention_days: 30

# Backup
backup_enabled: true
backup_schedule: "0 2 * * *"

# Monitoring
monitoring_enabled: true
monitoring_agent: "telegraf"
```

## 🔐 Vault Management

### Creating Vault Files from Examples

All sensitive data is stored in encrypted vault files. This repository provides example files for each type of vault that you need to copy and customize:

#### Step-by-Step Process

**1. Global Vault (Required)**
```bash
# Copy the example file
cp inventories/production/group_vars/all/vault.yml.example \
   inventories/production/group_vars/all/vault.yml

# Edit the file and replace placeholder values with your real credentials
nano inventories/production/group_vars/all/vault.yml

# Most important: Update Proxmox API credentials
# vault_PVE_TOKEN_USER: "your-proxmox-user@pve"
# vault_PVE_TOKEN_ID: "your-token-id"
# vault_PVE_TOKEN_SECRET: "your-actual-token-secret"

# Encrypt the file (you'll be prompted for a vault password)
ansible-vault encrypt inventories/production/group_vars/all/vault.yml
```

**2. Windows Vault (if you have Windows machines)**
```bash
# Copy the example
cp inventories/production/group_vars/machines_windows/vault.yml.example \
   inventories/production/group_vars/machines_windows/vault.yml

# Edit with your Windows credentials
nano inventories/production/group_vars/machines_windows/vault.yml

# Update at minimum:
# vault_windows_ansible_user: "your-windows-user"
# vault_windows_ansible_password: "your-windows-password"
# vault_windows_ansible_connection: "ssh" or "winrm"

# Encrypt the file
ansible-vault encrypt inventories/production/group_vars/machines_windows/vault.yml
```

**3. Linux Vault (if you have Linux machines)**
```bash
# Copy the example
cp inventories/production/group_vars/machines_linux/vault.yml.example \
   inventories/production/group_vars/machines_linux/vault.yml

# Edit with your Linux credentials
nano inventories/production/group_vars/machines_linux/vault.yml

# Update credentials (prefer SSH keys over passwords)
# vault_linux_ansible_user: "your-linux-user"
# vault_linux_ansible_password: "your-password-if-needed"

# Encrypt the file
ansible-vault encrypt inventories/production/group_vars/machines_linux/vault.yml
```

**4. 3CX Vault (if you have 3CX systems)**
```bash
# Copy the example
cp inventories/production/group_vars/machines_3cx/vault.yml.example \
   inventories/production/group_vars/machines_3cx/vault.yml

# Edit with your 3CX credentials
nano inventories/production/group_vars/machines_3cx/vault.yml

# Update 3CX-specific credentials
# vault_3cx_admin_user: "your-3cx-admin"
# vault_3cx_admin_password: "your-3cx-password"

# Encrypt the file
ansible-vault encrypt inventories/production/group_vars/machines_3cx/vault.yml
```

#### Important Security Notes

⚠️ **Critical**: Always encrypt vault files before committing to git:
- The `.gitignore` file protects unencrypted `vault.yml` files
- Never commit files containing real credentials in plain text
- Use strong, unique passwords for vault encryption
- Store vault passwords securely (password manager recommended)

#### Essential vs Optional Variables

**Essential (must be configured):**
- `vault_PVE_TOKEN_USER`, `vault_PVE_TOKEN_ID`, `vault_PVE_TOKEN_SECRET` - Required for Proxmox inventory
- `vault_windows_ansible_user`, `vault_windows_ansible_password` - Required for Windows connectivity
- `vault_linux_ansible_user` - Required for Linux connectivity

**Optional (can be configured later):**
- Database credentials, monitoring tokens, backup settings
- Application-specific credentials
- SSL certificate passwords

💡 **Tip**: Start with only the essential variables to get basic connectivity working, then add others as needed.

### Vault Operations

```bash
# Create new vault from scratch
ansible-vault create vault_file.yml

# Edit existing vault
ansible-vault edit vault_file.yml

# View vault contents (read-only)
ansible-vault view vault_file.yml

# Change vault password
ansible-vault rekey vault_file.yml

# Decrypt temporarily (use with caution!)
ansible-vault decrypt vault_file.yml

# Re-encrypt after editing
ansible-vault encrypt vault_file.yml
ansible-vault edit vault_file.yml

# View vault contents
ansible-vault view vault_file.yml

# Change vault password
ansible-vault rekey vault_file.yml

# Decrypt (temporarily)
ansible-vault decrypt vault_file.yml
```

### Vault File Templates

#### Global Vault (`all/vault.yml`)
- Proxmox API credentials
- Domain credentials
- Monitoring tokens
- Backup encryption keys

#### Windows Vault (`machines_windows/vault.yml`)
- WinRM/SSH credentials
- Domain service accounts
- Local administrator passwords
- Application-specific credentials

#### Linux Vault (`machines_linux/vault.yml`)
- SSH credentials
- Sudo passwords
- Database credentials
- SSL certificate passwords

#### 3CX Vault (`machines_3cx/vault.yml`)
- 3CX admin credentials
- SIP trunk credentials
- Database passwords
- License keys

## 🔗 Proxmox Integration

### Dynamic Inventory Configuration

The `proxmox.yml` inventory file automatically discovers VMs from Proxmox:

```yaml
plugin: 'community.proxmox.proxmox'
url: 'https://proxmox.example.com:8006'
user: "{{ vault_PVE_TOKEN_USER }}"
token_id: "{{ vault_PVE_TOKEN_ID }}"
token_secret: "{{ vault_PVE_TOKEN_SECRET }}"
validate_certs: false
want_facts: true
```

### Auto-Generated Groups

The inventory automatically creates groups based on:

- **VM Names**: `machines_windows`, `machines_linux`, `machines_3cx`
- **VM Status**: `status_running`, `status_stopped`
- **VM Types**: `type_qemu`, `type_lxc`
- **Tags**: `tag_production`, `tag_development`

### Proxmox API Setup

1. **Create API Token** in Proxmox:
   ```
   Datacenter → Permissions → API Tokens → Add
   Token ID: ansible
   User: ansible-user@pve
   ```

2. **Set Permissions**:
   ```
   Path: /
   User: ansible-user@pve
   Role: PVEAuditor (minimum) or Administrator
   ```

3. **Add to Vault**:
   ```yaml
   vault_PVE_TOKEN_USER: "ansible-user@pve"
   vault_PVE_TOKEN_ID: "ansible"
   vault_PVE_TOKEN_SECRET: "your-secret-here"
   ```

## 📖 Usage Examples

### Basic Operations

```bash
# List all discovered hosts
ansible-inventory -i inventories/production/proxmox.yml --list --ask-vault-pass

# Check connectivity to Windows machines
ansible machines_windows -m ansible.windows.win_ping --ask-vault-pass

# Check connectivity to Linux machines  
ansible machines_linux -m ping --ask-vault-pass

# Run health checks on all systems
ansible-playbook playbooks/common/health_check.yml --ask-vault-pass
```

### Windows Management

```bash
# Test Windows connectivity and gather system info
ansible-playbook playbooks/windows/test_windows_common.yml --ask-vault-pass

# Manage Windows updates
ansible-playbook playbooks/windows/manage_windows_updates.yml --ask-vault-pass

# Manage Windows registry
ansible-playbook playbooks/windows/test_registry.yml --ask-vault-pass
```

### Linux Management

```bash
# Update Linux systems
ansible-playbook playbooks/linux/linux_updates.yml --ask-vault-pass

# Deploy configurations
ansible-playbook playbooks/linux/deploy_config.yml --ask-vault-pass
```

### Using Tags

```bash
# Run only connectivity tests
ansible-playbook playbooks/windows/test_registry.yml --tags connectivity --ask-vault-pass

# Skip debug output
ansible-playbook playbooks/windows/test_registry.yml --skip-tags debug --ask-vault-pass

# Run specific sections
ansible-playbook playbooks/windows/manage_windows_updates.yml --tags security_updates --ask-vault-pass
```

## 📚 Playbooks

### Common Playbooks

- **`playbooks/common/health_check.yml`**: Cross-platform health checks
- **`playbooks/site.yml`**: Main site-wide orchestration playbook

### Windows Playbooks

- **`test_windows_common.yml`**: Basic connectivity and system info
- **`test_registry.yml`**: Windows registry management demonstration
- **`manage_windows_updates.yml`**: Comprehensive Windows update management
- **`test_win_updates.yml`**: Windows update testing scenarios

### Linux Playbooks

- **`linux_updates.yml`**: Linux package management and updates

## 🎭 Roles

### windows_common

Provides common Windows functionality:

- **Connectivity testing**: WinRM/SSH connection validation
- **System information**: Hardware, OS, and configuration details
- **Network information**: Interface and routing details

**Usage**:
```yaml
roles:
  - windows_common
vars:
  windows_common_collect_network_info: true
```

**Available Facts**:
- `windows_connectivity_status`: Connection status
- `windows_system_info`: Detailed system information
- `windows_network_info`: Network configuration
- `windows_host_facts`: Consolidated facts

### Other Roles

- **`common`**: Cross-platform base functionality
- **`linux_base`**: Linux system baseline configuration
- **`windows_base`**: Windows system baseline configuration

## 📁 Directory Structure

```
ansible_infrastructure/
├── ansible.cfg                    # Ansible configuration
├── requirements.yml               # Ansible Galaxy requirements
├── .gitignore                    # Git ignore rules (protects vaults)
├── README.md                     # This file
├── inventories/
│   ├── production/
│   │   ├── proxmox.yml           # Dynamic inventory config
│   │   ├── group_vars/
│   │   │   ├── all/
│   │   │   │   ├── common.yml    # Global variables
│   │   │   │   ├── vault.yml     # Encrypted secrets
│   │   │   │   └── vault.yml.example  # Template
│   │   │   ├── machines_windows/
│   │   │   ├── machines_linux/
│   │   │   └── machines_3cx/
│   │   └── host_vars/
│   └── staging/                  # Staging environment
├── playbooks/
│   ├── common/
│   │   └── health_check.yml
│   ├── linux/
│   │   └── linux_updates.yml
│   ├── windows/
│   │   ├── test_windows_common.yml
│   │   ├── test_registry.yml
│   │   ├── manage_windows_updates.yml
│   │   └── README_windows_updates.md
│   └── site.yml
├── roles/
│   ├── common/
│   ├── linux_base/
│   ├── windows_base/
│   └── windows_common/
│       ├── tasks/
│       ├── defaults/
│       └── README.md
├── scripts/
│   ├── setup_github_repo.sh      # GitHub repository setup helper
│   └── proxmox_inventory.sh      # Alternative inventory script
├── templates/                    # Jinja2 templates
├── files/                       # Static files
└── vars/                        # Additional variables
```

## 🔒 Security

### Vault Protection

- **Never commit unencrypted vaults**: Strict `.gitignore` rules prevent accidental commits
- **Use strong vault passwords**: Store in a secure password manager
- **Regular rotation**: Rotate vault passwords and credentials regularly
- **Access control**: Limit who has access to vault passwords

### Network Security

- **SSH Keys**: Prefer SSH key authentication over passwords
- **WinRM over HTTPS**: Use encrypted WinRM connections
- **Network Segmentation**: Isolate management networks
- **Firewall Rules**: Restrict access to management ports

### Best Practices

- **Principle of Least Privilege**: Grant minimal necessary permissions
- **Regular Updates**: Keep Ansible and collections updated
- **Audit Logs**: Monitor Ansible execution logs
- **Backup Strategy**: Secure backup of vault files and keys

## 🔍 Troubleshooting

### Common Issues

#### Connection Problems

```bash
# Test WinRM connectivity
ansible windows_host -m ansible.windows.win_ping --ask-vault-pass

# Test SSH connectivity  
ansible linux_host -m ping --ask-vault-pass

# Check inventory parsing
ansible-inventory --list --ask-vault-pass
```

#### Vault Issues

```bash
# Verify vault encryption
ansible-vault view vault_file.yml

# Test vault password
echo "test" | ansible-vault encrypt_string --stdin-name test_var
```

#### Proxmox Integration

```bash
# Test Proxmox API connection
curl -k https://proxmox.example.com:8006/api2/json/version

# Verify API token permissions
ansible-inventory -i inventories/production/proxmox.yml --graph --ask-vault-pass
```

### Debug Mode

Enable verbose output for troubleshooting:

```bash
# Various verbosity levels
ansible-playbook playbook.yml -v --ask-vault-pass    # Basic info
ansible-playbook playbook.yml -vv --ask-vault-pass   # More info
ansible-playbook playbook.yml -vvv --ask-vault-pass  # Debug info
ansible-playbook playbook.yml -vvvv --ask-vault-pass # Connection debug
```

### Log Analysis

Check logs for detailed information:

```bash
# Main Ansible log
tail -f /var/log/ansible.log

# Windows update logs
tail -f /path/to/windows/update/logs
```

## 🤝 Contributing

### Development Setup

1. **Fork the repository**
2. **Create a feature branch**:
   ```bash
   git checkout -b feature/new-functionality
   ```
3. **Make changes and test thoroughly**
4. **Follow Ansible best practices**
5. **Submit a pull request**

### Coding Standards

- **YAML**: Use 2-space indentation
- **Variables**: Use descriptive names with prefixes
- **Documentation**: Comment complex logic
- **Testing**: Test all changes in staging environment

### Pull Request Process

1. **Update documentation** for any new features
2. **Add example configurations** when appropriate
3. **Test with multiple target systems**
4. **Ensure vault files are not included**

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

For support and questions:

- **Issues**: Create GitHub issues for bugs and feature requests
- **Documentation**: Check the `roles/*/README.md` files for role-specific help
- **Community**: Ansible community forums and documentation

## 🙏 Acknowledgments

- **Ansible Community**: For the excellent automation platform
- **Proxmox Team**: For the virtualization platform
- **Contributors**: All contributors to this project

---

**⚠️ Security Notice**: Always use `--ask-vault-pass` when running playbooks. Never store vault passwords in plain text files.

---

## 💻 Windows Setup (Legacy Information)

### Powershell script to setup openssh windows connection

Run powershell ISE as an administrator user and run this script in order to :
- Create ansible user
- download and setup openssh-server
- restrict ssh connection only for ansible user
- configure ansible user password
- configure firewall needed rule 

´´´´bash
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
´´´´




## Gestion de vault 

# Éditer un fichier vault existant
ansible-vault edit inventories/production/group_vars/machines_windows/vault.yml

# Visualiser le contenu d'un vault (sans l'éditer)
ansible-vault view inventories/production/group_vars/machines_windows/vault.yml

# Changer le mot de passe d'un vault
ansible-vault rekey inventories/production/group_vars/machines_windows/vault.yml

# Chiffrer un fichier existant
ansible-vault encrypt inventories/production/group_vars/machines_windows/secrets.yml

# Déchiffrer un fichier
ansible-vault decrypt inventories/production/group_vars/machines_windows/vault.yml

# Vérifier que tous les vaults utilisent le bon mot de passe
find inventories/ -name "vault.yml" -exec ansible-vault view {} \; > /dev/null
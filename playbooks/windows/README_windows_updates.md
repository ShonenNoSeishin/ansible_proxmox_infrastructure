# Windows Updates Management with Ansible

This documentation covers the Windows update management system using Ansible's `win_updates` module with two complementary playbooks for testing and production use.

## 📚 Available Playbooks

### 1. `test_win_updates.yml` - Testing/Demo Playbook
Contains numerous usage examples of the `win_updates` module to understand different options and scenarios.

### 2. `manage_windows_updates.yml` - Production Playbook
Structured playbook for production update management with different operation modes and comprehensive error handling.

## 🚀 Production Playbook Usage

### SEARCH Mode (Discovery Only)
Scans for available updates without downloading or installing:
```bash
ansible-playbook -i inventories/production/proxmox.yml \
  playbooks/windows/manage_windows_updates.yml \
  --ask-vault-pass \
  -e update_mode=search
```

### DOWNLOAD Mode (Download Without Installation)
Downloads updates to local cache without installing:
```bash
ansible-playbook -i inventories/production/proxmox.yml \
  playbooks/windows/manage_windows_updates.yml \
  --ask-vault-pass \
  -e update_mode=download
```

### INSTALL Mode (Installation with Reboot)
Installs updates and allows automatic reboot if required:
```bash
ansible-playbook -i inventories/production/proxmox.yml \
  playbooks/windows/manage_windows_updates.yml \
  --ask-vault-pass \
  -e update_mode=install \
  -e allow_reboot=true
```

### INSTALL Mode (Installation without Reboot)
Installs updates but prevents automatic reboot:
```bash
ansible-playbook -i inventories/production/proxmox.yml \
  playbooks/windows/manage_windows_updates.yml \
  --ask-vault-pass \
  -e update_mode=install \
  -e allow_reboot=false
```

## ⚙️ Configuration Variables

### Primary Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `update_mode` | `search` | Operation mode: `search`, `download`, `install` |
| `allow_reboot` | `false` | Allow automatic reboot when required |
| `reboot_timeout` | `1800` | Reboot timeout in seconds (30 minutes) |
| `update_categories` | `[SecurityUpdates, CriticalUpdates]` | Update categories to include |

### Advanced Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `updates_to_exclude` | `[]` | List of regex patterns to exclude updates |
| `specific_updates` | `[]` | List of specific KB numbers to install |
| `update_log_path` | `C:\Logs\ansible_updates.log` | Path for update log file |
| `max_update_retries` | `3` | Maximum retry attempts for failed updates |

## 💡 Advanced Usage Examples

### Install Specific Updates
Target specific Knowledge Base (KB) articles:
```bash
ansible-playbook -i inventories/production/proxmox.yml \
  playbooks/windows/manage_windows_updates.yml \
  --ask-vault-pass \
  -e update_mode=install \
  -e "specific_updates=['KB4056892','KB4073117']"
```

### Exclude Problematic Updates
Exclude updates that may cause issues:
```bash
ansible-playbook -i inventories/production/proxmox.yml \
  playbooks/windows/manage_windows_updates.yml \
  --ask-vault-pass \
  -e update_mode=install \
  -e "updates_to_exclude=['Windows Malicious Software Removal Tool','.*Defender.*']"
```

### Custom Update Categories
Include additional update categories:
```bash
ansible-playbook -i inventories/production/proxmox.yml \
  playbooks/windows/manage_windows_updates.yml \
  --ask-vault-pass \
  -e update_mode=install \
  -e "update_categories=['SecurityUpdates','CriticalUpdates','UpdateRollups','DefinitionUpdates']"
```

### Extended Reboot Timeout
For systems requiring longer reboot times:
```bash
ansible-playbook -i inventories/production/proxmox.yml \
  playbooks/windows/manage_windows_updates.yml \
  --ask-vault-pass \
  -e update_mode=install \
  -e allow_reboot=true \
  -e reboot_timeout=3600
```

## 🏷️ Tag-Based Execution

### Execute Specific Phases

```bash
# Run only update search
ansible-playbook playbook.yml --tags search --ask-vault-pass

# Run only update download
ansible-playbook playbook.yml --tags download --ask-vault-pass

# Run only update installation
ansible-playbook playbook.yml --tags install --ask-vault-pass

# Display only reports
ansible-playbook playbook.yml --tags report --ask-vault-pass

# Skip debug output
ansible-playbook playbook.yml --skip-tags debug --ask-vault-pass
```

### Combined Tag Usage

```bash
# Search and download only
ansible-playbook playbook.yml --tags "search,download" --ask-vault-pass

# Full process without debug
ansible-playbook playbook.yml --skip-tags debug --ask-vault-pass
```

## 📋 Best Practices

### 1. Always Start with Search Mode
Discover available updates before making changes:
```bash
# First: Discover what's available
ansible-playbook playbook.yml -e update_mode=search --ask-vault-pass
```

### 2. Pre-Download During Off-Hours
Download updates during low-traffic periods:
```bash
# During maintenance window: Download updates
ansible-playbook playbook.yml -e update_mode=download --ask-vault-pass
```

### 3. Scheduled Installation Windows
Install updates during planned maintenance:
```bash
# During change window: Install pre-downloaded updates
ansible-playbook playbook.yml -e update_mode=install -e allow_reboot=true --ask-vault-pass
```

### 4. Reboot Management Strategy
**Controlled Reboots (Recommended for Production):**
```bash
-e allow_reboot=false  # Manual reboot control
```

**Automated Reboots (Use with Caution):**
```bash
-e allow_reboot=true   # Automatic reboots when required
```

### 5. Monitoring and Reporting
- **Reports**: Automatically saved to `/tmp/` on the Ansible control machine
- **Logs**: Created on each Windows machine at `C:\Logs\ansible_updates.log`
- **Status**: Real-time progress displayed during execution

## 📊 Update Categories Reference

### Available Categories
- `SecurityUpdates` - Security patches and fixes
- `CriticalUpdates` - Critical system updates
- `UpdateRollups` - Cumulative update packages
- `DefinitionUpdates` - Antivirus and security definitions
- `FeaturePacks` - New Windows features
- `ServicePacks` - Major service pack updates
- `Tools` - Microsoft tools and utilities
- `Drivers` - Hardware drivers

### Category Selection Examples
```yaml
# Security-focused (recommended for servers)
update_categories: ['SecurityUpdates', 'CriticalUpdates']

# Comprehensive updates (workstations)
update_categories: ['SecurityUpdates', 'CriticalUpdates', 'UpdateRollups', 'DefinitionUpdates']

# Minimal updates only
update_categories: ['SecurityUpdates']
```

## 🔍 Troubleshooting

### Common Issues and Solutions

#### Connectivity Problems
The `windows_common` role automatically tests connectivity. Check:
- **DNS Resolution**: Verify hostname resolution
- **Network Connectivity**: Test port 5985/5986 (WinRM) or 22 (SSH)
- **Authentication**: Verify credentials in vault files

```bash
# Test connectivity manually
ansible machines_windows -m ansible.windows.win_ping --ask-vault-pass
```

#### Update Timeout Issues
For large updates or slow systems:
```bash
# Increase timeout to 2 hours
ansible-playbook playbook.yml -e reboot_timeout=7200 --ask-vault-pass
```

#### Windows Update Service Issues
```powershell
# On target Windows machine, restart Windows Update service
Stop-Service -Name wuauserv
Start-Service -Name wuauserv
```

#### Permission Errors
The playbook automatically handles required privileges, but verify:
- Ansible user has administrative rights
- Windows Update service is running
- No group policies blocking updates

#### Disk Space Issues
```bash
# Check available space before updates
ansible-playbook playbook.yml --tags connectivity,system_info --ask-vault-pass
```

### Debug Mode
Enable verbose output for troubleshooting:
```bash
# Various debug levels
ansible-playbook playbook.yml -v --ask-vault-pass     # Basic info
ansible-playbook playbook.yml -vvv --ask-vault-pass   # Detailed debug
```

### Log Analysis
Check logs for detailed information:
```bash
# On Ansible control machine
ls -la /tmp/*_updates_*.json

# On Windows targets
Get-Content C:\Logs\ansible_updates.log -Tail 50
```

## 🔒 Security Considerations

### Update Validation
- Test updates in staging environment first
- Review excluded updates list regularly
- Monitor security advisories for critical patches

### Access Control
- Use dedicated service accounts for automation
- Implement least-privilege access principles
- Regularly rotate automation credentials

### Change Management
- Document all update deployment activities
- Maintain rollback procedures
- Schedule updates during approved windows

## 📈 Reporting and Monitoring

### Generated Reports
The playbook creates detailed JSON reports including:
- Available updates summary
- Installation results
- Reboot requirements
- Error details
- Execution timeline

### Report Location
```bash
# Control machine reports
/tmp/{{ inventory_hostname }}_updates_{{ ansible_date_time.epoch }}.json

# Windows machine logs
C:\Logs\ansible_updates.log
```

### Report Analysis
```bash
# View latest report
jq '.' /tmp/WIN-SERVER01_updates_*.json

# Check for failed updates
jq '.failed_updates[]' /tmp/*_updates_*.json
```

## 🤝 Integration with Other Systems

### Monitoring Integration
Export update status to monitoring systems:
```yaml
- name: Send status to monitoring
  uri:
    url: "{{ monitoring_webhook_url }}"
    method: POST
    body_format: json
    body:
      status: "{{ windows_update_status }}"
      updates_count: "{{ windows_updates_found }}"
  when: monitoring_webhook_url is defined
```

### Notification Integration
Send completion notifications:
```yaml
- name: Notify completion
  mail:
    to: "{{ admin_email }}"
    subject: "Windows Updates Completed - {{ inventory_hostname }}"
    body: "Update process completed. {{ windows_updates_installed }} updates installed."
  delegate_to: localhost
```


## ------- French Version -------


# Gestion des Mises à Jour Windows avec Ansible

## Playbooks disponibles

### 1. `test_win_updates.yml` - Playbook de test/démonstration
Contient de nombreux exemples d'utilisation du module `win_updates` pour comprendre les différentes options.

### 2. `manage_windows_updates.yml` - Playbook de production
Playbook structuré pour la gestion des mises à jour en production avec différents modes d'opération.

## Utilisation du playbook de production

### Mode SEARCH (recherche seulement)
```bash
ansible-playbook -i inventories/production/proxmox.yml \
  playbooks/windows/manage_windows_updates.yml \
  --ask-vault-pass \
  -e update_mode=search
```

### Mode DOWNLOAD (téléchargement sans installation)
```bash
ansible-playbook -i inventories/production/proxmox.yml \
  playbooks/windows/manage_windows_updates.yml \
  --ask-vault-pass \
  -e update_mode=download
```

### Mode INSTALL (installation avec redémarrage)
```bash
ansible-playbook -i inventories/production/proxmox.yml \
  playbooks/windows/manage_windows_updates.yml \
  --ask-vault-pass \
  -e update_mode=install \
  -e allow_reboot=true
```

### Mode INSTALL (installation sans redémarrage)
```bash
ansible-playbook -i inventories/production/proxmox.yml \
  playbooks/windows/manage_windows_updates.yml \
  --ask-vault-pass \
  -e update_mode=install \
  -e allow_reboot=false
```

## Variables de configuration

### Variables principales
| Variable | Défaut | Description |
|----------|--------|-------------|
| `update_mode` | `search` | Mode d'opération: `search`, `download`, `install` |
| `allow_reboot` | `false` | Autoriser le redémarrage automatique |
| `reboot_timeout` | `1800` | Timeout pour le redémarrage (secondes) |
| `update_categories` | `[SecurityUpdates, CriticalUpdates]` | Catégories de mises à jour |

### Variables avancées
| Variable | Défaut | Description |
|----------|--------|-------------|
| `updates_to_exclude` | `[]` | Liste de patterns regex pour exclure des mises à jour |
| `specific_updates` | `[]` | Liste de KB spécifiques à installer |
| `update_log_path` | `C:\Logs\ansible_updates.log` | Chemin du fichier de log |

## Exemples d'utilisation avancée

### Installation de mises à jour spécifiques
```bash
ansible-playbook -i inventories/production/proxmox.yml \
  playbooks/windows/manage_windows_updates.yml \
  --ask-vault-pass \
  -e update_mode=install \
  -e "specific_updates=['KB4056892','KB4073117']"
```

### Exclusion de mises à jour
```bash
ansible-playbook -i inventories/production/proxmox.yml \
  playbooks/windows/manage_windows_updates.yml \
  --ask-vault-pass \
  -e update_mode=install \
  -e "updates_to_exclude=['Windows Malicious Software Removal Tool']"
```

### Installation avec catégories personnalisées
```bash
ansible-playbook -i inventories/production/proxmox.yml \
  playbooks/windows/manage_windows_updates.yml \
  --ask-vault-pass \
  -e update_mode=install \
  -e "update_categories=['SecurityUpdates','CriticalUpdates','UpdateRollups']"
```

## Utilisation avec tags

### Exécuter seulement la recherche
```bash
ansible-playbook playbook.yml --tags search
```

### Exécuter seulement le téléchargement
```bash
ansible-playbook playbook.yml --tags download
```

### Exécuter seulement l'installation
```bash
ansible-playbook playbook.yml --tags install
```

### Voir seulement les rapports
```bash
ansible-playbook playbook.yml --tags report
```

### Exclure les affichages debug
```bash
ansible-playbook playbook.yml --skip-tags debug
```

## Bonnes pratiques

### 1. Test en mode search avant installation
Toujours commencer par un `update_mode=search` pour voir quelles mises à jour sont disponibles.

### 2. Téléchargement préalable
Utiliser `update_mode=download` pour télécharger les mises à jour pendant les heures creuses.

### 3. Installation planifiée
Programmer les installations avec `update_mode=install` pendant les fenêtres de maintenance.

### 4. Gestion des redémarrages
- `allow_reboot=false` : Pour contrôler manuellement les redémarrages
- `allow_reboot=true` : Pour les redémarrages automatiques (attention en production)

### 5. Monitoring
- Les rapports sont sauvegardés dans `/tmp/` sur la machine de contrôle
- Les logs sont créés sur chaque machine Windows dans `C:\Logs\`

## Dépannage

### Erreur de connectivité
Le rôle `windows_common` teste automatiquement la connectivité. Vérifiez :
- La résolution DNS
- La connectivité réseau
- Les paramètres SSH/WinRM

### Timeout de mise à jour
Augmentez `reboot_timeout` pour les mises à jour longues :
```bash
-e reboot_timeout=3600  # 1 heure
```

### Problèmes de permissions
Certaines mises à jour peuvent nécessiter des privilèges élevés. Le playbook gère automatiquement les permissions requises.

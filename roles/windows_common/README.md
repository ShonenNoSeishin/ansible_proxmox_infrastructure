# windows_common Role

This role contains common tasks for all Windows playbooks, providing standardized connectivity testing, system information gathering, and network configuration discovery.

## ✨ Features

- **Connectivity Testing**: Verifies connection with `win_ping`
- **System Information Collection**: Retrieves detailed Windows system information
- **Network Information Collection**: Gathers network configuration (optional)
- **Facts Consolidation**: Centralizes all collected information into structured facts

## ⚙️ Variables

### Control Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `windows_common_test_connectivity` | `true` | Enable/disable connectivity testing |
| `windows_common_show_connection_info` | `true` | Enable/disable connection info display |
| `windows_common_collect_system_info` | `true` | Enable/disable system info collection |
| `windows_common_show_system_info` | `true` | Enable/disable system info display |
| `windows_common_collect_network_info` | `false` | Enable/disable network info collection |
| `windows_common_powershell_timeout` | `60` | Timeout for PowerShell commands |

### Configuration Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `windows_common_registry_base_path` | `HKLM:\Software\MyCompany` | Base registry path for operations |

## 🏷️ Available Tags

- `connectivity` - Connectivity testing tasks
- `system_info` - System information collection tasks
- `network_info` - Network information collection tasks
- `facts` - All fact collection tasks
- `debug` - Information display tasks
- `windows_common` - All role tasks

## 📊 Generated Facts

The role creates several Ansible facts:

- **`windows_connectivity_status`** - Connection status ("OK" or "FAILED")
- **`windows_connection_info`** - Detailed connection information
- **`windows_system_info`** - Windows system information
- **`windows_network_info`** - Network information (if enabled)
- **`windows_host_facts`** - Consolidated facts from all collections

## 📖 Usage

### Basic Usage

```yaml
- name: My Windows playbook
  hosts: machines_windows
  roles:
    - windows_common
  tasks:
    - name: My specific tasks
      # ...
```

### Usage with Customization

```yaml
- name: My Windows playbook with options
  hosts: machines_windows
  vars:
    windows_common_collect_network_info: true
    windows_common_show_system_info: false
  roles:
    - windows_common
  tasks:
    - name: Use collected facts
      ansible.builtin.debug:
        var: windows_host_facts
```

### Usage with Tags

```bash
# Run only connectivity testing
ansible-playbook playbook.yml --tags connectivity

# Run only system information collection
ansible-playbook playbook.yml --tags system_info

# Run without debug output
ansible-playbook playbook.yml --skip-tags debug
```

## 💡 Examples

### Connectivity Check Only

```yaml
- name: Connectivity test
  hosts: machines_windows
  vars:
    windows_common_collect_system_info: false
  roles:
    - windows_common
```

### Complete Information Gathering

```yaml
- name: Full audit
  hosts: machines_windows
  vars:
    windows_common_collect_network_info: true
  roles:
    - windows_common
  tasks:
    - name: Save information to file
      ansible.builtin.copy:
        content: "{{ windows_host_facts | to_nice_json }}"
        dest: "/tmp/{{ inventory_hostname }}_facts.json"
      delegate_to: localhost
```

### Conditional System Information

```yaml
- name: Conditional info collection
  hosts: machines_windows
  vars:
    windows_common_collect_network_info: "{{ 'web' in group_names }}"
    windows_common_show_system_info: "{{ ansible_verbosity > 1 }}"
  roles:
    - windows_common
```

## 🔍 Fact Structure

### windows_host_facts Example

```json
{
  "connectivity": {
    "status": "OK",
    "timestamp": "2024-01-15T10:30:00Z",
    "response_time": "0.125s"
  },
  "system": {
    "hostname": "WIN-SERVER01",
    "os_version": "Windows Server 2019",
    "architecture": "x64",
    "total_memory": "16GB",
    "cpu_cores": 4
  },
  "network": {
    "interfaces": [
      {
        "name": "Ethernet",
        "ip_address": "192.168.1.100",
        "subnet_mask": "255.255.255.0"
      }
    ],
    "default_gateway": "192.168.1.1",
    "dns_servers": ["192.168.1.10", "8.8.8.8"]
  }
}
```

## 🛠️ Troubleshooting

### Common Issues

**Connection Failures:**
```bash
# Test with verbose output
ansible-playbook playbook.yml --tags connectivity -vvv

# Check WinRM configuration
ansible windows_host -m ansible.windows.win_command -a "winrm get winrm/config"
```

**PowerShell Timeouts:**
```yaml
# Increase timeout for slow systems
vars:
  windows_common_powershell_timeout: 120
```

**Network Information Collection Fails:**
```yaml
# Disable network collection if causing issues
vars:
  windows_common_collect_network_info: false
```

## 📋 Requirements

- Windows PowerShell 3.0+
- WinRM or SSH connectivity
- Administrative privileges for complete system information
- Network access for connectivity testing

## 🔗 Dependencies

This role has no external dependencies but works best with:
- `windows_base` role for system configuration
- `common` role for cross-platform functionality

## 📝 Notes

- Network information collection can be slow on systems with many interfaces
- Some system information requires administrative privileges
- Facts are cached during playbook execution for performance
- All generated facts are available to subsequent roles and tasks


------ French ------

# Rôle windows_common

Ce rôle contient les tâches communes pour tous les playbooks Windows.

## Fonctionnalités

- **Test de connectivité** : Vérifie la connectivité avec `win_ping`
- **Collecte d'informations système** : Récupère les informations détaillées du système Windows
- **Collecte d'informations réseau** : Récupère les informations réseau (optionnel)
- **Consolidation des faits** : Centralise toutes les informations collectées

## Variables

### Variables de contrôle

| Variable | Défaut | Description |
|----------|--------|-------------|
| `windows_common_test_connectivity` | `true` | Active/désactive le test de connectivité |
| `windows_common_show_connection_info` | `true` | Active/désactive l'affichage des infos de connexion |
| `windows_common_collect_system_info` | `true` | Active/désactive la collecte d'infos système |
| `windows_common_show_system_info` | `true` | Active/désactive l'affichage des infos système |
| `windows_common_collect_network_info` | `false` | Active/désactive la collecte d'infos réseau |
| `windows_common_powershell_timeout` | `60` | Timeout pour les commandes PowerShell |

### Variables de configuration

| Variable | Défaut | Description |
|----------|--------|-------------|
| `windows_common_registry_base_path` | `HKLM:\Software\MyCompany` | Chemin de base du registre |

## Tags disponibles

- `connectivity` : Tâches de test de connectivité
- `system_info` : Tâches de collecte d'informations système
- `network_info` : Tâches de collecte d'informations réseau
- `facts` : Toutes les tâches de collecte de faits
- `debug` : Tâches d'affichage des informations
- `windows_common` : Toutes les tâches du rôle

## Faits créés

Le rôle crée plusieurs faits Ansible :

- `windows_connectivity_status` : Status de la connectivité ("OK" ou "FAILED")
- `windows_connection_info` : Informations de connexion détaillées
- `windows_system_info` : Informations système Windows
- `windows_network_info` : Informations réseau (si activé)
- `windows_host_facts` : Consolidation de tous les faits

## Utilisation

### Usage basique

```yaml
- name: Mon playbook Windows
  hosts: machines_windows
  roles:
    - windows_common
  tasks:
    - name: Mes tâches spécifiques
      # ...
```

### Usage avec personnalisation

```yaml
- name: Mon playbook Windows avec options
  hosts: machines_windows
  vars:
    windows_common_collect_network_info: true
    windows_common_show_system_info: false
  roles:
    - windows_common
  tasks:
    - name: Utiliser les faits collectés
      ansible.builtin.debug:
        var: windows_host_facts
```

### Usage avec tags

```bash
# Exécuter seulement la connectivité
ansible-playbook playbook.yml --tags connectivity

# Exécuter seulement la collecte d'infos système
ansible-playbook playbook.yml --tags system_info

# Exécuter sans les affichages debug
ansible-playbook playbook.yml --skip-tags debug
```

## Exemples

### Vérifier la connectivité uniquement

```yaml
- name: Test de connectivité
  hosts: machines_windows
  vars:
    windows_common_collect_system_info: false
  roles:
    - windows_common
```

### Collecte complète d'informations

```yaml
- name: Audit complet
  hosts: machines_windows
  vars:
    windows_common_collect_network_info: true
  roles:
    - windows_common
  tasks:
    - name: Sauvegarder les informations
      ansible.builtin.copy:
        content: "{{ windows_host_facts | to_nice_json }}"
        dest: "/tmp/{{ inventory_hostname }}_facts.json"
      delegate_to: localhost
```

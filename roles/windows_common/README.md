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

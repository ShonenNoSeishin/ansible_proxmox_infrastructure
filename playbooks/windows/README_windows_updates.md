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

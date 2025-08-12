# Quick Setup Guide

This guide will help you quickly set up this Ansible infrastructure from scratch.

## 🚀 Prerequisites

### Install Required Tools

```bash
# Install GitHub CLI (Debian/Ubuntu)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh git ansible

# Verify installations
gh --version
git --version
ansible --version
```

## 🔧 Configuration

### 1. Proxmox API Setup

1. **Create API Token in Proxmox**:
   - Go to Datacenter → Permissions → API Tokens
   - Click "Add"
   - User: `ansible-user@pve`
   - Token ID: `ansible`
   - Save the generated secret

2. **Set Permissions**:
   - Go to Datacenter → Permissions
   - Add permission for `ansible-user@pve`
   - Path: `/`
   - Role: `PVEAuditor` (minimum) or `Administrator`

3. **Update Vault**:
   ```bash
   ansible-vault edit inventories/production/group_vars/all/vault.yml
   ```
   
   Add your Proxmox credentials:
   ```yaml
   vault_PVE_TOKEN_USER: "ansible-user@pve"
   vault_PVE_TOKEN_ID: "ansible"
   vault_PVE_TOKEN_SECRET: "your-secret-here"
   ```

### 2. Update Proxmox URL

Edit `inventories/production/proxmox.yml` and update the URL:
```yaml
url: 'https://your-proxmox-server:8006'
```

## 🧪 Testing

### 1. Test Inventory

```bash
ansible-inventory -i inventories/production/proxmox.yml --list --ask-vault-pass
```

### 2. Test Connectivity

```bash
# Windows systems
ansible machines_windows -m ansible.windows.win_ping --ask-vault-pass

# Linux systems
ansible machines_linux -m ping --ask-vault-pass
```

### 3. Run Health Check

```bash
ansible-playbook playbooks/common/health_check.yml --ask-vault-pass
```

## 📚 Common Commands

```bash
# List all hosts
ansible-inventory --list --ask-vault-pass

# Check specific group
ansible-inventory --graph machines_windows --ask-vault-pass

# Run Windows playbook
ansible-playbook playbooks/windows/test_windows_common.yml --ask-vault-pass

# View vault contents
ansible-vault view inventories/production/group_vars/all/vault.yml

# Edit vault
ansible-vault edit inventories/production/group_vars/all/vault.yml
```

## 🔒 Security Checklist

- [ ] All vault files are encrypted
- [ ] Strong vault passwords are used
- [ ] Vault passwords are stored securely
- [ ] `.gitignore` is properly configured
- [ ] No sensitive data in plain text files
- [ ] Repository permissions are set correctly

## 🆘 Troubleshooting

### Common Issues

1. **Proxmox Connection Failed**:
   - Check URL in `proxmox.yml`
   - Verify API token permissions
   - Test with: `curl -k https://your-proxmox:8006/api2/json/version`

2. **Vault Errors**:
   - Ensure vault files are properly encrypted
   - Check vault password
   - Verify file permissions

3. **SSH/WinRM Issues**:
   - Check network connectivity
   - Verify credentials in vault files
   - Test manual connections first

### Debug Mode

Add `-vvv` for verbose output:
```bash
ansible-playbook playbook.yml -vvv --ask-vault-pass
```

## 📖 Next Steps

1. **Customize Variables**: Edit `group_vars` files for your environment
2. **Add Hosts**: Configure individual hosts in `host_vars`
3. **Create Playbooks**: Build your automation workflows
4. **Set Up CI/CD**: Integrate with your deployment pipeline

For detailed information, see the main [README.md](README.md).

#!/bin/bash

# GitHub Repository Setup Script
# This script helps you connect to GitHub CLI and create a new repository

set -e

echo "==================== GitHub Repository Setup ===================="
echo "This script will help you set up this Ansible infrastructure"
echo "repository on GitHub using the GitHub CLI (gh)."
echo "=================================================================="
echo

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed."
    echo
    echo "To install GitHub CLI:"
    echo
    echo "On Debian/Ubuntu:"
    echo "  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg"
    echo "  echo \"deb [arch=\$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main\" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null"
    echo "  sudo apt update"
    echo "  sudo apt install gh"
    echo
    echo "On other systems, visit: https://cli.github.com/manual/installation"
    echo
    exit 1
fi

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed. Please install git first."
    exit 1
fi

echo "✅ Prerequisites check passed"
echo

# Check if user is authenticated with GitHub CLI
if ! gh auth status &> /dev/null; then
    echo "🔑 You need to authenticate with GitHub first."
    echo
    read -p "Do you want to authenticate now? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Starting GitHub authentication..."
        gh auth login
    else
        echo "❌ GitHub authentication is required. Exiting..."
        exit 1
    fi
else
    echo "✅ Already authenticated with GitHub"
    gh auth status
fi

echo

# Get repository details
echo "📝 Repository Configuration"
echo "==========================="

# Get current directory name as default repo name
current_dir=$(basename "$(pwd)")
read -p "Repository name [$current_dir]: " repo_name
repo_name=${repo_name:-$current_dir}

read -p "Repository description [Ansible infrastructure for multi-platform automation]: " repo_description
repo_description=${repo_description:-"Ansible infrastructure for multi-platform automation"}

echo
echo "Repository visibility:"
echo "  1) Private (recommended for infrastructure code)"
echo "  2) Public"
read -p "Choose visibility (1/2) [1]: " -n 1 -r visibility_choice
echo
visibility_choice=${visibility_choice:-1}

if [ "$visibility_choice" = "1" ]; then
    visibility_flag="--private"
    visibility_text="private"
else
    visibility_flag="--public"
    visibility_text="public"
fi

echo
echo "Configuration Summary:"
echo "====================="
echo "Repository name: $repo_name"
echo "Description: $repo_description"
echo "Visibility: $visibility_text"
echo "Current directory: $(pwd)"
echo

read -p "Proceed with repository creation? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Repository creation cancelled."
    exit 0
fi

echo
echo "🚀 Setting up the repository..."

# Initialize git repository if not already initialized
if [ ! -d ".git" ]; then
    echo "📁 Initializing git repository..."
    git init
    echo "✅ Git repository initialized"
else
    echo "✅ Git repository already exists"
fi

# Check if we have any vault files that should not be committed
echo "🔒 Checking for unencrypted vault files..."
unencrypted_vaults=$(find . -name "vault.yml" -not -path "./.git/*" 2>/dev/null || true)

if [ -n "$unencrypted_vaults" ]; then
    echo "⚠️  WARNING: Found unencrypted vault files:"
    echo "$unencrypted_vaults"
    echo
    echo "These files contain sensitive information and should be encrypted"
    echo "before committing to the repository."
    echo
    read -p "Do you want to continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Please encrypt your vault files first using:"
        echo "   ansible-vault encrypt <vault-file>"
        echo "   or copy from examples and encrypt manually"
        exit 1
    fi
fi

# Add files to git
echo "📦 Adding files to git..."
git add .

# Check if there are any changes to commit
if git diff --staged --quiet; then
    echo "ℹ️  No changes to commit (repository may already be up to date)"
else
    # Create initial commit
    echo "💾 Creating initial commit..."
    git commit -m "Initial Ansible infrastructure setup

- Dynamic Proxmox inventory integration
- Multi-platform support (Windows, Linux, 3CX)
- Secure vault management with examples
- Reusable roles and organized playbooks
- Comprehensive documentation and setup scripts"
    echo "✅ Initial commit created"
fi

# Create GitHub repository
echo "🌐 Creating GitHub repository..."
gh repo create "$repo_name" \
    --description "$repo_description" \
    $visibility_flag \
    --source=. \
    --push

if [ $? -eq 0 ]; then
    echo "✅ Repository created successfully!"
    echo
    echo "🎉 Your Ansible infrastructure repository is now available at:"
    echo "   https://github.com/$(gh api user --jq .login)/$repo_name"
    echo
    echo "📚 Next steps:"
    echo "1. Clone the repository on other systems:"
    echo "   git clone https://github.com/$(gh api user --jq .login)/$repo_name.git"
    echo
    echo "2. Create vault files from examples:"
    echo "   cp inventories/production/group_vars/all/vault.yml.example \\"
    echo "      inventories/production/group_vars/all/vault.yml"
    echo "   nano inventories/production/group_vars/all/vault.yml  # Edit with real credentials"
    echo "   ansible-vault encrypt inventories/production/group_vars/all/vault.yml"
    echo
    echo "3. Configure your Proxmox credentials in the vault files"
    echo
    echo "4. Test your setup:"
    echo "   ansible-inventory -i inventories/production/proxmox.yml --list --ask-vault-pass"
    echo
    echo "🔒 Security reminder:"
    echo "   - Never commit unencrypted vault files"
    echo "   - Use strong vault passwords"
    echo "   - Store vault passwords securely"
    echo "   - Regularly rotate credentials"
else
    echo "❌ Failed to create GitHub repository"
    exit 1
fi

echo
echo "==================== Setup Complete ===================="

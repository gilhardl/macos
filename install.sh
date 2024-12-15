#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Dotfiles directory
DOTFILES_DIR="$HOME/.dotfiles"

# List of dotfiles to symlink in $HOME (will be populated by download_dotfiles)
dotfiles=

# Installation paths
HOMEBREW_DIR="/opt/homebrew"
OMZ_DIR="$HOME/.oh-my-zsh"
ASDF_DIR="$HOME/.asdf"


BREW_BINARY="$HOMEBREW_DIR/bin/brew"
MAS_BINARY="$HOMEBREW_DIR/bin/mas"
ASDF_BINARY="$ASDF_DIR/asdf.sh"

# List of applications to install from the Mac App Store
# Format: "App Name:AppID:/Application Path" 
# 
# Find the app in the Mac App Store then get the App ID from the share URL
# Example: https://apps.apple.com/us/app/xcode/id497799835?mt=12
# => App ID: 497799835
# => Application Path: /Applications/Xcode.app
mas_apps=(
    "XCode:497799835:/Applications/Xcode.app"
)

# List of applications to install from Homebrew
# Format: "App Name:homebrew-cask-name:/Application Path"
# 
# Find the app in the Homebrew Cask repository
# Example: https://formulae.brew.sh/cask/docker
# => Cask Name: docker
# => Application Path: /Applications/Docker.app
brew_apps=(
    "Docker:docker:/Applications/Docker.app"
    "VSCode:visual-studio-code:/Applications/Visual Studio Code.app"
    "Chrome:google-chrome:/Applications/Google Chrome.app"
    "Postman:postman:/Applications/Postman.app"
    "Bitwarden:bitwarden:/Applications/Bitwarden.app" 
    "Figma:figma:/Applications/Figma.app"
    "Spotify:spotify:/Applications/Spotify.app"
)

#region: Utility functions

print() {
    if [[ $2 = "info" ]]; then
        echo -e "${BLUE}$1${NC}"
    elif [[ $2 = "success" ]]; then
        echo -e "${GREEN}$1${NC}"
    elif [[ $2 = "warning" ]]; then
        echo -e "${YELLOW}$1${NC}"
    elif [[ $2 = "error" ]]; then
        echo -e "${RED}$1${NC}"
    else
        echo -e "${NC}$1${NC}"
    fi
}

download_dotfiles() {
    if [[ -d "$DOTFILES_DIR" ]]; then
        print "\tDotfiles already downloaded, updating..." "info"
        cd "$DOTFILES_DIR"
        git pull
        cd -
        print "\tDotfiles updated" "success"
    else
        print "\tDownloading dotfiles..." "info"
        git clone https://github.com/gilhardl/dotfiles.git "$DOTFILES_DIR" --quiet
        print "\tDotfiles downloaded" "success"
    fi

    dotfiles=$(ls -a "$DOTFILES_DIR" | grep -E "^\.[^.]" | tr '\n' ' ')
}

backup_dotfiles() {
    print "\tBacking up existing dotfiles..." "info"
    local backup_dir="$DOTFILES_DIR/backup/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"

    # Backup existing dotfiles
    for file in $dotfiles; do
        if [[ -f "$HOME/$file" ]] || [[ -L "$HOME/$file" ]]; then
            mv "$HOME/$file" "$backup_dir/"
        fi
    done

    print "\tBackup completed" "success"
}

symlink_dotfiles() {
    print "\tCreating dotfiles symlinks..." "info"
    for file in $dotfiles; do
        ln -s "$DOTFILES_DIR/$file" "$HOME/$file"
    done
    print "\tDotfiles symlinks created" "success"
}

install_homebrew() {
    if [[ ! -f "$BREW_BINARY" ]]; then
        print "\tInstalling Homebrew..." "info"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        print "\tHomebrew installed" "success"
    else
        print "\tHomebrew already installed" "success"
    fi
}

upgrade_homebrew_packages() {
    if [[ -f "$BREW_BINARY" ]]; then
        print "\tUpdating Homebrew packages repository..." "info"
        "$BREW_BINARY" update
        print "\tHomebrew repository updated" "success"

        print "\tUpgrading Homebrew packages..." "info"
        "$BREW_BINARY" upgrade
        print "\tHomebrew packages upgraded" "success"
    else
        print "\tHomebrew not installed" "error"
    fi
}

install_mas() {
    if [[ ! -f "$BREW_BINARY" ]]; then
        print "\tHomebrew not installed" "error"
        return
    fi

    if [[ ! -f "$MAS_BINARY" ]]; then
        print "\tInstalling Mac App Store CLI..." "info"
        "$BREW_BINARY" install mas
        print "\tMac App Store CLI installed" "success"
    else
        print "\tMac App Store CLI already installed" "success"
    fi
}

upgrade_mas_apps() {
    if [[ -f "$MAS_BINARY" ]]; then
        print "\tUpgrading Mac App Store applications..." "info"
        "$MAS_BINARY" upgrade
        print "\tMac App Store applications upgraded" "success"
    else
        print "\tMac App Store CLI not installed" "error"
    fi
}

install_oh_my_zsh() {
    if [[ ! -d "$OMZ_DIR" ]]; then
        print "\tInstalling Oh My Zsh..." "info"
        RUNZSH=no KEEP_ZSHRC=yes /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/HEAD/tools/install.sh)"
        print "\tOh My Zsh installed" "success"
    else
        print "\tOh My Zsh already installed" "success"
    fi
}

install_oh_my_zsh_plugins() {
    print "\tInstalling Oh My Zsh plugins..." "info"

    local autosuggestions_plugin_dir="$OMZ_DIR/custom/plugins/zsh-autosuggestions"

    # Install zsh-autosuggestions
    if [[ ! -d "$autosuggestions_plugin_dir" ]]; then
        print "\t\tInstalling zsh-autosuggestions plugin..." "info"
        git clone https://github.com/zsh-users/zsh-autosuggestions.git "$autosuggestions_plugin_dir" --quiet
        print "\t\tzsh-autosuggestions plugin installed" "success"
    else
        print "\t\tzsh-autosuggestions plugin already installed" "success"
    fi

    print "\tOh My Zsh plugins installed" "success"
}

install_asdf() {
    if [[ ! -d "$ASDF_DIR" ]]; then
        print "\tInstalling asdf..." "info"
        git clone https://github.com/asdf-vm/asdf.git "$ASDF_DIR" --branch v0.14.1 --quiet
        source $ASDF_DIR/asdf.sh
        print "\tasdf installed" "success"
    else
        print "\tasdf already installed" "success"
    fi
}

install_asdf_tools() {
    print "\tInstalling asdf tools..." "info"    

    # Add nodejs plugin if not already added
    if ! asdf plugin list | grep -q nodejs; then
        print "\t\tInstalling nodejs plugin..." "info"
        asdf plugin add nodejs
        print "\t\tnodejs plugin installed" "success"
    else
        print "\t\tnodejs plugin already installed" "success"
    fi

    asdf install
    print "\tasdf tools installed" "success"
}

# apps: List of applications to install from the Mac App Store
#   Format: "App Name:AppID:/Application Path" 
# 
# Find the app in the Mac App Store then get the App ID from the share URL
# Example: https://apps.apple.com/us/app/xcode/id497799835?mt=12
# => App ID: 497799835
# => Application Path: /Applications/Xcode.app
install_mas_apps() {
    local apps=("$@")

    if [[ ! -f "$MAS_BINARY" ]]; then
        print "\tMac App Store CLI not installed" "error"
        return
    fi

    print "\tInstalling Mac App Store applications..." "info"
    for app in "${apps[@]}"; do
        # Read the app name, app ID and app path from the apps array
        IFS=':' read -r app_name app_id app_path <<< "$app"

        # Install the app if it's not already installed
        if [[ ! -e "$app_path" ]] || ! open -Ra "$app_path" &> /dev/null; then
            print "\t\tInstalling $app_name..." "info"
            "$MAS_BINARY" install "$app_id"
            print "\t\t$app_name installed with Mac App Store" "success"
        else
            print "\t\t$app_name already installed" "info"
        fi
    done

    print "\tMac App Store applications installed" "success"
}

# apps: List of applications to install from Homebrew
#   Format: "App Name:homebrew-cask-name:/Application Path"
# 
# Find the app in the Homebrew Cask repository
# Example: https://formulae.brew.sh/cask/docker
# => Cask Name: docker
# => Application Path: /Applications/Docker.app
install_brew_apps() {
    local apps=("$@")

    if [[ ! -f "$BREW_BINARY" ]]; then
        print "\tHomebrew not installed" "error"
        return
    fi

    print "\tInstalling Homebrew applications..." "info"

    for app in "${apps[@]}"; do
        # Read the app name, cask name and app path from the brew_apps array
        IFS=':' read -r app_name cask_name app_path <<< "$app"

        # Install the app if it's not already installed
        if [[ ! -e "$app_path" ]] || ! open -Ra "$app_path" &> /dev/null; then
            print "\t\tInstalling $app_name..." "info"
            "$BREW_BINARY" install --cask "$cask_name"
            print "\t\t$app_name installed with Homebrew" "success"
        else
            print "\t\t$app_name already installed" "info"
        fi
    done

    print "\tHomebrew applications installed" "success"
}

#endregion

#region: Installation steps
setup_dotfiles() {
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/gilhardl/dotfiles/main/install.sh)"
}

install_packages_managers() {
    print "Installing packages managers..." "info"
    install_homebrew
    install_mas
    print "Packages managers installed\n" "success"
}

upgrade_packages() {
    print "Upgrading packages..." "info"
    upgrade_mas_apps
    upgrade_homebrew_packages
    print "Packages upgraded\n" "success"
}

install_shell_environment() {
    print "Installing shell environment..." "info"
    install_oh_my_zsh
    install_oh_my_zsh_plugins
    print "Shell environment installed\n" "success"
}

install_dev_environment() {
    print "Installing dev environment..." "info"
    install_asdf
    install_asdf_tools
    print "Dev environment installed\n" "success"
}

install_apps() {
    print "Installing applications..." "info"
    install_mas_apps "${mas_apps[@]}"
    install_brew_apps "${brew_apps[@]}"
    print "Applications installed\n" "success"
}

#endregion

# Main installation
main() {
    print "Starting installation...\n" "info"

    setup_dotfiles
    install_packages_managers
    upgrade_packages
    install_shell_environment
    install_dev_environment
    install_apps

    print "Installation completed successfully!\n" "success"
    print "Please restart your terminal for changes to take effect." "warning"
}

# Run main installation
main
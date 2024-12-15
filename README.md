# MacOS setup

This repository contains my personal, opinionated MacOS system configuration and applications. It includes an automated installation script that I use for fresh MacOS installations to configure:
- dotfiles
- packages managers
- shell environment
- dev environment
- applications

## Requirements

- MacOS 14.0+ Sonoma

## Installation

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/gilhardl/macos/main/install.sh)"
```

The install script will:
1. Setup [dotfiles](#dotfiles)
2. Install and setup [packages management](#packages-management)
3. Upgrade existing packages and applications
4. Install and configure [shell environment](#shell-environment)
5. Install [dev environment](#dev-environment)
6. Install [applications](#applications)

## What's Inside

### Dotfiles

See [gilhardl/dotfiles](https://github.com/gilhardl/dotfiles)

### Packages management

- Homebrew
- Mac App Store CLI

### Shell environment

- Oh My Zsh
  - zsh-autosuggestions

### Dev environment

- asdf
  - Node

### Applications

- Xcode
- Docker
- VSCode
- Chrome
- Bitwarden
- Figma
- Spotify

### Custom scripts

- `install.sh` - Installation script

## Customization

You can customize the installation by forking this repo and editing the `install.sh` script to your liking. Then you can run the `install.sh` script by replacing the `https://raw.githubusercontent.com/gilhardl/macos/main/install.sh` with your fork url.

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/<your-username>/macos/main/install.sh)"
```

## License

This project is open-sourced under the [MIT License](LICENSE).

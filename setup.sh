#!/usr/bin/env bash

print() {
  local message="$1"
  local GREEN='\033[0;32m'
  local NC='\033[0m'

  printf "%b%s%b\n" "$GREEN" "$message" "$NC"
}

# packages not in standard dnf
if ! command -v lazygit &>/dev/null; then
  print "lazygit not found. Installing..."
  sudo dnf copr enable dejan/lazygit -y
  sudo dnf install lazygit -y
fi

if ! command -v ghostty &>/dev/null; then
  print "ghostty not found. Installing..."
  sudo dnf copr enable scottames/ghostty -y
  sudo dnf install ghostty -y
fi

if ! command -v brave-browser &>/dev/null; then
  print "brave-browser not found. Installing..."
  sudo dnf install dnf-plugins-core
  sudo dnf config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo -y
  sudo dnf install brave-browser -y
fi

if ! command -v zellij &>/dev/null; then
  print "zellij not found. Installing..."
  sudo dnf copr enable varlad/zellij -y
  sudo dnf install zellij -y
fi

if ! command -v docker &>/dev/null; then
  print "docker not found. Installing..."
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh ./get-docker.sh
  sudo rm get-docker.sh
  sudo groupadd docker
  sudo usermod -aG docker "$USER"
  newgrp docker
  sudo systemctl enable --now docker.service
  sudo systemctl enable --now containerd.service
fi

if ! command -v devpod &>/dev/null; then
  print "devpod not found. Installing..."
  curl -L -o devpod "https://github.com/loft-sh/devpod/releases/latest/download/devpod-linux-amd64" && sudo install -c -m 0755 devpod /usr/local/bin && rm -f devpod
fi

if ! command -v nix &>/dev/null; then
  print "nix not found. Installing..."
  curl -fsSL https://install.determinate.systems/nix | sh -s -- install
fi

#install nerdfonts
if ! fc-list | grep -qi "JetBrainsMono Nerd Font"; then
  print "JetBrainsMono Nerd Font not found. Installing..."
  mkdir -p ~/.local/share/fonts
  curl -L -o ~/.local/share/fonts/JetBrainsMono.zip \
    https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip
  unzip -o ~/.local/share/fonts/JetBrainsMono.zip -d ~/.local/share/fonts
  rm ~/.local/share/fonts/JetBrainsMono.zip
  fc-cache -fv
fi

if ! sudo dnf group list --installed | grep -qi "Development Tools"; then
  print "Development Tools group not found. Installing..."
  sudo dnf group install "Development Tools" -y
fi

# Install dnf packages
print "Installing packages"
sudo xargs dnf install -y <dnf-packages.txt

# Check if default shell is fish; if not, set it as default
current_shell=$(basename "$SHELL")

if [[ "$current_shell" != "fish" ]]; then
  if command -v fish &>/dev/null; then
    print "Changing default shell to fish..."
    chsh -s "$(command -v fish)"
    print "Default shell changed to fish. Please log out and back in for changes to take effect."
  else
    print "Fish shell is not installed. Please install fish first."
  fi
fi

print "Stowing dotfiles"
stow .

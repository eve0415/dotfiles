#!/usr/bin/env bash
set -euo pipefail

# =========================
# Dotfiles tool installer
# =========================
# Installs all required tools referenced in this dotfiles repo.
# Excludes: git, zsh, and other default system tools.
#
# Usage:
#   ./install.sh          # Install everything
#   ./install.sh --check  # Dry-run: show what's missing

CHECK_ONLY=false
[[ "${1:-}" == "--check" ]] && CHECK_ONLY=true

# ---- Colors ----
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[0;33m'
BLUE=$'\033[0;34m'
RESET=$'\033[0m'

info()    { printf "${BLUE}[info]${RESET}  %s\n" "$*"; }
success() { printf "${GREEN}[ok]${RESET}    %s\n" "$*"; }
warn()    { printf "${YELLOW}[skip]${RESET}  %s\n" "$*"; }
err()     { printf "${RED}[err]${RESET}   %s\n" "$*"; }

# ---- OS detection ----
OS="$(uname -s)"
ARCH="$(uname -m)"

if [[ "$OS" != "Darwin" && "$OS" != "Linux" ]]; then
  err "Unsupported OS: $OS"
  exit 1
fi

# =========================
# 1. Homebrew
# =========================
install_homebrew() {
  if command -v brew &>/dev/null; then
    success "Homebrew already installed"
    return
  fi
  if $CHECK_ONLY; then warn "Homebrew is not installed"; return; fi

  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add to PATH for the rest of this script
  if [[ "$OS" == "Darwin" && "$ARCH" == "arm64" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ "$OS" == "Darwin" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  else
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
  success "Homebrew installed"
}

# =========================
# 2. Homebrew packages
# =========================
BREW_PACKAGES=(
  # Terminal multiplexer
  tmux

  # Modern CLI tools
  fzf        # Fuzzy finder
  fd         # Fast find alternative (used by fzf config)
  neovim     # Text editor

  # Shell plugins
  zsh-autosuggestions
  zsh-syntax-highlighting
)

install_brew_packages() {
  if ! command -v brew &>/dev/null; then
    err "Homebrew not found -- cannot install packages"
    return 1
  fi

  info "Checking Homebrew packages..."
  local missing=()

  for pkg in "${BREW_PACKAGES[@]}"; do
    if brew list "$pkg" &>/dev/null; then
      success "$pkg"
    else
      missing+=("$pkg")
      if $CHECK_ONLY; then warn "$pkg is not installed"; fi
    fi
  done

  if $CHECK_ONLY; then return; fi

  if [[ ${#missing[@]} -gt 0 ]]; then
    info "Installing missing packages: ${missing[*]}"
    brew install "${missing[@]}"
    success "All Homebrew packages installed"
  else
    success "All Homebrew packages already installed"
  fi
}

# =========================
# 3. Git Credential Manager
# =========================
install_gcm() {
  if command -v git-credential-manager &>/dev/null; then
    success "Git Credential Manager"
    return
  fi
  if $CHECK_ONLY; then warn "Git Credential Manager is not installed"; return; fi

  info "Installing Git Credential Manager..."
  if [[ "$OS" == "Darwin" ]]; then
    brew install --cask git-credential-manager
  else
    # Linux: install from .deb or brew
    brew install git-credential-manager
  fi
  success "Git Credential Manager installed"
}

# =========================
# 4. WezTerm
# =========================
install_wezterm() {
  if command -v wezterm &>/dev/null; then
    success "WezTerm"
    return
  fi
  if $CHECK_ONLY; then warn "WezTerm is not installed"; return; fi

  info "Installing WezTerm..."
  if [[ "$OS" == "Darwin" ]]; then
    brew install --cask wezterm
  else
    # Linux: flatpak or manual install
    brew install --cask wezterm 2>/dev/null || {
      warn "WezTerm cask not available on Linux -- install manually from https://wezfurlong.org/wezterm/"
    }
  fi
  success "WezTerm installed"
}

# =========================
# 5. JetBrains Mono font
# =========================
install_font() {
  local font_found=false

  if [[ "$OS" == "Darwin" ]]; then
    # Check macOS font directories
    if fc-list 2>/dev/null | grep -qi "JetBrains Mono" || \
       ls ~/Library/Fonts/*JetBrains*Mono* &>/dev/null 2>&1 || \
       ls /Library/Fonts/*JetBrains*Mono* &>/dev/null 2>&1; then
      font_found=true
    fi
  else
    if fc-list 2>/dev/null | grep -qi "JetBrains Mono"; then
      font_found=true
    fi
  fi

  if $font_found; then
    success "JetBrains Mono font"
    return
  fi
  if $CHECK_ONLY; then warn "JetBrains Mono font is not installed"; return; fi

  info "Installing JetBrains Mono font..."
  brew install --cask font-jetbrains-mono
  success "JetBrains Mono font installed"
}

# =========================
# 6. fzf keybindings & completion
# =========================
setup_fzf() {
  if [[ -f ~/.fzf.zsh ]]; then
    success "fzf shell integration"
    return
  fi
  if $CHECK_ONLY; then warn "fzf shell integration not set up"; return; fi

  info "Setting up fzf keybindings and completion..."
  if command -v fzf &>/dev/null; then
    "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish
    success "fzf shell integration configured"
  else
    warn "fzf not found -- skipping shell integration"
  fi
}

# =========================
# Summary
# =========================
print_summary() {
  echo ""
  printf "${BLUE}========================================${RESET}\n"
  if $CHECK_ONLY; then
    printf "${BLUE}  Dotfiles dependency check complete${RESET}\n"
  else
    printf "${BLUE}  Installation complete!${RESET}\n"
  fi
  printf "${BLUE}========================================${RESET}\n"
  echo ""

  if ! $CHECK_ONLY; then
    info "Next steps:"
    echo "  1. Symlink dotfiles to their target locations"
    echo "  2. Open Neovim -- lazy.nvim will auto-install plugins"
    echo "  3. Restart your shell to pick up zsh plugin changes"
    echo ""
  fi
}

# =========================
# Main
# =========================
main() {
  echo ""
  if $CHECK_ONLY; then
    printf "${BLUE}Checking dotfiles dependencies...${RESET}\n"
  else
    printf "${BLUE}Installing dotfiles dependencies...${RESET}\n"
  fi
  echo ""

  install_homebrew
  install_brew_packages
  install_gcm
  install_wezterm
  install_font
  setup_fzf
  print_summary
}

main

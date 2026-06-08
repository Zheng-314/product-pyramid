#!/usr/bin/env bash
set -e

REPO_URL="https://github.com/Zheng-314/product-pyramid.git"
SKILL_NAME="product-pyramid"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; exit 1; }

# Detect OS
detect_os() {
  case "$(uname -s)" in
    Linux*)     OS="linux";;
    Darwin*)    OS="macos";;
    CYGWIN*|MINGW*|MSYS*) OS="windows";;
    *)          error "Unsupported OS: $(uname -s)";;
  esac
}

# Get home directory (cross-platform)
get_home() {
  if [ "$OS" = "windows" ]; then
    echo "${USERPROFILE:-$HOME}"
  else
    echo "$HOME"
  fi
}

# Install to a specific agent's skill directory
install_to_agent() {
  local agent_name="$1"
  local skill_dir="$2"

  if [ -d "$skill_dir/$SKILL_NAME" ]; then
    warn "$agent_name: $SKILL_NAME already exists, updating..."
    cd "$skill_dir/$SKILL_NAME" && git pull --quiet 2>/dev/null || true
  else
    mkdir -p "$skill_dir"
    git clone --quiet --depth 1 "$REPO_URL" "$skill_dir/$SKILL_NAME"
  fi
  info "$agent_name: installed to $skill_dir/$SKILL_NAME"
}

# Detect available agents and install
install_all() {
  local HOME_DIR
  HOME_DIR="$(get_home)"
  local installed=0

  echo ""
  echo "=== Product Pyramid Installer ==="
  echo ""

  # Claude Code
  if [ -d "$HOME_DIR/.claude" ]; then
    install_to_agent "Claude Code" "$HOME_DIR/.claude/skills"
    installed=$((installed + 1))
  fi

  # Codex
  if [ -d "$HOME_DIR/.codex" ]; then
    install_to_agent "Codex" "$HOME_DIR/.codex/skills"
    installed=$((installed + 1))
  fi

  # Cursor
  if [ -d "$HOME_DIR/.cursor" ]; then
    install_to_agent "Cursor" "$HOME_DIR/.cursor/skills-cursor"
    installed=$((installed + 1))
  fi

  if [ $installed -eq 0 ]; then
    error "No supported agents found. Install Claude Code, Codex, or Cursor first."
  fi

  echo ""
  info "Done! Installed to $installed agent(s)."
  echo ""
  echo "Usage:"
  echo "  Claude Code:  /product-pyramid"
  echo "  Codex:        /product-pyramid"
  echo "  Cursor:       /product-pyramid"
  echo ""
}

detect_os
install_all

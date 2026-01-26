#!/usr/bin/env bash
set -euo pipefail

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check uv
check_uv() {
    if ! command -v uv &> /dev/null; then
        error "uv is not installed"
        echo ""
        echo "Please install uv first:"
        echo "  curl -LsSf https://astral.sh/uv/install.sh | sh"
        echo ""
        return 1
    fi
    info "uv installed: $(uv --version | head -1)"
    return 0
}

# Check Node.js version
check_node() {
    if ! command -v node &> /dev/null; then
        error "Node.js is not installed"
        echo ""
        echo "Please install Node.js >= 20:"
        echo "  https://nodejs.org/"
        echo ""
        return 1
    fi

    local version
    version=$(node --version | sed 's/v//')
    local major
    major=$(echo "$version" | cut -d. -f1)

    if [ "$major" -lt 20 ]; then
        error "Node.js version too old: v$version (requires >= 20)"
        return 1
    fi

    info "Node.js installed: v$version"
    return 0
}

# Install fwauto
install_fwauto() {
    info "Installing fwauto (this may take a while)..."

    uv tool install --quiet --force --prerelease=allow fwauto

    info "fwauto installation complete"
}

# Check and install npm tool
install_npm_tool() {
    local cmd="$1"
    local package="$2"

    if command -v "$cmd" &> /dev/null; then
        info "$cmd installed: $($cmd --version 2>/dev/null | head -1)"
        return 0
    fi

    npm install -g --silent "$package"
}

# Install all AI tools
install_ai_tools() {
    echo ""
    info "Installing AI CLI tools (this may take a while)..."
    echo ""

    install_npm_tool "claude" "@anthropic-ai/claude-code"
    # install_npm_tool "gemini" "@google/gemini-cli"
    # install_npm_tool "codex" "@openai/codex"
}

# Main
main() {
    echo "=========================================="
    echo "  FWAuto Installation Script"
    echo "=========================================="
    echo ""

    info "Checking environment..."
    echo ""

    local has_error=0

    check_uv || has_error=1
    check_node || has_error=1

    if [ "$has_error" -eq 1 ]; then
        echo ""
        error "Environment check failed, please install missing tools first"
        exit 1
    fi

    echo ""
    info "Environment check passed!"

    # Install fwauto
    echo ""
    install_fwauto

    # Install AI tools
    install_ai_tools

    echo ""
    echo "=========================================="
    info "Installation complete!"
    echo "=========================================="
    echo ""
    echo "Run the following command to verify installation:"
    echo "  fwauto --help"
    echo ""
}

main "$@"

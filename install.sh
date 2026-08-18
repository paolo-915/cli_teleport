#!/usr/bin/env bash
set -euo pipefail

# --- Custom folder ---
# --- (You can modify APP_DIR before installing) ---
APP_DIR="$HOME/.local/share/cli_teleport"


# ANSI Color codes
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[+]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[x]${NC} $1"; exit 1; }


get_shell_info() {

    # Determine user's current active shell & target config file
    local user_shell
    user_shell="$(basename "${SHELL:-bash}")"
    shell_config=""

    case "$user_shell" in
        zsh)
            shell_config="$HOME/.zshrc"
            ;;
        bash)
            if [[ -f "$HOME/.bashrc" ]]; then
                shell_config="$HOME/.bashrc"
            elif [[ -f "$HOME/.bash_profile" ]]; then
                shell_config="$HOME/.bash_profile"
            else
                shell_config="$HOME/.profile"
            fi
            ;;
        *)
            # Fallback for other POSIX shells
            if [[ -f "$HOME/.zshrc" ]]; then
                shell_config="$HOME/.zshrc"
            elif [[ -f "$HOME/.bashrc" ]]; then
                shell_config="$HOME/.bashrc"
            elif [[ -f "$HOME/.profile" ]]; then
                shell_config="$HOME/.profile"
            fi
            ;;
    esac

}

configure_shell() {

    if [[ -z "$shell_config" ]]; then
        warn "Could not automatically detect your shell config file."
        echo "Please manually add the following to your shell configuration:"
        echo -e "  ${GREEN}source ${APP_DIR}/env_cli_teleport.sh${NC}"
        return 0
    fi

    # Check if the export lines are already inside the config file to avoid duplicate appends
    if grep -qs "source ${APP_DIR}/env_cli_teleport.sh" "$shell_config"; then
        info "cli_teleport already configured in $shell_config".
    else
        echo "# Added by cli_teleport installer: sourcing the environment" >> "$shell_config"
        echo "[[ \"-s ${APP_DIR}/env_cli_teleport.sh\" ]] && source ${APP_DIR}/env_cli_teleport.sh" >> "$shell_config"

        info "Appended 'source $APP_DIR/env_cli_teleport.sh' to $shell_config"
        warn "Run 'source $shell_config' or restart your terminal."
    fi

}

# --- Uninstaller Flag ---
if [[ "${1:-}" == "--uninstall" || "${1:-}" == "-u" ]]; then
    info "Removing cli_teleport..."
    get_shell_info
    if [[ -z "$shell_config" ]]; then
        warn "Could not automatically detect your shell config file."
        echo "Please manually delete the following from your shell configuration:"
        echo -e "  ${GREEN}source ${APP_DIR}/env_cli_teleport.sh${NC}"
    else
		sed -e "/# Added by cli_teleport installer/d" -e "/env_cli_teleport.sh/d" "$shell_config" > my_shell_config.tmp && mv my_shell_config.tmp "$shell_config"
    fi
    warn "The following folder will be deleted: $APP_DIR"
    rm -rI "$APP_DIR"
    info "cli_teleport successfully uninstalled."
    exit 0
fi

# --- 1. System Requirements Check ---
command -v python3 >/dev/null 2>&1 || error "Python 3 is required but was not found."
command -v bash >/dev/null 2>&1 || error "Bash is required but was not found."

# --- 2. Directory Creation ---
info "Installing cli_teleport..."
echo ""
mkdir -p "$APP_DIR"

# --- 3. Copy Package Source Files ---
NEW_LINE=$(sed -n '/APP_DIR=\"/p' install.sh)
export NEW_LINE
awk -v var="$NEW_LINE" ' { 
  sub(/        APP_DIR =.*$/, "        " var )
  print
} ' cli_teleport.py > cli_tempfile1.py.tmp

awk -v var="$NEW_LINE" ' { 
  sub(/  local APP_DIR=.*$/, "  local " var )
  print
} ' env_cli_teleport.sh > cli_tempfile2.sh.tmp

mv cli_tempfile1.py.tmp "$APP_DIR"/cli_teleport.py
mv cli_tempfile2.sh.tmp "$APP_DIR"/env_cli_teleport.sh

chmod ugo+xr "$APP_DIR/cli_teleport.py"
chmod ugo+xr "$APP_DIR/env_cli_teleport.sh"


# --- 4. Configure Shell & Finish ---
info "Executable and environment files installed in $APP_DIR"

get_shell_info
configure_shell

echo ""
info "Installation complete!"

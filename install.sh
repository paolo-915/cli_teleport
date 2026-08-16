#!/usr/bin/env bash
set -euo pipefail

# --- Custom APP name and folder ---
# --- (You can modify these two variables before installing) ---
APP_NAME="cli_teleport"
APP_DIR="$HOME/.local/share/$APP_NAME"


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
        info "${APP_NAME} already configured in $shell_config".
    else
        echo "" >> "$shell_config"
        echo "# Added by $APP_NAME installer: sourcing the environment" >> "$shell_config"
        echo "[[ \"-s ${APP_DIR}/env_cli_teleport.sh\" ]] && source ${APP_DIR}/env_cli_teleport.sh" >> "$shell_config"

        info "Appended 'source $APP_DIR/env_env_cli_teleport.sh' to $shell_config"
        warn "Run 'source $shell_config' or restart your terminal to update your PATH."
    fi

}

# --- Uninstaller Flag ---
if [[ "${1:-}" == "--uninstall" || "${1:-}" == "-u" ]]; then
    info "Removing $APP_NAME..."
    get_shell_info
    if [[ -z "$shell_config" ]]; then
        warn "Could not automatically detect your shell config file."
        echo "Please manually delete the following from your shell configuration:"
        echo -e "  ${GREEN}source ${APP_DIR}/env_cli_teleport.sh${NC}"
    else
		sed "/# Added by $APP_NAME installer/d" $shell_config > my_shell_config.tmp && mv my_shell_config.tmp $shell_config 
		sed "/env_cli_teleport.sh/d" $shell_config > my_shell_config.tmp && mv my_shell_config.tmp $shell_config 
    fi
    warn "The following folder will be deleted: $APP_DIR"
    rm -rI "$APP_DIR"
    info "$APP_NAME successfully uninstalled."
    exit 0
fi

# --- 1. System Requirements Check ---
command -v python3 >/dev/null 2>&1 || error "Python 3 is required but was not found."
command -v bash >/dev/null 2>&1 || error "Bash is required but was not found."

# --- 2. Directory Creation ---
info "Installing $APP_NAME..."
echo ""
mkdir -p "$APP_DIR"

# --- 3. Copy Package Source Files ---
NEW_LINE1=$(sed -n '/APP_NAME=\"/p' install.sh)
NEW_LINE2=$(sed -n '/APP_DIR=\"/p' install.sh)
export NEW_LINE1
export NEW_LINE2
awk -v var1="$NEW_LINE1" -v var2="$NEW_LINE2" ' { 
  sub(/        APP_NAME =.*$/, "        " var1 ) 
  sub(/        APP_DIR =.*$/, "        " var2 )
  print
} ' cli_teleport.py > cli_tempfile1.py.tmp

awk -v var1="$NEW_LINE1" -v var2="$NEW_LINE2" ' { 
  sub(/  local APP_NAME=.*$/, "  local " var1 ) 
  sub(/  local APP_DIR=.*$/, "  local " var2 )
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

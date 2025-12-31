#!/bin/sh
LOCAL_VERSION="v2.1"

INSTALLER_URL="https://raw.githubusercontent.com/ihatemustard/no/refs/heads/main/install.sh"
GITHUB_PAGE="https://github.com/ihatemustard/no/blob/main/install.sh"
GITHUB_URL="https://raw.githubusercontent.com/ihatemustard/no/refs/heads/main/no.sh"
INSTALL_DIR="/usr/local/bin"
TARGET="${INSTALL_DIR}/no"

RED=$(printf '\033[0;31m')
GREEN=$(printf '\033[0;32m')
YELLOW=$(printf '\033[1;33m')
BLUE=$(printf '\033[0;34m')
CYAN=$(printf '\033[0;36m')
BOLD=$(printf '\033[1m')
NC=$(printf '\033[0m')

# ======================
# TO BYPASS THE UPDATE CHECK (NOT RECOMMENDED), DELETE EVERYTHING FROM HERE
check_version() {
    REMOTE_VERSION=$(fetch -o - "$INSTALLER_URL" 2>/dev/null | sed -n '2p' | cut -d'"' -f2 | tr -d '\r')

    if [ -n "$REMOTE_VERSION" ] && [ "$REMOTE_VERSION" != "$LOCAL_VERSION" ]; then
        clear
        printf "${RED}╔═══════════════════════╗${NC}\n"
        printf "${RED}║ NEW VERSION AVAILABLE ║${NC}\n"
        printf "${RED}╚═══════════════════════╝${NC}\n"
        printf " Local version:  ${YELLOW}$LOCAL_VERSION${NC}\n"
        printf " Remote version: ${GREEN}$REMOTE_VERSION${NC}\n\n"

        printf " ${BOLD}1)${NC} Open New Version (Browser)\n"
        printf " ${BOLD}2)${NC} Exit\n\n"
        printf "${CYAN}Please select an option [1-2]:${NC} "
        read ver_choice

        case "$ver_choice" in
            1)
                if command -v open >/dev/null 2>&1; then
                    open "$GITHUB_PAGE"
                elif command -v xdg-open >/dev/null 2>&1; then
                    xdg-open "$GITHUB_PAGE"
                else
                    printf "\n${YELLOW}Visit:${NC} $GITHUB_PAGE\n"
                    sleep 5
                fi
                exit 0
                ;;
            *)
                exit 0
                ;;
        esac
    fi
}

check_version
# TO HERE
# ======================

print_banner() {
    clear
    printf "${CYAN}"
    printf " ╔═══════════════════════════╗\n"
    printf " ║     no-installer %s     ║\n" "$LOCAL_VERSION"
    printf " ║     by ihatemustard       ║\n"
    printf " ╚═══════════════════════════╝\n"
    printf "${NC}\n"
}

print_status() { printf "${BLUE}[INFO]${NC} %s\n" "$1"; }
print_success() { printf "${GREEN}[OK]${NC} %s\n" "$1"; }
print_error() { printf "${RED}[ERROR]${NC} %s\n" "$1"; }

check_env() {
    if [ "$(uname)" != "FreeBSD" ]; then
        print_error "This script is optimized for FreeBSD only."
        exit 1
    fi
    if [ "$(id -u)" -ne 0 ]; then
        print_error "Root privileges required."
        exit 1
    fi
}

install_no() {
    check_env
    echo
    [ ! -d "$INSTALL_DIR" ] && mkdir -p "$INSTALL_DIR"
    print_status "Downloading 'no'..."
    fetch -o "$TARGET" "$GITHUB_URL"
    if [ $? -eq 0 ] && [ -s "$TARGET" ]; then
        chmod 0755 "$TARGET"
        print_success "Installed to $TARGET"
    else
        print_error "Download failed."
    fi
}

remove_no() {
    check_env
    if [ -f "$TARGET" ]; then
        rm "$TARGET"
        print_success "Removed $TARGET"
    else
        print_error "Not found."
    fi
}

while true; do
    print_banner
    printf " ${BOLD}1)${NC} Install / Update 'no'\n"
    printf " ${BOLD}2)${NC} Uninstall 'no'\n"
    printf " ${BOLD}3)${NC} Exit\n"
    echo
    printf "${CYAN}Select [1-3]:${NC} "
    read choice
    case "$choice" in
        1) install_no ;;
        2) remove_no ;;
        3) exit 0 ;;
        *) print_error "Invalid selection" ;;
    esac
    printf "\nPress Enter..."
    read ignore
done

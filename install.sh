#!/bin/sh

# Version Control
CURRENT_VERSION="v2.0"
INSTALLER_URL="https://raw.githubusercontent.com/ihatemustard/no/refs/heads/main/install.sh"
GITHUB_PAGE="https://github.com/ihatemustard/no/blob/main/install.sh"

# Configuration
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

check_version() {
    # This grabs the first 10 lines and looks for the line starting with CURRENT_VERSION=
    REMOTE_VERSION=$(fetch -o - "$INSTALLER_URL" 2>/dev/null | grep "^CURRENT_VERSION=" | head -n 1 | cut -d'"' -f2)

    if [ -n "$REMOTE_VERSION" ] && [ "$REMOTE_VERSION" != "$CURRENT_VERSION" ]; then
        clear
        printf "${RED}╔════════════════════════════════════════════════════════════╗${NC}\n"
        printf "${RED}║                NEW VERSION AVAILABLE                       ║${NC}\n"
        printf "${RED}╚════════════════════════════════════════════════════════════╝${NC}\n"
        printf " Local version:  ${YELLOW}$CURRENT_VERSION${NC}\n"
        printf " Remote version: ${GREEN}$REMOTE_VERSION${NC}\n\n"
        
        printf " ${BOLD}1)${NC} Open New Version (Browser)\n"
        printf " ${BOLD}2)${NC} Exit\n\n"
        printf "${CYAN}Please select an option [1-2]:${NC} "
        read ver_choice

        case "$ver_choice" in
            1)
                if command -v open >/dev/null 2>&1; then open "$GITHUB_PAGE"
                elif command -v xdg-open >/dev/null 2>&1; then xdg-open "$GITHUB_PAGE"
                else
                    printf "\n${YELLOW}Please visit:${NC}\n$GITHUB_PAGE\n"
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

# Run version check
check_version

print_banner() {
    clear
    printf "${CYAN}"
    printf " ╔═══════════════════════════╗\n"
    printf " ║     no-installer $CURRENT_VERSION     ║\n"
    printf " ║     by ihatemustard       ║\n"
    printf " ╚═══════════════════════════╝\n"
    printf "${NC}\n"
}

# ... [The rest of your existing functions: print_status, install_no, etc.]

print_status() {
    printf "${BLUE}[INFO]${NC} %s\n" "$1"
}

print_success() {
    printf "${GREEN}[OK]${NC} %s\n" "$1"
}

print_error() {
    printf "${RED}[ERROR]${NC} %s\n" "$1"
}

check_env() {
    if [ "$(uname)" != "FreeBSD" ]; then
        print_error "This script is optimized for FreeBSD only."
        exit 1
    fi

    if [ "$(id -u)" -ne 0 ]; then
        print_error "Root privileges required."
        printf "       Use ${BOLD}su${NC} or ${BOLD}doas${NC} to run this installer.\n"
        exit 1
    fi
}

install_no() {
    check_env
    echo
    if [ ! -d "$INSTALL_DIR" ]; then
        print_status "Creating $INSTALL_DIR..."
        mkdir -p "$INSTALL_DIR"
    fi
    print_status "Fetching 'no' from GitHub using fetch(1)..."
    fetch -o "$TARGET" "$GITHUB_URL"
    if [ $? -ne 0 ] || [ ! -s "$TARGET" ]; then
        print_error "Download failed. Check your internet connection."
        rm -f "$TARGET"
        return 1
    fi
    chmod 0755 "$TARGET"
    print_success "Successfully installed to $TARGET"
}

remove_no() {
    check_env
    if [ -f "$TARGET" ]; then
        rm "$TARGET"
        print_success "Removed $TARGET"
    else
        print_error "'no' not found in $INSTALL_DIR"
    fi
}

while true; do
    print_banner
    printf " ${BOLD}1)${NC} Install / Update 'no'\n"
    printf " ${BOLD}2)${NC} Uninstall 'no'\n"
    printf " ${BOLD}3)${NC} Exit\n"
    echo
    printf "${CYAN}Select an option [1-3]:${NC} "
    read choice

    case "$choice" in
        1)
            install_no
            printf "\nPress Enter to return to menu..."
            read ignore
            ;;
        2)
            remove_no
            printf "\nPress Enter to return to menu..."
            read ignore
            ;;
        3)
            printf "${YELLOW}Exiting.${NC}\n"
            exit 0
            ;;
        *)
            print_error "Invalid selection."
            sleep 1
            ;;
    esac
done

#!/bin/sh

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


print_banner() {
    clear
    printf "${CYAN}"
    printf " ╔═══════════════════════════╗\n"
    printf " ║     no-installer v2.0     ║\n"
    printf " ║     by ihatemustard       ║\n"
    printf " ╚═══════════════════════════╝\n"
    printf "${NC}\n"
}

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
    printf "       Test it by typing: ${BOLD}no --version${NC}\n"
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

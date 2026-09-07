#!/usr/bin/env bash
set -uo pipefail

# ============================================================
# MANJARO SECURITY BEAST
# Native packages only
# No BlackArch
# No Kali repositories
# No wireless tooling
# ============================================================

SCRIPT_NAME="Manjaro Security Beast"
BASE_DIR="$HOME/security-beast"
LOG="$BASE_DIR/install.log"
INSTALLED="$BASE_DIR/installed.txt"
SKIPPED="$BASE_DIR/skipped.txt"
FAILED="$BASE_DIR/failed.txt"

mkdir -p "$BASE_DIR"
touch "$LOG" "$INSTALLED" "$SKIPPED" "$FAILED"

exec > >(tee -a "$LOG") 2>&1

echo
echo "============================================================"
echo "        $SCRIPT_NAME"
echo "============================================================"
echo

# ------------------------------------------------------------
# Safety checks
# ------------------------------------------------------------

if [[ $EUID -eq 0 ]]; then
    echo "[!] Do NOT run this script as root."
    echo "[!] Run: ./security-beast.sh"
    exit 1
fi

if ! command -v pacman >/dev/null 2>&1; then
    echo "[!] pacman not found."
    exit 1
fi

echo "[+] Checking for BlackArch repository..."

#if grep -Rqi 'blackarch' /etc/pacman.conf /etc/pacman.d 2>/dev/null; then
#    echo
#    echo "[!] BlackArch configuration appears to exist."
#    echo "[!] Remove/disable it before continuing."
#    echo
#    grep -Rni 'blackarch' /etc/pacman.conf /etc/pacman.d 2>/dev/null || true
#    exit 1
#fi

echo "[+] BlackArch repository not detected."

# ------------------------------------------------------------
# Update system
# ------------------------------------------------------------

echo
echo "[+] Synchronizing Manjaro..."
sudo pacman -Syu --needed

if [[ $? -ne 0 ]]; then
    echo "[!] System update failed."
    exit 1
fi

# ------------------------------------------------------------
# Package installer
# ------------------------------------------------------------

install_packages() {

    local category="$1"
    shift

    echo
    echo "============================================================"
    echo "CATEGORY: $category"
    echo "============================================================"

    local available=()
    local pkg

    for pkg in "$@"; do

        # Skip obvious wireless packages
        case "$pkg" in
            aircrack-ng|airgeddon|bettercap|bully|cowpatty|hostapd-wpe|kismet|mdk4|reaver|pixiewps|wifite|hcxdumptool|hcxtools|macchanger|wifiway|fern-wifi-cracker)
                echo "[WIRELESS-SKIP] $pkg"
                echo "$category :: $pkg" >> "$SKIPPED"
                continue
                ;;
        esac

        if pacman -Si "$pkg" >/dev/null 2>&1; then
            available+=("$pkg")
        else
            echo "[NOT-IN-REPO] $pkg"
            echo "$category :: $pkg" >> "$SKIPPED"
        fi
    done

    if [[ ${#available[@]} -eq 0 ]]; then
        echo "[!] Nothing available in this category."
        return
    fi

    echo
    echo "[+] Installing ${#available[@]} packages..."

    if sudo pacman -S --needed "${available[@]}"; then
        for pkg in "${available[@]}"; do
            if pacman -Q "$pkg" >/dev/null 2>&1; then
                echo "$pkg" >> "$INSTALLED"
            fi
        done
    else
        echo "[!] Category had installation failures."
        for pkg in "${available[@]}"; do
            if ! pacman -Q "$pkg" >/dev/null 2>&1; then
                echo "$category :: $pkg" >> "$FAILED"
            fi
        done
    fi
}

# ============================================================
# Core / shell / development
# ============================================================

install_packages "CORE & DEVELOPMENT" \
    git git-lfs base-devel \
    curl wget aria2 \
    jq yq \
    ripgrep fd fzf bat eza \
    tmux screen \
    zsh fish \
    neovim vim nano \
    tree unzip zip p7zip unrar \
    rsync rclone \
    openssh mosh \
    python python-pip python-pipx \
    python-virtualenv \
    go rust cargo \
    ruby ruby-bundler \
    nodejs npm \
    perl php \
    jdk-openjdk \
    cmake ninja meson \
    gcc clang llvm lldb \
    gdb strace ltrace \
    make autoconf automake pkgconf

# ============================================================
# Network discovery / enumeration
# ============================================================

install_packages "NETWORK RECON" \
    nmap nmap-scripts \
    masscan \
    rustscan \
    arp-scan \
    netcat \
    socat \
    traceroute \
    bind \
    dnsutils \
    whois \
    ldns \
    tcpdump \
    iperf3 \
    net-tools \
    inetutils \
    ethtool \
    mtr \
    curl \
    wget \
    httpie

# ============================================================
# DNS / OSINT
# ============================================================

install_packages "DNS & OSINT" \
    bind \
    ldns \
    whois \
    dnsenum \
    dnsrecon \
    fierce \
    theharvester \
    spiderfoot \
    recon-ng \
    amass \
    subfinder \
    assetfinder \
    findomain \
    maigret \
    sherlock

# ============================================================
# Web security
# ============================================================

install_packages "WEB SECURITY" \
    burpsuite \
    zaproxy \
    nikto \
    sqlmap \
    gobuster \
    ffuf \
    wfuzz \
    dirb \
    dirbuster \
    wpscan \
    whatweb \
    wafw00f \
    httpx \
    nuclei \
    feroxbuster \
    hakrawler \
    katana \
    gau \
    waybackurls \
    hakcheckurl \
    dalfox \
    arjun \
    commix \
    xsser \
    wapiti

# ============================================================
# HTTP / API
# ============================================================

install_packages "HTTP & API" \
    curl \
    wget \
    httpie \
    mitmproxy \
    websocat \
    grpcurl \
    jq \
    yq \
    insomnia \
    postman

# ============================================================
# Vulnerability assessment
# ============================================================

install_packages "VULNERABILITY ASSESSMENT" \
    metasploit \
    nuclei \
    nikto \
    nmap \
    lynis \
    openvas \
    gvm \
    wapiti \
    testssl.sh \
    sslscan \
    sslyze \
    cve-bin-tool \
    trivy \
    grype \
    syft \
    osv-scanner

# ============================================================
# Password / hash auditing
# ============================================================

install_packages "PASSWORD & HASH ANALYSIS" \
    john \
    hashcat \
    hashcat-utils \
    hashid \
    hashcat-utils \
    crunch \
    hydra \
    medusa \
    patator \
    thc-hydra \
    ophcrack \
    rainbowcrack \
    chntpw \
    fcrackzip \
    pdfcrack \
    rarcrack \
    sshpass

# ============================================================
# Windows / AD / SMB
# ============================================================

install_packages "WINDOWS & ACTIVE DIRECTORY" \
    samba \
    smbclient \
    cifs-utils \
    ldap-utils \
    openldap \
    krb5 \
    heimdal \
    rpcbind \
    impacket \
    bloodhound \
    bloodhound-python \
    evil-winrm \
    enum4linux \
    enum4linux-ng \
    crackmapexec \
    netexec \
    responder \
    ldapsearch

# ============================================================
# Network protocols / analysis
# ============================================================

install_packages "NETWORK ANALYSIS" \
    wireshark-qt \
    wireshark-cli \
    tcpdump \
    tshark \
    termshark \
    ngrep \
    nethogs \
    iftop \
    bmon \
    vnstat \
    iptraf-ng \
    conntrack-tools

# ============================================================
# Proxy / tunneling
# ============================================================

install_packages "PROXY & TUNNELING" \
    proxychains-ng \
    torsocks \
    tor \
    socat \
    sshuttle \
    chisel \
    ligolo-ng \
    gost \
    iodine \
    corkscrew \
    haproxy \
    nginx

# ============================================================
# Reverse engineering
# ============================================================

install_packages "REVERSE ENGINEERING" \
    ghidra \
    radare2 \
    rizin \
    cutter \
    binwalk \
    foremost \
    strings \
    file \
    binutils \
    objdump \
    readelf \
    patchelf \
    checksec \
    pwndbg \
    gef \
    gdb \
    lldb \
    strace \
    ltrace \
    valgrind \
    rr

# ============================================================
# Binary / exploit development
# ============================================================

install_packages "BINARY & EXPLOIT DEVELOPMENT" \
    gcc \
    clang \
    llvm \
    lldb \
    gdb \
    nasm \
    yasm \
    binutils \
    checksec \
    pwntools \
    ropper \
    ropgadget \
    one-gadget \
    seccomp-tools \
    angr \
    unicorn \
    capstone \
    keystone

# ============================================================
# Forensics
# ============================================================

install_packages "DIGITAL FORENSICS" \
    sleuthkit \
    autopsy \
    foremost \
    scalpel \
    binwalk \
    testdisk \
    photorec \
    ddrescue \
    ewf-tools \
    libewf \
    exiftool \
    bulk-extractor \
    yara \
    yara-x \
    volatility \
    volatility3 \
    plaso \
    timesketch

# ============================================================
# Malware analysis
# ============================================================

install_packages "MALWARE ANALYSIS" \
    yara \
    yara-x \
    clamav \
    radare2 \
    rizin \
    ghidra \
    strace \
    ltrace \
    gdb \
    binwalk \
    oletools \
    capa \
    pefile \
    python-capstone \
    python-yara

# ============================================================
# File / metadata analysis
# ============================================================

install_packages "FILE ANALYSIS" \
    file \
    libmagic \
    exiftool \
    binwalk \
    strings \
    hexedit \
    xxd \
    hexdump \
    ent \
    pngcheck \
    jpeginfo \
    pdfinfo \
    qpdf \
    poppler

# ============================================================
# Cryptography
# ============================================================

install_packages "CRYPTOGRAPHY" \
    openssl \
    gnutls \
    gnupg \
    age \
    scrypt \
    hashcat \
    john \
    ccrypt \
    cryptsetup \
    libsodium \
    openssh

# ============================================================
# Containers / cloud
# ============================================================

install_packages "CLOUD & CONTAINERS" \
    docker \
    docker-compose \
    podman \
    buildah \
    skopeo \
    kubectl \
    helm \
    terraform \
    ansible \
    aws-cli \
    azure-cli \
    google-cloud-cli \
    trivy \
    grype \
    syft

# ============================================================
# Source code security
# ============================================================

install_packages "SOURCE CODE SECURITY" \
    semgrep \
    bandit \
    shellcheck \
    cppcheck \
    flawfinder \
    hadolint \
    yamllint \
    eslint \
    prettier \
    git \
    git-lfs \
    gitleaks \
    trufflehog \
    detect-secrets \
    osv-scanner

# ============================================================
# Databases
# ============================================================

install_packages "DATABASE SECURITY" \
    postgresql \
    mariadb \
    sqlite \
    redis \
    mongodb \
    mysql-clients \
    sqlmap \
    pgcli \
    mycli

# ============================================================
# Steganography / CTF
# ============================================================

install_packages "CTF & STEGANOGRAPHY" \
    steghide \
    stegseek \
    zsteg \
    outguess \
    exiftool \
    binwalk \
    foremost \
    scalpel \
    pngcheck \
    jpeginfo \
    strings \
    xxd \
    file \
    qpdf \
    john \
    hashcat \
    pwntools \
    ropper \
    radare2 \
    ghidra

# ============================================================
# Documentation / wordlists / misc
# ============================================================

install_packages "SECURITY UTILITIES" \
    man-db \
    man-pages \
    texinfo \
    rlwrap \
    expect \
    socat \
    screen \
    tmux \
    pv \
    parallel \
    moreutils \
    dos2unix \
    tree \
    jq \
    yq \
    ripgrep \
    fd \
    fzf

# ============================================================
# Clean up
# ============================================================

echo
echo "============================================================"
echo "FINAL SYSTEM UPDATE"
echo "============================================================"

sudo pacman -Syu

echo
echo "============================================================"
echo "SECURITY BEAST COMPLETE"
echo "============================================================"

sort -u "$INSTALLED" -o "$INSTALLED"
sort -u "$SKIPPED" -o "$SKIPPED"
sort -u "$FAILED" -o "$FAILED"

echo
echo "Installed:"
wc -l < "$INSTALLED"

echo "Skipped:"
wc -l < "$SKIPPED"

echo "Failed:"
wc -l < "$FAILED"

echo
echo "Logs:"
echo "  $LOG"
echo "  $INSTALLED"
echo "  $SKIPPED"
echo "  $FAILED"

echo
echo "[+] Done."


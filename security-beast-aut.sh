#!/usr/bin/env bash
set -uo pipefail

BASE="$HOME/security-beast"
LOG="$BASE/aur-install.log"
INSTALLED="$BASE/aur-installed.txt"
FAILED="$BASE/aur-failed.txt"
SKIPPED="$BASE/aur-skipped.txt"

mkdir -p "$BASE"
touch "$LOG" "$INSTALLED" "$FAILED" "$SKIPPED"

exec > >(tee -a "$LOG") 2>&1

echo
echo "============================================================"
echo "        SECURITY BEAST — AUR EXPANSION"
echo "============================================================"
echo

if [[ $EUID -eq 0 ]]; then
    echo "[!] Do not run this as root."
    exit 1
fi

if ! command -v pacman >/dev/null 2>&1; then
    echo "[!] pacman not found."
    exit 1
fi

if ! command -v pamac >/dev/null 2>&1; then
    echo "[!] pamac is not installed."
    echo
    echo "Install it with:"
    echo
    echo "    sudo pacman -S pamac-cli"
    echo
    exit 1
fi

echo "[+] Updating system first..."
sudo pacman -Syu --needed

if [[ $? -ne 0 ]]; then
    echo "[!] System update failed."
    exit 1
fi

# ------------------------------------------------------------
# AUR package installer
# ------------------------------------------------------------

install_aur() {

    local category="$1"
    shift

    echo
    echo "============================================================"
    echo "CATEGORY: $category"
    echo "============================================================"

    for pkg in "$@"; do

        # Already installed?
        if pacman -Q "$pkg" >/dev/null 2>&1; then
            echo "[ALREADY] $pkg"
            echo "$pkg" >> "$INSTALLED"
            continue
        fi

        echo
        echo "------------------------------------------------------------"
        echo "[AUR] $pkg"
        echo "------------------------------------------------------------"

        # Ask AUR whether the exact package exists.
        if ! pamac search -a --quiet "^${pkg}$" 2>/dev/null \
            | grep -Fxq "$pkg"; then

            echo "[SKIP] AUR package not found: $pkg"
            echo "$category :: $pkg" >> "$SKIPPED"
            continue
        fi

        echo "[+] Building $pkg..."

        if pamac build --no-confirm "$pkg"; then

            if pacman -Q "$pkg" >/dev/null 2>&1; then
                echo "[OK] $pkg"
                echo "$pkg" >> "$INSTALLED"
            else
                echo "[FAIL] $pkg did not appear installed."
                echo "$category :: $pkg" >> "$FAILED"
            fi

        else

            echo "[FAIL] $pkg"
            echo "$category :: $pkg" >> "$FAILED"

        fi

    done
}

# ============================================================
# WEB SECURITY
# ============================================================

install_aur "WEB SECURITY" \
    burpsuite \
    ffuf \
    wfuzz \
    dirb \
    dirbuster \
    whatweb \
    wafw00f \
    nuclei \
    feroxbuster \
    hakrawler \
    katana \
    gau \
    waybackurls \
    dalfox \
    arjun \
    commix \
    xsser \
    wapiti

# ============================================================
# PASSWORD / HASH
# ============================================================

install_aur "PASSWORD & HASH" \
    hashid \
    crunch \
    patator \
    ophcrack \
    rainbowcrack

# NOTE:
# thc-hydra is normally represented by the hydra package.
# Do NOT install a duplicate "thc-hydra" package if hydra
# is already installed.

# ============================================================
# VULNERABILITY ASSESSMENT
# ============================================================

install_aur "VULNERABILITY ASSESSMENT" \
    openvas \
    gvm \
    sslyze \
    cve-bin-tool \
    grype

# ============================================================
# WINDOWS / ACTIVE DIRECTORY
# ============================================================

install_aur "WINDOWS & ACTIVE DIRECTORY" \
    python-bloodhound \
    evil-winrm \
    enum4linux \
    enum4linux-ng \
    crackmapexec \
    netexec \
    responder \
    bloodhound

# ============================================================
# PROXY / TUNNELING
# ============================================================

install_aur "PROXY & TUNNELING" \
    chisel \
    ligolo-ng

# ============================================================
# DIGITAL FORENSICS
# ============================================================

install_aur "DIGITAL FORENSICS" \
    autopsy \
    scalpel \
    ewf-tools \
    bulk-extractor \
    yara-x \
    volatility \
    plaso \
    timesketch

# ============================================================
# CTF / STEGANOGRAPHY
# ============================================================

install_aur "CTF & STEGANOGRAPHY" \
    steghide \
    stegseek \
    zsteg \
    outguess \
    pngcheck \
    jpeginfo \
    pwntools

# ============================================================
# MALWARE ANALYSIS
# ============================================================

install_aur "MALWARE ANALYSIS" \
    capa \
    oletools \
    pefile

# ============================================================
# EXTRA SECURITY DEVELOPMENT
# ============================================================

install_aur "SECURITY DEVELOPMENT" \
    ropper \
    ropgadget \
    one-gadget \
    seccomp-tools \
    angr \
    unicorn \
    capstone \
    keystone

# ============================================================
# CLEAN RESULTS
# ============================================================

sort -u "$INSTALLED" -o "$INSTALLED"
sort -u "$FAILED" -o "$FAILED"
sort -u "$SKIPPED" -o "$SKIPPED"

echo
echo "============================================================"
echo "                 AUR EXPANSION COMPLETE"
echo "============================================================"
echo

echo "Installed:"
wc -l < "$INSTALLED"

echo
echo "Failed:"
wc -l < "$FAILED"

echo
echo "Skipped:"
wc -l < "$SKIPPED"

echo
echo "Files:"
echo "  $INSTALLED"
echo "  $FAILED"
echo "  $SKIPPED"
echo "  $LOG"

echo
echo "[+] Done."


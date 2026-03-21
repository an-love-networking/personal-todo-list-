#!/usr/bin/env bash
# =============================================================================
# arch-gaming-setup.sh
# Post-KDE Arch Linux gaming setup script
# Run as your normal user (NOT root) after KDE Plasma is installed and working
# =============================================================================

set -euo pipefail

# ── colours ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

info()  { echo -e "${CYAN}${BOLD}==> ${RESET}${BOLD}$*${RESET}"; }
ok()    { echo -e "${GREEN}  ✓ $*${RESET}"; }
warn()  { echo -e "${YELLOW}  ! $*${RESET}"; }
die()   { echo -e "${RED}${BOLD}ERROR: $*${RESET}" >&2; exit 1; }
ask()   { echo -e "${YELLOW}${BOLD}[?] $*${RESET}"; }

# ── sanity checks ─────────────────────────────────────────────────────────────
[[ $EUID -eq 0 ]] && die "Do not run this script as root. Run as your normal user."
ping -c1 archlinux.org &>/dev/null || die "No internet connection. Check NetworkManager."

echo -e "\n${BOLD}Arch Linux Gaming Setup${RESET}"
echo    "═══════════════════════════════════════════"
echo    "Running as: $(whoami)"
echo    "This script will install:"
echo    "  · multilib + 32-bit libraries"
echo    "  · Steam, Lutris, Wine"
echo    "  · GameMode, MangoHud, Gamescope"
echo    "  · yay (AUR helper)"
echo    "  · Proton-GE via ProtonUp-Qt"
echo    "  · DXVK + VKD3D-Proton"
echo    "  · ZRAM compressed swap"
echo    "  · Esync file limit"
echo    "  · Gaming sysctl tweaks"
echo    "═══════════════════════════════════════════"
echo
ask "Continue? [y/N]"
read -r REPLY
[[ $REPLY =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }

# =============================================================================
# STEP 1 — Enable multilib
# =============================================================================
info "Step 1/10 — Enabling multilib (32-bit support)"

if grep -q '^\[multilib\]' /etc/pacman.conf; then
    ok "multilib already enabled"
else
    sudo sed -i '/^#\[multilib\]/{s/^#//;n;s/^#//}' /etc/pacman.conf
    ok "multilib enabled in /etc/pacman.conf"
fi

info "Syncing package databases"
sudo pacman -Syu --noconfirm
ok "Package databases updated"

# =============================================================================
# STEP 2 — Steam + core gaming libraries
# =============================================================================
info "Step 2/10 — Installing Steam + core gaming libraries"

sudo pacman -S --noconfirm --needed \
    steam \
    gamemode lib32-gamemode \
    mangohud lib32-mangohud \
    gamescope \
    lib32-alsa-plugins lib32-libpulse \
    lib32-openal lib32-sdl2 \
    lib32-gst-plugins-base lib32-gst-plugins-good \
    vulkan-tools

ok "Steam and gaming libraries installed"
warn "After this script finishes: launch Steam → Settings → Compatibility"
warn "Enable 'Steam Play for all other titles' and select Proton Experimental"

# =============================================================================
# STEP 3 — Lutris + Wine
# =============================================================================
info "Step 3/10 — Installing Lutris + Wine"

sudo pacman -S --noconfirm --needed \
    lutris \
    wine wine-gecko wine-mono \
    winetricks \
    lib32-gnutls lib32-libldap \
    lib32-libgpg-error lib32-sqlite \
    lib32-sdl2 lib32-sdl2_image

ok "Lutris and Wine installed"

# =============================================================================
# STEP 4 — yay (AUR helper)
# =============================================================================
info "Step 4/10 — Installing yay (AUR helper)"

if command -v yay &>/dev/null; then
    ok "yay already installed ($(yay --version | head -1))"
else
    sudo pacman -S --noconfirm --needed git base-devel
    TMPDIR=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$TMPDIR/yay"
    (cd "$TMPDIR/yay" && makepkg -si --noconfirm)
    rm -rf "$TMPDIR"
    ok "yay installed"
fi

# =============================================================================
# STEP 5 — DXVK + VKD3D-Proton (for Lutris Wine prefixes)
# =============================================================================
info "Step 5/10 — Installing DXVK + VKD3D-Proton"

yay -S --noconfirm --needed dxvk-bin vkd3d-proton-bin
ok "DXVK and VKD3D-Proton installed"

# =============================================================================
# STEP 6 — ProtonUp-Qt (to install Proton-GE and Wine-GE)
# =============================================================================
info "Step 6/10 — Installing ProtonUp-Qt"

yay -S --noconfirm --needed protonup-qt
ok "ProtonUp-Qt installed"
warn "After this script: launch ProtonUp-Qt from the KDE app menu"
warn "  → Add version → Steam → GE-Proton (latest)"
warn "  → Add version → Lutris → Wine-GE (latest)"

# =============================================================================
# STEP 7 — Esync / Fsync file descriptor limit
# =============================================================================
info "Step 7/10 — Raising file descriptor limit (Esync/Fsync)"

LIMITS_FILE="/etc/security/limits.conf"
USER=$(whoami)

if grep -q "$USER.*nofile.*524288" "$LIMITS_FILE" 2>/dev/null; then
    ok "File limit already set for $USER"
else
    echo "$USER hard nofile 524288" | sudo tee -a "$LIMITS_FILE" > /dev/null
    echo "$USER soft nofile 524288" | sudo tee -a "$LIMITS_FILE" > /dev/null
    ok "File descriptor limit set to 524288 for $USER"
    warn "You must log out and back in for this to take effect"
    warn "Verify after relogin with: ulimit -Hn  (should show 524288)"
fi

# =============================================================================
# STEP 8 — GameMode daemon
# =============================================================================
info "Step 8/10 — Enabling GameMode daemon"

systemctl --user enable gamemoded --now 2>/dev/null || true

if gamemoded -t &>/dev/null; then
    ok "GameMode is running and passed self-test"
else
    warn "GameMode test had warnings — check 'gamemoded -t' manually"
fi

# =============================================================================
# STEP 9 — ZRAM compressed swap
# =============================================================================
info "Step 9/10 — Configuring ZRAM"

ZRAM_CONF="/etc/systemd/zram-generator.conf"

if [[ -f "$ZRAM_CONF" ]]; then
    ok "ZRAM config already exists — skipping"
else
    sudo tee "$ZRAM_CONF" > /dev/null << 'EOF'
[zram0]
zram-size = min(ram / 2, 8192)
compression-algorithm = zstd
EOF
    sudo systemctl daemon-reload
    sudo systemctl start /dev/zram0 2>/dev/null || true
    ok "ZRAM configured and activated"
fi

# Verify
if swapon --show | grep -q zram; then
    ok "ZRAM swap is active: $(swapon --show | grep zram)"
else
    warn "ZRAM device not showing in swapon — will be active after next reboot"
fi

# =============================================================================
# STEP 10 — Performance sysctl tweaks
# =============================================================================
info "Step 10/10 — Applying gaming sysctl tweaks"

SYSCTL_CONF="/etc/sysctl.d/99-gaming.conf"

if [[ -f "$SYSCTL_CONF" ]]; then
    ok "Gaming sysctl config already exists — skipping"
else
    sudo tee "$SYSCTL_CONF" > /dev/null << 'EOF'
# Arch Linux gaming tweaks
vm.swappiness = 10
vm.vfs_cache_pressure = 50
kernel.split_lock_mitigate = 0
EOF
    sudo sysctl --system &>/dev/null
    ok "Sysctl tweaks applied"
fi

# =============================================================================
# OPTIONAL — Heroic Games Launcher
# =============================================================================
echo
ask "Install Heroic Games Launcher (Epic Games + GOG)? [y/N]"
read -r HEROIC
if [[ $HEROIC =~ ^[Yy]$ ]]; then
    yay -S --noconfirm --needed heroic-games-launcher-bin
    ok "Heroic Games Launcher installed"
fi

# =============================================================================
# OPTIONAL — Kernel parameters (nowatchdog)
# =============================================================================
echo
ask "Add 'nowatchdog nmi_watchdog=0' to boot entry for lower latency? [y/N]"
read -r WATCHDOG
if [[ $WATCHDOG =~ ^[Yy]$ ]]; then
    BOOT_ENTRY=$(ls /boot/loader/entries/*.conf 2>/dev/null | head -1)
    if [[ -z "$BOOT_ENTRY" ]]; then
        warn "No boot entry found in /boot/loader/entries/ — skipping"
    elif grep -q "nowatchdog" "$BOOT_ENTRY"; then
        ok "nowatchdog already present in $BOOT_ENTRY"
    else
        sudo sed -i 's/\(^options .*\)$/\1 nowatchdog nmi_watchdog=0/' "$BOOT_ENTRY"
        ok "Added nowatchdog to $BOOT_ENTRY"
    fi
fi

# =============================================================================
# DONE
# =============================================================================
echo
echo -e "${GREEN}${BOLD}════════════════════════════════════════${RESET}"
echo -e "${GREEN}${BOLD}  Gaming setup complete!${RESET}"
echo -e "${GREEN}${BOLD}════════════════════════════════════════${RESET}"
echo
echo -e "${BOLD}What to do next:${RESET}"
echo "  1. Log out and back in  →  activates the Esync file limit"
echo "  2. Launch ProtonUp-Qt   →  install GE-Proton + Wine-GE"
echo "  3. Launch Steam         →  enable Proton in Settings → Compatibility"
echo "  4. Per-game launch option (paste into Steam Properties):"
echo -e "     ${CYAN}MANGOHUD=1 gamemoderun %command%${RESET}"
echo
echo -e "${BOLD}Useful resources:${RESET}"
echo "  protondb.com              — game compatibility reports"
echo "  lutris.net/games          — pre-configured install scripts"
echo "  wiki.archlinux.org/Gaming — comprehensive Arch gaming wiki"
echo

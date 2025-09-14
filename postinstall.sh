#!/bin/bash
#
# postinstall.sh Version 1.2
#
# MIT License
# 
# Copyright (c) 2025 Christian Völkel
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

if [ "$EUID" -ne 0 ]; then
  echo "FEHLER: Bitte dieses Skript mit sudo ausführen (sudo ./postinstall.sh)."
  exit 1
fi

if [ -z "$SUDO_USER" ]; then
    echo "FEHLER: \$SUDO_USER nicht gefunden. Skript direkt als root gestartet?"
    exit 1
fi

CYAN='\033[0;36m'
NC='\033[0m'

show_banner() {
    clear
    echo -e "${CYAN}"
    echo '  ██████╗ ██╗   ██╗         ████████╗███████╗ ██████╗ ██╗  ██╗'
    echo ' ██╔════╝ ██║   ██║         ╚══██╔══╝██╔════╝██╔════╝ ██║  ██║'
    echo ' ██║      ██║   ██║████████╗   ██║   █████╗  ██║      ███████║'
    echo ' ██║      ╚██╗ ██╔╝            ██║   ██╔══╝  ██║      ██╔══██║'
    echo ' ╚██████╗  ╚████╔╝             ██║   ███████╗╚██████╗ ██║  ██║'
    echo '  ╚═════╝   ╚═══╝              ╚═╝   ╚══════╝ ╚═════╝ ╚═╝  ╚═╝'
    echo -e "${NC}"
    echo -e "${CYAN}           A R C H L I N U X   P O S T I N S T A L L"
    echo -e "===============================================================${NC}"
    echo ""
}

check_service_status() {
  local service_name="$1"
  if systemctl is-active --quiet "$service_name"; then
    echo "✅ Service '$service_name' ist aktiv und läuft."
  else
    echo "❌ FEHLER: Service '$service_name' ist nicht aktiv oder existiert nicht."
    exit 1
  fi
}

installiere_pakete() {
    if [ $# -eq 0 ]; then return; fi
    echo ">>> Prüfe/Installiere Paket(e): $@..."
    if pacman -S --noconfirm --needed "$@"; then
        echo "✅ Paket(e) '$@' erfolgreich installiert/überprüft."
    else
        echo "❌ FEHLER: Bei der Installation eines der Pakete ($@)."
        exit 1
    fi
}

installiere_aur() {
    if [ $# -eq 0 ]; then return; fi
    echo ">>> Prüfe/Installiere Paket(e) aus dem AUR: $@..."
    if sudo -H -u "$SUDO_USER" yay -S --noconfirm --needed --batchinstall --sudoloop "$@"; then
        echo "✅ Paket(e) '$@' aus dem AUR erfolgreich installiert/überprüft."
    else
        echo "❌ FEHLER: Bei der Installation eines der Pakete ($@) aus dem AUR."
        exit 1
    fi
}

setup_dns() {
    echo -e "${CYAN}Schritt 01/22: DNS-Resolver (systemd-resolved) wird aktiviert...${NC}"
    systemctl enable --now systemd-resolved
    check_service_status "systemd-resolved"
    echo ""
}

update_system() {
    echo -e "${CYAN}Schritt 02/22: System wird aktualisiert...${NC}"
    if pacman -Syyu --noconfirm; then
        echo "✅ System erfolgreich aktualisiert."
    else
        echo "❌ FEHLER: Bei der Aktualisierung vom System."
        exit 1
    fi
    echo ""
}

sort_mirrors() {
    echo -e "${CYAN}Schritt 03/22: Spiegelserver werden ermittelt und sortiert...${NC}"
    installiere_pakete "reflector"
    if reflector --country Germany --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist; then
        echo "✅ Mirrorlist erfolgreich aktualisiert."
    else
        echo "❌ FEHLER: Beim Aktualisieren der Mirrorlist mit 'reflector'."
        exit 1
    fi
    cp /etc/xdg/reflector/reflector.conf /etc/xdg/reflector/reflector.conf.bak
    echo "--country Germany" >> /etc/xdg/reflector/reflector.conf
    systemctl enable --now reflector.timer
    check_service_status "reflector.timer"
    echo ""
}

install_paru() {
    echo -e "${CYAN}Schritt 04/22: AUR-Helfer 'paru' wird installiert...${NC}"
    if command -v paru &> /dev/null; then
        echo "✅ AUR-Helper 'paru' ist bereits installiert."
        echo ""
        return
    fi
    installiere_pakete "base-devel" "git"
    sudo -H -u "$SUDO_USER" bash -c "
        git clone https://aur.archlinux.org/paru.git /home/"$SUDO_USER"/paru && \
        cd /home/"$SUDO_USER"/paru && \
        makepkg -si --noconfirm
    "
    rm -r /home/"$SUDO_USER"/paru
    if [ $? -eq 0 ]; then
        echo "✅ 'paru' erfolgreich installiert."
    else
        echo "❌ FEHLER: Während des Build-Prozesses von 'paru'."
        exit 1
    fi
    echo ""
}

install_yay() {
    echo -e "${CYAN}Schritt 05/22: AUR-Helfer 'yay' wird installiert...${NC}"
    if command -v yay &> /dev/null; then
        echo "✅ AUR-Helper 'yay' ist bereits installiert."
        echo ""
        return
    fi
    installiere_pakete "base-devel" "git"
    sudo -H -u "$SUDO_USER" bash -c "
        git clone https://aur.archlinux.org/yay.git /home/"$SUDO_USER"/yay && \
        cd /home/"$SUDO_USER"/yay && \
        makepkg -si --noconfirm
    "
    rm -r /home/"$SUDO_USER"/yay
    if [ $? -eq 0 ]; then
        echo "✅ 'yay' erfolgreich installiert."
    else
        echo "❌ FEHLER: Während des Build-Prozesses von 'yay'."
        exit 1
    fi
    echo ""
}

setup_snapper() {
    echo -e "${CYAN}Schritt 06/22: Snapper-Support und BTRFS-Assistant werden installiert...${NC}"
    if command -v snapper &> /dev/null; then
        installiere_aur "snapper-support" "btrfs-assistant" "btrfs-desktop-notification"
        snapper -c home delete-config
        snapper -c root set-config ALLOW_USERS=$SUDO_USER SYNC_ACL=yes
        snapper -c root set-config NUMBER_LIMIT=10
        snapper -c root set-config NUMBER_LIMIT_IMPORTANT=10
        snapper -c root set-config TIMELINE_LIMIT_DAILY=7
        snapper -c root set-config TIMELINE_LIMIT_HOURLY=7
        snapper -c root set-config TIMELINE_LIMIT_MONTHLY=6
        snapper -c root set-config TIMELINE_LIMIT_WEEKLY=4
        snapper -c root set-config TIMELINE_LIMIT_YEARLY=3
        echo "✅ Snapper für Benutzer '$SUDO_USER' konfiguriert."
        systemctl enable --now btrfs-scrub@-.timer
        check_service_status "btrfs-scrub@-.timer"
    else
        echo "⚠️ 'snapper' nicht gefunden. Dieser Schritt wird übersprungen."
    fi
    echo ""
}

setup_printers() {
    echo -e "${CYAN}Schritt 07/22: Drucker-Software (CUPS) wird installiert...${NC}"
    installiere_pakete "system-config-printer" "cups" "cups-browsed" "cups-filters" "cups-pdf" "cups-pk-helper"
    systemctl enable --now cups.service cups-browsed.service
    check_service_status "cups.service"
    check_service_status "cups-browsed.service"
    echo ""
}

install_firmware() {
    echo -e "${CYAN}Schritt 08/22: AMD/Intel-Firmware wird installiert...${NC}"
    installiere_pakete "linux-firmware"
    if grub-mkconfig -o /boot/grub/grub.cfg; then
        echo "✅ Booloader erfolgreich aktualisiert."
    else
        echo "❌ FEHLER: Bei der Aktualisierung des Bootloaders."
        exit 1
    fi
    echo ""
}

setup_timedate() {
    echo -e "${CYAN}Schritt 09/22: Uhrzeit-Synchronisation für Dual-Boot-Systeme wird konfiguriert...${NC}"
    if timedatectl set-local-rtc '0'; then
        timedatectl
        echo "✅ Uhrzeit-Synchronisation für Dual-Boot-Systeme wurde erfolgreich konfiguriert."
    else
        echo "❌ FEHLER: Bei der Konfiguration der Uhrzeit-Synchronisation für Dual-Boot-Systeme."
        exit 1
    fi
    echo ""
}

setup_ufw() {
    echo -e "${CYAN}Schritt 10/22: UFW-Firewall wird installiert und konfiguriert...${NC}"
    installiere_pakete "ufw" "gufw"
    systemctl enable --now ufw.service
    check_service_status "ufw.service"
    ufw logging on
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow proto igmp to 224.0.0.0/4 comment 'Allow IGMP'
    ufw allow ssh
    ufw allow 445/tcp comment 'SMB'
    ufw allow 137/udp comment 'SMB Netbios'
    ufw allow 138/udp comment 'SMB Netbios'
    ufw allow 139/tcp comment 'SMB Netbios'
    ufw allow 3702/tcp comment 'wsdd2 WSD-Discovery TCP'
    ufw allow 3702/udp comment 'wsdd2 WSD-Discovery UDP'
    ufw allow 5355/tcp comment 'wsdd2 WSD-Discovery TCP (alternative)'
    ufw allow 5355/udp comment 'wsdd2 WSD-Discovery UDP (alternative)'
    ufw allow 5678/udp comment 'Mikrotik WinBox'
    ufw allow 53317/tcp comment 'LocalSend TCP'
    ufw allow 53317/udp comment 'LocalSend UDP'
    ufw enable
    ufw status numbered
    echo ""
}

opt_harden_system() {
    echo -e "${CYAN}Schritt 11/22: Basis-System-Tuning und Härtung über sysctl-Einstellungen wird durchgeführt...${NC}"
    TOTAL_RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    TOTAL_RAM_GB=$((TOTAL_RAM_KB / 1024 / 1024))
    echo ">>> Erkannter Arbeitsspeicher: $TOTAL_RAM_GB GB"
    echo ">>> Erstelle Basis-Konfigurationsdatei: /etc/sysctl.d/98-custom-base.conf"
    tee /etc/sysctl.d/98-custom-base.conf > /dev/null << EOF
# =================================================================
# ===      Basis-System-Tuning & Härtungs-Konfiguration         ===
# =================================================================

# --- VM / Memory / Scheduler Tweaks ---
kernel.nmi_watchdog = 0
vm.swappiness = 10
vm.vfs_cache_pressure = 50
vm.dirty_ratio = 10
vm.dirty_background_ratio = 5
vm.dirty_writeback_centisecs = 1500
vm.min_free_kbytes = $((TOTAL_RAM_KB / 200))
kernel.sched_autogroup_enabled = 0

# --- Filesystem Tweaks & Härtung ---
fs.file-max = 1000000
fs.inotify.max_user_watches = 524288
fs.protected_fifos = 2
fs.protected_hardlinks = 1
fs.protected_regular = 2
fs.protected_symlinks = 1
fs.suid_dumpable = 0

# --- Kernel Security Hardening ---
kernel.randomize_va_space = 2
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2
kernel.sysrq = 0
kernel.core_uses_pid = 1
net.core.bpf_jit_harden = 2

# --- Netzwerk: Security Hardening (IPv4) ---
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.tcp_syncookies = 1

# --- Netzwerk: Security Hardening (IPv6) ---
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0

# --- Netzwerk: Globale Kern-Einstellungen ---
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.core.default_qdisc = fq_codel
net.core.netdev_max_backlog = 300000
net.core.somaxconn = 1024

# --- Netzwerk: Globale TCP-Einstellungen ---
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_sack = 1

# --- Netzwerk: TCP-Puffer (IPv4) ---
net.ipv4.tcp_rmem = 4096 87380 134217728
net.ipv4.tcp_wmem = 4096 65536 134217728

# --- Netzwerk: Time-Wait & Keepalive Management ---
net.ipv4.tcp_max_syn_backlog = 1024
net.ipv4.tcp_max_tw_buckets = 2000000
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_intvl = 60
net.ipv4.tcp_keepalive_probes = 10
EOF
    if [ "$TOTAL_RAM_GB" -ge 16 ]; then
    echo ">>> High-RAM-System erkannt. Erstelle spezifische I/O-Optimierungen..."
    tee /etc/sysctl.d/99-custom-high-ram.conf > /dev/null << EOF
# =================================================================
# ===           High-RAM I/O-Tuning Konfiguration               ===
# =================================================================
# Überschreibt die vm.dirty_*_ratio Werte für Systeme >= 16 GB RAM.
vm.dirty_bytes = 268435456
vm.dirty_background_bytes = 134217728
EOF
    fi
    if sysctl --system; then
        echo "✅ Basis-System-Tuning und Härtung über sysctl-Einstellungen erfolgreich durchgeführt."
    else
        echo "❌ FEHLER: Bei der Durchführung vom Basis-System-Tuning und Härtung über sysctl-Einstellungen."
        exit 1
    fi
    echo -e "${CYAN}Schritt 12/22: Erweitertes System-Tuning und Härtung wird durchgeführt...${NC}"
    chmod 0600 /boot/grub/grub.cfg
    chmod 0600 /etc/ssh/sshd_config
    chmod 0700 /etc/cron.hourly
    tee -a /etc/systemd/coredump.conf << EOF
ProcessSizeMax=0
Storage=none
EOF
    systemctl daemon-reload
    tee -a /etc/security/limits.conf << EOF
* hard   core   0
EOF
    tee /etc/systemd/zram-generator.conf << EOF
[zram0]
zram-size = ram / 2
zram-encryption = false
EOF
    installiere_pakete "arch-audit" "arch-audit-gtk"
    systemctl enable --now arch-audit.timer
    check_service_status "arch-audit.timer"
    echo ""
}

configure_grub() {
    echo -e "${CYAN}Schritt 13/22: GRUB wird konfiguriert...${NC}"
    local GRUB_CONFIG="/etc/default/grub"
    if grep -q "^GRUB_DEFAULT=" "$GRUB_CONFIG"; then
        sed -i "s/^GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/" "$GRUB_CONFIG"
    else
        echo "GRUB_DEFAULT=saved" >> "$GRUB_CONFIG"
    fi
    if grep -q "^#\?GRUB_SAVEDEFAULT=" "$GRUB_CONFIG"; then
        sed -i "s/^#\?GRUB_SAVEDEFAULT=.*/GRUB_SAVEDEFAULT=true/" "$GRUB_CONFIG"
    else
        echo "GRUB_SAVEDEFAULT=true" >> "$GRUB_CONFIG"
    fi
    echo "✅ GRUB_DEFAULT und GRUB_SAVEDEFAULT konfiguriert."
    local NEW_PARAM="lsm=landlock,lockdown,yama,integrity,bpf"
    if ! grep -q "lsm=" "$GRUB_CONFIG"; then
        local GRUB_CMD_LINE=$(grep "^GRUB_CMDLINE_LINUX_DEFAULT=" "$GRUB_CONFIG")
        local UPDATED_PARAMS=$(echo "$GRUB_CMD_LINE" | sed -n 's/GRUB_CMDLINE_LINUX_DEFAULT="\([^"]*\)"/\1/p')
        sed -i "s#^GRUB_CMDLINE_LINUX_DEFAULT=.*#GRUB_CMDLINE_LINUX_DEFAULT=\"$UPDATED_PARAMS $NEW_PARAM\"#" "$GRUB_CONFIG"
        echo "✅ Sicherheits-Kernel-Parameter hinzugefügt."
    else
        echo "✅ Kernel-Parameter 'lsm' ist bereits vorhanden. Keine Änderungen nötig."
    fi

    if grub-mkconfig -o /boot/grub/grub.cfg; then
        echo "✅ GRUB-Konfiguration erfolgreich aktualisiert."
    else
        echo "❌ FEHLER: Beim Aktualisieren der GRUB-Konfiguration."
        exit 1
    fi
    echo ""
}

setup_osprober() {
    echo -e "${CYAN}Schritt 14/22: OS-Prober wird installiert und konfiguriert...${NC}"
    GRUB_CONFIG="/etc/default/grub"
    installiere_pakete "os-prober"
    cp "$GRUB_CONFIG" "$GRUB_CONFIG.bak"
    sed -i 's/^#[[:space:]]*GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' "$GRUB_CONFIG"
    if grub-mkconfig -o /boot/grub/grub.cfg; then
        echo "✅ GRUB-Konfiguration erfolgreich aktualisiert."
    else
        echo "❌ FEHLER: Beim Aktualisieren der GRUB-Konfiguration."
        exit 1
    fi
    echo ""
}

setup_ioscheduler() {
    echo -e "${CYAN}Schritt 15/22: Verbesserte I/O-Scheduler für HDDs/SSDs werden konfiguriert...${NC}"
    local RULE_FILE="/etc/udev/rules.d/60-ioschedulers.rules"
    tee "$RULE_FILE" > /dev/null << EOF
# Regel für rotierende Festplatten (HDDs)
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="mq-deadline"
# Regel für nicht-rotierende Laufwerke (SSDs & NVMe)
ACTION=="add|change", KERNEL=="sd[a-z]|nvme[0-9]n[0-9]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="bfq"
ACTION=="add|change", KERNEL=="sd[a-z]|nvme[0-9]n[0-9]", ATTR{queue/rotational}=="0", ATTR{queue/iosched/low_latency}="1"
EOF
    echo "✅ udev-Regel '$RULE_FILE' erstellt."
    if udevadm control --reload-rules; then
        echo "✅ udev-Regeln erfolgreich neu geladen."
    else
        echo "❌ FEHLER: Beim Neuladen der udev-Regeln."
        exit 1
    fi
    if udevadm trigger; then
        echo "✅ udev-Regeln erfolgreich auf bestehende Geräte angewendet."
    else
        echo "❌ FEHLER: Beim Anwenden der udev-Regeln."
        exit 1
    fi
    echo ""
}

setup_systemd_oomd() {
    echo -e "${CYAN}Schritt 16/22: systemd-oomd wird aktiviert...${NC}"
    systemctl enable --now systemd-oomd.service
    check_service_status "systemd-oomd.service"
    echo ""
}

install_core_apps() {
    echo -e "${CYAN}Schritt 17/22: Wichtige Basisanwendungen werden installiert...${NC}"
    # Foto & Video
    installiere_pakete "gwenview"
    # Produktivität
    installiere_pakete "kaddressbook" "kwalletmanager"
    # Kommunikation & News
    installiere_pakete "kdeconnect" "putty"
    # Dienstprogramme
    installiere_pakete "filelight" "kjournald" "kcalc" "kcharselect" "partitionmanager" "kfind"
    # Dolphin Vorschauen
    installiere_pakete "kdegraphics-thumbnailers" "ffmpegthumbs"
    # System Hilfe & Tools
    installiere_pakete "man-db" "man-pages-de" "usbutils" "logrotate" "fastfetch" "btop" "flatpak" "nano-syntax-highlighting" "kio-admin" "meld" "hunspell-de"   ### You should change `hunspell-de` to your language! ###
    # System Netzwerk
    installiere_pakete "net-tools" "nm-connection-editor" "nss-mdns"
    # System Dateien
    installiere_pakete "rsync" "unrar" "p7zip" "exfatprogs" "dosfstools" "ntfs-3g" "nfs-utils" "nfsidmap" "foremost" "fuse" "arj" "lrzip" "lzop" "unarchiver" "kdf"
    # System Bluetooth
    installiere_pakete "bluez-tools" "bluez-obex" "bluez-utils"
    # System Multimedia
    installiere_pakete "libva" "libva-utils" "jp2a" "libdvdcss" "lame" "gstreamer-vaapi" "flac" "wavpack"
    # System Entwicklung
    installiere_pakete "linux-zen" "linux-zen-headers"
    # System Fonts & Ventoy
    installiere_aur "ttf-ms-fonts"
    echo ""
}

install_further_apps() {
    echo -e "${CYAN}Schritt 18/22: Weitere Anwendungen werden installiert...${NC}"
    # Firefox
    installiere_pakete "firefox" "firefox-i18n-de"
    # Libreoffice
    installiere_pakete "libreoffice-still" "libreoffice-still-de"
    # Okular
    installiere_pakete "okular"
    # Deja-Dup, KBackup
    installiere_pakete "deja-dup" "kbackup"
    # KeePassXC
    installiere_pakete "keepassxc"
    # Gimp
    installiere_pakete "gimp" "gimp-help-de"
    # Skanpage
    installiere_pakete "skanpage"
    # Filezilla
    installiere_pakete "filezilla"
    # Thunderbird
    installiere_pakete "thunderbird" "thunderbird-i18n-de"
    # VLC
    installiere_pakete "vlc" "vlc-plugins-base" "vlc-plugins-video-output" "vlc-plugins-all"
    # Paperwork
    installiere_pakete "paperwork"
    # Krita
    installiere_pakete "krita" "krita-plugin-gmic"
    # Elisa
    installiere_pakete "elisa"
    # Handbrake
    installiere_pakete "handbrake"
    # Kamoso
    installiere_pakete "kamoso"
    # Spiele
    installiere_pakete "kmahjongg" "kpat" "supertuxkart"
    # K3B
    installiere_pakete "cdrdao" "k3b"
    # Geany
    installiere_pakete "geany" "geany-plugins"
    # Kdenlive
    installiere_pakete "kdenlive"
    # Discord
    installiere_pakete "discord"
    # Geany Themes, Octopi, Threema, Whatsapp, LocalSend & Ventoy
    installiere_aur "geany-themes" "octopi" "threema-desktop-bin" "wasistlos" "localsend-bin" "ventoy-bin"
    echo ""
}

setup_zsh_starship() {
    echo -e "${CYAN}Schritt 19/22: ZSH, Starship und Nerd Fonts werden installiert und konfiguriert...${NC}"
    installiere_pakete "wget" "unzip" "zsh" "git" "curl" "starship" "fastfetch"
    sudo -H -u "$SUDO_USER" bash -c 'set -e
        echo ">>> Installiere FiraCode Nerd Font..."
        mkdir -p ~/.local/share/fonts
        wget -O ~/FiraCode.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraCode.zip
        unzip -o -q ~/FiraCode.zip -d ~/.local/share/fonts/
        rm ~/FiraCode.zip
        fc-cache -fv
        echo ">>> Installiere ZSH-Plugins..."
        mkdir -p ~/.zsh/{plugins,completions,themes}
        git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/plugins/zsh-autosuggestions
        git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh/plugins/zsh-syntax-highlighting
        git clone https://github.com/zsh-users/zsh-completions ~/.zsh/plugins/zsh-completions
        echo ">>> Konfiguriere Starship..."
        mkdir -p ~/.config
        starship preset catppuccin-powerline -o ~/.config/starship.toml
        echo ">>> Erstelle .zshrc Konfiguration..."
        tee ~/.zshrc > /dev/null << '"'EOF'"'
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
# aliases
alias ls="ls --color=auto"
alias sysupd="~/.local/bin/system-update.sh"
alias timers="systemctl list-timers --all"
# zsh plugins
source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fpath+=~/.zsh/plugins/zsh-completions/src
autoload -U compinit && compinit
# starship
eval "$(starship init zsh)"
# Tastatur
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[[2~" overwrite-mode
bindkey "^[[3~" delete-char
bindkey "^[[A" up-line-or-history
bindkey "^[[B" down-line-or-history
bindkey "^[[D" backward-char
bindkey "^[[C" forward-char
bindkey "^[[5~" beginning-of-buffer-or-history
bindkey "^[[6~" end-of-buffer-or-history
# fastfetch
fastfetch
EOF
        mkdir -p ~/.local/share/konsole/
        wget -O ~/.local/share/konsole/catppuccin-mocha.colorscheme https://raw.githubusercontent.com/catppuccin/konsole/refs/heads/main/themes/catppuccin-mocha.colorscheme
        tee ~/.local/share/konsole/ZSH-Profil.profile > /dev/null <<EOF
[Appearance]
ColorScheme=catppuccin-mocha
Font=FiraCode Nerd Font Mono,12

[General]
Command=/usr/bin/zsh
Name=ZSH-Profil

[Scrolling]
HistorySize=10000
EOF
        kwriteconfig6 --file konsolerc --group "Desktop Entry" --key DefaultProfile "ZSH-Profil.profile"
    '
    if [ $? -ne 0 ]; then
        echo "❌ FEHLER: Bei der Konfiguration von ZSH für Benutzer $SUDO_USER."
        exit 1
    fi
    echo "✅ ZSH für Benutzer $SUDO_USER konfiguriert."
    if chsh -s /usr/bin/zsh "$SUDO_USER"; then
        echo "✅ Standard-Shell für $SUDO_USER auf ZSH gesetzt."
    else
        echo "❌ FEHLER: Beim Ändern der Standard-Shell für $SUDO_USER."
        exit 1
    fi
    sed -i -e 's/#Color/Color/' -e '/^Color$/aILoveCandy' /etc/pacman.conf
    echo ""
}

setup_kde_settings() {
    echo -e "${CYAN}Schritt 20/22: KDE wird konfiguriert...${NC}"
    sudo -H -u "$SUDO_USER" bash -c 'set -e
        git clone https://github.com/kraken-afk/archsimpleblue.git ~/.local/share/plasma/look-and-feel/archsimpleblue
        cp -r /usr/share/plasma/look-and-feel/org.kde.breezetwilight.desktop ~/.local/share/plasma/look-and-feel/bt2
        cp -r /usr/share/plasma/look-and-feel/org.kde.breezetwilight.desktop ~/.local/share/plasma/look-and-feel/bd2
        tee ~/.local/share/plasma/look-and-feel/bt2/metadata.json > /dev/null <<'EOF'
{
    "KPackageStructure": "Plasma/LookAndFeel",
    "KPlugin": {
        "Authors": [
            {
                "Name": "Chris"
            }
        ],
        "Category": "",
        "Description": "Breeze Twilight 2 modded by Chris",
        "Id": "bt2",
        "License": "GPLv2+",
        "Name": "Breeze Twilight 2 modded by Chris"
    }
}
EOF
        tee ~/.local/share/plasma/look-and-feel/bd2/metadata.json > /dev/null <<'EOF'
{
    "KPackageStructure": "Plasma/LookAndFeel",
    "KPlugin": {
        "Authors": [
            {
                "Name": "Chris"
            }
        ],
        "Category": "",
        "Description": "Breeze Dark 2 modded by Chris",
        "Id": "bd2",
        "License": "GPLv2+",
        "Name": "Breeze Dark 2 modded by Chris"
    }
}
EOF
        sed -i 's/ColorScheme=BreezeLight/ColorScheme=BreezeClassic/' ~/.local/share/plasma/look-and-feel/bt2/contents/defaults
        sed -i 's/ColorScheme=BreezeClassic/ColorScheme=BreezeDark/' ~/.local/share/plasma/look-and-feel/bd2/contents/defaults
        sed -i 's/Theme=org.kde.Breeze/Theme=archsimpleblue/' ~/.local/share/plasma/look-and-feel/bt2/contents/defaults
        sed -i 's/Theme=org.kde.Breeze/Theme=archsimpleblue/' ~/.local/share/plasma/look-and-feel/bd2/contents/defaults
        kwriteconfig6 --file ksplashrc --group KSplash --key Theme 'archsimpleblue'
        kwriteconfig6 --file kcminputrc --group Keyboard --key NumLock '0'
        kwriteconfig6 --file kwinrc --group Plugins --key wobblywindowsEnabled 'true'
        kwriteconfig6 --file kwinrc --group TabBox --key LayoutName 'coverswitch'
        kwriteconfig6 --file kwinrc --group NightColor --key Active 'true'
        kwriteconfig6 --file kwinrc --group NightColor --key LatitudeFixed '52.52'
        kwriteconfig6 --file kwinrc --group NightColor --key LongitudeFixed '13.38'
        kwriteconfig6 --file kwinrc --group NightColor --key Mode 'Location'
    '
    if [ ! -f /etc/sddm.conf ]; then
        touch /etc/sddm.conf
    fi
    if [ ! -d /etc/sddm.conf.d ]; then
        mkdir -p /etc/sddm.conf.d
    fi
    tee /etc/sddm.conf.d/kde_settings.conf > /dev/null <<'EOF'
[General]
HaltCommand=/usr/bin/systemctl poweroff
Numlock=on
RebootCommand=/usr/bin/systemctl reboot

[Theme]
Current=breeze
CursorTheme=breeze_cursors
Font=Noto Sans,10,-1,0,400,0,0,0,0,0,0,0,0,0,0,1
EOF
    sudo -H -u "$SUDO_USER" bash -c 'set -e
        mkdir -p ~/.local/bin
        tee ~/.local/bin/system-update.sh > /dev/null << '"'EOF'"'
#!/bin/bash

CYAN="\033[0;36m"
NC="\033[0m"

echo ""
echo -e "🚀 ${CYAN}System wird aktualisiert. 🔒 Bitte Passwort eingeben, falls nötig...${NC}"
echo ""
yay -Syyu --noconfirm
sudo pacman -Qtdq | xargs -r sudo pacman -Rns --noconfirm
echo ""

if [ $? -eq 0 ]; then
    echo "✅ Update erfolgreich abgeschlossen."
else
    echo "❌ Update fehlgeschlagen oder abgebrochen. Bitte Fehlermeldungen überprüfen."
fi

echo ""
while true; do
    read -p "⚙️ Drücke 'e' zum Beenden: " -n 1 input
    if [[ $input == "e" || $input == "E" ]]; then
        break
    fi
    echo ""
done
EOF
        chmod +x ~/.local/bin/system-update.sh
        mkdir -p ~/.local/share/applications
        tee ~/.local/share/applications/system-update.desktop > /dev/null << EOF
[Desktop Entry]
Comment=
Exec=/usr/bin/konsole -e '~/.local/bin/system-update.sh'
Icon=system-software-update
Name=System-Update
NoDisplay=false
Path=
PrefersNonDefaultGPU=false
StartupNotify=true
Terminal=false
TerminalOptions=
Type=Application
X-KDE-SubstituteUID=false
X-KDE-Username=
Categories=System;
EOF
        tee ~/.local/bin/show-arch-audit.sh > /dev/null << '"'EOF'"'
#!/bin/bash

CYAN="\033[0;36m"
NC="\033[0m"

echo ""
echo -e "🚀 ${CYAN}arch-audit:${NC}"
echo ""
arch-audit
echo ""
while true; do
    read -p "⚙ Drücke e zum Beenden: " -n 1 input
    if [[ $input == "e" || $input == "E" ]]; then
        break
    fi
    echo ""
done
EOF
        chmod +x ~/.local/bin/show-arch-audit.sh
        tee ~/.local/share/applications/show-arch-audit.desktop > /dev/null << EOF
[Desktop Entry]
Comment=
Exec=/usr/bin/konsole -e '~/.local/bin/show-arch-audit.sh'
Icon=showinfo
Name=Show Arch-Audit
NoDisplay=false
Path=
PrefersNonDefaultGPU=false
StartupNotify=true
Terminal=false
TerminalOptions=
Type=Application
X-KDE-SubstituteUID=false
X-KDE-Username=
Categories=System;
EOF
        tee ~/.local/bin/toggle-knight.sh > /dev/null << '"'EOF'"'
#!/bin/bash
check_running() {
    if pidof -o %PPID -x "${0##*/}" >/dev/null; then
        echo "Fehler: ${0##*/} läuft bereits..."
        exit 1
    fi
}
check_running
LIGHT_THEME="bt2"
DARK_THEME="bd2"
CHANGE_THEME_COMMAND="plasma-apply-lookandfeel -a"
set_theme() {
    $CHANGE_THEME_COMMAND "$1"
    LAST_THEME="$1"
    kwriteconfig6 --file ksplashrc --group KSplash --key Theme 'archsimpleblue'
}
is_daylight() {
    local daylight_status
    daylight_status=$(qdbus6 org.kde.KWin /org/kde/KWin/NightLight org.kde.KWin.NightLight.daylight)
    [[ "$daylight_status" == "true" ]]
}
initialize_theme() {
    if is_daylight; then
        set_theme "$LIGHT_THEME"
    else
        set_theme "$DARK_THEME"
    fi
}
monitor_daylight_changes() {
    dbus-monitor --session "type='signal',interface='org.freedesktop.DBus.Properties', member='PropertiesChanged', path='/org/kde/KWin/NightLight'" | grep --line-buffered "daylight" |
        while read -r line; do
            if is_daylight; then
                [[ "$LAST_THEME" != "$LIGHT_THEME" ]] && set_theme "$LIGHT_THEME"
            else
                [[ "$LAST_THEME" != "$DARK_THEME" ]] && set_theme "$DARK_THEME"
            fi
        done
}
initialize_theme
monitor_daylight_changes
EOF
        chmod +x ~/.local/bin/toggle-knight.sh
        mkdir -p ~/.config/autostart
        tee ~/.config/autostart/toggle-knight.sh.desktop > /dev/null << EOF
[Desktop Entry]
Exec=/home/$USER/.local/bin/toggle-knight.sh
Icon=
Name=toggle-knight.sh
Path=
Terminal=False
Type=Application
EOF
        tee ~/.local/share/applications/dolphin-admin.desktop > /dev/null << EOF
[Desktop Entry]
Comment=
Exec=dolphin --sudo
Icon=yast-security
Name=Dolphin ADMIN
NoDisplay=false
Path=
PrefersNonDefaultGPU=false
StartupNotify=true
Terminal=false
TerminalOptions=
Type=Application
X-KDE-SubstituteUID=false
X-KDE-Username=
Categories=System;
EOF
        sleep 5
        plasma-apply-lookandfeel -a bt2
        sleep 1
        kwriteconfig6 --file ksplashrc --group KSplash --key Theme 'archsimpleblue'
    '
    if [ $? -ne 0 ]; then
        echo "❌ FEHLER: Bei der Konfiguration von KDE für Benutzer $SUDO_USER."
        exit 1
    fi
    echo "✅ KDE für Benutzer $SUDO_USER konfiguriert."
    echo ""
}

install_cc_hook() {
    echo -e "${CYAN}Schritt 21/22: Paket Cache automatisch aufräumen, behält nur eine vorherige Version...${NC}"
    installiere_pakete "pacman-contrib"
    sudo mkdir -p /etc/pacman.d/hooks
    tee /etc/pacman.d/hooks/clean_package_cache.hook > /dev/null << EOF
[Trigger]
Operation = Upgrade
Operation = Install
Operation = Remove
Type = Package
Target = *
[Action]
Description = Cleaning pacman cache...
When = PostTransaction
Exec = /usr/bin/paccache -rk 2
EOF
}

check_failed_services() {
    echo -e "${CYAN}Schritt 22/22: Überprüfe auf fehlgeschlagene Systemd-Services...${NC}"
    local failed_services=$(systemctl --failed --no-legend --no-pager)
    if [ -n "$failed_services" ]; then
        echo "❌ WARNUNG: Die folgenden Systemd-Services sind fehlgeschlagen:"
        echo "$failed_services"
        echo "Bitte überprüfen Sie diese mit 'systemctl status <servicename>'"
    else
        echo "✅ Keine fehlgeschlagenen Systemd-Services gefunden."
    fi
    echo ""
}

show_banner
setup_dns
update_system
sort_mirrors
install_paru
install_yay
setup_snapper
setup_printers
install_firmware
setup_timedate
setup_ufw
opt_harden_system
configure_grub
setup_osprober
setup_ioscheduler
setup_systemd_oomd
install_core_apps
install_further_apps
setup_zsh_starship
setup_kde_settings
install_cc_hook
check_failed_services
echo ""
echo -e "${CYAN}--- Post-Installation Skript erfolgreich abgeschlossen! ---${NC}"
echo -e "${CYAN}--- Du solltest das System jetzt mit 'sudo reboot' neu starten! ---${NC}"
echo ""

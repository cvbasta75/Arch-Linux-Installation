# Installationsanleitung für Arch Linux mit KDE Plasma

Diese Anleitung führt dich durch die Installation von Arch Linux mit KDE Plasma. Sie verwendet das `archinstall`-Skript und ein zusätzliches Post-Installationsskript, um den Prozess zu vereinfachen.

-----

### **Wichtige Hinweise & Haftungsausschluss**

  * **EIGENE VERANTWORTUNG**: Die Nutzung dieser Anleitung und der Skripte erfolgt auf eigene Gefahr. Es können unerwartete Probleme auftreten, da jedes System anders konfiguriert ist.
  * **DATENSICHERUNG**: Es wird **DRINGEND EMPFOHLEN**, vor jeglichen Änderungen eine vollständige Datensicherung zu erstellen.
  * **HAFTUNGSAUSSCHLUSS**: Der Ersteller übernimmt **KEINERLEI** Verantwortung oder Haftung für Datenverluste, Systeminstabilitäten oder andere Schäden, die durch die Nutzung dieser Informationen entstehen könnten.

-----

### **Anwendungsübersicht**

Hier ist eine Liste der Anwendungen, die das Installationsskript automatisch installiert:

#### **🌐 Web & Netzwerk**

  * **Firefox** (Webbrowser)
  * **Thunderbird** (E-Mail-Programm)
  * **FileZilla** (FTP/SFTP-Client)
  * **PuTTY** (SSH- & Telnet-Client)
  * **LocalSend** (Dateien im lokalen Netzwerk teilen)

#### **📞 Kommunikation & Telefon**

  * **Discord** (Chat, Voice & Community)
  * **Threema** (Sicherer Messenger)
  * **WasIstLos** (WhatsApp Client)
  * **KDE Connect** (Smartphone-Integration)

#### **🖼️ Grafik & Bild**

  * **Gwenview** (Bild-Betrachter)
  * **Spectacle** (Bildschirmfotos erstellen)
  * **GIMP** (Bild-Bearbeitung)
  * **Krita** (Digitales Malen & Zeichnen)
  * **Skanpage** (Scan-Anwendung)

#### **🎬 Multimedia**

  * **Elisa** (Musik-Wiedergabe)
  * **VLC** (Universeller Media-Player)
  * **Kamoso** (Webcam-Anwendung)
  * **Kdenlive** (Video-Bearbeitung)
  * **HandBrake** (Video-Konvertierung)

#### **🏢 Office & Dokumente**

  * **LibreOffice** (Office-Suite)
  * **KAddressBook** (Kontaktverwaltung)
  * **Paperwork** (Dokumenten-Scanner & Verwaltung)
  * **Okular** (PDF- & Dokumenten-Betrachter)

#### **⌨️ Entwicklung & Text**

  * **Kate** (Texteditor)
  * **Geany** (Leichte Entwicklungsumgebung)
  * **Meld** (Dateien & Ordner vergleichen)
  * **Vim** (Modal-Texteditor im Terminal)

#### **🗂️ Dateiverwaltung**

  * **Dolphin** (Dateimanager)
  * **Ark** (Archivverwaltung)

#### **⚙️ System & Werkzeuge**

  * **Konsole** (Terminal-Emulator)
  * **Octopi** (Grafische Paketverwaltung)
  * **Flatpak** (Distributions-Framework)
  * **UFW** (Firewall)
  * **CUPS** (Drucker-Verwaltung)
  * **Deja-Dup** (Datensicherung)
  * **KBackup** (Datensicherung)
  * **KeePassXC** (Passwortverwaltung)
  * **K3B** (Brennprogramm für CDs/DVDs)
  * **Ventoy** (Bootfähige USB-Sticks erstellen)

#### **🎮 Spiele**

  * **KMahjongg** (Mahjongg Solitaire)
  * **KPat** (Patience-Kartenspiele)
  * **SuperTuxKart** (3D-Rennspiel)

-----

### **Schritt 1: ARCH ISO herunterladen und USB-Stick vorbereiten**

1.  Lade das aktuelle Arch Linux ISO herunter: [https://archlinux.org/download/](https://archlinux.org/download/)
2.  Erstelle einen bootfähigen USB-Stick. Unter Linux kannst du den `dd`-Befehl verwenden. **WICHTIG**: Ersetze `/dev/sdX` durch die korrekte Gerätebezeichnung deines USB-Sticks. Eine falsche Angabe kann deine Festplatte löschen\!
    ```bash
    sudo dd if=archlinux-*.iso of=/dev/sdX bs=4M status=progress
    ```
3.  Alternativ kannst du das Open-Source-Werkzeug Ventoy verwenden, mit dem du ISO-Dateien direkt auf den Stick kopieren kannst, ohne ihn neu formatieren zu müssen: [https://www.ventoy.net](https://www.ventoy.net)

-----

### **Schritt 2: Vom USB-Stick booten**

Starte deinen PC neu und boote vom erstellten USB-Stick. Wähle, falls verfügbar, den UEFI-Boot-Modus. Du landest dann in einer Konsole mit Root-Rechten.

-----

### **Schritt 3: Netzwerkverbindung herstellen**

  * **Ethernet (Kabel)**: Die Verbindung sollte automatisch hergestellt werden.
  * **WLAN (Drahtlos)**: Nutze `iwctl` zur Konfiguration.
    ```bash
    iwctl
    ```
    Führe im `iwctl`-Prompt die folgenden Befehle aus:
    ```
    device list
    station wlan0 scan
    station wlan0 get-networks
    station wlan0 connect "WLAN-SSID"
    ```
    Verlasse `iwctl` mit `exit`.
  * **Verbindung testen**: Prüfe die Verbindung mit einem Ping.
    ```bash
    ping archlinux.org
    ```

-----

### **Schritt 4: Tastaturlayout und Systemzeit einstellen**

Stelle das deutsche Tastaturlayout ein und synchronisiere die Systemzeit:

```bash
loadkeys de
timedatectl set-ntp true
```

-----

### **Schritt 5: `archinstall` ausführen**

Der komfortable Teil der Installation beginnt jetzt.

**Sicherheitshinweis zur Konfigurationsdatei:**
Das Skript verwendet eine externe Konfigurationsdatei. Du kannst den Inhalt vor der Verwendung prüfen, indem du sie herunterlädst:

```bash
wget https://bit.ly/3JZStkt
less config.json
```

Starte die Installation, entweder lokal oder direkt von der URL:

```bash
archinstall --config config.json
```

oder

```bash
archinstall --config-url https://bit.ly/3JZStkt
```

Folge den Anweisungen im Menü, um die Festplatten, den Hostnamen und die Benutzerkonten zu konfigurieren.

#### **5.1 Festplattenkonfiguration**

1.  Wähle "Disk configuration" im Hauptmenü.
2.  Wähle "Partitioning" -\> "Use a best-effort default partition layout".
3.  Wähle deinen Zieldatenträger aus. **WICHTIG**: Alle Daten auf diesem Datenträger gehen verloren.
4.  Wähle bei "Filesystem" die Option **btrfs**.
5.  Bestätige "Would you like to use BTRFS subvolumes with a default structure?" mit "Yes".
6.  Bestätige "Would you like to use compression or disable CoW?" mit "Use compression".
7.  **(Optional)** Für maximale Sicherheit kannst du die Festplattenverschlüsselung mit LUKS konfigurieren.
8.  Navigiere zu "Btrfs snapshots" und wähle die Option "Snapper".

#### **5.2 Hostname**

1.  Wähle "Hostname" im Hauptmenü.
2.  Gib einen gewünschten Namen für deinen Computer ein.

#### **5.3 Authentifizierung**

1.  Wähle "Authentication".
2.  Lege ein Root-Passwort fest.
3.  Füge ein Benutzerkonto hinzu und beantworte die Frage "Should [user] be a superuser (sudo)?" unbedingt mit "Yes".

#### **5.4 Installation starten**

Überprüfe die Zusammenfassung und wähle "Install", um den Vorgang zu starten.

-----

### **Schritt 6: Nach dem Neustart - Post-Install-Skript ausführen**

Öffne nach dem Neustart und der Anmeldung eine Konsole und führe das Post-Installations-Skript aus.

**Sicherheitshinweis zur Skriptausführung:**
Es wird empfohlen, das Skript vor der Ausführung zu überprüfen:

```bash
wget https://bit.ly/3K0ziHj
less postinstall.sh
```

Führe das Skript anschließend mit den folgenden Befehlen aus:

```bash
chmod +x postinstall.sh
sudo ./postinstall.sh
```

**WICHTIG**: Während der Installation wirst du mehrfach zur Passworteingabe aufgefordert. Das ist normal und notwendig.
Nachdem das Skript beendet ist, starte deinen PC neu.

-----

### **Anhang A: Details zum Post-Install-Skript**

Das Skript automatisiert die folgenden Schritte:

  * Einrichten des DNS-Resolvers
  * Systemaktualisierung (`pacman -Syyu`)
  * Sortieren der Spiegelserver (`reflector`)
  * Installation von AUR-Helfern wie `paru` und `yay`
  * Konfiguration von `snapper` und `btrfs-assistant` für System-Snapshots
  * Einrichtung der Drucker-Software (CUPS)
  * Installation von Hardware-Firmware (`linux-firmware`)
  * Synchronisierung der Hardware-Uhr mit UTC
  * Einrichtung der UFW-Firewall
  * System-Tuning und Härtung (Optimierung von Kernel-Parametern, `zram`, `arch-audit`)
  * Konfiguration des GRUB-Bootloaders und Aktivierung zusätzlicher Kernel-Sicherheitsmodule
  * Einrichtung von `os-prober` zur Erkennung anderer Betriebssysteme
  * Konfiguration des I/O-Schedulers
  * Installation von `systemd-oomd` zur Verhinderung von System-Einfrieren
  * Installation einer umfangreichen Sammlung von System- und Desktop-Anwendungen
  * Einrichtung der Z-Shell (ZSH), Starship und Nerd Fonts
  * Konfiguration von KDE-Thema und -Schriftarten
  * Einrichtung eines automatischen Paket-Cache-Aufräumens
  * Prüfung auf fehlgeschlagene Systemdienste

-----

### **Anhang B: Manuelle Konfiguration nach dem Skript**

  * **BTRFS Snapshots**: Die empfohlene Aufbewahrungsrichtlinie für Snapshots ist bereits eingestellt. Snapshots für das `/home`-Verzeichnis sind standardmäßig deaktiviert, da klassische Backups für persönliche Daten besser geeignet sind.
  * **BTRFS Balance**: Dieser Prozess ordnet Daten neu an, um fragmentierten Speicherplatz zurückzugewinnen. Ein vollständiger Balance-Vorgang kann lange dauern. Oft ist ein gefilterter Balance die bessere Wahl, z.B. `btrfs balance start -dusage=50 /` um nur Blöcke neu anzuordnen, die weniger als 50% gefüllt sind.
  * **Systemupdates**: Dein System kann in Zukunft einfach mit dem Befehl `sysupd` aktualisiert werden.
  * **Installation von Software**:
    1.  **Offizielle Repositories**: Immer die erste Wahl. Nutze `pacman -S`.
    2.  **Arch User Repository (AUR)**: Nutze AUR-Helper wie `yay` oder `paru`. Prüfe im Zweifelsfall das `PKGBUILD`-Skript.
    3.  **Flatpak**: Sinnvoll für proprietäre Software oder Anwendungen, die eine strikte Isolierung benötigen.
  * **ARCH LINUX WIKI**: Das Wiki ist eine wertvolle Ressource für die Fehlersuche und erweiterte Informationen: [https://wiki.archlinux.org](https://wiki.archlinux.org)

-----

# Arch Linux Installation Guide with KDE Plasma

This guide will walk you through the installation of Arch Linux with KDE Plasma. It uses the `archinstall` script and an additional post-installation script to simplify the process.

-----

### **Important Notes & Disclaimer**

  * **YOUR OWN RESPONSIBILITY**: You use this guide and the scripts at your own risk. Every system is configured differently, and unexpected problems may occur.
  * **DATA BACKUP**: It is **STRONGLY RECOMMENDED** to create a complete and verified data backup of your important files or your entire system before making any changes.
  * **DISCLAIMER**: The creator of this guide and the scripts assumes **NO** responsibility or liability for any data loss, system instabilities, or other damages that may arise from the use of the information provided here.

-----

### **Application Overview**

Here is a list of the applications that the installation script automatically installs:

#### **🌐 Web & Network**

  * **Firefox** (Web browser)
  * **Thunderbird** (Email client)
  * **FileZilla** (FTP/SFTP file transfer)
  * **PuTTY** (SSH & Telnet client)
  * **LocalSend** (Share files on the local network)

#### **📞 Communication & Phone**

  * **Discord** (Chat, voice & community)
  * **Threema** (Secure messenger)
  * **WasIstLos** (WhatsApp client)
  * **KDE Connect** (Smartphone integration)

#### **🖼️ Graphics & Image**

  * **Gwenview** (Image viewer)
  * **Spectacle** (Take screenshots)
  * **GIMP** (Comprehensive image editing)
  * **Krita** (Digital painting & drawing)
  * **Skanpage** (Scanning application)

#### **🎬 Multimedia**

  * **Elisa** (Music playback)
  * **VLC** (Universal media player)
  * **Kamoso** (Webcam application)
  * **Kdenlive** (Advanced video editing)
  * **HandBrake** (Video conversion)

#### **🏢 Office & Documents**

  * **LibreOffice** (Complete office suite)
  * **KAddressBook** (Contact management)
  * **Paperwork** (Document scanner & management)
  * **Okular** (PDF & document viewer)

#### **⌨️ Development & Text**

  * **Kate** (Advanced text editor)
  * **Geany** (Lightweight development environment)
  * **Meld** (Compare files & folders)
  * **Vim** (Modal text editor in the terminal)

#### **🗂️ File Management**

  * **Dolphin** (File manager)
  * **Ark** (Archive manager)

#### **⚙️ System & Tools**

  * **Konsole** (Terminal emulator)
  * **Octopi** (Graphical package manager)
  * **Flatpak** (Distribution framework)
  * **UFW** (Firewall)
  * **CUPS** (Printer management)
  * **Deja-Dup** (Simple data backup)
  * **KBackup** (Simple data backup)
  * **KeePassXC** (Password manager)
  * **K3B** (CD/DVD burning program)
  * **Ventoy** (Create bootable USB sticks)

#### **🎮 Games**

  * **KMahjongg** (Mahjongg Solitaire)
  * **KPat** (Patience card games)
  * **SuperTuxKart** (3D racing game)

-----

### **Step 1: Download ARCH ISO and Prepare USB Stick**

1.  Download the latest Arch Linux ISO: [https://archlinux.org/download/](https://archlinux.org/download/)
2.  Create a bootable USB stick. On Linux, you can use the `dd` command. **IMPORTANT**: Replace `/dev/sdX` with the correct device name of your USB stick. An incorrect entry can erase your hard drive\!
    ```bash
    sudo dd if=archlinux-*.iso of=/dev/sdX bs=4M status=progress
    ```
3.  Alternatively, use the open-source tool Ventoy, which allows you to create a bootable drive by simply copying the ISO file to it without reformatting: [https://www.ventoy.net](https://www.ventoy.net)

-----

### **Step 2: Boot from the USB Stick**

Restart your PC and boot from the created USB stick. Choose the UEFI boot mode if available. You will then land in a console with root privileges.

-----

### **Step 3: Establish Network Connection**

  * **Ethernet (Cable)**: The connection should be established automatically.
  * **WLAN (Wireless)**: Use `iwctl` to configure the connection:
    ```bash
    iwctl
    ```
    Execute the following commands in the `iwctl` prompt:
    ```
    device list
    station wlan0 scan
    station wlan0 get-networks
    station wlan0 connect "WLAN-SSID"
    ```
    Then, exit `iwctl` with `exit`.
  * **Test Connection**: Check if everything is working with a ping:
    ```bash
    ping archlinux.org
    ```

-----

### **Step 4: Set Keyboard Layout and System Time**

Set the German keyboard layout and synchronize the system time:

```bash
loadkeys de
timedatectl set-ntp true
```

-----

### **Step 5: Run `archinstall`**

The comfortable part of the installation begins now.

**Security Notice for Configuration File:**
The following command uses a configuration file from an external source. You are encouraged to review the content of the file before use by downloading and viewing it first:

```bash
wget https://bit.ly/3JZStkt
less config.json
```

Once you agree with the content, you can start the script locally or use the direct URL:

```bash
archinstall --config config.json
```

or

```bash
archinstall --config-url https://bit.ly/3JZStkt
```

Follow the instructions to configure the disks, hostname, and user accounts. Do not change other settings.

#### **5.1 Disk Configuration**

1.  Select "Disk configuration" from the main menu.
2.  Choose "Partitioning" -\> "Use a best-effort default partition layout".
3.  Select the target disk from the list. **IMPORTANT**: All data on this disk will be erased.
4.  For "Filesystem," choose **btrfs**.
5.  Answer "Would you like to use BTRFS subvolumes with a default structure?" with "Yes".
6.  Answer "Would you like to use compression or disable CoW?" with "Use compression".
7.  **(Optional)** For maximum security, you can configure disk encryption with LUKS.
8.  Navigate to "Btrfs snapshots" and select "Snapper".

#### **5.2 Hostname**

1.  Select "Hostname" from the main menu.
2.  Enter the desired name for your computer.

#### **5.3 Authentication**

1.  Select "Authentication".
2.  Set a strong root password.
3.  Add a user account and be sure to answer "Should [user] be a superuser (sudo)?" with "Yes".

#### **5.4 Start Installation**

Review the configuration summary and select "Install" to begin the process.

-----

### **Step 6: After Reboot - Run Post-Install Script**

After the reboot and login, open a console (terminal) and run the post-installation script.

**Security Notice for Script Execution:**
The commands for running the script are deliberately separated. This allows you to inspect the script after downloading it and before running it with root privileges using the following command:

```bash
wget https://bit.ly/3K0ziHj
less postinstall.sh
```

Then, execute the script with these commands:

```bash
chmod +x postinstall.sh
sudo ./postinstall.sh
```

**IMPORTANT**: You will be prompted to enter your password multiple times during the installation. This is correct and necessary due to the security settings.
After the script is finished, you should restart your PC.

-----

### **Appendix A: Details of the Post-Install Script**

The script automates the following steps:

  * Setting up the DNS resolver
  * System update (`pacman -Syyu`)
  * Sorting mirror servers (`reflector`)
  * Installing AUR helpers like `paru` and `yay`
  * Configuring `snapper` and `btrfs-assistant` for system snapshots
  * Setting up printer software (CUPS)
  * Installing hardware firmware (`linux-firmware`)
  * Synchronizing the hardware clock with UTC
  * Setting up the UFW firewall
  * System tuning and hardening (optimizing kernel parameters, `zram`, `arch-audit`)
  * Configuring the GRUB bootloader and enabling additional kernel security modules
  * Setting up `os-prober` to detect other operating systems
  * Configuring the I/O scheduler
  * Installing `systemd-oomd` to prevent system freezes due to low memory
  * Installing a comprehensive collection of system tools and desktop applications
  * Setting up Z-Shell (ZSH), Starship, and Nerd Fonts
  * Configuring KDE theme and fonts
  * Setting up an automatic package cache cleanup
  * Checking for failed system services

-----

### **Appendix B: Manual Configuration After the Script**

  * **BTRFS Snapshots**: The recommended snapshot retention policy is already configured. Snapshots for your `/home` directory are generally not needed and are therefore disabled by default. Classic backup programs are better for personal data.
  * **BTRFS Balance**: This process re-arranges data to reclaim fragmented space. A full balance operation can take a very long time. Often, a filtered balance is the better choice, e.g., `btrfs balance start -dusage=50 /` to re-arrange only data blocks that are 50% or less full.
  * **System Updates**: You can easily update your system in the future with the `sysupd` command.
  * **Installing Software**:
    1.  **Official Repositories**: Always the first choice. Use `pacman -S`.
    2.  **Arch User Repository (AUR)**: Use AUR helpers like `yay` or `paru`. Always be aware of the security risks and review the `PKGBUILD` script if in doubt.
    3.  **Flatpak**: A good option if an application is not available in the official repositories or the AUR, or if you want strict isolation for security reasons.
  * **ARCH LINUX WIKI**: The Wiki is an exceptionally comprehensive and community-maintained knowledge base. It is the first and often best place to find solutions to problems: [https://wiki.archlinux.org](https://wiki.archlinux.org)

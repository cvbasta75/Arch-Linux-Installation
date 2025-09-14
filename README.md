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

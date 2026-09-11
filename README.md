# AzerothCore Server Manager Pro ⚔️🛡️

A modern, fast, modular, and lightweight GUI Server Management Desktop Application for **AzerothCore (WoW 3.3.5a)** written in PowerShell & Windows Forms. Designed for server owners, administrators, and GM teams to manage remote Linux servers seamlessly without terminal hassle.

---

## 🌟 Key Features

- 🖥️ **Dashboard & Real-Time Monitoring**:
  - Live systemd service management (`acore-authserver`, `acore-worldserver`) — Start, Stop, Restart.
  - Live CPU, RAM, Disk, and System Uptime widgets.
  - Live online players summary (Total, Alliance vs. Horde breakdown).

- 👥 **Players & Realm Explorer**:
  - Full online players table with GUID, Name, Level, Race, Class (with color badges), Faction, Zone, and Account.
  - In-place real-time character search and filtering.
  - Quick GM actions (Kick player via SOAP, expandable with Right-Click Context Menu).

- 💬 **GM Console**:
  - Interactive live SOAP command terminal.
  - Quick actions: `.announce`, `.server info`, `.server restart`, `.saveall`, and custom command prompt.
  - Formatted output with color stripping and error logging.

- ⚙️ **Rates & Configuration (22+ Parameters)**:
  - Responsive 2-column scrollable interface.
  - **XP & Progression**: Kill XP, Quest XP, Explore XP, Reputation, Crafting, Gathering, Honor, Arena Points, Talent Points per Level.
  - **Drops & Economy**: Money drop, Poor, Normal, Uncommon, Rare, Epic item drop rates.
  - **Player & Server QoL**: Player limit, Movement speed, Start Level (1-80), Start Gold, Guild Petition Signs, Unlock All Flight Paths.
  - **Cross-Faction Mode**: Cross-Faction Grouping, Cross-Faction Guilds, Cross-Faction Chat.
  - **System MOTD**: View, edit, and apply server welcome messages live to `worldserver.conf` and database.
  - Live `.reload config` execution on save with zero downtime.
  - **Rich Tooltips**: Detailed explanations and default hints on mouse hover for every single parameter.

- 💾 **Backups & Storage**:
  - Create full compressed MySQL database backups (`acore_auth`, `acore_characters`, `acore_world`) on the remote server with one click.
  - List existing backups with date and human-readable size.
  - Delete backups and automatic retention purge (keep last N backups).

- 📜 **Logs Viewer**:
  - View remote `Server.log`, `Auth.log`, or local manager logs.
  - Line count selector (50, 100, 200, 500 lines).
  - Search filter and auto-scroll.

- 🌐 **Full Bilingual Support**:
  - Instant dynamic switching between **English** and **Georgian (ქართული)** without restarting the application.
  - Easily extendable via `localization.json`.

---

## 🏗️ Architecture

```text
AzerothCore-Server-Manager/
|
+-- AzerothCore Control Panel.bat       # One-click launcher
+-- azeroth_gui.ps1                     # Modular clean entrypoint (~115 lines)
+-- azeroth_gui.config.json             # Active configuration
+-- azeroth_gui.config.example.json     # Configuration template
+-- localization.json                   # Bilingual dictionary (EN / KA)
+-- ROADMAP.md                          # Future development roadmap
+-- README.md                           # Documentation
+-- LICENSE                             # MIT License
+-- .gitignore                          # Git exclusions
|
+-- modules/                            # Backend logic
|   +-- AsyncEngine.ps1                 # Non-blocking async process manager & timer poller
|   +-- Config.ps1                      # Config loader & global variables
|   +-- Database.ps1                    # MySQL queries & player data processing
|   +-- Localization.ps1                # Dynamic UI language applicator
|   +-- Logger.ps1                      # File & UI logging
|   +-- SoapClient.ps1                  # SOAP XML builder & response parser
|   +-- SshClient.ps1                   # OpenSSH command builder & execution
|   \-- WowData.ps1                     # Races, classes (with class colors), and zones
|
+-- ui/                                 # Graphical User Interface
|   +-- Theme.ps1                       # Modern dark theme palette & UI helpers
|   +-- MainWindow.ps1                  # Frame, header, status bar, and tab host
|   \-- tabs/                           # Modular tabs
|       +-- TabDashboard.ps1            # Tab 1: Dashboard
|       +-- TabPlayers.ps1              # Tab 2: Players & Realm
|       +-- TabConsole.ps1              # Tab 3: GM Console
|       +-- TabRates.ps1                # Tab 4: Rates & Server Config
|       +-- TabBackups.ps1              # Tab 5: Backups & Storage
|       +-- TabMonitoring.ps1           # Tab 6: System Monitoring
|       +-- TabLogs.ps1                 # Tab 7: Logs Viewer
|       \-- TabSettings.ps1             # Tab 8: Connection Settings
|
\-- logs/                               # Log storage
    \-- .gitkeep
```

---

## 🚀 Getting Started

### Prerequisites

- **Client Machine (Windows)**:
  - Windows 10 / 11 or Windows Server 2016+
  - Windows PowerShell 5.1 or PowerShell 7+
  - Built-in Windows OpenSSH Client (`ssh.exe`)
- **Remote Server (Linux)**:
  - Ubuntu 20.04 / 22.04 / 24.04 or Debian
  - Running **AzerothCore (WotLK 3.3.5a)** with `acore-authserver` and `acore-worldserver` systemd services
  - SOAP enabled in `worldserver.conf` (`SOAP.Enabled = 1`, default port `7878`)
  - A GM account with `gmlevel 3` in `acore_auth.account_access` for SOAP commands

### Quick Setup

1. **Clone or Download Repository**:
   ```bash
   git clone https://github.com/baguviix/AzerothCore-Server-Manager-Pro.git
   ```

2. **Configure Connection**:
   - Open the application and go to the **Settings** tab, or edit `azeroth_gui.config.json` directly:
   ```json
   {
       "ServerIP": "YOUR_SERVER_IP",
       "User": "ubuntu",
       "Password": "YOUR_SSH_PASSWORD",
       "SoapUser": "YOUR_GM_ACCOUNT",
       "SoapPassword": "YOUR_GM_PASSWORD",
       "SoapPort": 7878,
       "Language": "en"
   }
   ```

3. **Launch**:
   - Double-click **`AzerothCore Control Panel.bat`**.

---

## 🛡️ Security Best Practices

- **Never commit `azeroth_gui.config.json` with real passwords** to public repositories. The included `.gitignore` protects it by default.
- SSH Key authentication (`SshKeyPath`) is strongly recommended over passwords.
- SOAP port `7878` should ideally only be bound to `127.0.0.1` or firewalled to trusted admin IPs.

---

## 📜 License

Distributed under the [MIT License](LICENSE).

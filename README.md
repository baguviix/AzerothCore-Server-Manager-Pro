# AzerothCore Server Manager Pro âš”ï¸ðŸ›¡ï¸

A modern, fast, modular, and lightweight GUI Server Management Desktop Application for **AzerothCore (WoW 3.3.5a)** written in PowerShell & Windows Forms. Designed for server owners, administrators, and GM teams to manage remote Linux servers seamlessly without terminal hassle.

---

## ðŸŒŸ Key Features

- ðŸ–¥ï¸ **Dashboard & Real-Time Monitoring**:
  - Live systemd service management (core-authserver, core-worldserver) â€” Start, Stop, Restart.
  - Live CPU, RAM, Disk, and System Uptime widgets.
  - Live online players summary (Total, Alliance vs. Horde breakdown).

- ðŸ‘¥ **Players & Realm Explorer**:
  - Full online players table with GUID, Name, Level, Race, Class (with color badges), Faction, Zone, and Account.
  - In-place real-time character search and filtering.
  - Quick GM actions (Kick player via SOAP, expandable with Right-Click Context Menu).

- ðŸ’¬ **GM Console**:
  - Interactive live SOAP command terminal.
  - Quick actions: .announce, .server info, .server restart, .saveall, and custom command prompt.
  - Formatted output with color stripping and error logging.

- âš™ï¸ **Rates & Configuration (22+ Parameters)**:
  - Responsive 2-column scrollable interface.
  - **XP & Progression**: Kill XP, Quest XP, Explore XP, Reputation, Crafting, Gathering, Honor, Arena Points, Talent Points per Level.
  - **Drops & Economy**: Money drop, Poor, Normal, Uncommon, Rare, Epic item drop rates.
  - **Player & Server QoL**: Player limit, Movement speed, Start Level (1-80), Start Gold, Guild Petition Signs, Unlock All Flight Paths.
  - **Cross-Faction Mode**: Cross-Faction Grouping, Cross-Faction Guilds, Cross-Faction Chat.
  - **System MOTD**: View, edit, and apply server welcome messages live to worldserver.conf and database.
  - Live .reload config execution on save with zero downtime.
  - **Rich Tooltips**: Detailed explanations and default hints on mouse hover for every single parameter.

- ðŸ’¾ **Backups & Storage**:
  - Create full compressed MySQL database backups (core_auth, core_characters, core_world) on the remote server with one click.
  - List existing backups with date and human-readable size.
  - Delete backups and automatic retention purge (keep last N backups).

- ðŸ“œ **Logs Viewer**:
  - View remote Server.log, Auth.log, or local manager logs.
  - Line count selector (50, 100, 200, 500 lines).
  - Search filter and auto-scroll.

- ðŸŒ **Full Bilingual Support**:
  - Instant dynamic switching between **English** and **Georgian (áƒ¥áƒáƒ áƒ—áƒ£áƒšáƒ˜)** without restarting the application.
  - Easily extendable via localization.json.

---

## ðŸ—ï¸ Architecture

`
AzerothCore-Server-Manager/
â”‚
â”œâ”€â”€ AzerothCore Control Panel.bat       # One-click launcher
â”œâ”€â”€ azeroth_gui.ps1                     # Modular clean entrypoint (~115 lines)
â”œâ”€â”€ azeroth_gui.config.json             # Active configuration
â”œâ”€â”€ azeroth_gui.config.example.json     # Configuration template
â”œâ”€â”€ localization.json                   # Bilingual dictionary (EN / KA)
â”œâ”€â”€ ROADMAP.md                          # Future development roadmap
â”œâ”€â”€ README.md                           # Documentation
â”œâ”€â”€ LICENSE                             # MIT License
â”œâ”€â”€ .gitignore                          # Git exclusions
â”‚
â”œâ”€â”€ modules/                            # Backend logic
â”‚   â”œâ”€â”€ AsyncEngine.ps1                 # Non-blocking async process manager & timer poller
â”‚   â”œâ”€â”€ Config.ps1                      # Config loader & global variables
â”‚   â”œâ”€â”€ Database.ps1                    # MySQL queries & player data processing
â”‚   â”œâ”€â”€ Localization.ps1                # Dynamic UI language applicator
â”‚   â”œâ”€â”€ Logger.ps1                      # File & UI logging
â”‚   â”œâ”€â”€ SoapClient.ps1                  # SOAP XML builder & response parser
â”‚   â”œâ”€â”€ SshClient.ps1                   # OpenSSH command builder & execution
â”‚   â””â”€â”€ WowData.ps1                     # Races, classes (with class colors), and zones
â”‚
â”œâ”€â”€ ui/                                 # Graphical User Interface
â”‚   â”œâ”€â”€ Theme.ps1                       # Modern dark theme palette & UI helpers
â”‚   â”œâ”€â”€ MainWindow.ps1                  # Frame, header, status bar, and tab host
â”‚   â””â”€â”€ tabs/                           # Modular tabs
â”‚       â”œâ”€â”€ TabDashboard.ps1            # Tab 1: Dashboard
â”‚       â”œâ”€â”€ TabPlayers.ps1              # Tab 2: Players & Realm
â”‚       â”œâ”€â”€ TabConsole.ps1              # Tab 3: GM Console
â”‚       â”œâ”€â”€ TabRates.ps1                # Tab 4: Rates & Server Config
â”‚       â”œâ”€â”€ TabBackups.ps1              # Tab 5: Backups & Storage
â”‚       â”œâ”€â”€ TabMonitoring.ps1           # Tab 6: System Monitoring
â”‚       â”œâ”€â”€ TabLogs.ps1                 # Tab 7: Logs Viewer
â”‚       â””â”€â”€ TabSettings.ps1             # Tab 8: Connection Settings
â”‚
â””â”€â”€ logs/                               # Log storage
    â””â”€â”€ .gitkeep
`

---

## ðŸš€ Getting Started

### Prerequisites

- **Client Machine (Windows)**:
  - Windows 10 / 11 or Windows Server 2016+
  - Windows PowerShell 5.1 or PowerShell 7+
  - Built-in Windows OpenSSH Client (ssh.exe)
- **Remote Server (Linux)**:
  - Ubuntu 20.04 / 22.04 / 24.04 or Debian
  - Running **AzerothCore (WotLK 3.3.5a)** with core-authserver and core-worldserver systemd services
  - SOAP enabled in worldserver.conf (SOAP.Enabled = 1, default port 7878)
  - A GM account with gmlevel 3 in core_auth.account_access for SOAP commands

### Quick Setup

1. **Clone or Download Repository**:
   `ash
   git clone https://github.com/YOUR_USERNAME/AzerothCore-Server-Manager.git
   `

2. **Configure Connection**:
   - Open the application and go to the **Settings** tab, or edit zeroth_gui.config.json directly:
   `json
   {
       "ServerIP": "YOUR_SERVER_IP",
       "User": "ubuntu",
       "Password": "YOUR_SSH_PASSWORD",
       "SoapUser": "YOUR_GM_ACCOUNT",
       "SoapPassword": "YOUR_GM_PASSWORD",
       "SoapPort": 7878,
       "Language": "en"
   }
   `

3. **Launch**:
   - Double-click **AzerothCore Control Panel.bat**.

---

## ðŸ›¡ï¸ Security Best Practices

- **Never commit zeroth_gui.config.json with real passwords** to public repositories. The included .gitignore protects it by default.
- SSH Key authentication (SshKeyPath) is strongly recommended over passwords.
- SOAP port 7878 should ideally only be bound to 127.0.0.1 or firewalled to trusted admin IPs.

---

## ðŸ“œ License

Distributed under the [MIT License](LICENSE).
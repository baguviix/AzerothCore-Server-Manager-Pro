# ==========================================
# SSH Remote Process Execution & Command Builders
# ==========================================
function Start-AsyncRemoteProcess {
    param([Parameter(Mandatory = $true)][string]$RemoteCommand)

    $askPassDir = Join-Path $env:TEMP "azeroth_gui"
    if (-not (Test-Path -LiteralPath $askPassDir)) {
        New-Item -ItemType Directory -Path $askPassDir -Force | Out-Null
    }
    $askPassScript = Join-Path $askPassDir "askpass.cmd"
    $escapedPassForBat = if ($script:Password) { $script:Password.Replace("%", "%%") } else { "" }
    "@echo off`r`necho $escapedPassForBat" | Set-Content -LiteralPath $askPassScript -Encoding ASCII

    $sshArgs = @(
        "-o", "ConnectTimeout=8",
        "-o", "StrictHostKeyChecking=accept-new"
    )

    if (-not [string]::IsNullOrWhiteSpace($script:SshKeyPath) -and (Test-Path -LiteralPath $script:SshKeyPath)) {
        $sshArgs += @("-i", "`"$($script:SshKeyPath)`"")
    }

    $sshArgs += "$($script:User)@$($script:ServerIP)"
    $escapedRemote = $RemoteCommand -replace '"', '\"'
    $sshArgs += "`"$escapedRemote`""

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "ssh.exe"
    $psi.Arguments = $sshArgs -join ' '
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.CreateNoWindow = $true

    if (-not [string]::IsNullOrWhiteSpace($script:Password)) {
        $psi.EnvironmentVariables["SSH_ASKPASS"] = $askPassScript
        $psi.EnvironmentVariables["SSH_ASKPASS_REQUIRE"] = "force"
        $psi.EnvironmentVariables["DISPLAY"] = "dummy:0"
    }

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $psi

    Write-Log -Message "Starting async SSH command: $RemoteCommand"
    if (-not $process.Start()) {
        throw "Failed to start ssh.exe process."
    }
    return $process
}

function Get-SudoCommandPrefix {
    if (-not [string]::IsNullOrWhiteSpace($script:Password)) {
        $esc = $script:Password.Replace("'", "'\''")
        return "echo '$esc' | sudo -S"
    } else {
        return "sudo -n"
    }
}

function Get-ServerStatusCommandString {
    $targetList = $script:ServiceNames -join ' '
    $sudo = Get-SudoCommandPrefix
    $sql = "SELECT c.guid, c.name, c.race, c.class, c.gender, c.level, c.zone, a.username FROM acore_characters.characters c JOIN acore_auth.account a ON c.account = a.id WHERE c.online = 1 ORDER BY c.level DESC;"
    $cmdParts = @(
        "systemctl show -p ActiveState --value $targetList",
        "pgrep -f 'bin/authserver|\./authserver' >/dev/null && echo 'AUTH_PROC_RUNNING' || echo 'AUTH_PROC_DOWN'",
        "pgrep -f 'bin/worldserver|\./worldserver' >/dev/null && echo 'WORLD_PROC_RUNNING' || echo 'WORLD_PROC_DOWN'",
        "echo '__AZ_STATS__'",
        "uptime -p 2>/dev/null || uptime",
        "free -m",
        "df -h -P /",
        "cat /proc/loadavg 2>/dev/null",
        "echo '__AZ_PLAYERS__'",
        "$sudo mysql -sN -e '$sql'"
    )
    return $cmdParts -join '; '
}

function Get-RatesReadCommandString {
    $sudo = Get-SudoCommandPrefix
    $conf = "/home/azeroth/azerothcore/env/dist/etc/worldserver.conf"
    $grepRegex = '^(Rate\.XP\.(Kill|Quest|Explore)|Rate\.Reputation\.Gain|SkillGain\.(Crafting|Gathering)|Rate\.(Honor|ArenaPoints|Talent)|Rate\.Drop\.(Money|Item\.(Poor|Normal|Uncommon|Rare|Epic))|PlayerLimit|Rate\.MoveSpeed\.Player|StartPlayerLevel|StartPlayerMoney|MinPetitionSigns|AllFlightPaths|AllowTwoSide\.Interaction\.(Group|Guild|Chat))[ \t]*='
    return "$sudo grep -E '$grepRegex' $conf; echo '__MOTD_START__'; $sudo mysql -sN -e 'SELECT text FROM acore_auth.motd LIMIT 1;'"
}

function Get-RatesSaveCommandString {
    param(
        [double]$KillXp,
        [double]$QuestXp,
        [double]$ExploreXp,
        [double]$Reputation,
        [int]$Crafting,
        [int]$Gathering,
        [double]$Honor,
        [double]$ArenaPoints,
        [int]$Talent,
        [double]$MoneyDrop,
        [double]$DropPoor,
        [double]$DropNormal,
        [double]$DropUncommon,
        [double]$DropRare,
        [double]$DropEpic,
        [int]$PlayerLimit,
        [double]$MoveSpeed,
        [int]$StartLevel,
        [long]$StartMoneyCopper,
        [int]$PetitionSigns,
        [int]$FlightPaths,
        [int]$CrossGroup,
        [int]$CrossGuild,
        [int]$CrossChat,
        [string]$Motd
    )
    $sudo = Get-SudoCommandPrefix
    $conf = "/home/azeroth/azerothcore/env/dist/etc/worldserver.conf"

    $sedCmds = @(
        "$sudo sed -i -E 's/^(Rate\.XP\.Kill[ \t]*=[ \t]*).*/\1$KillXp/' $conf",
        "$sudo sed -i -E 's/^(Rate\.XP\.Quest[ \t]*=[ \t]*).*/\1$QuestXp/' $conf",
        "$sudo sed -i -E 's/^(Rate\.XP\.Explore[ \t]*=[ \t]*).*/\1$ExploreXp/' $conf",
        "$sudo sed -i -E 's/^(Rate\.Reputation\.Gain[ \t]*=[ \t]*).*/\1$Reputation/' $conf",
        "$sudo sed -i -E 's/^(SkillGain\.Crafting[ \t]*=[ \t]*).*/\1$Crafting/' $conf",
        "$sudo sed -i -E 's/^(SkillGain\.Gathering[ \t]*=[ \t]*).*/\1$Gathering/' $conf",
        "$sudo sed -i -E 's/^(Rate\.Honor[ \t]*=[ \t]*).*/\1$Honor/' $conf",
        "$sudo sed -i -E 's/^(Rate\.ArenaPoints[ \t]*=[ \t]*).*/\1$ArenaPoints/' $conf",
        "$sudo sed -i -E 's/^(Rate\.Talent[ \t]*=[ \t]*).*/\1$Talent/' $conf",
        "$sudo sed -i -E 's/^(Rate\.Drop\.Money[ \t]*=[ \t]*).*/\1$MoneyDrop/' $conf",
        "$sudo sed -i -E 's/^(Rate\.Drop\.Item\.Poor[ \t]*=[ \t]*).*/\1$DropPoor/' $conf",
        "$sudo sed -i -E 's/^(Rate\.Drop\.Item\.Normal[ \t]*=[ \t]*).*/\1$DropNormal/' $conf",
        "$sudo sed -i -E 's/^(Rate\.Drop\.Item\.Uncommon[ \t]*=[ \t]*).*/\1$DropUncommon/' $conf",
        "$sudo sed -i -E 's/^(Rate\.Drop\.Item\.Rare[ \t]*=[ \t]*).*/\1$DropRare/' $conf",
        "$sudo sed -i -E 's/^(Rate\.Drop\.Item\.Epic[ \t]*=[ \t]*).*/\1$DropEpic/' $conf",
        "$sudo sed -i -E 's/^(PlayerLimit[ \t]*=[ \t]*).*/\1$PlayerLimit/' $conf",
        "$sudo sed -i -E 's/^(Rate\.MoveSpeed\.Player[ \t]*=[ \t]*).*/\1$MoveSpeed/' $conf",
        "$sudo sed -i -E 's/^(StartPlayerLevel[ \t]*=[ \t]*).*/\1$StartLevel/' $conf",
        "$sudo sed -i -E 's/^(StartPlayerMoney[ \t]*=[ \t]*).*/\1$StartMoneyCopper/' $conf",
        "$sudo sed -i -E 's/^(MinPetitionSigns[ \t]*=[ \t]*).*/\1$PetitionSigns/' $conf",
        "$sudo sed -i -E 's/^(AllFlightPaths[ \t]*=[ \t]*).*/\1$FlightPaths/' $conf",
        "$sudo sed -i -E 's/^(AllowTwoSide\.Interaction\.Group[ \t]*=[ \t]*).*/\1$CrossGroup/' $conf",
        "$sudo sed -i -E 's/^(AllowTwoSide\.Interaction\.Guild[ \t]*=[ \t]*).*/\1$CrossGuild/' $conf",
        "$sudo sed -i -E 's/^(AllowTwoSide\.Interaction\.Chat[ \t]*=[ \t]*).*/\1$CrossChat/' $conf"
    )

    $extraCmds = @()
    if (-not [string]::IsNullOrWhiteSpace($Motd)) {
        $escMotd = $Motd.Replace("'", "\'")
        $extraCmds += "$sudo mysql -e `"UPDATE acore_auth.motd SET text = '$escMotd' WHERE realmid = 1;`" 2>/dev/null || true"
        $soapMotd = Get-SoapCommandString -CommandText "server motd set $Motd"
        $extraCmds += $soapMotd
    }

    $soapReload = Get-SoapCommandString -CommandText ".reload config"
    $allParts = $sedCmds + $extraCmds + @("echo '__RATES_SAVED__'", $soapReload)
    return $allParts -join '; '
}

function Get-BackupsListCommandString {
    return 'mkdir -p ~/acore_backups && ls -la --time-style=+%Y-%m-%d\ %H:%M:%S ~/acore_backups/ 2>/dev/null | grep "\.sql\.gz$" | awk ''{print $5 "\t" $6 " " $7 "\t" $8}'''
}

function Get-BackupCreateCommandString {
    $sudo = Get-SudoCommandPrefix
    return "mkdir -p ~/acore_backups && BF=~/acore_backups/acore_backup_`$(date +%Y%m%d_%H%M%S).sql.gz && $sudo mysqldump -u root acore_auth acore_characters acore_world 2>/dev/null | gzip > `$BF && ls -lh `$BF"
}

function Get-BackupDeleteCommandString {
    param([string]$FileName)
    $safeName = [System.IO.Path]::GetFileName($FileName)
    return "rm -f ~/acore_backups/$safeName && echo 'BACKUP_DELETED'"
}

function Get-BackupPurgeCommandString {
    param([int]$RetentionCount)
    $skip = $RetentionCount + 1
    return "cd ~/acore_backups && ls -1t acore_backup_*.sql.gz 2>/dev/null | tail -n +$skip | xargs -r rm -f && echo 'PURGE_COMPLETED'"
}
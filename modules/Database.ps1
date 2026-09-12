# ==========================================
# Database & Player Operations Module
# ==========================================
$script:AllianceCount = 0
$script:HordeCount = 0
$script:PlayersRatioStr = "0% / 0%"
$script:AllOnlinePlayers = @()

function Update-PlayersSummaryLabels {
    $total = if ($null -ne $script:AllOnlinePlayers) { $script:AllOnlinePlayers.Count } else { 0 }
    $aCount = if ($null -ne $script:AllianceCount) { $script:AllianceCount } else { 0 }
    $hCount = if ($null -ne $script:HordeCount) { $script:HordeCount } else { 0 }
    $rStr = if ($null -ne $script:PlayersRatioStr) { $script:PlayersRatioStr } else { "0% / 0%" }

    if ($null -ne $lblPlayersTotal) { $lblPlayersTotal.Text = (Get-Text "PlayersTotal") + $total }
    if ($null -ne $lblPlayersAlliance) { $lblPlayersAlliance.Text = (Get-Text "PlayersAlliance") + $aCount }
    if ($null -ne $lblPlayersHorde) { $lblPlayersHorde.Text = (Get-Text "PlayersHorde") + $hCount }
    if ($null -ne $lblPlayersRatio) { $lblPlayersRatio.Text = (Get-Text "PlayersRatio") + $rStr }

    if ($null -ne $lblDashPlayersCount) { $lblDashPlayersCount.Text = "$total Online" }
    if ($null -ne $lblDashFactionSplit) { $lblDashFactionSplit.Text = "Alliance: $aCount | Horde: $hCount ($rStr)" }
}

function Get-PlayersStatusCommandString {
    $sudo = Get-SudoCommandPrefix
    $sql = "SELECT c.guid, c.name, c.race, c.class, c.gender, c.level, c.zone, a.username FROM acore_characters.characters c JOIN acore_auth.account a ON c.account = a.id WHERE c.online = 1 ORDER BY c.level DESC;"
    return "$sudo mysql -sN -e '$sql'"
}

function Update-PlayersUi {
    param([string]$RawData)

    $script:AllOnlinePlayers = @()
    if ($null -ne $gridPlayers) { $gridPlayers.Rows.Clear() }

    $lines = $RawData -split "`r?`n"
    $allianceCount = 0
    $hordeCount = 0

    foreach ($line in $lines) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        $parts = $line -split "`t"
        if ($parts.Length -ge 8) {
            $guid   = $parts[0]
            $name   = $parts[1]
            $raceId = [int]$parts[2]
            $classId= [int]$parts[3]
            $gender = [int]$parts[4]
            $level  = [int]$parts[5]
            $zoneId = [int]$parts[6]
            $account= $parts[7]

            $raceInfo = if ($WoWRaces.ContainsKey($raceId)) { $WoWRaces[$raceId] } else { @{ Name = "Race $raceId"; Faction = "Unknown" } }
            $classInfo = if ($WoWClasses.ContainsKey($classId)) { $WoWClasses[$classId] } else { @{ Name = "Class $classId"; Color = [System.Drawing.Color]::White } }
            $zoneName = if ($WoWZones.ContainsKey($zoneId)) { $WoWZones[$zoneId] } else { if ($zoneId -eq 0) { "Eastern Kingdoms" } else { "Zone $zoneId" } }

            if ($raceInfo.Faction -eq "Alliance") { $allianceCount++ }
            elseif ($raceInfo.Faction -eq "Horde") { $hordeCount++ }

            $pObj = [PSCustomObject]@{
                Guid     = $guid
                Name     = $name
                Level    = $level
                Race     = $raceInfo.Name
                Faction  = $raceInfo.Faction
                Class    = $classInfo.Name
                Color    = $classInfo.Color
                Zone     = $zoneName
                Account  = $account
            }
            $script:AllOnlinePlayers += $pObj
        }
    }

    $script:AllianceCount = $allianceCount
    $script:HordeCount = $hordeCount
    $script:PlayersRatioStr = if ($script:AllOnlinePlayers.Count -gt 0) {
        $aPct = [math]::Round(($allianceCount / $script:AllOnlinePlayers.Count) * 100)
        $hPct = 100 - $aPct
        "${aPct}% / ${hPct}%"
    } else {
        "0% / 0%"
    }

    Update-PlayersSummaryLabels
    Filter-PlayersGrid
}

function Filter-PlayersGrid {
    if ($null -eq $gridPlayers) { return }
    $gridPlayers.Rows.Clear()
    $search = if ($null -ne $txtPlayerFilter) { $txtPlayerFilter.Text.Trim().ToLower() } else { "" }

    foreach ($p in $script:AllOnlinePlayers) {
        if ([string]::IsNullOrEmpty($search) -or
            $p.Name.ToLower().Contains($search) -or
            $p.Class.ToLower().Contains($search) -or
            $p.Race.ToLower().Contains($search) -or
            $p.Zone.ToLower().Contains($search) -or
            $p.Account.ToLower().Contains($search)) {

            $rowIndex = $gridPlayers.Rows.Add(@($p.Guid, $p.Name, $p.Level, $p.Race, $p.Faction, $p.Class, $p.Zone, $p.Account))
            $row = $gridPlayers.Rows[$rowIndex]
            $row.Cells["Class"].Style.ForeColor = $p.Color
            $row.Cells["Class"].Style.Font = $fontBold

            if ($p.Faction -eq "Alliance") {
                $row.Cells["Faction"].Style.ForeColor = [System.Drawing.Color]::FromArgb(60, 140, 255)
            } elseif ($p.Faction -eq "Horde") {
                $row.Cells["Faction"].Style.ForeColor = [System.Drawing.Color]::FromArgb(255, 75, 75)
            }
        }
    }
}
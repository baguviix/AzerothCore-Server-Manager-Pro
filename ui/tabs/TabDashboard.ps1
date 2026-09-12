# ==========================================
# Tab 1: Dashboard (áƒ›áƒáƒ áƒ—áƒ•áƒ˜áƒ¡ áƒžáƒáƒœáƒ”áƒšáƒ˜)
# ==========================================
$cardAuth  = New-StatusCard -Parent $tabDashboard -Title (Get-Text "CardAuth")  -Location (New-Object System.Drawing.Point(20, 20))  -Size (New-Object System.Drawing.Size(490, 160))
$cardWorld = New-StatusCard -Parent $tabDashboard -Title (Get-Text "CardWorld") -Location (New-Object System.Drawing.Point(530, 20)) -Size (New-Object System.Drawing.Size(490, 160))
$cardStats = New-StatusCard -Parent $tabDashboard -Title (Get-Text "CardOnlineSummary") -Location (New-Object System.Drawing.Point(20, 200)) -Size (New-Object System.Drawing.Size(490, 170))
$cardQuick = New-StatusCard -Parent $tabDashboard -Title (Get-Text "QuickActions") -Location (New-Object System.Drawing.Point(530, 200)) -Size (New-Object System.Drawing.Size(490, 170))

# Inside Auth Card
$lblAuthStatusBadge = New-Object System.Windows.Forms.Label
$lblAuthStatusBadge.Text = (Get-Text "StatusChecking")
$lblAuthStatusBadge.Font = $fontHeader
$lblAuthStatusBadge.ForeColor = $accentOrange
$lblAuthStatusBadge.Location = New-Object System.Drawing.Point(16, 45)
$lblAuthStatusBadge.AutoSize = $true
$cardAuth.Controls.Add($lblAuthStatusBadge)

$btnStartAuth   = New-StyledButton -Text (Get-Text "BtnStartAuth")   -BgColor $accentGreen -Location (New-Object System.Drawing.Point(16, 100))  -Size (New-Object System.Drawing.Size(140, 36))
$btnStopAuth    = New-StyledButton -Text (Get-Text "BtnStopAuth")    -BgColor $accentRed   -Location (New-Object System.Drawing.Point(170, 100)) -Size (New-Object System.Drawing.Size(140, 36))
$btnRestartAuth = New-StyledButton -Text (Get-Text "BtnRestartAuth") -BgColor $accentBlue  -Location (New-Object System.Drawing.Point(324, 100)) -Size (New-Object System.Drawing.Size(150, 36))
$cardAuth.Controls.AddRange(@($btnStartAuth, $btnStopAuth, $btnRestartAuth))

# Inside World Card
$lblWorldStatusBadge = New-Object System.Windows.Forms.Label
$lblWorldStatusBadge.Text = (Get-Text "StatusChecking")
$lblWorldStatusBadge.Font = $fontHeader
$lblWorldStatusBadge.ForeColor = $accentOrange
$lblWorldStatusBadge.Location = New-Object System.Drawing.Point(16, 45)
$lblWorldStatusBadge.AutoSize = $true
$cardWorld.Controls.Add($lblWorldStatusBadge)

$btnStartWorld   = New-StyledButton -Text (Get-Text "BtnStartWorld")   -BgColor $accentGreen -Location (New-Object System.Drawing.Point(16, 100))  -Size (New-Object System.Drawing.Size(140, 36))
$btnStopWorld    = New-StyledButton -Text (Get-Text "BtnStopWorld")    -BgColor $accentRed   -Location (New-Object System.Drawing.Point(170, 100)) -Size (New-Object System.Drawing.Size(140, 36))
$btnRestartWorld = New-StyledButton -Text (Get-Text "BtnRestartWorld") -BgColor $accentBlue  -Location (New-Object System.Drawing.Point(324, 100)) -Size (New-Object System.Drawing.Size(150, 36))
$cardWorld.Controls.AddRange(@($btnStartWorld, $btnStopWorld, $btnRestartWorld))

# Inside Players Card
$lblDashPlayersCount = New-Object System.Windows.Forms.Label
$lblDashPlayersCount.Text = "0 Online"
$lblDashPlayersCount.Font = New-Object System.Drawing.Font("Segoe UI", 24, [System.Drawing.FontStyle]::Bold)
$lblDashPlayersCount.ForeColor = $accentGreen
$lblDashPlayersCount.Location = New-Object System.Drawing.Point(16, 45)
$lblDashPlayersCount.AutoSize = $true
$cardStats.Controls.Add($lblDashPlayersCount)

$lblDashFactionSplit = New-Object System.Windows.Forms.Label
$lblDashFactionSplit.Text = "Alliance: 0 | Horde: 0"
$lblDashFactionSplit.Font = $fontBody
$lblDashFactionSplit.ForeColor = $textLight
$lblDashFactionSplit.Location = New-Object System.Drawing.Point(20, 110)
$lblDashFactionSplit.AutoSize = $true
$cardStats.Controls.Add($lblDashFactionSplit)

# Inside Quick Actions Card
$btnFullRefresh = New-StyledButton -Text (Get-Text "BtnRefreshAll") -BgColor $accentBlue -Location (New-Object System.Drawing.Point(20, 45)) -Size (New-Object System.Drawing.Size(210, 42))
$btnQuickBackup = New-StyledButton -Text (Get-Text "BtnCreateBackup") -BgColor ([System.Drawing.Color]::FromArgb(120, 90, 200)) -Location (New-Object System.Drawing.Point(250, 45)) -Size (New-Object System.Drawing.Size(210, 42))
$cardQuick.Controls.AddRange(@($btnFullRefresh, $btnQuickBackup))

# Summary Metrics Panel at bottom of Dashboard
$pnlDashMetrics = New-Object System.Windows.Forms.Panel
$pnlDashMetrics.Location = New-Object System.Drawing.Point(20, 390)
$pnlDashMetrics.Size = New-Object System.Drawing.Size(1000, 200)
$pnlDashMetrics.BackColor = $cardBg
$pnlDashMetrics.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$tabDashboard.Controls.Add($pnlDashMetrics)

$lblDashSysMetrics = New-Object System.Windows.Forms.Label
$lblDashSysMetrics.Text = "System Metrics: Loading..."
$lblDashSysMetrics.Font = $fontBody
$lblDashSysMetrics.ForeColor = $textLight
$lblDashSysMetrics.Location = New-Object System.Drawing.Point(20, 20)
$lblDashSysMetrics.Size = New-Object System.Drawing.Size(950, 150)
$pnlDashMetrics.Controls.Add($lblDashSysMetrics)

$script:AuthIsRunning = $null
$script:WorldIsRunning = $null

function Update-DashboardBadgesUi {
    if ($null -ne $lblAuthStatusBadge) {
        if ($null -eq $script:AuthIsRunning) {
            $lblAuthStatusBadge.Text = Get-Text "StatusChecking"
            $lblAuthStatusBadge.ForeColor = $accentOrange
        } elseif ($script:AuthIsRunning) {
            $lblAuthStatusBadge.Text = Get-Text "StatusRunning"
            $lblAuthStatusBadge.ForeColor = $accentGreen
        } else {
            $lblAuthStatusBadge.Text = Get-Text "StatusStopped"
            $lblAuthStatusBadge.ForeColor = $accentRed
        }
    }
    if ($null -ne $lblWorldStatusBadge) {
        if ($null -eq $script:WorldIsRunning) {
            $lblWorldStatusBadge.Text = Get-Text "StatusChecking"
            $lblWorldStatusBadge.ForeColor = $accentOrange
        } elseif ($script:WorldIsRunning) {
            $lblWorldStatusBadge.Text = Get-Text "StatusRunning"
            $lblWorldStatusBadge.ForeColor = $accentGreen
        } else {
            $lblWorldStatusBadge.Text = Get-Text "StatusStopped"
            $lblWorldStatusBadge.ForeColor = $accentRed
        }
    }
}

function Update-DashboardStatusUi {
    param([string]$Output)

    $script:AuthIsRunning = ($Output -match "AUTH_PROC_RUNNING")
    $script:WorldIsRunning = ($Output -match "WORLD_PROC_RUNNING")
    Update-DashboardBadgesUi

    if ($Output -match "__AZ_STATS__") {
        $statsStart = $Output.IndexOf("__AZ_STATS__")
        $statsPart = if ($Output -match "__AZ_PLAYERS__") {
            $playersStart = $Output.IndexOf("__AZ_PLAYERS__")
            if ($playersStart -gt $statsStart) {
                $Output.Substring($statsStart, ($playersStart - $statsStart))
            } else {
                $Output.Substring($statsStart)
            }
        } else {
            $Output.Substring($statsStart)
        }
        $lines = $statsPart -split "`r?`n"

        $uptimeLine = ""
        $memLine = ""
        $dfLine = ""
        $loadLine = ""

        foreach ($l in $lines) {
            if ($l -match "up\s+" -or $l -match "days?|hours?|mins?") { $uptimeLine = $l.Trim() }
            if ($l -match "^Mem:\s+(\d+)\s+(\d+)\s+(\d+)") {
                $totalMem = [int]$matches[1]
                $usedMem  = [int]$matches[2]
                $pctMem = if ($totalMem -gt 0) { [math]::Round(($usedMem / $totalMem) * 100) } else { 0 }
                $memLine = "RAM: ${usedMem}MB / ${totalMem}MB (${pctMem}%)"
                if ($null -ne $widgetRam) {
                    $widgetRam.Bar.Value = [math]::Min(100, [math]::Max(0, $pctMem))
                    $widgetRam.Label.Text = $memLine
                }
            }
            if ($l -match "^\S+\s+(\S+)\s+(\S+)\s+(\S+)\s+(\d+)%\s+/") {
                $diskTotal = $matches[1]
                $diskUsed  = $matches[2]
                $diskAvail = $matches[3]
                $diskPct   = [int]$matches[4]
                $dfLine = "Disk: ${diskUsed} / ${diskTotal} (${diskPct}%, free: ${diskAvail})"
                if ($null -ne $widgetDisk) {
                    $widgetDisk.Bar.Value = [math]::Min(100, [math]::Max(0, $diskPct))
                    $widgetDisk.Label.Text = $dfLine
                }
            }
            if ($l -match "load average:\s*(.*)") {
                $loadLine = "Load Avg: " + $matches[1].Trim()
            }
        }

        $lblDashSysMetrics.Text = "$uptimeLine`r`n$memLine`r`n$dfLine`r`n$loadLine"
        if ($null -ne $lblUptimeVal) {
            $lblUptimeVal.Text = if ($uptimeLine) { $uptimeLine } else { "System Active" }
        }

        if ($Output -match "(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)") {
            $load1 = [double]$matches[1]
            $cpuPct = [math]::Min(100, [math]::Round($load1 * 25))
            if ($null -ne $widgetCpu) {
                $widgetCpu.Bar.Value = [int]$cpuPct
                $widgetCpu.Label.Text = "CPU Est: ${cpuPct}% ($loadLine)"
            }
        }
    }

    if ($Output -match "__AZ_PLAYERS__") {
        $pIdx = $Output.IndexOf("__AZ_PLAYERS__") + "__AZ_PLAYERS__".Length
        $playersPart = $Output.Substring($pIdx).Trim()
        Update-PlayersUi -RawData $playersPart
    }
}

# Event Handlers
$btnFullRefresh.Add_Click({ Start-AsyncOperation -Operation "status" })
$btnQuickBackup.Add_Click({ Start-AsyncOperation -Operation "create_backup" })

$btnStartAuth.Add_Click({ Start-AsyncOperation -Operation "service_action" -Args @{ ServiceName = "acore-authserver"; Action = "start" } })
$btnStopAuth.Add_Click({ Start-AsyncOperation -Operation "service_action" -Args @{ ServiceName = "acore-authserver"; Action = "stop" } })
$btnRestartAuth.Add_Click({ Start-AsyncOperation -Operation "service_action" -Args @{ ServiceName = "acore-authserver"; Action = "restart" } })

$btnStartWorld.Add_Click({ Start-AsyncOperation -Operation "service_action" -Args @{ ServiceName = "acore-worldserver"; Action = "start" } })
$btnStopWorld.Add_Click({ Start-AsyncOperation -Operation "service_action" -Args @{ ServiceName = "acore-worldserver"; Action = "stop" } })
$btnRestartWorld.Add_Click({ Start-AsyncOperation -Operation "service_action" -Args @{ ServiceName = "acore-worldserver"; Action = "restart" } })
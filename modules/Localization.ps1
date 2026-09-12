# ==========================================
# Localization Module (localization.json)
# ==========================================
$script:LocKa = @{}
$script:LocEn = @{}

function Load-LocalizationData {
    $locPath = Join-Path $scriptRoot "localization.json"
    if (Test-Path -LiteralPath $locPath) {
        try {
            $locJson = Get-Content -LiteralPath $locPath -Raw -Encoding UTF8 | ConvertFrom-Json
            if ($locJson.ka) {
                $locJson.ka.psobject.properties | ForEach-Object { $script:LocKa[$_.Name] = [string]$_.Value }
            }
            if ($locJson.en) {
                $locJson.en.psobject.properties | ForEach-Object { $script:LocEn[$_.Name] = [string]$_.Value }
            }
        } catch {
            Write-Log -Message "Failed to load localization.json: $_" -Level "WARN"
        }
    }
}

Load-LocalizationData

function Get-Text {
    param([string]$Key)
    $curLang = if ($script:Language) { $script:Language } else { "ka" }
    $dict = if ($curLang -eq "ka") { $script:LocKa } else { $script:LocEn }
    if ($dict -and $dict.ContainsKey($Key)) {
        return $dict[$Key]
    }
    if ($script:LocEn -and $script:LocEn.ContainsKey($Key)) {
        return $script:LocEn[$Key]
    }
    return $Key
}

function Apply-UiLanguage {
    param([string]$NewLang)
    $script:Language = $NewLang

    if ($null -eq $form) { return }

    # Window & Top Panel
    $form.Text = Get-Text "AppTitle"
    if ($null -ne $lblTitle) { $lblTitle.Text = Get-Text "AppTitle" }
    if ($null -ne $lblHostBadge) { $lblHostBadge.Text = (Get-Text "CardServerHost") + ": $script:ServerIP" }
    if ($null -ne $lblLang) { $lblLang.Text = if ($script:Language -eq "ka") { "ენა / Language:" } else { "Language / ენა:" } }
    if ($null -ne $lblStatus -and -not ($progressBar -and $progressBar.Visible)) {
        $lblStatus.Text = Get-Text "StatusReady"
    }

    # Tab Headers
    if ($null -ne $tabDashboard)  { $tabDashboard.Text  = Get-Text "TabDashboard" }
    if ($null -ne $tabPlayers)    { $tabPlayers.Text    = Get-Text "TabPlayers" }
    if ($null -ne $tabConsole)    { $tabConsole.Text    = Get-Text "TabConsole" }
    if ($null -ne $tabRates)      { $tabRates.Text      = Get-Text "TabRates" }
    if ($null -ne $tabBackups)    { $tabBackups.Text    = Get-Text "TabBackups" }
    if ($null -ne $tabMonitoring) { $tabMonitoring.Text = Get-Text "TabMonitoring" }
    if ($null -ne $tabLogs)       { $tabLogs.Text       = Get-Text "TabLogs" }
    if ($null -ne $tabSettings)   { $tabSettings.Text   = Get-Text "TabSettings" }

    # Tab 1: Dashboard Cards, Badges & Buttons
    if ($null -ne $cardAuth -and $null -ne $cardAuth.Tag)   { $cardAuth.Tag.Text = Get-Text "CardAuth" }
    if ($null -ne $cardWorld -and $null -ne $cardWorld.Tag)  { $cardWorld.Tag.Text = Get-Text "CardWorld" }
    if ($null -ne $cardStats -and $null -ne $cardStats.Tag)  { $cardStats.Tag.Text = Get-Text "CardOnlineSummary" }
    if ($null -ne $cardQuick -and $null -ne $cardQuick.Tag)  { $cardQuick.Tag.Text = Get-Text "QuickActions" }

    if (Get-Command "Update-DashboardBadgesUi" -ErrorAction SilentlyContinue) {
        Update-DashboardBadgesUi
    }

    if ($null -ne $btnStartAuth)   { $btnStartAuth.Text   = Get-Text "BtnStartAuth" }
    if ($null -ne $btnStopAuth)    { $btnStopAuth.Text    = Get-Text "BtnStopAuth" }
    if ($null -ne $btnRestartAuth) { $btnRestartAuth.Text = Get-Text "BtnRestartAuth" }
    if ($null -ne $btnStartWorld)  { $btnStartWorld.Text  = Get-Text "BtnStartWorld" }
    if ($null -ne $btnStopWorld)   { $btnStopWorld.Text   = Get-Text "BtnStopWorld" }
    if ($null -ne $btnRestartWorld){ $btnRestartWorld.Text= Get-Text "BtnRestartWorld" }
    if ($null -ne $btnFullRefresh) { $btnFullRefresh.Text = Get-Text "BtnRefreshAll" }
    if ($null -ne $btnQuickBackup) { $btnQuickBackup.Text = Get-Text "BtnCreateBackup" }

    # Tab 2: Players & Realm
    if (Get-Command "Update-PlayersSummaryLabels" -ErrorAction SilentlyContinue) {
        Update-PlayersSummaryLabels
    }
    if ($null -ne $btnRefreshPlayers) { $btnRefreshPlayers.Text = Get-Text "BtnRefreshPlayers" }
    if ($null -ne $btnKickPlayer)     { $btnKickPlayer.Text     = Get-Text "BtnKickPlayer" }
    if ($null -ne $ttPlayerFilter -and $null -ne $txtPlayerFilter) {
        $ttPlayerFilter.SetToolTip($txtPlayerFilter, (Get-Text "TxtPlayerFilterPlaceholder"))
    }

    # DataGridView Players Column Headers
    if ($null -ne $gridPlayers -and $gridPlayers.Columns.Count -ge 8) {
        $gridPlayers.Columns["Guid"].HeaderText    = Get-Text "ColGuid"
        $gridPlayers.Columns["Name"].HeaderText    = Get-Text "ColName"
        $gridPlayers.Columns["Level"].HeaderText   = Get-Text "ColLevel"
        $gridPlayers.Columns["Race"].HeaderText    = Get-Text "ColRace"
        $gridPlayers.Columns["Faction"].HeaderText = Get-Text "ColFaction"
        $gridPlayers.Columns["Class"].HeaderText   = Get-Text "ColClass"
        $gridPlayers.Columns["Zone"].HeaderText    = Get-Text "ColZone"
        $gridPlayers.Columns["Account"].HeaderText = Get-Text "ColAccount"
    }

    # Tab 3: Console
    if ($null -ne $btnAnnounce)      { $btnAnnounce.Text      = Get-Text "BtnAnnounce" }
    if ($null -ne $btnSaveAll)       { $btnSaveAll.Text       = Get-Text "BtnSaveAll" }
    if ($null -ne $btnServerInfo)    { $btnServerInfo.Text    = Get-Text "BtnServerInfo" }
    if ($null -ne $btnServerRestart) { $btnServerRestart.Text = Get-Text "BtnServerRestart" }
    if ($null -ne $btnRestartCancel) { $btnRestartCancel.Text = Get-Text "BtnRestartCancel" }
    if ($null -ne $btnClearConsole)  { $btnClearConsole.Text  = Get-Text "BtnClearConsole" }
    if ($null -ne $lblCmdPrompt)     { $lblCmdPrompt.Text     = Get-Text "LblCommand" }
    if ($null -ne $btnSendCmd)       { $btnSendCmd.Text       = Get-Text "BtnSendCmd" }

    # Tab 4: Rates & Config
    if ($null -ne $lblRatesNotice) { $lblRatesNotice.Text = Get-Text "RatesNotice" }
    if ($null -ne $lblSecProgression) { $lblSecProgression.Text = Get-Text "SecProgression" }
    if ($null -ne $lblSecDrops)       { $lblSecDrops.Text       = Get-Text "SecDrops" }
    if ($null -ne $lblSecQoL)         { $lblSecQoL.Text         = Get-Text "SecQoL" }
    if ($null -ne $lblSecCross)       { $lblSecCross.Text       = Get-Text "SecCrossFaction" }
    if ($null -ne $lblSecMotd)        { $lblSecMotd.Text        = Get-Text "SecMotd" }

    $rateNumericControls = @(
        $numKillXp, $numQuestXp, $numExploreXp, $numReputation, $numCrafting, $numGathering,
        $numHonor, $numArenaPoints, $numTalent, $numMoneyDrop, $numDropPoor, $numDropNormal,
        $numDropUncommon, $numDropRare, $numDropEpic, $numPlayerLimit, $numMoveSpeed,
        $numStartLevel, $numStartGold, $numPetitionSigns
    )
    foreach ($ctrl in $rateNumericControls) {
        if ($null -ne $ctrl -and $null -ne $ctrl.Tag) {
            $tag = $ctrl.Tag
            if ($tag -is [hashtable]) {
                if ($tag.LabelControl -and $tag.LabelKey) {
                    $tag.LabelControl.Text = Get-Text $tag.LabelKey
                }
                if ($script:RatesToolTip -and $tag.TipKey) {
                    $tip = Get-Text $tag.TipKey
                    $script:RatesToolTip.SetToolTip($ctrl, $tip)
                    if ($tag.LabelControl) {
                        $script:RatesToolTip.SetToolTip($tag.LabelControl, $tip)
                    }
                }
            }
        }
    }

    $rateCheckboxes = @($chkFlightPaths, $chkCrossGroup, $chkCrossGuild, $chkCrossChat)
    foreach ($chk in $rateCheckboxes) {
        if ($null -ne $chk -and $null -ne $chk.Tag) {
            $tag = $chk.Tag
            if ($tag -is [hashtable]) {
                if ($tag.LabelKey) { $chk.Text = Get-Text $tag.LabelKey }
                if ($script:RatesToolTip -and $tag.TipKey) {
                    $script:RatesToolTip.SetToolTip($chk, (Get-Text $tag.TipKey))
                }
            }
        }
    }

    if ($null -ne $lblMotd) {
        $lblMotd.Text = Get-Text "LblMotd"
        if ($script:RatesToolTip) { $script:RatesToolTip.SetToolTip($lblMotd, (Get-Text "TipMotd")) }
    }
    if ($null -ne $txtMotd -and $script:RatesToolTip) {
        $script:RatesToolTip.SetToolTip($txtMotd, (Get-Text "TipMotd"))
    }

    if ($null -ne $btnLoadRates)   { $btnLoadRates.Text   = Get-Text "BtnLoadRates" }
    if ($null -ne $btnSaveRates)   { $btnSaveRates.Text   = Get-Text "BtnSaveRates" }

    # Tab 5: Backups
    if (Get-Command "Update-BackupsSummaryLabel" -ErrorAction SilentlyContinue) {
        Update-BackupsSummaryLabel
    }
    if ($null -ne $btnCreateBackup)  { $btnCreateBackup.Text   = Get-Text "BtnCreateBackup" }
    if ($null -ne $btnRefreshBackups){ $btnRefreshBackups.Text = Get-Text "BtnRefreshBackups" }
    if ($null -ne $btnDeleteBackup)  { $btnDeleteBackup.Text   = Get-Text "BtnDeleteBackup" }
    if ($null -ne $btnPurgeBackups)  { $btnPurgeBackups.Text   = Get-Text "BtnPurgeBackups" }

    # DataGridView Backups Column Headers
    if ($null -ne $gridBackups -and $gridBackups.Columns.Count -ge 3) {
        $gridBackups.Columns["FileName"].HeaderText = Get-Text "ColFileName"
        $gridBackups.Columns["Size"].HeaderText     = Get-Text "ColSize"
        $gridBackups.Columns["Date"].HeaderText     = Get-Text "ColDate"
    }

    # Tab 6: Monitoring
    if ($null -ne $widgetCpu -and $null -ne $widgetCpu.TitleLabel)   { $widgetCpu.TitleLabel.Text  = Get-Text "CpuUsage" }
    if ($null -ne $widgetRam -and $null -ne $widgetRam.TitleLabel)   { $widgetRam.TitleLabel.Text  = Get-Text "RamUsage" }
    if ($null -ne $widgetDisk -and $null -ne $widgetDisk.TitleLabel) { $widgetDisk.TitleLabel.Text = Get-Text "DiskUsage" }
    if ($null -ne $lblUptimeTitle)                                   { $lblUptimeTitle.Text        = Get-Text "SystemUptime" }

    # Tab 7: Logs
    if ($null -ne $comboLogType) {
        $curLogIdx = $comboLogType.SelectedIndex
        $comboLogType.Items.Clear()
        $comboLogType.Items.AddRange(@((Get-Text "LogWorld"), (Get-Text "LogAuth"), (Get-Text "LogLocal")))
        $comboLogType.SelectedIndex = if ($curLogIdx -ge 0 -and $curLogIdx -lt 3) { $curLogIdx } else { 0 }
    }
    if ($null -ne $lblTail)       { $lblTail.Text       = Get-Text "LblTailLines" }
    if ($null -ne $btnRefreshLog) { $btnRefreshLog.Text = Get-Text "BtnRefreshLog" }
    if ($null -ne $chkAutoScroll) { $chkAutoScroll.Text = Get-Text "ChkAutoScroll" }

    # Tab 8: Settings
    if ($null -ne $txtSetHostIp -and $null -ne $txtSetHostIp.Tag)       { $txtSetHostIp.Tag.Text    = Get-Text "LblHostIp" }
    if ($null -ne $txtSetSshUser -and $null -ne $txtSetSshUser.Tag)     { $txtSetSshUser.Tag.Text   = Get-Text "LblSshUser" }
    if ($null -ne $txtSetSshPass -and $null -ne $txtSetSshPass.Tag)     { $txtSetSshPass.Tag.Text   = Get-Text "LblSshPass" }
    if ($null -ne $txtSetSshKey -and $null -ne $txtSetSshKey.Tag)       { $txtSetSshKey.Tag.Text    = Get-Text "LblSshKey" }
    if ($null -ne $txtSetSoapUser -and $null -ne $txtSetSoapUser.Tag)   { $txtSetSoapUser.Tag.Text  = Get-Text "LblSoapUser" }
    if ($null -ne $txtSetSoapPass -and $null -ne $txtSetSoapPass.Tag)   { $txtSetSoapPass.Tag.Text  = Get-Text "LblSoapPass" }
    if ($null -ne $txtSetSoapPort -and $null -ne $txtSetSoapPort.Tag)   { $txtSetSoapPort.Tag.Text  = Get-Text "LblSoapPort" }
    if ($null -ne $txtSetAutoRef -and $null -ne $txtSetAutoRef.Tag)     { $txtSetAutoRef.Tag.Text   = Get-Text "LblAutoRefresh" }
    if ($null -ne $txtSetRetention -and $null -ne $txtSetRetention.Tag) { $txtSetRetention.Tag.Text = Get-Text "LblBackupRetention" }

    if ($null -ne $btnSaveSettings) { $btnSaveSettings.Text = Get-Text "BtnSaveSettings" }
    if ($null -ne $btnTestSsh)      { $btnTestSsh.Text      = Get-Text "BtnTestSsh" }
    if ($null -ne $btnTestSoap)     { $btnTestSoap.Text     = Get-Text "BtnTestSoap" }
}
# ==========================================
# Tab 2: Players & Realm Stats (áƒ›áƒáƒ—áƒáƒ›áƒáƒ¨áƒ”áƒ”áƒ‘áƒ˜)
# ==========================================
$pnlPlayersTop = New-Object System.Windows.Forms.Panel
$pnlPlayersTop.Dock = [System.Windows.Forms.DockStyle]::Top
$pnlPlayersTop.Height = 70
$pnlPlayersTop.BackColor = $cardBg
$tabPlayers.Controls.Add($pnlPlayersTop)

$lblPlayersTotal = New-Object System.Windows.Forms.Label
$lblPlayersTotal.Text = (Get-Text "PlayersTotal") + "0"
$lblPlayersTotal.Font = $fontSubHeader
$lblPlayersTotal.ForeColor = $accentGreen
$lblPlayersTotal.Location = New-Object System.Drawing.Point(16, 12)
$lblPlayersTotal.AutoSize = $true
$pnlPlayersTop.Controls.Add($lblPlayersTotal)

$lblPlayersAlliance = New-Object System.Windows.Forms.Label
$lblPlayersAlliance.Text = (Get-Text "PlayersAlliance") + "0"
$lblPlayersAlliance.Font = $fontSubHeader
$lblPlayersAlliance.ForeColor = [System.Drawing.Color]::FromArgb(60, 140, 255)
$lblPlayersAlliance.Location = New-Object System.Drawing.Point(200, 12)
$lblPlayersAlliance.AutoSize = $true
$pnlPlayersTop.Controls.Add($lblPlayersAlliance)

$lblPlayersHorde = New-Object System.Windows.Forms.Label
$lblPlayersHorde.Text = (Get-Text "PlayersHorde") + "0"
$lblPlayersHorde.Font = $fontSubHeader
$lblPlayersHorde.ForeColor = [System.Drawing.Color]::FromArgb(255, 75, 75)
$lblPlayersHorde.Location = New-Object System.Drawing.Point(380, 12)
$lblPlayersHorde.AutoSize = $true
$pnlPlayersTop.Controls.Add($lblPlayersHorde)

$lblPlayersRatio = New-Object System.Windows.Forms.Label
$lblPlayersRatio.Text = (Get-Text "PlayersRatio") + "0% / 0%"
$lblPlayersRatio.Font = $fontSubHeader
$lblPlayersRatio.ForeColor = $accentOrange
$lblPlayersRatio.Location = New-Object System.Drawing.Point(540, 12)
$lblPlayersRatio.AutoSize = $true
$pnlPlayersTop.Controls.Add($lblPlayersRatio)

# Search Box & Action Buttons
$txtPlayerFilter = New-Object System.Windows.Forms.TextBox
$txtPlayerFilter.Font = $fontBody
$txtPlayerFilter.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 30)
$txtPlayerFilter.ForeColor = $textLight
$txtPlayerFilter.Location = New-Object System.Drawing.Point(16, 38)
$txtPlayerFilter.Size = New-Object System.Drawing.Size(260, 24)
$pnlPlayersTop.Controls.Add($txtPlayerFilter)

$ttPlayerFilter = New-Object System.Windows.Forms.ToolTip
$ttPlayerFilter.SetToolTip($txtPlayerFilter, (Get-Text "TxtPlayerFilterPlaceholder"))

$btnRefreshPlayers = New-StyledButton -Text (Get-Text "BtnRefreshPlayers") -BgColor $accentBlue -Location (New-Object System.Drawing.Point(290, 35)) -Size (New-Object System.Drawing.Size(180, 28))
$btnKickPlayer    = New-StyledButton -Text (Get-Text "BtnKickPlayer")    -BgColor $accentRed  -Location (New-Object System.Drawing.Point(485, 35)) -Size (New-Object System.Drawing.Size(180, 28))
$pnlPlayersTop.Controls.AddRange(@($btnRefreshPlayers, $btnKickPlayer))

# DataGridView for Players
$gridPlayers = New-Object System.Windows.Forms.DataGridView
$gridPlayers.Dock = [System.Windows.Forms.DockStyle]::Fill
$gridPlayers.BackgroundColor = $bgDark
$gridPlayers.ForeColor = $textLight
$gridPlayers.DefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(30, 32, 48)
$gridPlayers.DefaultCellStyle.ForeColor = $textLight
$gridPlayers.DefaultCellStyle.SelectionBackColor = [System.Drawing.Color]::FromArgb(65, 72, 104)
$gridPlayers.DefaultCellStyle.SelectionForeColor = [System.Drawing.Color]::White
$gridPlayers.AlternatingRowsDefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(24, 26, 38)
$gridPlayers.ColumnHeadersDefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(40, 44, 65)
$gridPlayers.ColumnHeadersDefaultCellStyle.ForeColor = $accentBlue
$gridPlayers.ColumnHeadersDefaultCellStyle.Font = $fontBold
$gridPlayers.EnableHeadersVisualStyles = $false
$gridPlayers.AllowUserToAddRows = $false
$gridPlayers.AllowUserToDeleteRows = $false
$gridPlayers.ReadOnly = $true
$gridPlayers.SelectionMode = [System.Windows.Forms.DataGridViewSelectionMode]::FullRowSelect
$gridPlayers.MultiSelect = $false
$gridPlayers.RowHeadersVisible = $false
$gridPlayers.BorderStyle = [System.Windows.Forms.BorderStyle]::None
$tabPlayers.Controls.Add($gridPlayers)
$gridPlayers.BringToFront()

# Columns
$gridPlayers.Columns.Add("Guid", (Get-Text "ColGuid")) | Out-Null
$gridPlayers.Columns.Add("Name", (Get-Text "ColName")) | Out-Null
$gridPlayers.Columns.Add("Level", (Get-Text "ColLevel")) | Out-Null
$gridPlayers.Columns.Add("Race", (Get-Text "ColRace")) | Out-Null
$gridPlayers.Columns.Add("Faction", (Get-Text "ColFaction")) | Out-Null
$gridPlayers.Columns.Add("Class", (Get-Text "ColClass")) | Out-Null
$gridPlayers.Columns.Add("Zone", (Get-Text "ColZone")) | Out-Null
$gridPlayers.Columns.Add("Account", (Get-Text "ColAccount")) | Out-Null

$gridPlayers.Columns["Guid"].Width = 70
$gridPlayers.Columns["Name"].Width = 140
$gridPlayers.Columns["Level"].Width = 60
$gridPlayers.Columns["Race"].Width = 110
$gridPlayers.Columns["Faction"].Width = 100
$gridPlayers.Columns["Class"].Width = 120
$gridPlayers.Columns["Zone"].Width = 200
$gridPlayers.Columns["Account"].AutoSizeMode = [System.Windows.Forms.DataGridViewAutoSizeColumnMode]::Fill

# Event Handlers
$btnRefreshPlayers.Add_Click({ Start-AsyncOperation -Operation "fetch_players" })
$txtPlayerFilter.Add_TextChanged({ Filter-PlayersGrid })

$btnKickPlayer.Add_Click({
    if ($gridPlayers.SelectedRows.Count -gt 0) {
        $pName = $gridPlayers.SelectedRows[0].Cells["Name"].Value
        $msg = [string]::Format((Get-Text "ConfirmKick"), $pName)
        $ans = [System.Windows.Forms.MessageBox]::Show($msg, "Kick Player", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
        if ($ans -eq [System.Windows.Forms.DialogResult]::Yes) {
            Start-AsyncOperation -Operation "send_console_cmd" -Args @{ Command = ".kick $pName" }
        }
    }
})
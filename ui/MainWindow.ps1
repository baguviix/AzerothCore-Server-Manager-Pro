# ==========================================
# Main Form & Window Frame
# ==========================================
$form = New-Object System.Windows.Forms.Form
$form.Text = Get-Text "AppTitle"
$form.Size = New-Object System.Drawing.Size(1060, 750)
$form.MinimumSize = New-Object System.Drawing.Size(960, 650)
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$form.BackColor = $bgDark
$form.ForeColor = $textLight
$form.ShowInTaskbar = $true

# Top Header Panel
$topPanel = New-Object System.Windows.Forms.Panel
$topPanel.Dock = [System.Windows.Forms.DockStyle]::Top
$topPanel.Height = 62
$topPanel.BackColor = [System.Drawing.Color]::FromArgb(22, 22, 30)
$form.Controls.Add($topPanel)

$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text = Get-Text "AppTitle"
$lblTitle.Font = $fontHeader
$lblTitle.ForeColor = $accentBlue
$lblTitle.Location = New-Object System.Drawing.Point(16, 16)
$lblTitle.AutoSize = $true
$topPanel.Controls.Add($lblTitle)

$lblHostBadge = New-Object System.Windows.Forms.Label
$lblHostBadge.Text = "Host: $script:ServerIP"
$lblHostBadge.Font = $fontSmall
$lblHostBadge.ForeColor = [System.Drawing.Color]::FromArgb(150, 160, 180)
$lblHostBadge.Location = New-Object System.Drawing.Point(18, 40)
$lblHostBadge.AutoSize = $true
$topPanel.Controls.Add($lblHostBadge)

$lblLang = New-Object System.Windows.Forms.Label
$lblLang.Text = "Language / ენა:"
$lblLang.Font = $fontSmall
$lblLang.ForeColor = $textLight
$lblLang.Location = New-Object System.Drawing.Point(850, 20)
$lblLang.AutoSize = $true
$topPanel.Controls.Add($lblLang)

$comboLanguage = New-Object System.Windows.Forms.ComboBox
$comboLanguage.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$comboLanguage.Font = $fontSmall
$comboLanguage.BackColor = $cardBg
$comboLanguage.ForeColor = $textLight
$comboLanguage.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$comboLanguage.Location = New-Object System.Drawing.Point(950, 16)
$comboLanguage.Size = New-Object System.Drawing.Size(90, 24)
$comboLanguage.Items.AddRange(@("ქართული", "English"))
$comboLanguage.SelectedIndex = if ($script:Language -eq "ka") { 0 } else { 1 }
$topPanel.Controls.Add($comboLanguage)

# Bottom Status Strip
$bottomPanel = New-Object System.Windows.Forms.Panel
$bottomPanel.Dock = [System.Windows.Forms.DockStyle]::Bottom
$bottomPanel.Height = 32
$bottomPanel.BackColor = [System.Drawing.Color]::FromArgb(22, 22, 30)
$form.Controls.Add($bottomPanel)

$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Text = Get-Text "StatusReady"
$lblStatus.Font = $fontSmall
$lblStatus.ForeColor = $accentGreen
$lblStatus.Location = New-Object System.Drawing.Point(16, 8)
$lblStatus.AutoSize = $true
$bottomPanel.Controls.Add($lblStatus)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(750, 6)
$progressBar.Size = New-Object System.Drawing.Size(280, 18)
$progressBar.Visible = $false
$bottomPanel.Controls.Add($progressBar)

# Main TabControl
$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.Dock = [System.Windows.Forms.DockStyle]::Fill
$tabControl.Font = $fontBody
$form.Controls.Add($tabControl)
$tabControl.BringToFront()

function Add-ManagedTab {
    param([string]$Key, [string]$Title)
    $tp = New-Object System.Windows.Forms.TabPage
    $tp.Text = $Title
    $tp.Name = $Key
    $tp.BackColor = $bgDark
    $tp.ForeColor = $textLight
    $tabControl.TabPages.Add($tp) | Out-Null
    return $tp
}

$tabDashboard = Add-ManagedTab -Key "tabDashboard" -Title (Get-Text "TabDashboard")
$tabPlayers   = Add-ManagedTab -Key "tabPlayers"   -Title (Get-Text "TabPlayers")
$tabConsole   = Add-ManagedTab -Key "tabConsole"   -Title (Get-Text "TabConsole")
$tabRates     = Add-ManagedTab -Key "tabRates"     -Title (Get-Text "TabRates")
$tabBackups   = Add-ManagedTab -Key "tabBackups"   -Title (Get-Text "TabBackups")
$tabMonitoring= Add-ManagedTab -Key "tabMonitoring"-Title (Get-Text "TabMonitoring")
$tabLogs      = Add-ManagedTab -Key "tabLogs"      -Title (Get-Text "TabLogs")
$tabSettings  = Add-ManagedTab -Key "tabSettings"  -Title (Get-Text "TabSettings")
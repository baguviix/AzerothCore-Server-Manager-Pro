# ==========================================
# Tab 5: Backups & Storage (áƒ¡áƒáƒ áƒ”áƒ–áƒ”áƒ áƒ•áƒ áƒáƒ¡áƒšáƒ”áƒ‘áƒ˜)
# ==========================================
$pnlBackupsTop = New-Object System.Windows.Forms.Panel
$pnlBackupsTop.Dock = [System.Windows.Forms.DockStyle]::Top
$pnlBackupsTop.Height = 76
$pnlBackupsTop.BackColor = $cardBg
$tabBackups.Controls.Add($pnlBackupsTop)

$script:BackupsCount = 0
$script:BackupsTotalMb = 0

function Update-BackupsSummaryLabel {
    if ($null -ne $lblBackupsStorage) {
        $count = if ($null -ne $script:BackupsCount) { $script:BackupsCount } else { 0 }
        $totalMb = if ($null -ne $script:BackupsTotalMb) { $script:BackupsTotalMb } else { 0 }
        $lblBackupsStorage.Text = [string]::Format((Get-Text "BackupsStorage"), $count, $totalMb, $script:BackupRetentionCount)
    }
}

$lblBackupsStorage = New-Object System.Windows.Forms.Label
$lblBackupsStorage.Text = [string]::Format((Get-Text "BackupsStorage"), 0, 0, $script:BackupRetentionCount)
$lblBackupsStorage.Font = $fontSubHeader
$lblBackupsStorage.ForeColor = $accentGreen
$lblBackupsStorage.Location = New-Object System.Drawing.Point(16, 12)
$lblBackupsStorage.AutoSize = $true
$pnlBackupsTop.Controls.Add($lblBackupsStorage)

$btnCreateBackup  = New-StyledButton -Text (Get-Text "BtnCreateBackup")  -BgColor $accentGreen -Location (New-Object System.Drawing.Point(16, 38))  -Size (New-Object System.Drawing.Size(190, 30))
$btnRefreshBackups = New-StyledButton -Text (Get-Text "BtnRefreshBackups") -BgColor $accentBlue  -Location (New-Object System.Drawing.Point(216, 38)) -Size (New-Object System.Drawing.Size(150, 30))
$btnDeleteBackup  = New-StyledButton -Text (Get-Text "BtnDeleteBackup")  -BgColor $accentRed   -Location (New-Object System.Drawing.Point(376, 38)) -Size (New-Object System.Drawing.Size(180, 30))
$btnPurgeBackups  = New-StyledButton -Text (Get-Text "BtnPurgeBackups")  -BgColor $accentOrange -Location (New-Object System.Drawing.Point(566, 38)) -Size (New-Object System.Drawing.Size(190, 30))
$pnlBackupsTop.Controls.AddRange(@($btnCreateBackup, $btnRefreshBackups, $btnDeleteBackup, $btnPurgeBackups))

$gridBackups = New-Object System.Windows.Forms.DataGridView
$gridBackups.Dock = [System.Windows.Forms.DockStyle]::Fill
$gridBackups.BackgroundColor = $bgDark
$gridBackups.ForeColor = $textLight
$gridBackups.DefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(30, 32, 48)
$gridBackups.DefaultCellStyle.ForeColor = $textLight
$gridBackups.DefaultCellStyle.SelectionBackColor = [System.Drawing.Color]::FromArgb(65, 72, 104)
$gridBackups.DefaultCellStyle.SelectionForeColor = [System.Drawing.Color]::White
$gridBackups.AlternatingRowsDefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(24, 26, 38)
$gridBackups.ColumnHeadersDefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(40, 44, 65)
$gridBackups.ColumnHeadersDefaultCellStyle.ForeColor = $accentBlue
$gridBackups.ColumnHeadersDefaultCellStyle.Font = $fontBold
$gridBackups.EnableHeadersVisualStyles = $false
$gridBackups.AllowUserToAddRows = $false
$gridBackups.AllowUserToDeleteRows = $false
$gridBackups.ReadOnly = $true
$gridBackups.SelectionMode = [System.Windows.Forms.DataGridViewSelectionMode]::FullRowSelect
$gridBackups.MultiSelect = $false
$gridBackups.RowHeadersVisible = $false
$gridBackups.BorderStyle = [System.Windows.Forms.BorderStyle]::None
$tabBackups.Controls.Add($gridBackups)
$gridBackups.BringToFront()

$gridBackups.Columns.Add("FileName", (Get-Text "ColFileName")) | Out-Null
$gridBackups.Columns.Add("Size", (Get-Text "ColSize")) | Out-Null
$gridBackups.Columns.Add("Date", (Get-Text "ColDate")) | Out-Null
$gridBackups.Columns["FileName"].AutoSizeMode = [System.Windows.Forms.DataGridViewAutoSizeColumnMode]::Fill
$gridBackups.Columns["Size"].Width = 140
$gridBackups.Columns["Date"].Width = 220

function Update-BackupsUi {
    param([string]$RawData)
    if ($null -eq $gridBackups) { return }
    $gridBackups.Rows.Clear()
    $totalMb = 0
    $count = 0

    $lines = $RawData -split "`r?`n"
    foreach ($line in $lines) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        $parts = $line -split "`t"
        if ($parts.Length -ge 3) {
            $bytes = [long]$parts[0]
            $date  = $parts[1]
            $file  = [System.IO.Path]::GetFileName($parts[2])
            $mb = [math]::Round(($bytes / 1048576), 2)
            $totalMb += $mb
            $count++

            $gridBackups.Rows.Add(@($file, "$mb MB", $date)) | Out-Null
        }
    }
    $script:BackupsCount = $count
    $script:BackupsTotalMb = $totalMb
    Update-BackupsSummaryLabel
}

# Event Handlers
$btnCreateBackup.Add_Click({ Start-AsyncOperation -Operation "create_backup" })
$btnRefreshBackups.Add_Click({ Start-AsyncOperation -Operation "list_backups" })
$btnPurgeBackups.Add_Click({ Start-AsyncOperation -Operation "purge_backups" -Args @{ RetentionCount = $script:BackupRetentionCount } })

$btnDeleteBackup.Add_Click({
    if ($gridBackups.SelectedRows.Count -gt 0) {
        $fName = $gridBackups.SelectedRows[0].Cells["FileName"].Value
        $msg = [string]::Format((Get-Text "ConfirmDeleteBackup"), $fName)
        $ans = [System.Windows.Forms.MessageBox]::Show($msg, "Delete Backup", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Warning)
        if ($ans -eq [System.Windows.Forms.DialogResult]::Yes) {
            Start-AsyncOperation -Operation "delete_backup" -Args @{ FileName = $fName }
        }
    }
})
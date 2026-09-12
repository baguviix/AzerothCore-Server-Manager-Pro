# ==========================================
# Tab 7: Logs (áƒ¡áƒ”áƒ áƒ•áƒ”áƒ áƒ˜áƒ¡ áƒ“áƒ áƒáƒžáƒšáƒ˜áƒ™áƒáƒªáƒ˜áƒ˜áƒ¡ áƒšáƒáƒ’áƒ”áƒ‘áƒ˜)
# ==========================================
$pnlLogsTop = New-Object System.Windows.Forms.Panel
$pnlLogsTop.Dock = [System.Windows.Forms.DockStyle]::Top
$pnlLogsTop.Height = 50
$pnlLogsTop.BackColor = $cardBg
$tabLogs.Controls.Add($pnlLogsTop)

$comboLogType = New-Object System.Windows.Forms.ComboBox
$comboLogType.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$comboLogType.Font = $fontBody
$comboLogType.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 30)
$comboLogType.ForeColor = $textLight
$comboLogType.Location = New-Object System.Drawing.Point(16, 12)
$comboLogType.Size = New-Object System.Drawing.Size(200, 24)
$comboLogType.Items.AddRange(@((Get-Text "LogWorld"), (Get-Text "LogAuth"), (Get-Text "LogLocal")))
$comboLogType.SelectedIndex = 0
$pnlLogsTop.Controls.Add($comboLogType)

$lblTail = New-Object System.Windows.Forms.Label
$lblTail.Text = (Get-Text "LblTailLines")
$lblTail.Font = $fontBody
$lblTail.ForeColor = $textLight
$lblTail.Location = New-Object System.Drawing.Point(230, 15)
$lblTail.AutoSize = $true
$pnlLogsTop.Controls.Add($lblTail)

$comboLogLines = New-Object System.Windows.Forms.ComboBox
$comboLogLines.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$comboLogLines.Font = $fontBody
$comboLogLines.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 30)
$comboLogLines.ForeColor = $textLight
$comboLogLines.Location = New-Object System.Drawing.Point(290, 12)
$comboLogLines.Size = New-Object System.Drawing.Size(80, 24)
$comboLogLines.Items.AddRange(@("50", "100", "200", "500"))
$comboLogLines.SelectedIndex = 1
$pnlLogsTop.Controls.Add($comboLogLines)

$btnRefreshLog = New-StyledButton -Text (Get-Text "BtnRefreshLog") -BgColor $accentBlue -Location (New-Object System.Drawing.Point(390, 10)) -Size (New-Object System.Drawing.Size(140, 28))
$pnlLogsTop.Controls.Add($btnRefreshLog)

$chkAutoScroll = New-Object System.Windows.Forms.CheckBox
$chkAutoScroll.Text = (Get-Text "ChkAutoScroll")
$chkAutoScroll.Font = $fontBody
$chkAutoScroll.ForeColor = $textLight
$chkAutoScroll.Location = New-Object System.Drawing.Point(550, 14)
$chkAutoScroll.Checked = $true
$chkAutoScroll.AutoSize = $true
$pnlLogsTop.Controls.Add($chkAutoScroll)

$rtbLogs = New-Object System.Windows.Forms.RichTextBox
$rtbLogs.Dock = [System.Windows.Forms.DockStyle]::Fill
$rtbLogs.BackColor = [System.Drawing.Color]::FromArgb(15, 17, 26)
$rtbLogs.ForeColor = [System.Drawing.Color]::FromArgb(200, 220, 240)
$rtbLogs.Font = $fontConsole
$rtbLogs.ReadOnly = $true
$rtbLogs.BorderStyle = [System.Windows.Forms.BorderStyle]::None
$tabLogs.Controls.Add($rtbLogs)
$rtbLogs.BringToFront()

function Update-LogsUi {
    param([string]$Text)
    if ($null -eq $rtbLogs) { return }
    $rtbLogs.Text = $Text
    if ($chkAutoScroll.Checked) {
        $rtbLogs.SelectionStart = $rtbLogs.TextLength
        $rtbLogs.ScrollToCaret()
    }
}

# Event Handlers
$btnRefreshLog.Add_Click({
    $type = switch ($comboLogType.SelectedIndex) {
        0 { "world" }
        1 { "auth" }
        default { "local" }
    }
    if ($type -eq "local") {
        $logPath = if ([System.IO.Path]::IsPathRooted($script:LogFile)) { $script:LogFile } else { Join-Path $scriptRoot $script:LogFile }
        if (Test-Path -LiteralPath $logPath) {
            $rtbLogs.Text = Get-Content -LiteralPath $logPath -Tail 200 -Encoding UTF8 | Out-String
            if ($chkAutoScroll.Checked) {
                $rtbLogs.SelectionStart = $rtbLogs.TextLength
                $rtbLogs.ScrollToCaret()
            }
        }
    } else {
        $lines = [int]$comboLogLines.SelectedItem
        Start-AsyncOperation -Operation "load_log" -Args @{ LogType = $type; Lines = $lines }
    }
})
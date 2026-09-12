# ==========================================
# Tab 6: Monitoring (áƒ¡áƒ˜áƒ¡áƒ¢áƒ”áƒ›áƒ˜áƒ¡ áƒ›áƒáƒœáƒ˜áƒ¢áƒáƒ áƒ˜áƒœáƒ’áƒ˜)
# ==========================================
$pnlMonContainer = New-Object System.Windows.Forms.Panel
$pnlMonContainer.Dock = [System.Windows.Forms.DockStyle]::Fill
$pnlMonContainer.BackColor = $bgDark
$tabMonitoring.Controls.Add($pnlMonContainer)

$widgetCpu  = New-MetricWidget -Parent $pnlMonContainer -Title (Get-Text "CpuUsage")  -Location (New-Object System.Drawing.Point(30, 30))  -Size (New-Object System.Drawing.Size(460, 120))
$widgetRam  = New-MetricWidget -Parent $pnlMonContainer -Title (Get-Text "RamUsage")  -Location (New-Object System.Drawing.Point(520, 30)) -Size (New-Object System.Drawing.Size(460, 120))
$widgetDisk = New-MetricWidget -Parent $pnlMonContainer -Title (Get-Text "DiskUsage") -Location (New-Object System.Drawing.Point(30, 180)) -Size (New-Object System.Drawing.Size(460, 120))

$pnlUptime = New-Object System.Windows.Forms.Panel
$pnlUptime.Location = New-Object System.Drawing.Point(520, 180)
$pnlUptime.Size = New-Object System.Drawing.Size(460, 120)
$pnlUptime.BackColor = $cardBg
$pnlUptime.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$pnlMonContainer.Controls.Add($pnlUptime)

$lblUptimeTitle = New-Object System.Windows.Forms.Label
$lblUptimeTitle.Text = (Get-Text "SystemUptime")
$lblUptimeTitle.Font = $fontSubHeader
$lblUptimeTitle.ForeColor = $accentBlue
$lblUptimeTitle.Location = New-Object System.Drawing.Point(16, 14)
$lblUptimeTitle.AutoSize = $true
$pnlUptime.Controls.Add($lblUptimeTitle)

$lblUptimeVal = New-Object System.Windows.Forms.Label
$lblUptimeVal.Text = "Uptime: Unknown"
$lblUptimeVal.Font = $fontBold
$lblUptimeVal.ForeColor = $accentGreen
$lblUptimeVal.Location = New-Object System.Drawing.Point(16, 45)
$lblUptimeVal.Size = New-Object System.Drawing.Size(420, 60)
$pnlUptime.Controls.Add($lblUptimeVal)
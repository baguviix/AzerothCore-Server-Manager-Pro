# ==========================================
# Tab 8: Settings (áƒžáƒáƒ áƒáƒ›áƒ”áƒ¢áƒ áƒ”áƒ‘áƒ˜)
# ==========================================
$pnlSettings = New-Object System.Windows.Forms.Panel
$pnlSettings.Dock = [System.Windows.Forms.DockStyle]::Fill
$pnlSettings.BackColor = $bgDark
$tabSettings.Controls.Add($pnlSettings)

function Add-SettingInputRow {
    param(
        [System.Windows.Forms.Control]$Parent,
        [string]$LabelText,
        [string]$ValueText,
        [int]$TopY,
        [bool]$IsPassword = $false
    )
    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = $LabelText
    $lbl.Font = $fontBold
    $lbl.ForeColor = $textLight
    $lbl.Location = New-Object System.Drawing.Point(30, $TopY)
    $lbl.Size = New-Object System.Drawing.Size(260, 24)
    $Parent.Controls.Add($lbl)

    $txt = New-Object System.Windows.Forms.TextBox
    $txt.Font = $fontBody
    $txt.BackColor = $cardBg
    $txt.ForeColor = [System.Drawing.Color]::White
    $txt.Location = New-Object System.Drawing.Point(300, ($TopY - 2))
    $txt.Size = New-Object System.Drawing.Size(360, 24)
    $txt.Text = $ValueText
    if ($IsPassword) { $txt.UseSystemPasswordChar = $true }
    $txt.Tag = $lbl
    $Parent.Controls.Add($txt)
    return $txt
}

$txtSetHostIp     = Add-SettingInputRow -Parent $pnlSettings -LabelText (Get-Text "LblHostIp") -ValueText $script:ServerIP -TopY 30
$txtSetSshUser    = Add-SettingInputRow -Parent $pnlSettings -LabelText (Get-Text "LblSshUser") -ValueText $script:User -TopY 70
$txtSetSshPass    = Add-SettingInputRow -Parent $pnlSettings -LabelText (Get-Text "LblSshPass") -ValueText $script:Password -TopY 110 -IsPassword $true
$txtSetSshKey     = Add-SettingInputRow -Parent $pnlSettings -LabelText (Get-Text "LblSshKey") -ValueText $script:SshKeyPath -TopY 150

$txtSetSoapUser   = Add-SettingInputRow -Parent $pnlSettings -LabelText (Get-Text "LblSoapUser") -ValueText $script:SoapUser -TopY 200
$txtSetSoapPass   = Add-SettingInputRow -Parent $pnlSettings -LabelText (Get-Text "LblSoapPass") -ValueText $script:SoapPassword -TopY 240 -IsPassword $true
$txtSetSoapPort   = Add-SettingInputRow -Parent $pnlSettings -LabelText (Get-Text "LblSoapPort") -ValueText $script:SoapPort -TopY 280

$txtSetAutoRef    = Add-SettingInputRow -Parent $pnlSettings -LabelText (Get-Text "LblAutoRefresh") -ValueText $script:AutoRefreshSeconds -TopY 330
$txtSetRetention  = Add-SettingInputRow -Parent $pnlSettings -LabelText (Get-Text "LblBackupRetention") -ValueText $script:BackupRetentionCount -TopY 370

$btnSaveSettings = New-StyledButton -Text (Get-Text "BtnSaveSettings") -BgColor $accentGreen -Location (New-Object System.Drawing.Point(300, 420)) -Size (New-Object System.Drawing.Size(200, 42))
$btnTestSsh      = New-StyledButton -Text (Get-Text "BtnTestSsh")      -BgColor $accentBlue  -Location (New-Object System.Drawing.Point(520, 420)) -Size (New-Object System.Drawing.Size(200, 42))
$btnTestSoap     = New-StyledButton -Text (Get-Text "BtnTestSoap")     -BgColor $accentOrange -Location (New-Object System.Drawing.Point(740, 420)) -Size (New-Object System.Drawing.Size(200, 42))
$pnlSettings.Controls.AddRange(@($btnSaveSettings, $btnTestSsh, $btnTestSoap))

# Event Handlers
$btnSaveSettings.Add_Click({
    $script:ServerIP               = $txtSetHostIp.Text.Trim()
    $script:User                   = $txtSetSshUser.Text.Trim()
    $script:Password               = $txtSetSshPass.Text
    $script:SshKeyPath             = $txtSetSshKey.Text.Trim()
    $script:SoapUser               = $txtSetSoapUser.Text.Trim()
    $script:SoapPassword           = $txtSetSoapPass.Text
    $script:SoapPort               = [int]$txtSetSoapPort.Text.Trim()
    $script:AutoRefreshSeconds     = [int]$txtSetAutoRef.Text.Trim()
    $script:BackupRetentionCount   = [int]$txtSetRetention.Text.Trim()

    Save-CurrentConfig
    [System.Windows.Forms.MessageBox]::Show((Get-Text "SettingsSaved"), "Settings", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
})

$btnTestSsh.Add_Click({
    Start-AsyncOperation -Operation "status"
})

$btnTestSoap.Add_Click({
    Start-AsyncOperation -Operation "send_console_cmd" -Args @{ Command = "server info" }
})
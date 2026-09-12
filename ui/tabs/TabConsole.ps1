# ==========================================
# Tab 3: GM Console (áƒ—áƒáƒ›áƒáƒ¨áƒ˜áƒ¡ áƒ¨áƒ˜áƒ“áƒ GM áƒ™áƒáƒœáƒ¡áƒáƒšáƒ˜)
# ==========================================
$script:ConsoleHistory = New-Object System.Collections.Generic.List[string]
$script:ConsoleHistoryIndex = -1

$pnlConsoleTop = New-Object System.Windows.Forms.Panel
$pnlConsoleTop.Dock = [System.Windows.Forms.DockStyle]::Top
$pnlConsoleTop.Height = 54
$pnlConsoleTop.BackColor = $cardBg
$tabConsole.Controls.Add($pnlConsoleTop)

$btnAnnounce     = New-StyledButton -Text (Get-Text "BtnAnnounce")     -BgColor ([System.Drawing.Color]::FromArgb(210, 105, 30)) -Location (New-Object System.Drawing.Point(12, 10))  -Size (New-Object System.Drawing.Size(155, 34))
$btnSaveAll      = New-StyledButton -Text (Get-Text "BtnSaveAll")      -BgColor $accentGreen -Location (New-Object System.Drawing.Point(175, 10)) -Size (New-Object System.Drawing.Size(130, 34))
$btnServerInfo   = New-StyledButton -Text (Get-Text "BtnServerInfo")   -BgColor $accentBlue  -Location (New-Object System.Drawing.Point(313, 10)) -Size (New-Object System.Drawing.Size(130, 34))
$btnServerRestart= New-StyledButton -Text (Get-Text "BtnServerRestart") -BgColor $accentOrange -Location (New-Object System.Drawing.Point(451, 10)) -Size (New-Object System.Drawing.Size(160, 34))
$btnRestartCancel= New-StyledButton -Text (Get-Text "BtnRestartCancel")-BgColor $accentRed   -Location (New-Object System.Drawing.Point(619, 10)) -Size (New-Object System.Drawing.Size(170, 34))
$btnClearConsole = New-StyledButton -Text (Get-Text "BtnClearConsole") -BgColor ([System.Drawing.Color]::FromArgb(70, 75, 90))   -Location (New-Object System.Drawing.Point(797, 10)) -Size (New-Object System.Drawing.Size(140, 34))
$pnlConsoleTop.Controls.AddRange(@($btnAnnounce, $btnSaveAll, $btnServerInfo, $btnServerRestart, $btnRestartCancel, $btnClearConsole))

$pnlConsoleBottom = New-Object System.Windows.Forms.Panel
$pnlConsoleBottom.Dock = [System.Windows.Forms.DockStyle]::Bottom
$pnlConsoleBottom.Height = 52
$pnlConsoleBottom.BackColor = $cardBg
$tabConsole.Controls.Add($pnlConsoleBottom)

$lblCmdPrompt = New-Object System.Windows.Forms.Label
$lblCmdPrompt.Text = (Get-Text "LblCommand")
$lblCmdPrompt.Font = $fontBold
$lblCmdPrompt.ForeColor = $accentBlue
$lblCmdPrompt.Location = New-Object System.Drawing.Point(12, 16)
$lblCmdPrompt.AutoSize = $true
$pnlConsoleBottom.Controls.Add($lblCmdPrompt)

$txtConsoleCmd = New-Object System.Windows.Forms.TextBox
$txtConsoleCmd.Font = $fontConsole
$txtConsoleCmd.BackColor = [System.Drawing.Color]::FromArgb(15, 17, 26)
$txtConsoleCmd.ForeColor = [System.Drawing.Color]::White
$txtConsoleCmd.Location = New-Object System.Drawing.Point(100, 14)
$txtConsoleCmd.Size = New-Object System.Drawing.Size(780, 23)
$pnlConsoleBottom.Controls.Add($txtConsoleCmd)

$btnSendCmd = New-StyledButton -Text (Get-Text "BtnSendCmd") -BgColor $accentBlue -Location (New-Object System.Drawing.Point(890, 11)) -Size (New-Object System.Drawing.Size(130, 30))
$pnlConsoleBottom.Controls.Add($btnSendCmd)

$rtbConsole = New-Object System.Windows.Forms.RichTextBox
$rtbConsole.Dock = [System.Windows.Forms.DockStyle]::Fill
$rtbConsole.BackColor = [System.Drawing.Color]::FromArgb(15, 17, 26)
$rtbConsole.ForeColor = [System.Drawing.Color]::FromArgb(200, 220, 240)
$rtbConsole.Font = $fontConsole
$rtbConsole.ReadOnly = $true
$rtbConsole.BorderStyle = [System.Windows.Forms.BorderStyle]::None
$tabConsole.Controls.Add($rtbConsole)
$rtbConsole.BringToFront()

function Update-ConsoleUi {
    param([string]$Cmd, [string]$RawXml, [string]$Stderr)

    $ts = [DateTime]::Now.ToString("HH:mm:ss")
    $parsed = Parse-SoapResponseXml -RawXml $RawXml

    $rtbConsole.SelectionStart = $rtbConsole.TextLength
    $rtbConsole.SelectionLength = 0
    $rtbConsole.SelectionColor = [System.Drawing.Color]::FromArgb(255, 215, 0) # Gold
    $rtbConsole.AppendText("[$ts] > $Cmd`r`n")

    $rtbConsole.SelectionStart = $rtbConsole.TextLength
    $rtbConsole.SelectionLength = 0
    if ($parsed -match "Fault|Error|failed|command not found") {
        $rtbConsole.SelectionColor = $accentRed
    } else {
        $rtbConsole.SelectionColor = [System.Drawing.Color]::FromArgb(180, 240, 180)
    }
    $rtbConsole.AppendText("$parsed`r`n`r`n")
    $rtbConsole.ScrollToCaret()
}

function Send-ConsoleCommandInput {
    $cmd = $txtConsoleCmd.Text.Trim()
    if (-not [string]::IsNullOrWhiteSpace($cmd)) {
        $script:ConsoleHistory.Add($cmd)
        $script:ConsoleHistoryIndex = $script:ConsoleHistory.Count
        $txtConsoleCmd.Clear()
        Start-AsyncOperation -Operation "send_console_cmd" -Args @{ Command = $cmd }
    }
}

# Event Handlers
$btnSendCmd.Add_Click({ Send-ConsoleCommandInput })

$txtConsoleCmd.Add_KeyDown({
    param($s, $e)
    if ($e.KeyCode -eq [System.Windows.Forms.Keys]::Enter) {
        $e.SuppressKeyPress = $true
        Send-ConsoleCommandInput
    } elseif ($e.KeyCode -eq [System.Windows.Forms.Keys]::Up) {
        if ($script:ConsoleHistory.Count -gt 0 -and $script:ConsoleHistoryIndex -gt 0) {
            $script:ConsoleHistoryIndex--
            $txtConsoleCmd.Text = $script:ConsoleHistory[$script:ConsoleHistoryIndex]
            $txtConsoleCmd.SelectionStart = $txtConsoleCmd.Text.Length
        }
        $e.Handled = $true
    } elseif ($e.KeyCode -eq [System.Windows.Forms.Keys]::Down) {
        if ($script:ConsoleHistoryIndex -lt ($script:ConsoleHistory.Count - 1)) {
            $script:ConsoleHistoryIndex++
            $txtConsoleCmd.Text = $script:ConsoleHistory[$script:ConsoleHistoryIndex]
            $txtConsoleCmd.SelectionStart = $txtConsoleCmd.Text.Length
        } else {
            $script:ConsoleHistoryIndex = $script:ConsoleHistory.Count
            $txtConsoleCmd.Clear()
        }
        $e.Handled = $true
    }
})

$btnAnnounce.Add_Click({
    $inputPrompt = [Microsoft.VisualBasic.Interaction]::InputBox((Get-Text "PromptAnnounce"), "SOAP Announce", "")
    if (-not [string]::IsNullOrWhiteSpace($inputPrompt)) {
        Start-AsyncOperation -Operation "send_console_cmd" -Args @{ Command = ".announce $inputPrompt" }
    }
})

$btnSaveAll.Add_Click({ Start-AsyncOperation -Operation "send_console_cmd" -Args @{ Command = ".saveall" } })
$btnServerInfo.Add_Click({ Start-AsyncOperation -Operation "send_console_cmd" -Args @{ Command = "server info" } })

$btnServerRestart.Add_Click({
    $reason = [Microsoft.VisualBasic.Interaction]::InputBox((Get-Text "PromptRestartReason"), "Server Restart (5m)", "Scheduled maintenance")
    if (-not [string]::IsNullOrWhiteSpace($reason)) {
        Start-AsyncOperation -Operation "send_console_cmd" -Args @{ Command = ".server restart 5 $reason" }
    }
})

$btnRestartCancel.Add_Click({ Start-AsyncOperation -Operation "send_console_cmd" -Args @{ Command = ".server restart cancel" } })
$btnClearConsole.Add_Click({ $rtbConsole.Clear() })
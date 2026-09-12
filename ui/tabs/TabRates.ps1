# ==========================================
# Tab 4: Rates & Config (áƒ’áƒáƒœáƒáƒ™áƒ•áƒ”áƒ—áƒ”áƒ‘áƒ˜ áƒ“áƒ áƒ™áƒáƒœáƒ¤áƒ˜áƒ’áƒ˜)
# ==========================================
$pnlRatesNotice = New-Object System.Windows.Forms.Panel
$pnlRatesNotice.Dock = [System.Windows.Forms.DockStyle]::Top
$pnlRatesNotice.Height = 44
$pnlRatesNotice.BackColor = [System.Drawing.Color]::FromArgb(35, 42, 60)
$tabRates.Controls.Add($pnlRatesNotice)

$lblRatesNotice = New-Object System.Windows.Forms.Label
$lblRatesNotice.Text = (Get-Text "RatesNotice")
$lblRatesNotice.Font = $fontBody
$lblRatesNotice.ForeColor = $accentGreen
$lblRatesNotice.Location = New-Object System.Drawing.Point(16, 12)
$lblRatesNotice.AutoSize = $true
$pnlRatesNotice.Controls.Add($lblRatesNotice)

# Bottom Actions Bar (Always visible)
$pnlRatesActions = New-Object System.Windows.Forms.Panel
$pnlRatesActions.Dock = [System.Windows.Forms.DockStyle]::Bottom
$pnlRatesActions.Height = 62
$pnlRatesActions.BackColor = [System.Drawing.Color]::FromArgb(24, 28, 40)
$tabRates.Controls.Add($pnlRatesActions)

$btnLoadRates = New-StyledButton -Text (Get-Text "BtnLoadRates") -BgColor $accentBlue  -Location (New-Object System.Drawing.Point(25, 10)) -Size (New-Object System.Drawing.Size(220, 42))
$btnSaveRates = New-StyledButton -Text (Get-Text "BtnSaveRates") -BgColor $accentGreen -Location (New-Object System.Drawing.Point(260, 10)) -Size (New-Object System.Drawing.Size(260, 42))
$pnlRatesActions.Controls.AddRange(@($btnLoadRates, $btnSaveRates))

# Scrollable Form Body
$pnlRatesScroll = New-Object System.Windows.Forms.Panel
$pnlRatesScroll.Dock = [System.Windows.Forms.DockStyle]::Fill
$pnlRatesScroll.AutoScroll = $true
$pnlRatesScroll.BackColor = $bgDark
$tabRates.Controls.Add($pnlRatesScroll)
$pnlRatesScroll.BringToFront()

# ToolTip Component for Rates & Config
$script:RatesToolTip = New-Object System.Windows.Forms.ToolTip
$script:RatesToolTip.AutoPopDelay = 10000
$script:RatesToolTip.InitialDelay = 350
$script:RatesToolTip.ReshowDelay = 150
$script:RatesToolTip.ShowAlways = $true

# Helper: Add Section Header Card
function Add-RatesSectionHeader {
    param(
        [System.Windows.Forms.Control]$Parent,
        [string]$LocKey,
        [int]$X,
        [int]$Y,
        [int]$Width = 490
    )
    $pnlHdr = New-Object System.Windows.Forms.Panel
    $pnlHdr.Location = New-Object System.Drawing.Point($X, $Y)
    $pnlHdr.Size = New-Object System.Drawing.Size($Width, 34)
    $pnlHdr.BackColor = [System.Drawing.Color]::FromArgb(38, 46, 68)

    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = (Get-Text $LocKey)
    $lbl.Font = $fontBold
    $lbl.ForeColor = $accentOrange
    $lbl.Location = New-Object System.Drawing.Point(12, 7)
    $lbl.AutoSize = $true
    $lbl.Tag = $LocKey
    $pnlHdr.Controls.Add($lbl)

    $Parent.Controls.Add($pnlHdr)
    return $lbl
}

# Helper: Add Numeric Row
function Add-RateNumericRow {
    param(
        [System.Windows.Forms.Control]$Parent,
        [string]$LabelKey,
        [int]$X,
        [int]$Y,
        [int]$TotalWidth = 490,
        [double]$DefaultVal = 1,
        [double]$MinVal = 0.1,
        [double]$MaxVal = 100,
        [int]$DecimalPlaces = 1,
        [string]$TipKey = ""
    )
    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = (Get-Text $LabelKey)
    $lbl.Font = $fontBody
    $lbl.ForeColor = $textLight
    $lbl.Location = New-Object System.Drawing.Point($X, ($Y + 3))
    $lbl.Size = New-Object System.Drawing.Size(($TotalWidth - 140), 24)
    $lbl.Tag = $LabelKey
    $Parent.Controls.Add($lbl)

    $num = New-Object System.Windows.Forms.NumericUpDown
    $num.Font = $fontBody
    $num.BackColor = $cardBg
    $num.ForeColor = [System.Drawing.Color]::White
    $num.Location = New-Object System.Drawing.Point(($X + $TotalWidth - 130), $Y)
    $num.Size = New-Object System.Drawing.Size(130, 24)
    $num.DecimalPlaces = $DecimalPlaces
    $num.Minimum = [decimal]$MinVal
    $num.Maximum = [decimal]$MaxVal
    $num.Value = [decimal]$DefaultVal
    $num.Increment = if ($DecimalPlaces -gt 0) { [decimal]0.5 } else { [decimal]1 }
    $num.Tag = @{ LabelControl = $lbl; LabelKey = $LabelKey; TipKey = $TipKey }
    $Parent.Controls.Add($num)

    if (-not [string]::IsNullOrEmpty($TipKey)) {
        $tip = Get-Text $TipKey
        $script:RatesToolTip.SetToolTip($lbl, $tip)
        $script:RatesToolTip.SetToolTip($num, $tip)
    }

    return $num
}

# Helper: Add Checkbox Row
function Add-RateCheckboxRow {
    param(
        [System.Windows.Forms.Control]$Parent,
        [string]$LabelKey,
        [int]$X,
        [int]$Y,
        [int]$TotalWidth = 490,
        [bool]$DefaultVal = $false,
        [string]$TipKey = ""
    )
    $chk = New-Object System.Windows.Forms.CheckBox
    $chk.Text = (Get-Text $LabelKey)
    $chk.Font = $fontBody
    $chk.ForeColor = $textLight
    $chk.Location = New-Object System.Drawing.Point($X, $Y)
    $chk.Size = New-Object System.Drawing.Size($TotalWidth, 28)
    $chk.Checked = $DefaultVal
    $chk.Cursor = [System.Windows.Forms.Cursors]::Hand
    $chk.Tag = @{ LabelKey = $LabelKey; TipKey = $TipKey }
    $Parent.Controls.Add($chk)

    if (-not [string]::IsNullOrEmpty($TipKey)) {
        $tip = Get-Text $TipKey
        $script:RatesToolTip.SetToolTip($chk, $tip)
    }

    return $chk
}

# ==========================================
# LEFT COLUMN (X = 25, Width = 490)
# ==========================================

# Section 1: XP & Progression
$lblSecProgression = Add-RatesSectionHeader -Parent $pnlRatesScroll -LocKey "SecProgression" -X 25 -Y 16
$numKillXp      = Add-RateNumericRow -Parent $pnlRatesScroll -LabelKey "LblKillXp"      -X 25 -Y 58  -DefaultVal 1 -MinVal 0.1 -MaxVal 100 -DecimalPlaces 1 -TipKey "TipKillXp"
$numQuestXp     = Add-RateNumericRow -Parent $pnlRatesScroll -LabelKey "LblQuestXp"     -X 25 -Y 92  -DefaultVal 1 -MinVal 0.1 -MaxVal 100 -DecimalPlaces 1 -TipKey "TipQuestXp"
$numExploreXp   = Add-RateNumericRow -Parent $pnlRatesScroll -LabelKey "LblExploreXp"   -X 25 -Y 126 -DefaultVal 1 -MinVal 0.1 -MaxVal 100 -DecimalPlaces 1 -TipKey "TipExploreXp"
$numReputation  = Add-RateNumericRow -Parent $pnlRatesScroll -LabelKey "LblReputation"  -X 25 -Y 160 -DefaultVal 1 -MinVal 0.1 -MaxVal 100 -DecimalPlaces 1 -TipKey "TipReputation"
$numCrafting    = Add-RateNumericRow -Parent $pnlRatesScroll -LabelKey "LblCrafting"    -X 25 -Y 194 -DefaultVal 1 -MinVal 1   -MaxVal 50  -DecimalPlaces 0 -TipKey "TipCrafting"
$numGathering   = Add-RateNumericRow -Parent $pnlRatesScroll -LabelKey "LblGathering"   -X 25 -Y 228 -DefaultVal 1 -MinVal 1   -MaxVal 50  -DecimalPlaces 0 -TipKey "TipGathering"
$numHonor       = Add-RateNumericRow -Parent $pnlRatesScroll -LabelKey "LblHonor"       -X 25 -Y 262 -DefaultVal 1 -MinVal 0.1 -MaxVal 100 -DecimalPlaces 1 -TipKey "TipHonor"
$numArenaPoints = Add-RateNumericRow -Parent $pnlRatesScroll -LabelKey "LblArenaPoints" -X 25 -Y 296 -DefaultVal 1 -MinVal 0.1 -MaxVal 100 -DecimalPlaces 1 -TipKey "TipArenaPoints"
$numTalent      = Add-RateNumericRow -Parent $pnlRatesScroll -LabelKey "LblTalent"      -X 25 -Y 330 -DefaultVal 1 -MinVal 1   -MaxVal 10  -DecimalPlaces 0 -TipKey "TipTalent"

# Section 2: Drops & Economy
$lblSecDrops    = Add-RatesSectionHeader -Parent $pnlRatesScroll -LocKey "SecDrops"     -X 25 -Y 376
$numMoneyDrop   = Add-RateNumericRow -Parent $pnlRatesScroll -LabelKey "LblMoneyDrop"   -X 25 -Y 418 -DefaultVal 1 -MinVal 0.1 -MaxVal 100 -DecimalPlaces 1 -TipKey "TipMoneyDrop"
$numDropPoor    = Add-RateNumericRow -Parent $pnlRatesScroll -LabelKey "LblDropPoor"    -X 25 -Y 452 -DefaultVal 1 -MinVal 0.1 -MaxVal 100 -DecimalPlaces 1 -TipKey "TipDropPoor"
$numDropNormal  = Add-RateNumericRow -Parent $pnlRatesScroll -LabelKey "LblDropNormal"  -X 25 -Y 486 -DefaultVal 1 -MinVal 0.1 -MaxVal 100 -DecimalPlaces 1 -TipKey "TipDropNormal"
$numDropUncommon= Add-RateNumericRow -Parent $pnlRatesScroll -LabelKey "LblDropUncommon"-X 25 -Y 520 -DefaultVal 1 -MinVal 0.1 -MaxVal 100 -DecimalPlaces 1 -TipKey "TipDropUncommon"
$numDropRare    = Add-RateNumericRow -Parent $pnlRatesScroll -LabelKey "LblDropRare"    -X 25 -Y 554 -DefaultVal 1 -MinVal 0.1 -MaxVal 100 -DecimalPlaces 1 -TipKey "TipDropRare"
$numDropEpic    = Add-RateNumericRow -Parent $pnlRatesScroll -LabelKey "LblDropEpic"    -X 25 -Y 588 -DefaultVal 1 -MinVal 0.1 -MaxVal 100 -DecimalPlaces 1 -TipKey "TipDropEpic"

# Spacer at bottom of column 1
$pnlSpacer1 = New-Object System.Windows.Forms.Panel
$pnlSpacer1.Location = New-Object System.Drawing.Point(25, 622)
$pnlSpacer1.Size = New-Object System.Drawing.Size(490, 20)
$pnlRatesScroll.Controls.Add($pnlSpacer1)

# ==========================================
# RIGHT COLUMN (X = 540, Width = 490)
# ==========================================

# Section 3: Player & Server QoL
$lblSecQoL      = Add-RatesSectionHeader -Parent $pnlRatesScroll -LocKey "SecQoL"          -X 540 -Y 16
$numPlayerLimit = Add-RateNumericRow -Parent $pnlRatesScroll -LabelKey "LblPlayerLimit"   -X 540 -Y 58  -DefaultVal 1000 -MinVal 1   -MaxVal 3000 -DecimalPlaces 0 -TipKey "TipPlayerLimit"
$numMoveSpeed   = Add-RateNumericRow -Parent $pnlRatesScroll -LabelKey "LblMoveSpeed"     -X 540 -Y 92  -DefaultVal 1    -MinVal 0.5 -MaxVal 5.0  -DecimalPlaces 1 -TipKey "TipMoveSpeed"
$numStartLevel  = Add-RateNumericRow -Parent $pnlRatesScroll -LabelKey "LblStartLevel"    -X 540 -Y 126 -DefaultVal 1    -MinVal 1   -MaxVal 80   -DecimalPlaces 0 -TipKey "TipStartLevel"
$numStartGold   = Add-RateNumericRow -Parent $pnlRatesScroll -LabelKey "LblStartGold"     -X 540 -Y 160 -DefaultVal 0    -MinVal 0   -MaxVal 100000 -DecimalPlaces 0 -TipKey "TipStartGold"
$numPetitionSigns= Add-RateNumericRow -Parent $pnlRatesScroll -LabelKey "LblPetitionSigns"-X 540 -Y 194 -DefaultVal 9    -MinVal 0   -MaxVal 9    -DecimalPlaces 0 -TipKey "TipPetitionSigns"
$chkFlightPaths = Add-RateCheckboxRow -Parent $pnlRatesScroll -LabelKey "ChkFlightPaths"  -X 540 -Y 228 -DefaultVal $false -TipKey "TipFlightPaths"

# Section 4: Cross-Faction Mode
$lblSecCross    = Add-RatesSectionHeader -Parent $pnlRatesScroll -LocKey "SecCrossFaction" -X 540 -Y 272
$chkCrossGroup  = Add-RateCheckboxRow -Parent $pnlRatesScroll -LabelKey "ChkCrossGroup"   -X 540 -Y 312 -DefaultVal $false -TipKey "TipCrossGroup"
$chkCrossGuild  = Add-RateCheckboxRow -Parent $pnlRatesScroll -LabelKey "ChkCrossGuild"   -X 540 -Y 346 -DefaultVal $false -TipKey "TipCrossGuild"
$chkCrossChat   = Add-RateCheckboxRow -Parent $pnlRatesScroll -LabelKey "ChkCrossChat"    -X 540 -Y 380 -DefaultVal $false -TipKey "TipCrossChat"

# Section 5: MOTD & System Message
$lblSecMotd     = Add-RatesSectionHeader -Parent $pnlRatesScroll -LocKey "SecMotd"         -X 540 -Y 424
$lblMotd = New-Object System.Windows.Forms.Label
$lblMotd.Text = (Get-Text "LblMotd")
$lblMotd.Font = $fontBody
$lblMotd.ForeColor = $textLight
$lblMotd.Location = New-Object System.Drawing.Point(540, 466)
$lblMotd.Size = New-Object System.Drawing.Size(490, 20)
$lblMotd.Tag = "LblMotd"
$pnlRatesScroll.Controls.Add($lblMotd)

$txtMotd = New-Object System.Windows.Forms.TextBox
$txtMotd.Font = $fontBody
$txtMotd.BackColor = $cardBg
$txtMotd.ForeColor = [System.Drawing.Color]::White
$txtMotd.Location = New-Object System.Drawing.Point(540, 490)
$txtMotd.Size = New-Object System.Drawing.Size(490, 26)
$txtMotd.Text = "Welcome to AzerothCore!"
$txtMotd.Tag = "TipMotd"
$pnlRatesScroll.Controls.Add($txtMotd)

$tipMotd = Get-Text "TipMotd"
$script:RatesToolTip.SetToolTip($lblMotd, $tipMotd)
$script:RatesToolTip.SetToolTip($txtMotd, $tipMotd)

# Spacer at bottom of column 2
$pnlSpacer2 = New-Object System.Windows.Forms.Panel
$pnlSpacer2.Location = New-Object System.Drawing.Point(540, 622)
$pnlSpacer2.Size = New-Object System.Drawing.Size(490, 20)
$pnlRatesScroll.Controls.Add($pnlSpacer2)

# ==========================================
# Rates Data Parsing & UI Update
# ==========================================
function Update-RatesUi {
    param([string]$RawData)
    if ([string]::IsNullOrWhiteSpace($RawData)) { return }

    $lines = $RawData -split "`r?`n"
    foreach ($l in $lines) {
        if ($l -match "Rate\.XP\.Kill\s*=\s*(\d+(\.\d+)?)")           { $numKillXp.Value = [decimal]$matches[1] }
        if ($l -match "Rate\.XP\.Quest\s*=\s*(\d+(\.\d+)?)")          { $numQuestXp.Value = [decimal]$matches[1] }
        if ($l -match "Rate\.XP\.Explore\s*=\s*(\d+(\.\d+)?)")        { $numExploreXp.Value = [decimal]$matches[1] }
        if ($l -match "Rate\.Reputation\.Gain\s*=\s*(\d+(\.\d+)?)")   { $numReputation.Value = [decimal]$matches[1] }
        if ($l -match "SkillGain\.Crafting\s*=\s*(\d+)")              { $numCrafting.Value = [decimal]$matches[1] }
        if ($l -match "SkillGain\.Gathering\s*=\s*(\d+)")             { $numGathering.Value = [decimal]$matches[1] }
        if ($l -match "Rate\.Honor\s*=\s*(\d+(\.\d+)?)")              { $numHonor.Value = [decimal]$matches[1] }
        if ($l -match "Rate\.ArenaPoints\s*=\s*(\d+(\.\d+)?)")        { $numArenaPoints.Value = [decimal]$matches[1] }
        if ($l -match "Rate\.Talent\s*=\s*(\d+)")                     { $numTalent.Value = [decimal]$matches[1] }
        if ($l -match "Rate\.Drop\.Money\s*=\s*(\d+(\.\d+)?)")        { $numMoneyDrop.Value = [decimal]$matches[1] }
        if ($l -match "Rate\.Drop\.Item\.Poor\s*=\s*(\d+(\.\d+)?)")   { $numDropPoor.Value = [decimal]$matches[1] }
        if ($l -match "Rate\.Drop\.Item\.Normal\s*=\s*(\d+(\.\d+)?)") { $numDropNormal.Value = [decimal]$matches[1] }
        if ($l -match "Rate\.Drop\.Item\.Uncommon\s*=\s*(\d+(\.\d+)?)"){ $numDropUncommon.Value = [decimal]$matches[1] }
        if ($l -match "Rate\.Drop\.Item\.Rare\s*=\s*(\d+(\.\d+)?)")   { $numDropRare.Value = [decimal]$matches[1] }
        if ($l -match "Rate\.Drop\.Item\.Epic\s*=\s*(\d+(\.\d+)?)")   { $numDropEpic.Value = [decimal]$matches[1] }
        if ($l -match "PlayerLimit\s*=\s*(\d+)")                      { $numPlayerLimit.Value = [decimal]$matches[1] }
        if ($l -match "Rate\.MoveSpeed\.Player\s*=\s*(\d+(\.\d+)?)")  { $numMoveSpeed.Value = [decimal]$matches[1] }
        if ($l -match "StartPlayerLevel\s*=\s*(\d+)")                 { $numStartLevel.Value = [decimal]$matches[1] }
        if ($l -match "StartPlayerMoney\s*=\s*(\d+)")                 { 
            $copper = [decimal]$matches[1]
            $numStartGold.Value = [math]::Floor($copper / 10000)
        }
        if ($l -match "MinPetitionSigns\s*=\s*(\d+)")                 { $numPetitionSigns.Value = [decimal]$matches[1] }
        if ($l -match "AllFlightPaths\s*=\s*(\d+)")                   { $chkFlightPaths.Checked = ($matches[1] -eq "1") }
        if ($l -match "AllowTwoSide\.Interaction\.Group\s*=\s*(\d+)") { $chkCrossGroup.Checked = ($matches[1] -eq "1") }
        if ($l -match "AllowTwoSide\.Interaction\.Guild\s*=\s*(\d+)") { $chkCrossGuild.Checked = ($matches[1] -eq "1") }
        if ($l -match "AllowTwoSide\.Interaction\.Chat\s*=\s*(\d+)")  { $chkCrossChat.Checked = ($matches[1] -eq "1") }
    }

    if ($RawData -match "__MOTD_START__\r?\n([\s\S]*)") {
        $motdVal = $matches[1].Trim()
        if (-not [string]::IsNullOrEmpty($motdVal)) {
            $txtMotd.Text = $motdVal
        }
    }
}

function Update-RatesSavedUi {
    param([string]$RawData)
    Write-Log -Message "Rates saved response: $RawData"
    [System.Windows.Forms.MessageBox]::Show((Get-Text "RatesSaveSuccess"), "Rates", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    Update-ConsoleUi -Cmd ".reload config" -RawXml $RawData -Stderr ""
}

# ==========================================
# Event Handlers
# ==========================================
$btnLoadRates.Add_Click({ Start-AsyncOperation -Operation "read_rates" })

$btnSaveRates.Add_Click({
    $copper = [long]([decimal]$numStartGold.Value * 10000)
    Start-AsyncOperation -Operation "save_rates" -Args @{
        KillXp           = [double]$numKillXp.Value
        QuestXp          = [double]$numQuestXp.Value
        ExploreXp        = [double]$numExploreXp.Value
        Reputation       = [double]$numReputation.Value
        Crafting         = [int]$numCrafting.Value
        Gathering        = [int]$numGathering.Value
        Honor            = [double]$numHonor.Value
        ArenaPoints      = [double]$numArenaPoints.Value
        Talent           = [int]$numTalent.Value
        MoneyDrop        = [double]$numMoneyDrop.Value
        DropPoor         = [double]$numDropPoor.Value
        DropNormal       = [double]$numDropNormal.Value
        DropUncommon     = [double]$numDropUncommon.Value
        DropRare         = [double]$numDropRare.Value
        DropEpic         = [double]$numDropEpic.Value
        PlayerLimit      = [int]$numPlayerLimit.Value
        MoveSpeed        = [double]$numMoveSpeed.Value
        StartLevel       = [int]$numStartLevel.Value
        StartMoneyCopper = $copper
        PetitionSigns    = [int]$numPetitionSigns.Value
        FlightPaths      = if ($chkFlightPaths.Checked) { 1 } else { 0 }
        CrossGroup       = if ($chkCrossGroup.Checked) { 1 } else { 0 }
        CrossGuild       = if ($chkCrossGuild.Checked) { 1 } else { 0 }
        CrossChat        = if ($chkCrossChat.Checked) { 1 } else { 0 }
        Motd             = $txtMotd.Text
    }
})
# ==========================================
# UI Theme, Fonts, Colors & Widget Helpers
# ==========================================

# Modern Dark Palette
$bgDark      = [System.Drawing.Color]::FromArgb(26, 27, 38)
$cardBg      = [System.Drawing.Color]::FromArgb(36, 40, 59)
$cardBorder  = [System.Drawing.Color]::FromArgb(65, 72, 104)
$accentBlue  = [System.Drawing.Color]::FromArgb(122, 162, 247)
$accentGreen = [System.Drawing.Color]::FromArgb(158, 206, 106)
$accentRed   = [System.Drawing.Color]::FromArgb(247, 118, 142)
$accentOrange= [System.Drawing.Color]::FromArgb(255, 158, 100)
$textLight   = [System.Drawing.Color]::FromArgb(192, 202, 245)

# Typography
$fontHeader   = New-Object System.Drawing.Font("Segoe UI", 13, [System.Drawing.FontStyle]::Bold)
$fontSubHeader= New-Object System.Drawing.Font("Segoe UI", 10.5, [System.Drawing.FontStyle]::Bold)
$fontBody     = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Regular)
$fontBold     = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
$fontSmall    = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Regular)
$fontConsole  = New-Object System.Drawing.Font("Consolas", 10, [System.Drawing.FontStyle]::Regular)

function New-StyledButton {
    param(
        [string]$Text,
        [System.Drawing.Color]$BgColor,
        [System.Drawing.Point]$Location,
        [System.Drawing.Size]$Size
    )
    $b = New-Object System.Windows.Forms.Button
    $b.Text = $Text
    $b.BackColor = $BgColor
    $b.ForeColor = [System.Drawing.Color]::White
    $b.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $b.FlatAppearance.BorderSize = 0
    $b.Font = $fontBold
    $b.Location = $Location
    $b.Size = $Size
    $b.Cursor = [System.Windows.Forms.Cursors]::Hand
    return $b
}

function New-StatusCard {
    param(
        [System.Windows.Forms.Control]$Parent,
        [string]$Title,
        [System.Drawing.Point]$Location,
        [System.Drawing.Size]$Size
    )
    $p = New-Object System.Windows.Forms.Panel
    $p.Location = $Location
    $p.Size = $Size
    $p.BackColor = $cardBg
    $p.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    $Parent.Controls.Add($p)

    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = $Title
    $lbl.Font = $fontSubHeader
    $lbl.ForeColor = $accentBlue
    $lbl.Location = New-Object System.Drawing.Point(12, 12)
    $lbl.AutoSize = $true
    $p.Controls.Add($lbl)
    $p.Tag = $lbl
    return $p
}

function New-MetricWidget {
    param(
        [System.Windows.Forms.Control]$Parent,
        [string]$Title,
        [System.Drawing.Point]$Location,
        [System.Drawing.Size]$Size
    )
    $p = New-Object System.Windows.Forms.Panel
    $p.Location = $Location
    $p.Size = $Size
    $p.BackColor = $cardBg
    $p.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    $Parent.Controls.Add($p)

    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = $Title
    $lbl.Font = $fontSubHeader
    $lbl.ForeColor = $accentBlue
    $lbl.Location = New-Object System.Drawing.Point(16, 14)
    $lbl.AutoSize = $true
    $p.Controls.Add($lbl)
    $p.Tag = $lbl

    $bar = New-Object System.Windows.Forms.ProgressBar
    $bar.Location = New-Object System.Drawing.Point(16, 45)
    $bar.Size = New-Object System.Drawing.Size(($Size.Width - 32), 24)
    $bar.Minimum = 0
    $bar.Maximum = 100
    $bar.Value = 0
    $p.Controls.Add($bar)

    $val = New-Object System.Windows.Forms.Label
    $val.Text = "0%"
    $val.Font = $fontBold
    $val.ForeColor = [System.Drawing.Color]::White
    $val.Location = New-Object System.Drawing.Point(16, 78)
    $val.AutoSize = $true
    $p.Controls.Add($val)

    return @{ Panel = $p; Bar = $bar; Label = $val; TitleLabel = $lbl }
}
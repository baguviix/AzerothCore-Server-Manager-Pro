# ==============================================================================
# AzerothCore Server Manager Pro - Modular Entrypoint
# ==============================================================================
$ErrorActionPreference = "Stop"

# 1. Load Windows Forms & System Assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName Microsoft.VisualBasic
Add-Type -AssemblyName System.Web
[System.Windows.Forms.Application]::EnableVisualStyles()

# 2. Determine Application Root Directory
$scriptRoot = if (-not [string]::IsNullOrWhiteSpace($PSScriptRoot)) {
    $PSScriptRoot
} elseif ($MyInvocation.MyCommand -and $MyInvocation.MyCommand.Path) {
    Split-Path -Parent $MyInvocation.MyCommand.Path
} else {
    (Get-Location).Path
}
if (-not $scriptRoot) { $scriptRoot = (Get-Location).Path }

# 3. Load Core Backend Modules
. "$scriptRoot\modules\Config.ps1"
. "$scriptRoot\modules\Logger.ps1"
. "$scriptRoot\modules\Localization.ps1"
. "$scriptRoot\modules\WowData.ps1"
. "$scriptRoot\modules\SoapClient.ps1"
. "$scriptRoot\modules\SshClient.ps1"
. "$scriptRoot\modules\Database.ps1"
. "$scriptRoot\modules\AsyncEngine.ps1"

# 4. Load UI Framework & Main Frame
. "$scriptRoot\ui\Theme.ps1"
. "$scriptRoot\ui\MainWindow.ps1"

# 5. Load All 8 Tabs in Order
. "$scriptRoot\ui\tabs\TabDashboard.ps1"
. "$scriptRoot\ui\tabs\TabPlayers.ps1"
. "$scriptRoot\ui\tabs\TabConsole.ps1"
. "$scriptRoot\ui\tabs\TabRates.ps1"
. "$scriptRoot\ui\tabs\TabBackups.ps1"
. "$scriptRoot\ui\tabs\TabMonitoring.ps1"
. "$scriptRoot\ui\tabs\TabLogs.ps1"
. "$scriptRoot\ui\tabs\TabSettings.ps1"

# 7. Global Event Bindings
$comboLanguage.Add_SelectedIndexChanged({
    $newLang = "en"
    if ($comboLanguage.SelectedIndex -eq 0) {
        $newLang = "ka"
    }
    Apply-UiLanguage -NewLang $newLang
    Save-CurrentConfig
})

$tabControl.Add_SelectedIndexChanged({
    switch ($tabControl.SelectedIndex) {
        1 { # Players
            if ($script:AllOnlinePlayers.Count -eq 0 -and $null -eq $script:OpContext) {
                Start-AsyncOperation -Operation "fetch_players"
            }
        }
        3 { # Rates
            if ($null -eq $script:OpContext) {
                Start-AsyncOperation -Operation "read_rates"
            }
        }
        4 { # Backups
            if ($gridBackups.Rows.Count -eq 0 -and $null -eq $script:OpContext) {
                Start-AsyncOperation -Operation "list_backups"
            }
        }
        6 { # Logs
            if ($null -eq $script:OpContext) {
                $btnRefreshLog.PerformClick()
            }
        }
    }
})

# 8. Background Auto-Refresh Timer
$script:RefreshTimer = New-Object System.Windows.Forms.Timer
$timerIntervalMs = 30000
if ($script:AutoRefreshSeconds -gt 0) {
    $timerIntervalMs = $script:AutoRefreshSeconds * 1000
}
$script:RefreshTimer.Interval = $timerIntervalMs
$script:RefreshTimer.Add_Tick({
    if ($null -eq $script:OpContext -and $script:AutoRefreshSeconds -gt 0) {
        Start-AsyncOperation -Operation "status"
    }
})

# 9. Form Lifecycle Events
$form.Add_Shown({
    Apply-UiLanguage -NewLang $script:Language
    Start-AsyncOperation -Operation "status"
    if ($script:AutoRefreshSeconds -gt 0) {
        $script:RefreshTimer.Start()
    }
})

$form.Add_FormClosing({
    try {
        if ($null -ne $script:RefreshTimer) { $script:RefreshTimer.Stop() }
        if ($null -ne $script:OpPollerTimer) { $script:OpPollerTimer.Stop() }
        if ($null -ne $script:OpContext -and $null -ne $script:OpContext.Process) {
            $script:OpContext.Process.Kill()
        }
    } catch {}
})

# 10. Start Application Loop
[System.Windows.Forms.Application]::Run($form)
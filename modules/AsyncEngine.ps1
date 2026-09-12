# ==========================================
# Asynchronous Dispatcher Engine & Timers
# ==========================================
$script:OpContext = $null

function Set-UiBusyState {
    param([bool]$IsBusy, [string]$StatusText = "")
    if ($null -eq $lblStatus -or $null -eq $progressBar) { return }

    if ($IsBusy) {
        $lblStatus.Text = if ($StatusText) { $StatusText } else { (Get-Text "StatusConnecting") }
        $lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(230, 180, 50)
        $progressBar.Style = [System.Windows.Forms.ProgressBarStyle]::Marquee
        $progressBar.Visible = $true
    } else {
        $lblStatus.Text = if ($StatusText) { $StatusText } else { (Get-Text "StatusReady") }
        $lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(100, 200, 100)
        $progressBar.Visible = $false
    }
}

function Start-AsyncOperation {
    param(
        [Parameter(Mandatory = $true)][string]$Operation,
        [hashtable]$Args = @{}
    )

    if ($null -ne $script:OpContext) {
        Write-Log -Message "Operation already in progress: $($script:OpContext.Operation)" -Level "WARN"
        return
    }

    try {
        $remoteCmd = ""
        $busyText = ""

        switch ($Operation) {
            "status" {
                $remoteCmd = Get-ServerStatusCommandString
                $busyText = Get-Text "StatusChecking"
            }
            "service_action" {
                $svc = $Args["ServiceName"]
                $act = $Args["Action"]
                $sudo = Get-SudoCommandPrefix
                $remoteCmd = "$sudo systemctl $act $svc; sleep 1; systemctl is-active $svc"
                $busyText = "$act $svc..."
            }
            "fetch_players" {
                $remoteCmd = Get-PlayersStatusCommandString
                $busyText = Get-Text "BtnRefreshPlayers" + "..."
            }
            "send_console_cmd" {
                $cmdText = $Args["Command"]
                $remoteCmd = Get-SoapCommandString -CommandText $cmdText
                $busyText = "SOAP: $cmdText..."
            }
            "read_rates" {
                $remoteCmd = Get-RatesReadCommandString
                $busyText = Get-Text "BtnLoadRates" + "..."
            }
            "save_rates" {
                $remoteCmd = Get-RatesSaveCommandString `
                    -KillXp $Args["KillXp"] -QuestXp $Args["QuestXp"] -ExploreXp $Args["ExploreXp"] `
                    -Reputation $Args["Reputation"] -Crafting $Args["Crafting"] -Gathering $Args["Gathering"] `
                    -Honor $Args["Honor"] -ArenaPoints $Args["ArenaPoints"] -Talent $Args["Talent"] `
                    -MoneyDrop $Args["MoneyDrop"] -DropPoor $Args["DropPoor"] -DropNormal $Args["DropNormal"] `
                    -DropUncommon $Args["DropUncommon"] -DropRare $Args["DropRare"] -DropEpic $Args["DropEpic"] `
                    -PlayerLimit $Args["PlayerLimit"] -MoveSpeed $Args["MoveSpeed"] -StartLevel $Args["StartLevel"] `
                    -StartMoneyCopper $Args["StartMoneyCopper"] -PetitionSigns $Args["PetitionSigns"] -FlightPaths $Args["FlightPaths"] `
                    -CrossGroup $Args["CrossGroup"] -CrossGuild $Args["CrossGuild"] -CrossChat $Args["CrossChat"] -Motd $Args["Motd"]
                $busyText = Get-Text "BtnSaveRates" + "..."
            }
            "list_backups" {
                $remoteCmd = Get-BackupsListCommandString
                $busyText = Get-Text "BtnRefreshBackups" + "..."
            }
            "create_backup" {
                $remoteCmd = Get-BackupCreateCommandString
                $busyText = Get-Text "BtnCreateBackup" + "..."
            }
            "delete_backup" {
                $remoteCmd = Get-BackupDeleteCommandString -FileName $Args["FileName"]
                $busyText = Get-Text "BtnDeleteBackup" + "..."
            }
            "purge_backups" {
                $remoteCmd = Get-BackupPurgeCommandString -RetentionCount $Args["RetentionCount"]
                $busyText = Get-Text "BtnPurgeBackups" + "..."
            }
            "load_log" {
                $logType = $Args["LogType"]
                $lines = $Args["Lines"]
                $remoteCmd = switch ($logType) {
                    "auth" { "tail -n $lines /home/azeroth/azerothcore/env/dist/etc/../logs/Auth.log 2>/dev/null || journalctl -u acore-authserver -n $lines --no-pager" }
                    "world" { "tail -n $lines /home/azeroth/azerothcore/env/dist/etc/../logs/Server.log 2>/dev/null || journalctl -u acore-worldserver -n $lines --no-pager" }
                    default { "tail -n $lines /home/azeroth/azerothcore/env/dist/etc/../logs/Server.log 2>/dev/null" }
                }
                $busyText = Get-Text "BtnRefreshLog" + "..."
            }
            default {
                throw "Unknown operation: $Operation"
            }
        }

        Set-UiBusyState -IsBusy $true -StatusText $busyText
        $proc = Start-AsyncRemoteProcess -RemoteCommand $remoteCmd

        $script:OpContext = @{
            Process   = $proc
            Operation = $Operation
            Args      = $Args
            StartTime = [DateTime]::UtcNow
        }

        $script:OpPollerTimer.Start()
    } catch {
        Write-Log -Message "Failed to start async operation '$Operation': $_" -Level "ERROR"
        Set-UiBusyState -IsBusy $false -StatusText (Get-Text "StatusError")
        [System.Windows.Forms.MessageBox]::Show($_.ToString(), (Get-Text "StatusError"), [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}

function Handle-OpCompleted {
    param($Context, [string]$Stdout, [string]$Stderr, [int]$ExitCode)

    $op = $Context.Operation
    Write-Log -Message "Async op completed: $op (ExitCode: $ExitCode)"

    try {
        switch ($op) {
            "status" {
                Update-DashboardStatusUi -Output $Stdout
            }
            "service_action" {
                Write-Log -Message "Service action finished: $Stdout $Stderr"
                Start-AsyncOperation -Operation "status"
            }
            "fetch_players" {
                Update-PlayersUi -RawData $Stdout
            }
            "send_console_cmd" {
                Update-ConsoleUi -Cmd $Context.Args["Command"] -RawXml $Stdout -Stderr $Stderr
            }
            "read_rates" {
                Update-RatesUi -RawData $Stdout
            }
            "save_rates" {
                Update-RatesSavedUi -RawData $Stdout
            }
            "list_backups" {
                Update-BackupsUi -RawData $Stdout
            }
            "create_backup" {
                Write-Log -Message "Backup creation result: $Stdout"
                [System.Windows.Forms.MessageBox]::Show((Get-Text "BackupCreatedSuccess"), "Backups", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
                Start-AsyncOperation -Operation "list_backups"
            }
            "delete_backup" {
                Start-AsyncOperation -Operation "list_backups"
            }
            "purge_backups" {
                $ret = $Context.Args["RetentionCount"]
                $msg = [string]::Format((Get-Text "PurgeComplete"), $ret)
                [System.Windows.Forms.MessageBox]::Show($msg, "Backups", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
                Start-AsyncOperation -Operation "list_backups"
            }
            "load_log" {
                Update-LogsUi -Text $Stdout
            }
        }
        Set-UiBusyState -IsBusy $false
    } catch {
        Write-Log -Message "Error handling completion for '$op': $_" -Level "ERROR"
        Set-UiBusyState -IsBusy $false -StatusText (Get-Text "StatusError")
    }
}

# Poller Timer Setup
$script:OpPollerTimer = New-Object System.Windows.Forms.Timer
$script:OpPollerTimer.Interval = 100
$script:OpPollerTimer.Add_Tick({
    if ($null -eq $script:OpContext) {
        $script:OpPollerTimer.Stop()
        return
    }

    $proc = $script:OpContext.Process
    $elapsed = ([DateTime]::UtcNow - $script:OpContext.StartTime).TotalMilliseconds

    if ($proc.HasExited) {
        $script:OpPollerTimer.Stop()
        $stdout = $proc.StandardOutput.ReadToEnd()
        $stderr = $proc.StandardError.ReadToEnd()
        $code = $proc.ExitCode
        $ctx = $script:OpContext
        $script:OpContext = $null
        Handle-OpCompleted -Context $ctx -Stdout $stdout -Stderr $stderr -ExitCode $code
    } elseif ($elapsed -gt $script:SshTimeoutMilliseconds) {
        $script:OpPollerTimer.Stop()
        try { $proc.Kill() } catch {}
        $ctx = $script:OpContext
        $script:OpContext = $null
        Set-UiBusyState -IsBusy $false -StatusText (Get-Text "StatusError")
        Write-Log -Message "Operation $($ctx.Operation) timed out after $($script:SshTimeoutMilliseconds)ms" -Level "ERROR"
        [System.Windows.Forms.MessageBox]::Show("Operation timed out ($($script:SshTimeoutMilliseconds)ms)", (Get-Text "StatusError"), [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
})
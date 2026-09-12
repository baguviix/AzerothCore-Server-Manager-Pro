# ==========================================
# Configuration Loader & Global Variables
# ==========================================
$ConfigPath = Join-Path $scriptRoot "azeroth_gui.config.json"
$DefaultConfig = [PSCustomObject]@{
    ServerIP               = "127.0.0.1"
    User                   = "ubuntu"
    Password               = ""
    SshKeyPath             = ""
    Language               = "ka"
    ServiceNames           = @("acore-authserver", "acore-worldserver")
    SshTimeoutMilliseconds = 15000
    LogFile                = "logs/azeroth_gui.log"
    AutoRefreshSeconds     = 30
    MinimizeToTray         = $false
    SoapUser               = "admin"
    SoapPassword           = ""
    SoapPort               = 7878
    BackupRetentionCount   = 7
}

try {
    if (Test-Path -LiteralPath $ConfigPath) {
        $Config = Get-Content -LiteralPath $ConfigPath -Raw -Encoding UTF8 | ConvertFrom-Json
    } else {
        $Config = $DefaultConfig
    }
} catch {
    $Config = $DefaultConfig
}

$script:ServerIP = if ([string]::IsNullOrWhiteSpace([string]$Config.ServerIP)) { "127.0.0.1" } else { [string]$Config.ServerIP }
$script:User = if ([string]::IsNullOrWhiteSpace([string]$Config.User)) { "ubuntu" } else { [string]$Config.User }
$script:Password = if ($null -ne $Config.Password) { [string]$Config.Password } else { "" }
$script:SshKeyPath = [string]$Config.SshKeyPath
$script:Language = if ([string]::IsNullOrWhiteSpace([string]$Config.Language)) { "ka" } else { [string]$Config.Language }
$script:ServiceNames = if ($Config.ServiceNames) { @($Config.ServiceNames | ForEach-Object { [string]$_ }) } else { @("acore-authserver", "acore-worldserver") }
$script:SshTimeoutMilliseconds = if ($Config.SshTimeoutMilliseconds -and [int]$Config.SshTimeoutMilliseconds -ge 3000) { [int]$Config.SshTimeoutMilliseconds } else { 15000 }
$script:AutoRefreshSeconds = if ($Config.AutoRefreshSeconds -and [int]$Config.AutoRefreshSeconds -ge 0) { [int]$Config.AutoRefreshSeconds } else { 30 }
$script:MinimizeToTray = if ($null -ne $Config.MinimizeToTray) { [bool]$Config.MinimizeToTray } else { $false }
$script:SoapUser = if ([string]::IsNullOrWhiteSpace([string]$Config.SoapUser)) { "admin" } else { [string]$Config.SoapUser }
$script:SoapPassword = if ($null -ne $Config.SoapPassword) { [string]$Config.SoapPassword } else { "" }
$script:SoapPort = if ($Config.SoapPort -and [int]$Config.SoapPort -gt 0) { [int]$Config.SoapPort } else { 7878 }
$script:BackupRetentionCount = if ($Config.BackupRetentionCount -and [int]$Config.BackupRetentionCount -gt 0) { [int]$Config.BackupRetentionCount } else { 7 }
$script:LogFile = if ([string]::IsNullOrWhiteSpace([string]$Config.LogFile)) { "logs/azeroth_gui.log" } else { [string]$Config.LogFile }

# Scope compatibility aliases
$ServerIP = $script:ServerIP
$User = $script:User
$Password = $script:Password
$SshKeyPath = $script:SshKeyPath
$Language = $script:Language
$ServiceNames = $script:ServiceNames
$SshTimeoutMilliseconds = $script:SshTimeoutMilliseconds
$AutoRefreshSeconds = $script:AutoRefreshSeconds
$MinimizeToTray = $script:MinimizeToTray
$SoapUser = $script:SoapUser
$SoapPassword = $script:SoapPassword
$SoapPort = $script:SoapPort
$BackupRetentionCount = $script:BackupRetentionCount
$LogFile = $script:LogFile

function Save-CurrentConfig {
    $currentCfg = [PSCustomObject]@{
        ServerIP               = $script:ServerIP
        User                   = $script:User
        Password               = $script:Password
        SshKeyPath             = $script:SshKeyPath
        Language               = $script:Language
        ServiceNames           = $script:ServiceNames
        SshTimeoutMilliseconds = $script:SshTimeoutMilliseconds
        LogFile                = $script:LogFile
        AutoRefreshSeconds     = $script:AutoRefreshSeconds
        MinimizeToTray         = $script:MinimizeToTray
        SoapUser               = $script:SoapUser
        SoapPassword           = $script:SoapPassword
        SoapPort               = $script:SoapPort
        BackupRetentionCount   = $script:BackupRetentionCount
    }
    try {
        $json = $currentCfg | ConvertTo-Json -Depth 4
        [System.IO.File]::WriteAllText($ConfigPath, $json, [System.Text.Encoding]::UTF8)
    } catch {
        Write-Log -Message "Failed to save configuration: $_" -Level "WARN"
    }
}
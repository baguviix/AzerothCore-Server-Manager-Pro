# ==========================================
# Logging Helper Module
# ==========================================
function Write-Log {
    param(
        [Parameter(Mandatory = $true)][string]$Message,
        [string]$Level = "INFO"
    )
    $ts = [DateTime]::Now.ToString("yyyy-MM-dd HH:mm:ss")
    $line = "[$ts] [$Level] $Message"
    try {
        $logPath = if ([System.IO.Path]::IsPathRooted($script:LogFile)) {
            $script:LogFile
        } else {
            Join-Path $scriptRoot $script:LogFile
        }

        $dir = [System.IO.Path]::GetDirectoryName($logPath)
        if (-not [string]::IsNullOrWhiteSpace($dir) -and -not (Test-Path -LiteralPath $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
        Add-Content -LiteralPath $logPath -Value $line -Encoding UTF8
    } catch {}
}
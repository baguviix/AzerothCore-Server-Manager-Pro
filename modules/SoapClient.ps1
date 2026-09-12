# ==========================================
# SOAP Client Module
# ==========================================
function Get-SoapCommandString {
    param([Parameter(Mandatory = $true)][string]$CommandText)

    $escapedCmd = [System.Security.SecurityElement]::Escape($CommandText)
    $xml = @"
<?xml version="1.0" encoding="utf-8"?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">
<SOAP-ENV:Body>
<ns1:executeCommand xmlns:ns1="urn:AC">
<command>$escapedCmd</command>
</ns1:executeCommand>
</SOAP-ENV:Body>
</SOAP-ENV:Envelope>
"@

    $b64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($xml))
    $auth = "$($script:SoapUser):$($script:SoapPassword)"
    return "echo '$b64' | base64 -d | curl -s --max-time 10 -u '$auth' --data-binary @- -H 'Content-Type: text/xml; charset=UTF-8' http://127.0.0.1:$($script:SoapPort)/"
}

function Parse-SoapResponseXml {
    param([string]$RawXml)
    if ([string]::IsNullOrWhiteSpace($RawXml)) {
        return "No response from SOAP server."
    }
    try {
        if ($RawXml -match '<result>(.*?)</result>') {
            $matched = $matches[1]
            $decoded = [System.Web.HttpUtility]::HtmlDecode($matched)
            return $decoded.Replace("&#xD;", "`r").Trim()
        } elseif ($RawXml -match '<faultstring>(.*?)</faultstring>') {
            return "SOAP Fault: " + $matches[1]
        }
        return $RawXml.Trim()
    } catch {
        return $RawXml.Trim()
    }
}
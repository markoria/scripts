<#
.Synopsis
    Checks for encoding of file
.DESCRIPTION
    This script check for file encoding and returns details 
.INPUTS
    You can pipe a file path to this object
.OUTPUTS
    this script outputs an object containing encoding information
.EXAMPLE
    encoding.ps1 -path "Path to file"
#>

[CmdletBinding(ConfirmImpact = 'Medium', SupportsShouldProcess = $true)]
Param
(
    [Parameter(Mandatory = $true, 
        ValueFromPipelineByPropertyName = $true, 
        Position = 0,
        ParameterSetName = 'Parameter Set 1')]
    [ValidateNotNull()]
    [ValidateNotNullOrEmpty()]
    [string]
    $path
)

$legacyEncoding = $false
try {
    try {
        [byte[]]$byte = get-content -AsByteStream -ReadCount 4 -TotalCount 4 -LiteralPath $path
            
    }
    catch {
        #same as try since sometimes it throws an error without any reason
        [byte[]]$byte = get-content -Encoding Byte -ReadCount 4 -TotalCount 4 -LiteralPath $path
        $legacyEncoding = $true
    }
        
    if (-not $byte) {
        if ($legacyEncoding) { "unknown" } else { [System.Text.Encoding]::Default }
    }
}
catch {
    throw
}
    
#Write-Host Bytes: $byte[0] $byte[1] $byte[2] $byte[3]
 
# EF BB BF (UTF8)
if ( $byte[0] -eq 0xef -and $byte[1] -eq 0xbb -and $byte[2] -eq 0xbf )
{ if ($legacyEncoding) { "UTF8" } else { [System.Text.Encoding]::UTF8 } }
 
# FE FF (UTF-16 Big-Endian)
elseif ($byte[0] -eq 0xfe -and $byte[1] -eq 0xff)
{ if ($legacyEncoding) { "bigendianunicode" } else { [System.Text.Encoding]::BigEndianUnicode } }
 
# FF FE (UTF-16 Little-Endian)
elseif ($byte[0] -eq 0xff -and $byte[1] -eq 0xfe)
{ if ($legacyEncoding) { "unicode" } else { [System.Text.Encoding]::Unicode } }
 
# 00 00 FE FF (UTF32 Big-Endian)
elseif ($byte[0] -eq 0 -and $byte[1] -eq 0 -and $byte[2] -eq 0xfe -and $byte[3] -eq 0xff)
{ if ($legacyEncoding) { "utf32" } else { [System.Text.Encoding]::UTF32 } }
 
# FE FF 00 00 (UTF32 Little-Endian)
elseif ($byte[0] -eq 0xfe -and $byte[1] -eq 0xff -and $byte[2] -eq 0 -and $byte[3] -eq 0)
{ if ($legacyEncoding) { "utf32" } else { [System.Text.Encoding]::UTF32 } }
 
# 2B 2F 76 (38 | 38 | 2B | 2F)
elseif ($byte[0] -eq 0x2b -and $byte[1] -eq 0x2f -and $byte[2] -eq 0x76 -and ($byte[3] -eq 0x38 -or $byte[3] -eq 0x39 -or $byte[3] -eq 0x2b -or $byte[3] -eq 0x2f) )
{ if ($legacyEncoding) { "utf7" } else { [System.Text.Encoding]::UTF7 } }
 
# F7 64 4C (UTF-1)
elseif ( $byte[0] -eq 0xf7 -and $byte[1] -eq 0x64 -and $byte[2] -eq 0x4c )
{ throw "UTF-1 not a supported encoding" }
 
# DD 73 66 73 (UTF-EBCDIC)
elseif ($byte[0] -eq 0xdd -and $byte[1] -eq 0x73 -and $byte[2] -eq 0x66 -and $byte[3] -eq 0x73)
{ throw "UTF-EBCDIC not a supported encoding" }
 
# 0E FE FF (SCSU)
elseif ( $byte[0] -eq 0x0e -and $byte[1] -eq 0xfe -and $byte[2] -eq 0xff )
{ throw "SCSU not a supported encoding" }
 
# FB EE 28 (BOCU-1)
elseif ( $byte[0] -eq 0xfb -and $byte[1] -eq 0xee -and $byte[2] -eq 0x28 )
{ throw "BOCU-1 not a supported encoding" }
 
# 84 31 95 33 (GB-18030)
elseif ($byte[0] -eq 0x84 -and $byte[1] -eq 0x31 -and $byte[2] -eq 0x95 -and $byte[3] -eq 0x33)
{ throw "GB-18030 not a supported encoding" }
 
else
{ if ($legacyEncoding) { "ascii" } else { [System.Text.Encoding]::ASCII } }

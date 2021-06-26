<#
.Synopsis
    Converts escaped json string into proper json string
.DESCRIPTION
    This script converts .net escaped json string to proper json
.INPUTS
    You can pipe a file path to this object
.OUTPUTS
    this script outputs a file to the filesystem with modified json 
.EXAMPLE
    fixEscapedJson.ps1 -path `"Path to file`"
#>

[CmdletBinding(ConfirmImpact='Medium',SupportsShouldProcess=$true)]
Param
(
    [Parameter(Mandatory=$true, 
                ValueFromPipelineByPropertyName=$true, 
                Position=0,
                ParameterSetName='Parameter Set 1')]
    [ValidateNotNull()]
    [ValidateNotNullOrEmpty()]
    [string]
    $path
)
try {
$newpath = $path -replace '.json', '_fixed.json'
$fileContents = Get-Content -Path $path -ErrorVariable GetFileError
$newContent = $fileContents -replace '(?<=Source":\s*)\[(.*?)\]', "`{`$1`}"
$newContent = $newContent -replace '"\\"([\w_]*)\\"([:\s]*)\\?("?[\w\.\s-]*)', "`"`$1`"`$2`$3"
$newContent = $newContent -replace '(?<=\d)",',','
$newContent = $newContent -replace '\\""(?=,|})', '"'
$newContent > $newpath
}
catch {
    Write-Error "Could not transform file $($_.ErrorDetails)"
}
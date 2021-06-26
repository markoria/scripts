#changes file encoding from windows code page to utf8

param (
  [string]$path,
  [int]$codePage,
  [bool]$withBOM = $false,
  [switch]$help
)
if ($help -or ([string]::IsNullOrWhiteSpace($path) -or $codePage -eq $null )) {
  write-host $path
  Write-Host "-path is the path of the file or folder"
  Write-Host "-codePage is the initial encoding in file described as windows code page"
  Write-Host "-withBOM is the flag for addition of BOM (defaults to false)"
  Write-Host "Command example:"
  Write-Host ".\encodingChanger.ps1 -path `"Path to file`" -codePage 1252 "
  Write-Host ".\encodingChanger.ps1 -path `"Path to file`" -codePage 1252 -withBOM $true"
  Write-Host ""
}
 
$utf8 = New-Object System.Text.UTF8Encoding($withBOM)
$enc = [System.Text.Encoding]::GetEncoding($codePage)

if ((Get-Item $path) -is [System.IO.DirectoryInfo]) {  

  foreach ($i in Get-ChildItem -Path $path -Recurse -Force) {
    $file = Get-ChildItem $i.FullName
    $newFilePath = Join-Path $file.Directory "$($file.BaseName)-edited$($file.Extension)"
    $content = [IO.File]::ReadLines("$($i.FullName)", $enc)
    [System.IO.File]::WriteAllLines("$($newFilePath)", $content, $utf8)
  }

}
else {
  $file = Get-ChildItem $path
  $newFilePath = Join-Path $file.Directory "$($file.BaseName)-edited$($file.Extension)"
  $content = [IO.File]::ReadLines("$($path)", $enc)
  [System.IO.File]::WriteAllLines("$($newFilePath)", $content, $utf8)
}
    
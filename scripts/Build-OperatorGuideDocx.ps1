#Requires -Version 5.1
<#
  Builds docs/Server_Operator_Guide.docx from docs/Server_Operator_Guide.md (OOXML).
#>
param(
    [string]$RepoRoot = (Split-Path $PSScriptRoot -Parent)
)
Add-Type -AssemblyName System.IO.Compression
$ErrorActionPreference = 'Stop'

$mdPath = Join-Path $RepoRoot 'docs\Server_Operator_Guide.md'
$outDocx = Join-Path $RepoRoot 'docs\Server_Operator_Guide.docx'

function Xml-Escape([string]$s) {
    if ([string]::IsNullOrEmpty($s)) { return '' }
    return [System.Security.SecurityElement]::Escape($s)
}

function Add-P {
    param([System.Text.StringBuilder]$Sb, [string]$Text, [string]$Style = 'Normal')
    if ([string]::IsNullOrWhiteSpace($Text)) { return }
    $null = $Sb.Append("<w:p><w:pPr><w:pStyle w:val=`"$Style`"/></w:pPr><w:r><w:t xml:space=`"preserve`">")
    $null = $Sb.Append((Xml-Escape $Text))
    $null = $Sb.Append('</w:t></w:r></w:p>')
}

if (-not (Test-Path -LiteralPath $mdPath)) {
    throw "Missing: $mdPath"
}

$lines = Get-Content -LiteralPath $mdPath -Encoding UTF8
$body = [System.Text.StringBuilder]::new()
$inCode = $false

foreach ($line in $lines) {
    $t = $line.TrimEnd()
    if ($t -match '^```') {
        $inCode = -not $inCode
        continue
    }
    if ($inCode) {
        Add-P -Sb $body -Text ('    ' + $t) -Style 'Normal'
        continue
    }
    if ($t -match '^---\s*$') { continue }
    if ($t -match '^###\s+(.+)$') {
        Add-P -Sb $body -Text $matches[1] -Style 'Heading3'
        continue
    }
    if ($t -match '^##\s+(.+)$') {
        Add-P -Sb $body -Text $matches[1] -Style 'Heading2'
        continue
    }
    if ($t -match '^#\s+(.+)$') {
        Add-P -Sb $body -Text $matches[1] -Style 'Heading1'
        continue
    }
    if ($t -match '^[-*]\s+(.+)$') {
        Add-P -Sb $body -Text ([char]0x2022 + ' ' + $matches[1]) -Style 'Normal'
        continue
    }
    if ([string]::IsNullOrWhiteSpace($t)) { continue }
    if ($t -match '^\|[\s\-:|]+\|$') { continue }
    # Markdown tables and normal text: keep as paragraph
    $plain = $t -replace '\*\*([^*]+)\*\*', '$1'
    Add-P -Sb $body -Text $plain -Style 'Normal'
}

$documentXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
  <w:body>
$($body.ToString())
    <w:sectPr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440"/></w:sectPr>
  </w:body>
</w:document>
"@

$stylesXml = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:docDefaults><w:rPrDefault><w:rPr><w:sz w:val="22"/></w:rPr></w:rPrDefault></w:docDefaults>
  <w:style w:type="paragraph" w:default="1" w:styleId="Normal">
    <w:name w:val="Normal"/><w:qFormat/>
    <w:pPr><w:spacing w:after="120" w:line="276" w:lineRule="auto"/></w:pPr>
    <w:rPr><w:sz w:val="22"/></w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading1">
    <w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:qFormat/>
    <w:pPr><w:spacing w:before="240" w:after="120"/></w:pPr>
    <w:rPr><w:b/><w:sz w:val="32"/></w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading2">
    <w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:qFormat/>
    <w:pPr><w:spacing w:before="200" w:after="80"/></w:pPr>
    <w:rPr><w:b/><w:sz w:val="28"/></w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading3">
    <w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:qFormat/>
    <w:pPr><w:spacing w:before="160" w:after="60"/></w:pPr>
    <w:rPr><w:b/><w:sz w:val="24"/></w:rPr>
  </w:style>
</w:styles>
'@

$contentTypes = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
</Types>
'@

$relsRoot = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
</Relationships>
'@

$relsDoc = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
</Relationships>
'@

New-Item -ItemType Directory -Force -Path (Split-Path $outDocx -Parent) | Out-Null
if (Test-Path -LiteralPath $outDocx) { Remove-Item -LiteralPath $outDocx -Force }

$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$zipStream = [System.IO.File]::Open($outDocx, [System.IO.FileMode]::CreateNew)
try {
    $zip = New-Object System.IO.Compression.ZipArchive($zipStream, [System.IO.Compression.ZipArchiveMode]::Create)
    function Zip-Add([string]$EntryName, [string]$Content) {
        $e = $zip.CreateEntry($EntryName, [System.IO.Compression.CompressionLevel]::Optimal)
        $sw = New-Object System.IO.StreamWriter($e.Open(), $utf8NoBom)
        try { $sw.Write($Content) } finally { $sw.Dispose() }
    }
    Zip-Add '[Content_Types].xml' $contentTypes
    Zip-Add '_rels/.rels' $relsRoot
    Zip-Add 'word/document.xml' $documentXml
    Zip-Add 'word/styles.xml' $stylesXml
    Zip-Add 'word/_rels/document.xml.rels' $relsDoc
}
finally {
    if ($zip) { $zip.Dispose() }
    $zipStream.Dispose()
}

Write-Host "Wrote: $outDocx"

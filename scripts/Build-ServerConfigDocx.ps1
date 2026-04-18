#Requires -Version 5.1
<#
  Builds docs/Server_Config_Reference.docx (OOXML) from configs under $RepoRoot\configs
#>
param(
    [string]$RepoRoot = (Split-Path $PSScriptRoot -Parent)
)
Add-Type -AssemblyName System.IO.Compression
$ErrorActionPreference = 'Stop'
$configsRoot = Join-Path $RepoRoot 'configs'
$outDocx = Join-Path $RepoRoot 'docs\Server_Config_Reference.docx'
$outMd = Join-Path $RepoRoot 'docs\Server_Config_Reference.md'

function Xml-Escape([string]$s) {
    if ([string]::IsNullOrEmpty($s)) { return '' }
    return [System.Security.SecurityElement]::Escape($s)
}

function Get-ConfFileSummary {
    param([string]$FilePath)
    $name = Split-Path $FilePath -Leaf
    $lines = Get-Content -LiteralPath $FilePath -Encoding UTF8 -ErrorAction Stop
    $desc = [System.Collections.Generic.List[string]]::new()
    $keys = [System.Collections.Generic.List[string]]::new()
    foreach ($line in $lines) {
        if ($desc.Count -lt 6) {
            if ($line -match '^\s*#\s*(.+)$') {
                $t = $matches[1].Trim()
                if ($t.Length -ge 8 -and $t -notmatch '^[#=\s\-]{6,}$' -and $t -notmatch '^SECTION INDEX') {
                    $desc.Add($t)
                }
            }
        }
        if ($line -match '^\s*([A-Za-z0-9_.]+)\s*=') {
            $k = $matches[1]
            if (-not $keys.Contains($k)) { $keys.Add($k) }
            if ($keys.Count -ge 14) { break }
        }
    }
    return [PSCustomObject]@{ Name = $name; Desc = $desc; Keys = $keys }
}

function Add-P {
    param([System.Text.StringBuilder]$Sb, [string]$Text, [string]$Style = 'Normal')
    $null = $Sb.Append("<w:p><w:pPr><w:pStyle w:val=`"$Style`"/></w:pPr><w:r><w:t xml:space=`"preserve`">")
    $null = $Sb.Append((Xml-Escape $Text))
    $null = $Sb.Append('</w:t></w:r></w:p>')
}

# Simple bullet prefix for lists (no numbering.xml required)
function Add-BulletLine {
    param([System.Text.StringBuilder]$Sb, [string]$Text)
    Add-P -Sb $Sb -Text ([char]0x2022 + ' ' + $Text) -Style 'Normal'
}

$moduleConf = Get-ChildItem -Path (Join-Path $configsRoot 'modules') -Recurse -Filter '*.conf' -File | Sort-Object FullName
$summaries = foreach ($f in $moduleConf) { Get-ConfFileSummary -FilePath $f.FullName }

New-Item -ItemType Directory -Force -Path (Split-Path $outDocx -Parent) | Out-Null

# --- Build Markdown (fallback / human-readable copy) ---
$md = [System.Text.StringBuilder]::new()
$null = $md.AppendLine('# Server Config Reference')
$null = $md.AppendLine('')
$null = $md.AppendLine('Generated for this AzerothCore deployment. Edit configs under `configs/`, then restart worldserver (and authserver if needed).')
$null = $md.AppendLine('')
$null = $md.AppendLine('## Table of contents')
$null = $md.AppendLine('1. [Expansion era (Vanilla / TBC / WotLK)](#expansion-era-vanilla--tbc--wotlk)')
$null = $md.AppendLine('2. [Our custom values (recap)](#our-custom-values-recap)')
$null = $md.AppendLine('3. [Core: worldserver.conf & authserver.conf](#core-servers)')
$null = $md.AppendLine('4. [Module configs (configs/modules/*.conf)](#module-configs)')
$null = $md.AppendLine('')

$null = $md.AppendLine('## Expansion era (Vanilla / TBC / WotLK)')
$null = $md.AppendLine('')
$null = $md.AppendLine('Expansion is controlled by **several layers** together:')
$null = $md.AppendLine('')
$null = $md.AppendLine('| Layer | File | What to change |')
$null = $md.AppendLine('|-------|------|----------------|')
$null = $md.AppendLine('| Level cap | `configs/worldserver.conf` | `MaxPlayerLevel`: **60** (Vanilla), **70** (TBC), **80** (WotLK). |')
$null = $md.AppendLine('| Individual Progression stages | `configs/modules/individualProgression.conf` | `ProgressionLimit` (0 = no cap through stage 18), `StartingProgression` (jump new characters to a stage). Stage **7** is documented as Vanilla lock; **8** is TBC-related (e.g. Draenei/BELF); **13** is WotLK/DK-related. Exact enum: **IndividualProgression.h** in the module source. |')
$null = $md.AppendLine('| Randombots | `configs/modules/playerbots.conf` | `RandomBotMaxLevel`, `RandomBotMaps` (0,1 = Kalimdor/EK; add **530** Outland, **571** Northrend), `ExcludedAccountsMaxLevel` in IP must match `MaxPlayerLevel` for bot accounts. |')
$null = $md.AppendLine('')
$null = $md.AppendLine('### Checklists')
$null = $md.AppendLine('')
$null = $md.AppendLine('**Vanilla-focused**')
$null = $md.AppendLine('- `MaxPlayerLevel = 60`')
$null = $md.AppendLine('- `IndividualProgression.ProgressionLimit = 7` (example: stay in Vanilla content per module docs)')
$null = $md.AppendLine('- `IndividualProgression.ExcludedAccountsMaxLevel = 60`')
$null = $md.AppendLine('- `AiPlayerbot.RandomBotMaxLevel = 60`, `RandomBotMaps = 0,1` (optional)')
$null = $md.AppendLine('')
$null = $md.AppendLine('**TBC era**')
$null = $md.AppendLine('- `MaxPlayerLevel = 70`')
$null = $md.AppendLine('- Raise or clear `ProgressionLimit` so players can reach TBC stages (see module enum; stage **8** marks TBC entry in conf examples)')
$null = $md.AppendLine('- `ExcludedAccountsMaxLevel = 70`')
$null = $md.AppendLine('- `AiPlayerbot.RandomBotMaxLevel = 70`, add **530** to `RandomBotMaps`')
$null = $md.AppendLine('')
$null = $md.AppendLine('**Full WotLK**')
$null = $md.AppendLine('- `MaxPlayerLevel = 80`')
$null = $md.AppendLine('- `IndividualProgression.ProgressionLimit = 0` (no stage cap)')
$null = $md.AppendLine('- `IndividualProgression.ExcludedAccountsMaxLevel = 80`')
$null = $md.AppendLine('- `AiPlayerbot.RandomBotMaxLevel = 80`, `RandomBotMaps = 0,1,530,571`')
$null = $md.AppendLine('')
$null = $md.AppendLine('> **Note:** Individual Progression stores progression in the **database**. Changing configs alone does not reset players'' progression state.')
$null = $md.AppendLine('')

$null = $md.AppendLine('## Our custom values (recap)')
$null = $md.AppendLine('')
$null = $md.AppendLine('| Location | Setting | Value |')
$null = $md.AppendLine('|----------|---------|-------|')
$null = $md.AppendLine('| worldserver.conf | MaxPlayerLevel | 60 |')
$null = $md.AppendLine('| worldserver.conf | ItemDelete.ItemLevel | 60 |')
$null = $md.AppendLine('| individualProgression.conf | ProgressionLimit | 7 |')
$null = $md.AppendLine('| individualProgression.conf | ExcludedAccountsMaxLevel | 60 |')
$null = $md.AppendLine('| playerbots.conf | Min/MaxRandomBots | 600 |')
$null = $md.AppendLine('| playerbots.conf | RandomBotMaxLevel | 60 |')
$null = $md.AppendLine('| playerbots.conf | SyncLevelWithPlayers | 1 |')
$null = $md.AppendLine('| playerbots.conf | DisableRandomLevels / RandombotStartingLevel | 1 / 1 |')
$null = $md.AppendLine('| playerbots.conf | botActiveAloneSmartScaleWhenMaxLevel | 60 |')
$null = $md.AppendLine('| playerbots.conf | RandomBotMaps | 0,1 |')
$null = $md.AppendLine('| playerbots.conf | FastReactInBG | 0 |')
$null = $md.AppendLine('| playerbots.conf | RandomBotUpdateInterval | 25 |')
$null = $md.AppendLine('| playerbots.conf | RandomBotsPerInterval | 40 |')
$null = $md.AppendLine('| playerbots.conf | IterationsPerTick | 8 |')
$null = $md.AppendLine('| .gitignore | mysql/, *.pdb | ignored |')
$null = $md.AppendLine('')

$null = $md.AppendLine('## Core servers')
$null = $md.AppendLine('')
$null = $md.AppendLine('### worldserver.conf')
$null = $md.AppendLine('Main game server: database connections, rates, maps, visibility, battlegrounds, LFG, logging, performance (`MapUpdateInterval`, `ThreadPool`, etc.).')
$null = $md.AppendLine('')
$null = $md.AppendLine('### authserver.conf')
$null = $md.AppendLine('Login server: realm list, ports, database connection for authentication.')
$null = $md.AppendLine('')

$null = $md.AppendLine('## Module configs')
$null = $md.AppendLine('')
$null = $md.AppendLine('The following summaries cover **`configs/modules/*.conf`** only. **`configs/worldserver.conf`** and **`configs/authserver.conf`** are described under [Core servers](#core-servers) above.')
$null = $md.AppendLine('')
$null = $md.AppendLine('To regenerate this file and `Server_Config_Reference.docx`, run from the repo root: `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Build-ServerConfigDocx.ps1`')
$null = $md.AppendLine('')
foreach ($s in $summaries) {
    $null = $md.AppendLine("### $($s.Name)")
    foreach ($d in $s.Desc) { $null = $md.AppendLine($d) }
    if ($s.Keys.Count -gt 0) {
        $null = $md.AppendLine('')
        $null = $md.AppendLine('Sample keys: ' + ($s.Keys -join ', ') + '.')
    }
    $null = $md.AppendLine('')
}
[System.IO.File]::WriteAllText($outMd, $md.ToString(), [System.Text.UTF8Encoding]::new($false))

# --- WordprocessingML body ---
$body = [System.Text.StringBuilder]::new()
Add-P -Sb $body -Text 'Server Config Reference' -Style 'Heading1'
Add-P -Sb $body -Text 'AzerothCore deployment — configs under configs/. Restart worldserver after edits; backup files first.' -Style 'Normal'

Add-P -Sb $body -Text 'Expansion era (Vanilla / TBC / WotLK)' -Style 'Heading2'
Add-P -Sb $body -Text 'Use worldserver MaxPlayerLevel (60 / 70 / 80), Individual Progression ProgressionLimit and StartingProgression (stages 0–18; see IndividualProgression.h in module source). Conf anchors: stage 7 = Vanilla example; 8 = TBC; 13 = WotLK/DK. Align playerbots: RandomBotMaxLevel, RandomBotMaps (530 Outland, 571 Northrend), and ExcludedAccountsMaxLevel with MaxPlayerLevel.' -Style 'Normal'

Add-P -Sb $body -Text 'Our custom values (recap)' -Style 'Heading2'
Add-BulletLine $body 'worldserver: MaxPlayerLevel=60, ItemDelete.ItemLevel=60'
Add-BulletLine $body 'individualProgression: ProgressionLimit=7, ExcludedAccountsMaxLevel=60'
Add-BulletLine $body 'playerbots: 600 bots, RandomBotMaxLevel=60, SyncLevelWithPlayers=1, start level 1, RandomBotMaps=0,1, CPU-related tweaks (FastReactInBG=0, etc.)'
Add-BulletLine $body '.gitignore: mysql/, *.pdb'

Add-P -Sb $body -Text 'Core servers' -Style 'Heading2'
Add-P -Sb $body -Text 'worldserver.conf — Main world server (DB, rates, maps, visibility, BG/LFG, performance).' -Style 'Normal'
Add-P -Sb $body -Text 'authserver.conf — Authentication and realmlist.' -Style 'Normal'

Add-P -Sb $body -Text 'Module configuration files' -Style 'Heading2'
Add-P -Sb $body -Text ('Module configs under configs/modules: ' + $summaries.Count + ' files. Summaries below (headers + sample keys).') -Style 'Normal'

foreach ($s in $summaries) {
    Add-P -Sb $body -Text $s.Name -Style 'Heading3'
    $d0 = if ($s.Desc.Count -gt 0) { $s.Desc[0] } else { '(no description comments)' }
    Add-P -Sb $body -Text $d0 -Style 'Normal'
    if ($s.Desc.Count -gt 1) {
        for ($i = 1; $i -lt [Math]::Min(4, $s.Desc.Count); $i++) {
            Add-P -Sb $body -Text $s.Desc[$i] -Style 'Normal'
        }
    }
    if ($s.Keys.Count -gt 0) {
        Add-P -Sb $body -Text ('Sample keys: ' + ($s.Keys -join ', ') + '.') -Style 'Normal'
    }
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
Write-Host "Wrote: $outMd"

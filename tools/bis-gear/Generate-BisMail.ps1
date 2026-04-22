param(
    [Parameter(Mandatory = $true)]
    [string] $Class,
    [Parameter(Mandatory = $true)]
    [string] $Name,
    [string] $DataDir,
    [string] $AliasFile,
    [string] $OutDir,
    [switch] $IncludeAlternates,
    [switch] $Apply
)

$ErrorActionPreference = "Stop"
$scriptRoot = $PSScriptRoot
if ([string]::IsNullOrEmpty($scriptRoot)) {
    $scriptRoot = Split-Path -Parent -LiteralPath $MyInvocation.MyCommand.Path
}
if ([string]::IsNullOrEmpty($DataDir)) { $DataDir = Join-Path $scriptRoot "data\tbc-p1" }
if ([string]::IsNullOrEmpty($AliasFile)) { $AliasFile = Join-Path $scriptRoot "class-spec-aliases.tsv" }
if ([string]::IsNullOrEmpty($OutDir)) { $OutDir = Join-Path $scriptRoot "sql\generated" }

function Resolve-Slug {
    param([string] $Raw)
    $q = ($Raw.Trim().ToLowerInvariant() -replace '\s+', ' ')
    if ([string]::IsNullOrWhiteSpace($q)) { return $null }

    if (-not (Test-Path -LiteralPath $AliasFile)) {
        Write-Error "Missing alias file: $AliasFile"
    }
    foreach ($line in Get-Content -LiteralPath $AliasFile) {
        if ($line -match '^\s*#' -or [string]::IsNullOrWhiteSpace($line)) { continue }
        $tab = $line.IndexOf("`t")
        if ($tab -lt 0) { continue }
        $slug = $line.Substring(0, $tab).Trim()
        $rest = $line.Substring($tab + 1)
        foreach ($syn in ($rest -split ',')) {
            $t = $syn.Trim()
            if ($q -eq $t) { return $slug }
        }
    }
    $direct = Join-Path $DataDir "$q.csv"
    if (Test-Path -LiteralPath $direct) { return $q }
    return $null
}

function Test-CsvHasItemIds {
    param([string] $Path)
    foreach ($line in Get-Content -LiteralPath $Path) {
        if ($line -match '^Meta,') { continue }
        if ($line -match '^[^,]+,[^,]+,\s*[0-9]') { return $true }
    }
    return $false
}

$slug = Resolve-Slug $Class
if (-not $slug) {
    Write-Error "Could not resolve class/spec: `"$Class`". Use a slug (e.g. druid-restoration) or add a line to $AliasFile"
}

$csvPath = Join-Path $DataDir "$slug.csv"
if (-not (Test-Path -LiteralPath $csvPath)) {
    Write-Error "No CSV for slug `"$slug`": $csvPath - run Initialize-TbcP1BisTemplates.ps1 and fill ItemId."
}

if (-not (Test-CsvHasItemIds $csvPath)) {
    Write-Error "CSV has no numeric ItemId values yet: $csvPath. Add Wowhead TBC item IDs, or try a filled spec: -Class 'protection paladin'"
}

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$safe = ($Name -replace '[^a-zA-Z0-9_-]', '_')
$outSql = Join-Path $OutDir "tbc-p1-$slug-$safe.sql"
$subject = "TBC P1 BiS $slug"
$export = Join-Path $scriptRoot "Export-BisSql.ps1"

$psArgs = @(
    "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $export
    "-CsvPath", $csvPath
    "-CharacterName", $Name
    "-MailSubject", $subject
)
if ($IncludeAlternates) { $psArgs += "-IncludeAlts" }

Write-Host "Slug:      $slug"
Write-Host "CSV:       $csvPath"
Write-Host "Character: $Name"
Write-Host "Output:    $outSql"

$header = @(
    "-- TBC Phase 1 BiS mail SQL"
    "-- Spec: $slug"
    "-- Character: $Name"
    "-- Generated: $([DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ'))"
    ""
) -join "`r`n"

$body = & powershell.exe @psArgs | Out-String
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
($header + $body.TrimEnd()) | Set-Content -LiteralPath $outSql -Encoding UTF8
Write-Host "Wrote $outSql"

if ($Apply) {
    if (-not $env:MYSQL_CMD) {
        Write-Error "Set MYSQL_CMD to your mysql client line, e.g. mysql -h 127.0.0.1 -u acore -pacore acore_characters"
    }
    Write-Host "Applying SQL via MYSQL_CMD ..."
    $inner = $env:MYSQL_CMD + ' < "' + $outSql + '"'
    $proc = Start-Process -FilePath "cmd.exe" -ArgumentList "/c", $inner -NoNewWindow -Wait -PassThru
    if ($proc.ExitCode -ne 0) { exit $proc.ExitCode }
    Write-Host "Done."
} else {
    Write-Host ('Run on your characters database, e.g. mysql ... acore_characters with input file: ' + $outSql)
}

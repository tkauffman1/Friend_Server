param(
    [Parameter(Mandatory = $true)]
    [string] $CsvPath,
    [Parameter(Mandatory = $true)]
    [string] $CharacterName,
    [string] $MailSubject = "BiS gear",
    [string] $MailBody = "Granted by Export-BisSql.ps1 - claim from mailbox.",
    [int] $AttachmentsPerMail = 12,
    [switch] $IncludeAlts,
    [switch] $OneMailPerItem
)

if (-not (Test-Path -LiteralPath $CsvPath)) {
    Write-Error "CSV not found: $CsvPath"
    exit 1
}

$rows = Import-Csv -LiteralPath $CsvPath
$ids = [System.Collections.Generic.List[int]]::new()
foreach ($r in $rows) {
    if ($r.Slot -eq 'Meta') { continue }
    $id = ($r.ItemId | ForEach-Object { $_.Trim() }) -replace '\s', ''
    if ($id -match '^\d+$') { $ids.Add([int]$id) }
    if ($IncludeAlts -and $r.AltItemId) {
        $aid = ($r.AltItemId | ForEach-Object { $_.Trim() }) -replace '\s', ''
        if ($aid -match '^\d+$') { $ids.Add([int]$aid) }
    }
}

if ($ids.Count -eq 0) {
    Write-Error "No numeric ItemId values in CSV."
    exit 1
}

$escName = $CharacterName.Replace('\', '\\').Replace("'", "''")
$escSub = $MailSubject.Replace('\', '\\').Replace("'", "''")
$escBody = $MailBody.Replace('\', '\\').Replace("'", "''")

$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine('-- AzerothCore: run on the `characters` database (backup first).')
[void]$sb.AppendLine("-- Target character: $CharacterName")
[void]$sb.AppendLine("-- Items: $($ids.Count)")
[void]$sb.AppendLine('-- If you see SQL Error 1213 (deadlock): stop `worldserver`, run again, or retry once.')
[void]$sb.AppendLine('-- Repeated MAX(guid)/MAX(id) per row competes with the live server; this script prefetches once.')
[void]$sb.AppendLine('')
[void]$sb.AppendLine('SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;')
[void]$sb.AppendLine('START TRANSACTION;')
[void]$sb.AppendLine('')
[void]$sb.AppendLine('-- Resolve recipient (case-insensitive; WoW stores mixed-case names).')
[void]$sb.AppendLine('-- If this returns no rows, you are on the wrong DB or the name is wrong:')
[void]$sb.AppendLine('--   SELECT `guid`, `name` FROM `characters` WHERE LOWER(`name`) = LOWER(''' + $escName + ''');')
[void]$sb.AppendLine('SET @receiver := (SELECT `guid` FROM `characters` WHERE LOWER(`name`) = LOWER(''' + $escName + ''') LIMIT 1);')
[void]$sb.AppendLine('-- Fail before inserts if not found (otherwise owner_guid would be NULL):')
[void]$sb.AppendLine('SELECT 1 / IF(@receiver IS NULL, 0, 1) AS `character_must_exist`;')
[void]$sb.AppendLine('')
[void]$sb.AppendLine('-- Allocate guids/mail ids sequentially (two index scans instead of one per item).')
[void]$sb.AppendLine('SET @next_item_guid := (SELECT IFNULL(MAX(`guid`), 0) FROM `item_instance`);')
[void]$sb.AppendLine('SET @next_mail_id := (SELECT IFNULL(MAX(`id`), 0) FROM `mail`);')
[void]$sb.AppendLine('')

$insItem = 'INSERT INTO `item_instance` (`guid`, `itemEntry`, `owner_guid`, `creatorGuid`, `giftCreatorGuid`, `count`, `duration`, `charges`, `flags`, `enchantments`, `randomPropertyId`, `durability`, `playedTime`, `text`)'

if ($OneMailPerItem) {
    $n = 1
    foreach ($entry in $ids) {
        [void]$sb.AppendLine("-- Item $n / $($ids.Count)  entry $entry")
        [void]$sb.AppendLine('SET @next_item_guid := @next_item_guid + 1;')
        [void]$sb.AppendLine('SET @ig := @next_item_guid;')
        [void]$sb.AppendLine($insItem)
        [void]$sb.AppendLine("VALUES (@ig, $entry, @receiver, 0, 0, 1, 0, NULL, 0, '', 0, 0, 0, NULL);")
        [void]$sb.AppendLine('')
        [void]$sb.AppendLine('SET @next_mail_id := @next_mail_id + 1;')
        [void]$sb.AppendLine('SET @mid := @next_mail_id;')
        # Omit `auctionId` (auction-house only); some older DB dumps omit this column entirely.
        [void]$sb.AppendLine('INSERT INTO `mail` (`id`, `messageType`, `stationery`, `mailTemplateId`, `sender`, `receiver`, `subject`, `body`, `has_items`, `expire_time`, `deliver_time`, `money`, `cod`, `checked`)')
        [void]$sb.AppendLine("VALUES (@mid, 0, 41, 0, 0, @receiver, '$escSub ($n/$($ids.Count))', '$escBody', 1, UNIX_TIMESTAMP() + 86400 * 30, UNIX_TIMESTAMP(), 0, 0, 0);")
        [void]$sb.AppendLine('')
        [void]$sb.AppendLine('INSERT INTO `mail_items` (`mail_id`, `item_guid`, `receiver`) VALUES (@mid, @ig, @receiver);')
        [void]$sb.AppendLine('')
        $n++
    }
}
else {
    $batch = 0
    for ($off = 0; $off -lt $ids.Count; $off += $AttachmentsPerMail) {
        $take = [Math]::Min($AttachmentsPerMail, $ids.Count - $off)
        $slice = $ids[$off..($off + $take - 1)]
        $batch++
        [void]$sb.AppendLine("-- Mail batch $batch (items $($off + 1)..$($off + $take) of $($ids.Count))")
        $varNames = @()
        $i = 0
        foreach ($entry in $slice) {
            $i++
            $vn = "ig_${off}_$i"
            $varNames += $vn
            [void]$sb.AppendLine('SET @next_item_guid := @next_item_guid + 1;')
            [void]$sb.AppendLine(("SET @{0} := @next_item_guid;" -f $vn))
            [void]$sb.AppendLine($insItem)
            [void]$sb.AppendLine("VALUES (@$vn, $entry, @receiver, 0, 0, 1, 0, NULL, 0, '', 0, 0, 0, NULL);")
            [void]$sb.AppendLine('')
        }
        [void]$sb.AppendLine('SET @next_mail_id := @next_mail_id + 1;')
        [void]$sb.AppendLine('SET @mid := @next_mail_id;')
        [void]$sb.AppendLine('INSERT INTO `mail` (`id`, `messageType`, `stationery`, `mailTemplateId`, `sender`, `receiver`, `subject`, `body`, `has_items`, `expire_time`, `deliver_time`, `money`, `cod`, `checked`)')
        [void]$sb.AppendLine("VALUES (@mid, 0, 41, 0, 0, @receiver, '$escSub (part $batch)', '$escBody', 1, UNIX_TIMESTAMP() + 86400 * 30, UNIX_TIMESTAMP(), 0, 0, 0);")
        [void]$sb.AppendLine('')
        [void]$sb.Append('INSERT INTO `mail_items` (`mail_id`, `item_guid`, `receiver`) VALUES ')
        $lines = foreach ($vn in $varNames) { "(@mid, @$vn, @receiver)" }
        [void]$sb.AppendLine(($lines -join (',' + [Environment]::NewLine)) + ';')
        [void]$sb.AppendLine('')
    }
}

[void]$sb.AppendLine('COMMIT;')
Write-Output $sb.ToString()

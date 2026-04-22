# Creates empty TBC P1 CSV stubs. Without -Force, existing files are left unchanged.
# WARNING: -Force overwrites every CSV — do not use it if you have already filled ItemId columns.
param(
    [string] $OutputRoot = (Join-Path $PSScriptRoot "data\tbc-p1"),
    [switch] $Force
)

$specs = @(
    @{ Slug = "druid-balance";        Label = "Druid Balance" }
    @{ Slug = "druid-feral-bear";     Label = "Druid Feral Bear" }
    @{ Slug = "druid-feral-cat";      Label = "Druid Feral Cat" }
    @{ Slug = "druid-restoration";    Label = "Druid Restoration" }
    @{ Slug = "hunter-beast-mastery"; Label = "Hunter Beast Mastery" }
    @{ Slug = "hunter-marksmanship";  Label = "Hunter Marksmanship" }
    @{ Slug = "hunter-survival";      Label = "Hunter Survival" }
    @{ Slug = "mage-arcane";          Label = "Mage Arcane" }
    @{ Slug = "mage-fire";            Label = "Mage Fire" }
    @{ Slug = "mage-frost";           Label = "Mage Frost" }
    @{ Slug = "paladin-holy";         Label = "Paladin Holy" }
    @{ Slug = "paladin-protection";    Label = "Paladin Protection" }
    @{ Slug = "paladin-retribution";   Label = "Paladin Retribution" }
    @{ Slug = "priest-discipline";    Label = "Priest Discipline" }
    @{ Slug = "priest-holy";          Label = "Priest Holy" }
    @{ Slug = "priest-shadow";        Label = "Priest Shadow" }
    @{ Slug = "rogue-assassination";   Label = "Rogue Assassination" }
    @{ Slug = "rogue-combat";         Label = "Rogue Combat" }
    @{ Slug = "rogue-subtlety";       Label = "Rogue Subtlety" }
    @{ Slug = "shaman-elemental";     Label = "Shaman Elemental" }
    @{ Slug = "shaman-enhancement";   Label = "Shaman Enhancement" }
    @{ Slug = "shaman-restoration";   Label = "Shaman Restoration" }
    @{ Slug = "warlock-affliction";   Label = "Warlock Affliction" }
    @{ Slug = "warlock-demonology";   Label = "Warlock Demonology" }
    @{ Slug = "warlock-destruction";  Label = "Warlock Destruction" }
    @{ Slug = "warrior-arms";         Label = "Warrior Arms" }
    @{ Slug = "warrior-fury";         Label = "Warrior Fury" }
    @{ Slug = "warrior-protection";  Label = "Warrior Protection" }
)

$slots = @(
    "Head", "Neck", "Shoulders", "Back", "Chest", "Wrists", "Hands", "Waist", "Legs", "Feet",
    "Ring1", "Ring2", "Trinket1", "Trinket2", "Weapon", "OffHand", "RangedOrRelic"
)

New-Item -ItemType Directory -Force -Path $OutputRoot | Out-Null
$header = "Slot,Name,ItemId,AltItemId,SourceNote"

foreach ($s in $specs) {
    $path = Join-Path $OutputRoot "$($s.Slug).csv"
    if ((Test-Path $path) -and -not $Force) { continue }
    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add($header)
    $note = "TBC P1 template: $($s.Label). Add Wowhead TBC item IDs."
    $lines.Add(('Meta,"{0}",,,' -f ($note -replace '"', '""')))
    foreach ($slot in $slots) { $lines.Add("${slot},,,,") }
    ($lines -join "`r`n") | Set-Content -LiteralPath $path -Encoding UTF8
}

Write-Host "Wrote $($specs.Count) CSV templates under $OutputRoot"

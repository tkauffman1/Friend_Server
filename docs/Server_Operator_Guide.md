# Server operator guide (WoW-focused)

You run a private server like you’d care about your main: **lockouts**, **PvP queues**, **honor**, **arena**, and **RDF** matter—not just `MaxPlayerLevel`. This guide maps **what players care about** to **which config file** and **which keys**. After edits, restart **`worldserver.exe`** (and **`authserver.exe`** only if you touched `configs/authserver.conf`). Keep backups.

---

## Table of contents

Use your viewer’s outline or search (Ctrl+F). In **Word**: *View → Navigation Pane* or insert *References → Table of Contents* after opening the `.docx`.

- [Quick start](#quick-start)
- [XP leveling and rates](#xp-leveling-and-rates)
- [Dungeons raids lockouts and the calendar](#dungeons-raids-lockouts-and-the-calendar)
- [Dungeon Finder RDF and deserter](#dungeon-finder-rdf-and-deserter)
- [Battlegrounds](#battlegrounds)
- [Cross-faction BGs CFBG](#cross-faction-bgs-cfbg)
- [Arena](#arena)
- [Honor and PvP rewards](#honor-and-pvp-rewards)
- [Wintergrasp](#wintergrasp)
- [Open world PvP and duels](#open-world-pvp-and-duels)
- [Level cap and phased progression](#level-cap-and-phased-progression)
- [Playerbots](#playerbots)
- [Server performance](#server-performance)
- [Auth and realm](#auth-and-realm)
- [Other modules](#other-modules)
- [This deployment checklist](#this-deployment-checklist)
- [Regenerate the Word file](#regenerate-the-word-file)

---

## Quick start

| If players complain about… | Open first |
|----------------------------|------------|
| XP too slow / too fast | `configs/worldserver.conf` → `Rate.XP.*` |
| Raid week feels wrong / “when is reset?” | `worldserver.conf` → `Instance.ResetTimeHour`, `Instance.ResetTimeRelativeTimestamp`, `Rate.InstanceResetTime` |
| RDF / LFG broken or want it off | `worldserver.conf` → `DungeonFinder.*` · `configs/modules/individualProgression.conf` → `IndividualProgression.DisableRDF` |
| BG queues empty or unfair | `worldserver.conf` → `Battleground.*` · `configs/modules/CFBG.conf` · `configs/modules/playerbots.conf` (bots in BG) |
| Arena rating / queues | `worldserver.conf` → `Arena.*` |
| Honor grind | `worldserver.conf` → `Rate.Honor` · `MaxHonorPoints` (search in same file) |
| Wintergrasp dead | `worldserver.conf` → `Wintergrasp.*` |
| Bots feel idle or wrong level | `configs/modules/playerbots.conf` |

---

## XP leveling and rates

**File:** `configs/worldserver.conf`

**Core XP multipliers** (search `Rate.XP`):

| Setting | What it affects (player perspective) |
|--------|----------------------------------------|
| `Rate.XP.Kill` | Mob grinding |
| `Rate.XP.Quest` | Quest turn-ins |
| `Rate.XP.Quest.DF` | XP from **Dungeon Finder** random dungeon rewards |
| `Rate.XP.Explore` | Exploration |
| `Rate.XP.Pet` | Hunter pet leveling |

`1` = baseline multiplier; `2` = double. **BG kill XP** is separate: `Rate.XP.BattlegroundKill*` and `Battleground.GiveXPForKills` (off by default on many configs—check if you want HKs to level people).

**Optional per-level or per-character XP**

- `configs/modules/dynamicxp.conf` — different multipliers per level band (`Dynamic.XP.Rate.10-19`, etc.).
- `configs/modules/individual_xp.conf` — per-account/per-character rates if enabled.

**Other grinds players notice:** `Rate.Honor`, `Rate.Reputation.Gain`, `Rate.Drop.Item.*`, `Rate.Drop.Money`, `Rate.Rest.*` — same file.

---

## Dungeons raids lockouts and the calendar

**File:** `configs/worldserver.conf`

This is what decides **“when does my ICC lock reset?”** and **how fast the reset cycle feels** server-wide.

| Setting | Why it matters |
|--------|----------------|
| `Instance.ResetTimeHour` | **Hour of day** (0–23) when the **global** instance reset tick runs (default often early morning). |
| `Instance.ResetTimeRelativeTimestamp` | **Calendar alignment**: timestamp used so **3-day vs 7-day** raid resets line up correctly in the in-game calendar. Don’t change casually—read the comment block in the file. |
| `Rate.InstanceResetTime` | **Multiplier** on time **between** raid/heroic resets (DBC-driven). Not “daily quest reset”—it’s the **spacing** of lockout periods. **Requires clean `instance_reset` data in the characters DB** to apply cleanly—see file comment. |
| `Instance.SharedNormalHeroicId` | **ICC / RS**: normal and heroic **share one lockout** when enabled (ToC behaves differently—see comment). |
| `AccountInstancesPerHour` | Anti-dungeon-spam: max **different** instances entered per hour per account. |
| `Instance.IgnoreRaid` | Lets people enter **without a raid group** (testing / casual rules). |
| `Instance.IgnoreLevel` | Ignore **level** requirements on portals. |

**Individual Progression** can gate which content exists at all—separate from lockout *timing*: `configs/modules/individualProgression.conf`.

---

## Dungeon Finder RDF and deserter

**File:** `configs/worldserver.conf` (section *DUNGEON AND BATTLEGROUND FINDER*)

| Setting | Player-facing effect |
|--------|------------------------|
| `DungeonFinder.OptionsMask` | Bitmask: **dungeon finder**, **raid browser**, **seasonal bosses**. Turning bits off removes tools players expect in 3.3.5. |
| `DungeonFinder.CastDeserter` | **Deserter** debuff if you bail on RDF. |
| `JoinBGAndLFG.Enable` | Queue **BG + LFG** at the same time (often off for balance). |

**Module:** `configs/modules/individualProgression.conf` → **`IndividualProgression.DisableRDF`** — disables **random** dungeon finder in IP context; **specific** dungeon queue may still work (read module comment).

---

## Battlegrounds

**File:** `configs/worldserver.conf`

Players care about **queue pop**, **deserter**, **prep time**, **rewards**, and **AFK reporting**.

| Topic | Settings to search |
|-------|-------------------|
| Queue / prep | `Battleground.PrepTime`, `Battleground.PremadeGroupWaitForMatch`, `Battleground.PrematureFinishTimer` |
| Leavers | `Battleground.CastDeserter`, `Battleground.TrackDeserters.Enable` |
| Random BG daily reset hour | `Battleground.Random.ResetHour` |
| Honor / arena points from BG wins | `Battleground.RewardWinnerHonorFirst`, `Battleground.RewardWinnerHonorLast`, arena variants, loser rewards |
| XP from HKs in BG | `Battleground.GiveXPForKills`, `Rate.XP.BattlegroundKill*` |
| AFK | `Battleground.ReportAFK`, `Battleground.ReportAFK.Timer` |
| Announcer spam | `Battleground.QueueAnnouncer.*` |

**Bots in BGs:** `configs/modules/playerbots.conf` — `AiPlayerbot.RandomBotJoinBG`, auto-join brackets, `AiPlayerbot.FastReactInBG`.

---

## Cross-faction BGs CFBG

**File:** `configs/modules/CFBG.conf`

| Setting | Effect |
|--------|--------|
| `CFBG.Enable` | **Mixed faction** in one BG queue (horde+alliance on same team fill). |
| `CFBG.Battlefield.Enable` | Cross-faction **Wintergrasp** queue behavior (see module comment). |
| `CFBG.BalancedTeams` | Level / team balance checks. |

Tune here if **queues are dead** on a low-pop server or you want **faster pops**.

---

## Arena

**File:** `configs/worldserver.conf` (search `Arena.`)

| Topic | Examples |
|-------|-----------|
| Matchmaking | `Arena.MaxRatingDifference`, `Arena.ArenaMatchmakerRatingModifier`, rating discard timers |
| Season feel | `Arena.GamesRequired`, `Arena.AutoDistributePoints`, `Arena.AutoDistributeInterval` |
| Team creation cost | `ArenaTeam.CharterCost.2v2` / `3v3` / `5v5` |
| Queue announcer | `Arena.QueueAnnouncer.*` |

**Playerbots** can fill arena teams: same `playerbots.conf` section as BG auto-join (`RandomBotArenaTeam*` etc.).

---

## Honor and PvP rewards

**File:** `configs/worldserver.conf`

| Setting | Effect |
|--------|--------|
| `Rate.Honor` | Global **honor** gain multiplier (HKs, BGs, etc.—see also BG-specific rep lines). |
| `MaxHonorPoints` / `StartHonorPoints` | Caps and starting honor. |
| `HonorPointsAfterDuel` | Honor from **duels** (if non-zero in your build). |
| `Rate.ArenaPoints` / `Rate.ArenaPoints2v2` / `Rate.ArenaPoints3v3` | **Arena points** accrual. |
| `PvPToken.Enable` | Token drops on HKs (optional meta). |

**BG honor rep:** `Rate.Reputation.Gain.WSG`, `.AB`, `.AV` (stack with `Rate.Reputation.Gain`).

---

## Wintergrasp

**File:** `configs/worldserver.conf` (search `Wintergrasp.`)

| Setting | Effect |
|--------|--------|
| `Wintergrasp.Enable` | **0** = WG battle disabled (world processing may still run); **2** = disable all processing—read comment. |
| `Wintergrasp.PlayerMin` / `PlayerMax` | Min/max per **team** to start / cap battle. |
| `Wintergrasp.PlayerMinLvl` | Level requirement (default **75** in stock—wrong for a level **60** server—**lower or raise `MaxPlayerLevel` logic** with your cap). |
| `Wintergrasp.BattleTimer` / `Wintergrasp.NoBattleTimer` | Battle length and time **between** battles. |

**Cross-faction WG:** `configs/modules/CFBG.conf` → `CFBG.Battlefield.Enable`.

---

## Open world PvP and duels

**File:** `configs/worldserver.conf`

- **FFA areas** (Gurubashi-style): search `FFAPVP`, `FFAPvPTimer`.
- **Outdoor capture points** (EP etc.): `OutdoorPvPCaptureRate`.
- **Visibility in BG/Arena vs world:** `Visibility.Distance.BGArenas` vs `Visibility.Distance.Continents` (affects how far you see enemies—**performance vs clarity**).
- **Durability on PvP death:** `DurabilityLoss.InPvP`.
- **Corpse delay:** `Death.CorpseReclaimDelay.PvP`.

---

## Level cap and phased progression

**File:** `configs/worldserver.conf` → **`MaxPlayerLevel`** (`60` / `70` / `80`).

**File:** `configs/modules/individualProgression.conf`

- **`ProgressionLimit`** — hard stop on **progression stage** (e.g. stay in “Vanilla phase”).
- **`StartingProgression`** — new characters jump to a stage (testing).
- **`DeathKnightUnlockProgression`**, **`TbcRacesUnlockProgression`** — when **DK** / **Blood Elf & Draenei** unlock.

Progression is also **stored in the database**—configs don’t rewind player unlocks.

---

## Playerbots

**File:** `configs/modules/playerbots.conf`

**Population:** `AiPlayerbot.MinRandomBots` / `MaxRandomBots` — set **both to 600** and **`EnablePeriodicOnlineOffline = 0`** for **600 online at once**.

**Leveling with players:** `DisableRandomLevels = 1`, `RandombotStartingLevel = 1`, **`SyncLevelWithPlayers`** (bots cap to highest **online** real player—turn **off** if you want a full 1–60 spread regardless).

**Activity / “they play while I’m online”:** **`BotActiveAlone`** (high = more bots questing in empty zones). **`RandomBotXPRate`** multiplies bot XP.

**Maps:** `RandomBotMaps` — `0,1` = Kalimdor + Eastern Kingdoms only; add `530`, `571` for Outland / Northrend.

**Bot account cap vs players:** `individualProgression.conf` → **`ExcludedAccountsMaxLevel`** (match **`MaxPlayerLevel`**).

---

## Server performance

**`worldserver.conf`:** `MapUpdateInterval`, `MapUpdate.Threads`, `ThreadPool`, visibility distances, `vmap.*`, `MoveMaps.Enable`.

**`playerbots.conf`:** `IterationsPerTick`, `RandomBotUpdateInterval`, `RandomBotsPerInterval`, `FastReactInBG` — trade **CPU** vs **responsiveness**.

---

## Auth and realm

**File:** `configs/authserver.conf` — ports, bind IP, login database. Change when you know your network.

---

## Other modules

Under **`configs/modules/`**, one `.conf` per mod (transmog, solo LFG, AH bot, etc.). Open the file—top comments usually explain toggles. **`worldserver.conf.dist`** in the same folder tree is the **full default** reference if you nuked a section.

---

## This deployment checklist

| Topic | Where | Notes |
|-------|--------|------|
| Level cap | `worldserver.conf` | `MaxPlayerLevel = 60` |
| Phase lock | `individualProgression.conf` | `ProgressionLimit = 7`, `ExcludedAccountsMaxLevel = 60` |
| Bots | `playerbots.conf` | 600 online, L1 start, sync/high activity, `RandomBotXPRate` > 1, maps `0,1` |
| PvP / raids | **this guide** | WG level min vs your cap; tune `Rate.Honor`, BG, `Instance.*` as needed |

---

## Regenerate the Word file

From the repo root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\Build-OperatorGuideDocx.ps1
```

Writes **`docs/Server_Operator_Guide.docx`** from this Markdown. In Word, use the **Navigation pane** or insert a **Table of contents** (Heading 1/2 styles) for clickable structure.
